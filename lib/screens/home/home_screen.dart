import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcharade/screens/game/game_screen.dart';
import 'package:jcharade/screens/game/game_screen_v2.dart';
import '../../providers/category_provider.dart';
import '../../providers/game_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import 'widgets/category_card.dart';
import 'widgets/timer_selector.dart';
import 'widgets/custom_category_dialog.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _titleAnimationController;
  late AnimationController _cardsAnimationController;
  late Animation<double> _titleSlideAnimation;
  late Animation<double> _cardsSlideAnimation;

  int selectedTimerDuration = AppConstants.defaultTimerDuration;
  String? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _titleAnimationController = AnimationController(
      duration: AppConstants.mediumAnimation,
      vsync: this,
    );

    _cardsAnimationController = AnimationController(
      duration: AppConstants.longAnimation,
      vsync: this,
    );

    _titleSlideAnimation = Tween<double>(begin: -100.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _titleAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _cardsSlideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _cardsAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 300), () {
      _titleAnimationController.forward();
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      _cardsAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _titleAnimationController.dispose();
    _cardsAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0B), // Clean dark background
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              SizedBox(height: 20.h),
              _buildTitle(),
              SizedBox(height: 30.h),
              _buildSubtitle(),
              SizedBox(height: 40.h),
              Expanded(
                child: AnimatedBuilder(
                  animation: _cardsSlideAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _cardsSlideAnimation.value),
                      child: Opacity(
                        opacity: 1 - (_cardsSlideAnimation.value / 50),
                        child: child,
                      ),
                    );
                  },
                  child: _buildMainContent(),
                ),
              ),
              _buildBottomSection(),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return AnimatedBuilder(
      animation: _titleSlideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_titleSlideAnimation.value, 0),
          child: child,
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'J-',
            style: TextStyle(
              fontSize: 48.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF6366F1), // Modern purple
              shadows: [
                Shadow(
                  offset: const Offset(2, 2),
                  blurRadius: 4,
                  color: Colors.black.withOpacity(0.3),
                ),
              ],
            ),
          ),
          Text(
            'Heads up',
            style: TextStyle(
              fontSize: 48.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  offset: const Offset(2, 2),
                  blurRadius: 4,
                  color: Colors.black.withOpacity(0.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'Act It Out, Guess It Right! �',
      style: TextStyle(
        fontSize: 18.sp,
        color: Colors.white.withOpacity(0.9),
        fontWeight: FontWeight.w500,
      ),
      textAlign: TextAlign.center,
      maxLines: 1,
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Choose Your Category'),
          SizedBox(height: 16.h),
          _buildCategoryGrid(),
          SizedBox(height: 30.h),
          _buildSectionTitle('Timer Duration'),
          SizedBox(height: 16.h),
          TimerSelector(
            selectedDuration: selectedTimerDuration,
            onDurationChanged: (duration) {
              setState(() {
                selectedTimerDuration = duration;
              });
              HapticFeedback.lightImpact();
            },
          ),
          SizedBox(height: 30.h),
          _buildCustomCategorySection(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildCategoryGrid() {
    final categoriesAsync = ref.watch(categoriesProvider);

    return categoriesAsync.when(
      data: (categories) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 0.9,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return CategoryCard(
              category: category,
              isSelected: selectedCategoryId == category.id,
              onTap: () {
                setState(() {
                  selectedCategoryId = category.id;
                });
                HapticFeedback.lightImpact();
              },
            );
          },
        );
      },
      loading: () =>
          const Center(child: CircularProgressIndicator(color: Colors.white)),
      error: (error, stack) => Center(
        child: Text(
          'Error loading categories: $error',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildCustomCategorySection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          Icon(
            Icons.add_circle_outline,
            size: 32.w,
            color: const Color(0xFF6366F1), // Modern purple
          ),
          SizedBox(height: 8.h),
          Text(
            'Create Custom Category',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Add your own words and categories',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.white.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12.h),
          ElevatedButton(
            onPressed: _showCustomCategoryDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1), // Modern purple
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
            ),
            child: Text(
              'Create Category',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    final isReadyToStart = selectedCategoryId != null;

    return Column(
      children: [
        if (!isReadyToStart) ...[
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.orange.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange, size: 20.w),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'Select a category to start playing',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
        ],
        _buildStartButton(isReadyToStart),
      ],
    );
  }

  Widget _buildStartButton(bool isEnabled) {
    return AnimatedContainer(
      duration: AppConstants.shortAnimation,
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: isEnabled ? _startGame : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled
              ? const Color(0xFF6366F1) // Modern purple
              : Colors.grey.withOpacity(0.3),
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.withOpacity(0.3),
          disabledForegroundColor: Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28.r),
          ),
          elevation: isEnabled ? 8 : 2,
          shadowColor: const Color(0xFF6366F1).withOpacity(0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_arrow_rounded, size: 28.w),
            SizedBox(width: 8.w),
            Text(
              'START GAME',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomCategoryDialog() {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => const CustomCategoryDialog(),
    );
  }

  void _startGame() async {
    if (selectedCategoryId == null) return;

    HapticFeedback.mediumImpact();
    GameHelpers.playSound(type: SoundType.gameStart);
    try {
      await ref
          .read(gameProvider.notifier)
          .initializeGame(
            categoryId: selectedCategoryId!,
            timerDuration: selectedTimerDuration,
          );

      if (mounted) {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const GameScreen()));
      }
    } catch (e) {
      if (mounted) {
        GameHelpers.showGameSnackBar(
          context,
          message: 'Error starting game: $e',
          backgroundColor: Colors.red,
          icon: Icons.error,
        );
      }
    }
  }
}
