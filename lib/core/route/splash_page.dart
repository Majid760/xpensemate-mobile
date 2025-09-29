//lib/features/splash/presentation/pages/splash_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/app_spacing.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/utils/assset_path.dart';
import 'package:xpensemate/core/widget/app_image.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<Offset> _logoSlideAnimation;
  late Animation<double> _logoFadeAnimation;

  // Characters in reverse order: e, t, a, M, e, s, n, e, p
  final String _appName = "penseMate";
  final List<AnimationController> _characterControllers = [];
  final List<Animation<double>> _characterRotationAnimations = [];
  final List<Animation<Offset>> _characterSlideAnimations = [];
  final List<Animation<double>> _characterOpacityAnimations = [];

  // Motto animation
  late AnimationController _mottoController;
  late Animation<double> _mottoFadeAnimation;
  late Animation<Offset> _mottoSlideAnimation;
  // final String _motto = "Track Smart, Spend Wise"; // Will use localized string

  // Loading animation
  late AnimationController _loadingController;
  late Animation<double> _loadingProgressAnimation;
  bool _showLoading = false;

  // GlobalKey to get logo position
  final GlobalKey _logoKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    // Logo animation controller
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Logo slide animation (from far left)
    _logoSlideAnimation = Tween<Offset>(
      begin: const Offset(-3, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Logo fade animation
    _logoFadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Character animations - in reverse order
    for (var i = 0; i < _appName.length; i++) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      );
      _characterControllers.add(controller);

      // Rotation animation (spinning)
      final rotationAnimation = Tween<double>(
        begin: 0,
        end: 2, // 2 full rotations
      ).animate(
        CurvedAnimation(
          parent: controller,
          curve: const Interval(0, 0.6, curve: Curves.easeInOut),
        ),
      );
      _characterRotationAnimations.add(rotationAnimation);

      // Slide animation (from logo position to final position)
      final slideAnimation = Tween<Offset>(
        begin: Offset.zero,
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: controller,
          curve: const Interval(0.3, 1, curve: Curves.easeOutBack),
        ),
      );
      _characterSlideAnimations.add(slideAnimation);

      // Opacity animation
      final opacityAnimation = Tween<double>(
        begin: 0,
        end: 1,
      ).animate(
        CurvedAnimation(
          parent: controller,
          curve: const Interval(0, 0.3, curve: Curves.easeIn),
        ),
      );
      _characterOpacityAnimations.add(opacityAnimation);
    }

    // Motto animation
    _mottoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _mottoFadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _mottoController,
        curve: Curves.easeIn,
      ),
    );

    _mottoSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mottoController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Loading animation
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _loadingProgressAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _loadingController,
        curve: Curves.easeInOut,
      ),
    );
  }

  Future<void> _startAnimations() async {
    // Start logo animation
    await _logoController.forward();

    // Wait a bit after logo settles
    await Future<void>.delayed(const Duration(milliseconds: 300));

    // Start character animations in reverse order (e, t, a, M, e, s, n, e, p)
    for (var i = _appName.length - 1; i >= 0; i--) {
      if (mounted) {
        await _characterControllers[i].forward();
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
    }

    // Wait a bit after text completes
    await Future<void>.delayed(const Duration(milliseconds: 400));

    // Start motto animation
    if (mounted) {
      await _mottoController.forward();
    }

    // Wait a bit, then show loading
    await Future<void>.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      setState(() {
        _showLoading = true;
      });
      await _loadingController.forward();
    }

    // Wait for loading to complete, then navigate
    await Future<void>.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      context.go('/home');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _mottoController.dispose();
    _loadingController.dispose();
    for (final controller in _characterControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: context.colorScheme.tertiary,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo and Text Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated Logo
                  SlideTransition(
                    position: _logoSlideAnimation,
                    child: FadeTransition(
                      opacity: _logoFadeAnimation,
                      child: Container(
                        key: _logoKey,
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: AppImage.asset(
                          AssetPaths.logoWithoutText,
                          height: 50,
                          width: 50,
                          color: context.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  // Animated Text
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: _buildAnimatedText(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              // Animated Motto
              SlideTransition(
                position: _mottoSlideAnimation,
                child: FadeTransition(
                  opacity: _mottoFadeAnimation,
                  child: Text(
                    context.l10n.moto,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color:
                          context.colorScheme.onPrimary.withValues(alpha: .9),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Loading Animation
              if (_showLoading) _buildLoadingAnimation(context),
            ],
          ),
        ),
      );

  Widget _buildLoadingAnimation(BuildContext context) => Column(
        children: [
          // Preparing text with dots animation
          AnimatedBuilder(
            animation: _loadingController,
            builder: (context, child) {
              final dots = '.' * ((_loadingController.value * 3).floor() % 4);
              return FadeTransition(
                opacity: _loadingProgressAnimation,
                child: Text(
                  '${context.l10n.loading}$dots',
                  style: TextStyle(
                    fontSize: 16,
                    color: context.colorScheme.onPrimary.withValues(alpha: .7),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          // Progress bar
          AnimatedBuilder(
            animation: _loadingProgressAnimation,
            builder: (context, child) => Container(
              width: 200,
              height: 4,
              decoration: BoxDecoration(
                color: context.colorScheme.onPrimary.withValues(alpha: .2),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Stack(
                children: [
                  // Animated progress fill
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _loadingProgressAnimation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            context.colorScheme.primary,
                            context.colorScheme.primary.withValues(alpha: 0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Shimmer effect
                  Positioned(
                    left: _loadingProgressAnimation.value * 200 - 30,
                    child: Container(
                      width: 30,
                      height: 4,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            context.colorScheme.onPrimary.withValues(alpha: 0),
                            context.colorScheme.onPrimary
                                .withValues(alpha: 0.6),
                            context.colorScheme.onPrimary.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );

  List<Widget> _buildAnimatedText() {
    final characters = <Widget>[];

    for (var i = 0; i < _appName.length; i++) {
      characters.add(
        AnimatedBuilder(
          animation: _characterControllers[i],
          builder: (context, child) {
            final rotation = _characterRotationAnimations[i].value;
            final opacity =
                _characterOpacityAnimations[i].value.clamp(0.0, 1.0);

            final characterIndex = i;
            final slideX = -1.0 *
                (1.0 - _characterControllers[i].value) *
                (characterIndex + 1) *
                0.5;

            return Transform.translate(
              offset: Offset(slideX * 50, 0),
              child: Transform.rotate(
                angle: rotation * 3.14159,
                child: Opacity(
                  opacity: opacity,
                  child: Text(
                    _appName[i],
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: context.colorScheme.onPrimary,
                      letterSpacing: AppSpacing.xs,
                      height: 1,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    return characters;
  }
}
