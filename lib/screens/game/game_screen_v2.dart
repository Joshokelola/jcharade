import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/word.dart';
import '../../providers/game_provider.dart';
import '../results/results_screen.dart';

class GameScreenV2 extends ConsumerStatefulWidget {
  const GameScreenV2({super.key});

  @override
  ConsumerState<GameScreenV2> createState() => _GameScreenV2State();
}

class _GameScreenV2State extends ConsumerState<GameScreenV2>
    with TickerProviderStateMixin {
  Timer? _gameTimer;

  // Animation controllers
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late AnimationController _correctController;
  late AnimationController _skipController;

  // Animations
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _correctScaleAnimation;
  late Animation<double> _skipScaleAnimation;

  int _currentWordIndex = 0;
  int _correctCount = 0;
  int _skippedCount = 0;
  int _remainingTime = 0;
  bool _isGameActive = false;
  bool _showingResult = false;

  List<Word> _gameWords = [];
  String _lastAction = '';

  @override
  void initState() {
    super.initState();

    // Force landscape orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _initializeAnimations();
    _initializeGame();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation =
        Tween<Offset>(
          begin: const Offset(0, 0),
          end: const Offset(0, -1),
        ).animate(
          CurvedAnimation(
            parent: _slideController,
            curve: Curves.easeInOutBack,
          ),
        );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _correctController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _correctScaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _correctController, curve: Curves.elasticOut),
    );

    _skipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _skipScaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _skipController, curve: Curves.elasticOut),
    );
  }

  void _initializeGame() {
    final gameState = ref.read(gameProvider);
    if (gameState != null && gameState.gameWords.isNotEmpty) {
      _gameWords = gameState.gameWords;
      _remainingTime = gameState.timeRemaining;
      _startGame();
    } else {
      debugPrint('Game state not available, returning to home');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    }
  }

  void _startGame() {
    setState(() {
      _isGameActive = true;
    });

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingTime--;
      });

      if (_remainingTime <= 0) {
        _endGame();
      }
    });

    _pulseController.repeat(reverse: true);
  }

  void _handleCorrectAnswer() async {
    if (!_isGameActive || _showingResult) return;

    setState(() {
      _showingResult = true;
      _lastAction = 'correct';
    });

    HapticFeedback.lightImpact();
 

    _correctController.reset();
    _correctController.forward();

    await Future.delayed(const Duration(milliseconds: 300));

    setState(() {
      _correctCount++;
    });

    final gameState = ref.read(gameProvider.notifier);
    gameState.markWordCorrect();

    await Future.delayed(const Duration(milliseconds: 800));
    _nextWord();
  }

  void _handleSkipWord() async {
    if (!_isGameActive || _showingResult) return;

    setState(() {
      _showingResult = true;
      _lastAction = 'skip';
    });

    HapticFeedback.selectionClick();

    _skipController.reset();
    _skipController.forward();

    await Future.delayed(const Duration(milliseconds: 300));

    setState(() {
      _skippedCount++;
    });

    final gameState = ref.read(gameProvider.notifier);
    gameState.skipWord();

    await Future.delayed(const Duration(milliseconds: 800));
    _nextWord();
  }

  void _nextWord() async {
    if (_currentWordIndex < _gameWords.length - 1) {
      // Animate slide out
      await _slideController.forward();

      setState(() {
        _currentWordIndex++;
        _showingResult = false;
        _lastAction = '';
      });

      // Reset and slide in
      _slideController.reset();
    } else {
      _endGame();
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

    setState(() {
      _isGameActive = false;
    });

    final gameState = ref.read(gameProvider);
    if (gameState != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsScreen(
            score: _correctCount,
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
    _gameTimer?.cancel();
    _slideController.dispose();
    _pulseController.dispose();
    _correctController.dispose();
    _skipController.dispose();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentWord = _currentWordIndex < _gameWords.length
        ? _gameWords[_currentWordIndex]
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0B),
      body: currentWord == null
          ? const Center(child: CircularProgressIndicator())
          : GestureDetector(
              onPanEnd: (details) {
                if (_showingResult || !_isGameActive) return;

                final velocity = details.velocity.pixelsPerSecond;
                final dx = velocity.dx;
                final dy = velocity.dy;

                // Horizontal swipes for primary actions
                if (dx.abs() > dy.abs() && dx.abs() > 500) {
                  if (dx > 0) {
                    // Swipe right = Correct
                    _handleCorrectAnswer();
                  } else {
                    // Swipe left = Skip
                    _handleSkipWord();
                  }
                }
                // Vertical swipes for secondary actions
                else if (dy.abs() > dx.abs() && dy.abs() > 500) {
                  if (dy < 0) {
                    // Swipe up = Pause
                    _pauseGame();
                  }
                }
              },
              child: Stack(
                children: [
                  // Gradient background
                  Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 1.2,
                        colors: [
                          const Color(0xFF6366F1).withOpacity(0.15),
                          const Color(0xFF0A0A0B),
                          const Color(0xFF000000),
                        ],
                      ),
                    ),
                  ),

                  // Main fullscreen layout
                  SafeArea(
                    child: Column(
                      children: [
                        // Minimal top status
                        _buildMinimalHeader(),

                        // Massive word display (takes center stage)
                        Expanded(
                          child: _buildFullscreenWordDisplay(currentWord),
                        ),

                        // Bottom gesture hints
                        _buildGestureHints(),
                      ],
                    ),
                  ),

                  // Result overlay
                  if (_showingResult) _buildResultOverlay(),
                ],
              ),
            ),
    );
  }

  Widget _buildMinimalHeader() {
    final progress = _currentWordIndex / (_gameWords.length - 1);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Row(
        children: [
          // Progress indicator
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_currentWordIndex + 1}/${_gameWords.length}',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${_correctCount}✓ ${_skippedCount}✗',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Container(
                  height: 3.h,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF6366F1),
                            const Color(0xFF8B5CF6),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 20.w),

          // Timer - centered and prominent
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _remainingTime <= 10 ? _pulseAnimation.value : 1.0,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
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
                                .withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    _formatTime(_remainingTime),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
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

  Widget _buildFullscreenWordDisplay(Word word) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(40.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Category badge
                Consumer(
                  builder: (context, ref, child) {
                    final gameState = ref.watch(gameProvider);
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF6366F1),
                            const Color(0xFF8B5CF6),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(25.r),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        gameState?.selectedCategory.name.toUpperCase() ??
                            'CATEGORY',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: 60.h),

                // MASSIVE word display - the centerpiece
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(30.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF1E1E1E).withOpacity(0.8),
                        const Color(0xFF2A2A2A).withOpacity(0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30.r),
                    border: Border.all(
                      color: const Color(0xFF6366F1).withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // The main word - HUGE and prominent
                      SizedBox(
                        width: double.infinity,
                        height: 160.h,
                        child: Center(
                          child: Text(
                            word.text.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 56.sp,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 3,
                              height: 0.9,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                          ),
                        ),
                      ),

                      SizedBox(height: 30.h),

                      // Difficulty stars
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          final isActive = index < word.difficulty;
                          return Container(
                            margin: EdgeInsets.symmetric(horizontal: 8.w),
                            child: Icon(
                              Icons.star,
                              size: 24.sp,
                              color: isActive
                                  ? const Color(0xFF6366F1)
                                  : Colors.white.withOpacity(0.2),
                            ),
                          );
                        }),
                      ),

                      // Hint if available
                      if (word.hint != null) ...[
                        SizedBox(height: 20.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 12.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: const Color(0xFF6366F1).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                color: const Color(0xFF6366F1),
                                size: 20.sp,
                              ),
                              SizedBox(width: 8.w),
                              Flexible(
                                child: Text(
                                  word.hint!,
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16.sp,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGestureHints() {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Row(
        children: [
          // Left swipe - Skip
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.orange[600]!.withOpacity(0.2),
                    Colors.orange[800]!.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(15.r),
                border: Border.all(
                  color: Colors.orange[600]!.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.arrow_back,
                    color: Colors.orange[400],
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'SWIPE LEFT',
                    style: TextStyle(
                      color: Colors.orange[400],
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'PASS',
                    style: TextStyle(
                      color: Colors.orange[300],
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(width: 16.w),

          // Up swipe - Pause
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_upward, color: Colors.white60, size: 16.sp),
                Text(
                  'PAUSE',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 16.w),

          // Right swipe - Correct
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.green[600]!.withOpacity(0.2),
                    Colors.green[800]!.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(15.r),
                border: Border.all(
                  color: Colors.green[600]!.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'GOT IT!',
                    style: TextStyle(
                      color: Colors.green[300],
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'SWIPE RIGHT',
                    style: TextStyle(
                      color: Colors.green[400],
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(
                    Icons.arrow_forward,
                    color: Colors.green[400],
                    size: 20.sp,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultOverlay() {
    final isCorrect = _lastAction == 'correct';

    return AnimatedBuilder(
      animation: isCorrect ? _correctScaleAnimation : _skipScaleAnimation,
      builder: (context, child) {
        return Container(
          color: Colors.black54,
          child: Center(
            child: Transform.scale(
              scale: isCorrect
                  ? _correctScaleAnimation.value
                  : _skipScaleAnimation.value,
              child: Container(
                padding: EdgeInsets.all(40.w),
                decoration: BoxDecoration(
                  color: isCorrect ? Colors.green[600] : Colors.orange[600],
                  borderRadius: BorderRadius.circular(25.r),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (isCorrect ? Colors.green[600]! : Colors.orange[600]!)
                              .withOpacity(0.4),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isCorrect ? Icons.check_circle : Icons.skip_next,
                      color: Colors.white,
                      size: 60.sp,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      isCorrect ? 'AWESOME!' : 'PASSED',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
