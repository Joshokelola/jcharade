import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:all_sensors/all_sensors.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:jcharade/utils/helpers.dart';
import 'package:jcharade/utils/web_sensor_permissions.dart' as web_sensors;
import 'package:jcharade/utils/web_orientation.dart' as web_orientation;
import '../../models/word.dart';
import '../../providers/game_provider.dart';
import '../results/results_screen.dart';

enum _FlipDirection { up, down }

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with TickerProviderStateMixin {
  // Using a list to manage all subscriptions like in the official example
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];

  Timer? _gameTimer;
  late AnimationController _flipController;
  late AnimationController _pulseController;
  late AnimationController _scoreAnimationController;
  late AnimationController _flashController;

  late Animation<double> _flipAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scoreAnimation;
  late Animation<Color?> _flashAnimation;

  AudioPlayer? _audioPlayer;

  int _currentWordIndex = 0;
  int _score = 0;
  int _remainingTime = 0;
  bool _isGameActive = false;

  static const Duration _tiltCooldown = Duration(milliseconds: 900);
  static const Duration _tiltActivationDelay = Duration(seconds: 2);
  static const double _skipTiltThreshold = 6; // Tilt up (away) -> skip
  static const double _correctTiltThreshold =
      -6; // Tilt down (toward) -> correct
  static const double _tiltSmoothingFactor = 0.25; // simple low-pass filter

  List<Word> _gameWords = [];
  DateTime? _lastTiltAction;
  DateTime? _tiltUnlockTime;
  double _smoothedZ = 0;
  int _outgoingWordIndex = 0;
  bool _isWordTransitioning = false;
  _FlipDirection _flipDirection = _FlipDirection.down;

  @override
  void initState() {
    super.initState();

    // Force landscape orientation
    if (!kIsWeb) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }

    _initializeAnimations();
    _initializeGame();
    _initializeSensors();
    _initializeAudio();
    unawaited(web_sensors.requestMotionPermission());
  }

  void _initializeAnimations() {
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 550),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: math.pi).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );

    _flipController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (!mounted) return;
        _flipController.reset();
        setState(() {
          _isWordTransitioning = false;
          _outgoingWordIndex = _currentWordIndex;
        });
      }
    });

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _scoreAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scoreAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _scoreAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _flashController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _flashAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.transparent,
    ).animate(_flashController);
  }

  void _initializeGame() {
    final gameState = ref.read(gameProvider);
    if (gameState != null && gameState.gameWords.isNotEmpty) {
      _gameWords = gameState.gameWords;
      _remainingTime = gameState.timeRemaining;
      _currentWordIndex = 0;
      _outgoingWordIndex = 0;
      _startGame();
    } else {
      // Handle case where game state is not available
      debugPrint('Game state not available, returning to home');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    }
  }

  void _initializeAudio() {
    _audioPlayer = AudioPlayer();
  }

  void _initializeSensors() {
    final accelerometerStream = accelerometerEvents;
    if (accelerometerStream == null) {
      debugPrint('Accelerometer not available on this platform');
      return;
    }

    _streamSubscriptions.add(
      accelerometerStream.listen(
        (AccelerometerEvent event) {
          // Only process sensor data if game is active and mounted
          if (!_isGameActive || !mounted) return;

          try {
            final now = DateTime.now();

            if (_tiltUnlockTime == null || now.isBefore(_tiltUnlockTime!)) {
              return; // ignore accidental tilts while players get ready
            }

            _smoothedZ =
                (_smoothedZ * (1 - _tiltSmoothingFactor)) +
                (event.z * _tiltSmoothingFactor);
            final zValue = _smoothedZ;

            if (_lastTiltAction != null &&
                now.difference(_lastTiltAction!) < _tiltCooldown) {
              return;
            }

            if (zValue >= _skipTiltThreshold) {
              _lastTiltAction = now;
              debugPrint('Tilt UP detected: Z=$zValue');
              _handleSkipWord();
            }
            // Detect tilt DOWN (Top edge toward floor) -> CORRECT
            else if (zValue <= _correctTiltThreshold) {
              _lastTiltAction = now;
              debugPrint('Tilt DOWN detected: Z=$zValue');
              _handleCorrectAnswer();
            }
          } catch (e) {
            debugPrint('Error processing accelerometer data: $e');
          }
        },
        onError: (e) {
          debugPrint('Accelerometer sensor error: $e');
        },
        cancelOnError: true,
      ),
    );
  }

  void _startGame() {
    _tiltUnlockTime = DateTime.now().add(_tiltActivationDelay);
    _lastTiltAction = null;
    _smoothedZ = 0;
    if (!kIsWeb) {
      unawaited(
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky),
      );
    }
    unawaited(web_orientation.lockLandscape());

    setState(() {
      _isGameActive = true;
    });

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      setState(() {
        _remainingTime--;
      });

      if (_remainingTime <= 0) {
        _endGame();
      }
    });

    // Start pulse animation for timer
    _pulseController.repeat(reverse: true);
  }

  Future<void> _triggerFlash(Color color) async {
    setState(() {
      _flashAnimation =
          ColorTween(
            begin: color.withOpacity(0.6),
            end: Colors.transparent,
          ).animate(
            CurvedAnimation(parent: _flashController, curve: Curves.easeOut),
          );
    });

    await _flashController.forward(from: 0);
  }

  Future<void> _handleCorrectAnswer() async {
    if (!_isGameActive || _isWordTransitioning) return;

    // Noticeable Haptic feedback
    HapticFeedback.heavyImpact();
    // Visual Flash (Green)
    _triggerFlash(Colors.greenAccent);

    // Play success sound
    _playSound('success');

    // Animate score
    _scoreAnimationController.reset();
    _scoreAnimationController.forward();

    setState(() {
      _score++;
    });

    // Update game state
    final gameState = ref.read(gameProvider.notifier);
    gameState.markWordCorrect();

    _nextWord(_FlipDirection.down);
  }

  Future<void> _handleSkipWord() async {
    if (!_isGameActive || _isWordTransitioning) return;

    // Noticeable Haptic feedback
    HapticFeedback.vibrate();

    // Visual Flash (Orange/Red)
    _triggerFlash(Colors.orangeAccent);

    // Play skip sound
    _playSound('skip');

    // Update game state
    final gameState = ref.read(gameProvider.notifier);
    gameState.skipWord();

    _nextWord(_FlipDirection.up);
  }

  void _nextWord(_FlipDirection direction) {
    if (_gameWords.isEmpty) return;

    if (_currentWordIndex < _gameWords.length - 1) {
      final nextIndex = _currentWordIndex + 1;
      _startWordTransition(nextIndex, direction);
    } else {
      _endGame();
    }
  }

  void _startWordTransition(int nextIndex, _FlipDirection direction) {
    if (_isWordTransitioning || nextIndex >= _gameWords.length) return;

    setState(() {
      _flipDirection = direction;
      _outgoingWordIndex = _currentWordIndex;
      _currentWordIndex = nextIndex;
      _isWordTransitioning = true;
    });

    _flipController.forward(from: 0);
  }

  void _playSound(String soundType) async {
    if (_audioPlayer == null) return;

    try {
      // You would add actual sound files to assets
      // For now, we'll use system sounds via haptic feedback
      switch (soundType) {
        case 'success':
          GameHelpers.playSound(type: SoundType.correct);
          break;
        case 'skip':
          GameHelpers.playSound(type: SoundType.skip);
          break;
        case 'end':
          GameHelpers.playSound(type: SoundType.gameEnd);
          break;
      }
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  void _endGame() {
    try {
      _gameTimer?.cancel();
    } catch (e) {
      debugPrint('Error canceling game timer: $e');
    }

    try {
      _pulseController.stop();
    } catch (e) {
      debugPrint('Error stopping pulse controller: $e');
    }

    try {
      _flipController.stop();
      _flipController.reset();
    } catch (e) {
      debugPrint('Error stopping flip controller: $e');
    }

    _tiltUnlockTime = null;
    _lastTiltAction = null;
    if (!kIsWeb) {
      unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));
    }
    unawaited(web_orientation.unlockOrientation());

    final lastIndex = _gameWords.isEmpty ? 0 : _gameWords.length - 1;
    setState(() {
      _isGameActive = false;
      _isWordTransitioning = false;
      _outgoingWordIndex = _gameWords.isEmpty
          ? 0
          : _currentWordIndex.clamp(0, lastIndex);
    });

    _playSound('end');

    // Navigate to results screen
    final gameState = ref.read(gameProvider);
    if (gameState != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsScreen(
            score: _score,
            totalWords: _currentWordIndex + 1,
            category: gameState.selectedCategory,
            timerDuration: gameState.timerDuration,
          ),
        ),
      );
    }
  }

  void _pauseGame() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'Game Paused',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1A1A1B),
        content: Text(
          'The game is paused. Tap Resume to continue.',
          style: TextStyle(color: Colors.white70, fontSize: 16.sp),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _endGame();
            },
            child: Text('End Game', style: TextStyle(color: Colors.red[300])),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
            ),
            child: const Text('Resume'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    // Cancel all stream subscriptions like in official example
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }

    // Cancel timer safely
    _gameTimer?.cancel();

    // Dispose animation controllers
    _flipController.dispose();
    _pulseController.dispose();
    _scoreAnimationController.dispose();
    _flashController.dispose();

    // Dispose audio player
    _audioPlayer?.dispose();

    if (!kIsWeb) {
      unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));
    }

    unawaited(web_orientation.unlockOrientation());

    if (!kIsWeb) {
      // Reset orientation to allow all orientations when leaving game
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentWord = _currentWordIndex < _gameWords.length
        ? _gameWords[_currentWordIndex]
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [
                  const Color(0xFF1A1A2E),
                  const Color(0xFF0F0F23),
                  const Color(0xFF000000),
                ],
              ),
            ),
            child: SafeArea(
              child: currentWord == null
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        // Header with timer and score
                        _buildHeader(),

                        // Main card area
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 24.w,
                              vertical: 16.h,
                            ),
                            child: _buildMainCard(),
                          ),
                        ),

                        // Minimal control hint
                        Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: Text(
                            'Tilt Down to Correct • Tilt Up for Skip',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.3),
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          // Flash overlay for feedback
          AnimatedBuilder(
            animation: _flashController,
            builder: (context, child) {
              return IgnorePointer(
                child: Container(color: _flashAnimation.value),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 80.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1B).withOpacity(0.8),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Pause button
          Container(
            width: 60.w,
            height: 60.h,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: IconButton(
              onPressed: _pauseGame,
              icon: Icon(
                Icons.pause_circle_outline,
                color: Colors.white,
                size: 14.sp,
              ),
            ),
          ),

          // Timer - make it more prominent
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _remainingTime <= 10 ? _pulseAnimation.value : 1.0,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _remainingTime <= 10
                          ? [Colors.red[600]!, Colors.red[800]!]
                          : [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(25.r),
                    boxShadow: [
                      BoxShadow(
                        color:
                            (_remainingTime <= 10
                                    ? Colors.red[600]!
                                    : const Color(0xFF6366F1))
                                .withOpacity(0.5),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    _formatTime(_remainingTime),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          offset: const Offset(1, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Score
          AnimatedBuilder(
            animation: _scoreAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scoreAnimation.value,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green[600]!, Colors.green[700]!],
                    ),
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green[600]!.withOpacity(0.5),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'Score: $_score',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          offset: const Offset(1, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMainCard() {
    if (_gameWords.isEmpty) {
      return const SizedBox();
    }

    final safeCurrentIndex = _currentWordIndex.clamp(0, _gameWords.length - 1);
    final safeOutgoingIndex = _outgoingWordIndex.clamp(
      0,
      _gameWords.length - 1,
    );
    final currentWord = _gameWords[safeCurrentIndex];
    final outgoingWord = _gameWords[safeOutgoingIndex];

    return AnimatedBuilder(
      animation: _flipController,
      builder: (context, child) {
        final isAnimating = _isWordTransitioning && _gameWords.length > 1;
        final angle = isAnimating ? _flipAnimation.value : 0.0;
        final isFirstHalf = angle <= math.pi / 2;
        final displayWord = isAnimating
            ? (isFirstHalf ? outgoingWord : currentWord)
            : currentWord;

        final directionMultiplier = _flipDirection == _FlipDirection.down
            ? 1.0
            : -1.0;
        final effectiveAngle = isAnimating
            ? directionMultiplier * (isFirstHalf ? angle : angle - math.pi)
            : 0.0;
        final depthTranslation = isAnimating
            ? math.sin(angle).abs() * 25.0 * directionMultiplier
            : 0.0;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0015)
            ..translate(0.0, depthTranslation)
            ..rotateX(effectiveAngle),
          child: _buildWordCard(displayWord),
        );
      },
    );
  }

  Widget _buildWordCard(Word word) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1F1F23),
            const Color(0xFF2A2A2E),
            const Color(0xFF1F1F23),
          ],
        ),
        borderRadius: BorderRadius.circular(25.r),
        border: Border.all(
          color: const Color(0xFF6366F1).withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Main word - Maximized
          Expanded(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Center(
                child: Text(
                  word.text.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40.sp, // Maximized font size
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    height: 1.0,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.8),
                        offset: const Offset(4, 4),
                        blurRadius: 8,
                      ),
                      Shadow(
                        color: const Color(0xFF6366F1).withOpacity(0.6),
                        offset: const Offset(0, 0),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
