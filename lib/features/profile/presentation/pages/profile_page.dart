import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/service/permission_service.dart';
import 'package:xpensemate/core/service/service_locator.dart';
import 'package:xpensemate/core/theme/colors/app_colors.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/widget/app_dialogs.dart' hide AppPermission;
import 'package:xpensemate/core/widget/morphic_button.dart';
import 'package:xpensemate/core/widget/profile_image_widget.dart';
import 'package:xpensemate/features/profile/presentation/cubit/cubit/profile_cubit.dart';
import 'package:xpensemate/features/profile/presentation/cubit/cubit/profile_state.dart';
import 'package:xpensemate/features/profile/presentation/widgets/profile_content_item_widget.dart';
import 'package:xpensemate/features/profile/presentation/widgets/profile_edit_sheet.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final ScrollController _scrollController = ScrollController();
  bool _showUserName = false;
  double _titleProgress = 0;

  bool isDarkMode = false;

  static const _gradientColors = [
    AppColors.primary,
    AppColors.secondary,
    AppColors.tertiary,
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeScrollListener();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutQuart),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeController.forward();
    _slideController.forward();
    _pulseController.repeat(reverse: true);
  }

  void _initializeScrollListener() {
    _scrollController.addListener(() {
      final showUserName = _scrollController.offset > 140;
      final progress = (_scrollController.offset / 140).clamp(0.0, 1.0);
      if (_showUserName != showUserName) {
        setState(() {
          _showUserName = showUserName;
          _titleProgress = progress;
        });
      } else {
        setState(() => _titleProgress = progress);
      }
    });
  }

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state.status == ProfileStatus.error &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        builder: (context, profileState) => Scaffold(
          backgroundColor: context.colorScheme.surface,
          body: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _gradientColors,
                stops: [0.0, 0.5, 1.0],
              ),
            ),
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  expandedHeight: 250,
                  pinned: true,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  centerTitle: true,
                  title: _AppBarTitle(
                    displayName: context.profileCubit.displayName,
                    progress: _titleProgress,
                  ),
                  leading: Padding(
                    padding: EdgeInsets.only(left: context.md),
                    child: GestureDetector(
                      // onTap: () => context.go('/'),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: context.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  actions: [
                    Padding(
                      padding: EdgeInsets.only(right: context.md),
                      child: _AppBarActions(
                        progress: _titleProgress,
                        profileState: profileState,
                        onEditTap: () => showEditProfile(
                          context,
                          () {},
                          (user) => {},
                        ),
                      ),
                    ),
                  ],
                  flexibleSpace: _FlexibleSpace(
                    profileState: profileState,
                    fadeAnimation: _fadeAnimation,
                    slideAnimation: _slideAnimation,
                    titleProgress: _titleProgress,
                    onCameraTap: () => _handleImagePicker(context),
                  ),
                ),
                SliverToBoxAdapter(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: context.colorScheme.surface,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              context.colorScheme.shadow.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: ModernContent(
                          profileState: profileState,
                          onLogoutTap: () {},
                          onComingSoon: (str) => showEditProfile(
                            context,
                            () {},
                            (user) => {},
                          ),
                          isDarkMode: isDarkMode,
                          onThemeChanged: (bool value) {
                            setState(() => isDarkMode = value);
                            HapticFeedback.selectionClick();
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Future<void> _handleImagePicker(BuildContext context) async {
    final result = await sl.permissions.requestMultiplePermissions(
      [AppPermission.camera, AppPermission.gallery],
    );
    if (mounted && (result[AppPermission.camera]?.isGranted ?? false)) {
      final currentContext = context;
      AppDialogs.showImagePicker(
        context: currentContext,
        onImageSelected: (file) {
          currentContext.profileCubit.updateProfileImage(file!);
        },
      );
    }
  }
}

/* ----------------------------------------------------------
   Widgets that used to be private methods
   ---------------------------------------------------------- */

class _AppBarTitle extends StatelessWidget {
  const _AppBarTitle({required this.displayName, required this.progress});

  final String displayName;
  final double progress;

  @override
  Widget build(BuildContext context) => Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: 1.0 - progress,
            child: Text(
              context.l10n.profile,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: context.colorScheme.onPrimary,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Opacity(
            opacity: progress,
            child: Text(
              displayName,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: context.colorScheme.onPrimary,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      );
}

class _AppBarActions extends StatelessWidget {
  const _AppBarActions({
    required this.progress,
    required this.profileState,
    required this.onEditTap,
  });

  final double progress;
  final ProfileState profileState;
  final VoidCallback onEditTap;

  @override
  Widget build(BuildContext context) => Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: (1.0 - progress).clamp(0.0, 1.0),
            child: IgnorePointer(
              ignoring: progress > 0.05,
              child: GlassmorphicButton(
                icon: Icons.edit_rounded,
                onTap: onEditTap,
              ),
            ),
          ),
          Opacity(
            opacity: progress,
            child: _CompactProfileImage(profileState: profileState),
          ),
        ],
      );
}

class _FlexibleSpace extends StatelessWidget {
  const _FlexibleSpace({
    required this.profileState,
    required this.fadeAnimation,
    required this.slideAnimation,
    required this.titleProgress,
    required this.onCameraTap,
  });

  final ProfileState profileState;
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final double titleProgress;
  final VoidCallback onCameraTap;

  @override
  Widget build(BuildContext context) => FlexibleSpaceBar(
        background: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.secondary,
                AppColors.tertiary,
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final targetAlignment = Alignment.lerp(
                      const Alignment(0, 0.25),
                      const Alignment(0, 0.25),
                      titleProgress,
                    ) ??
                    const Alignment(0, 0.25);
                final scale = lerpDouble(1.0, 0.0, titleProgress) ?? 1.0;
                final topBarHeight =
                    MediaQuery.of(context).padding.top + kToolbarHeight;

                return Stack(
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: topBarHeight + 20,
                      child: Opacity(
                        opacity: titleProgress,
                        child: const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primary,
                                AppColors.secondary,
                                AppColors.tertiary,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: targetAlignment,
                      child: Transform.scale(
                        scale: scale,
                        child: Opacity(
                          opacity: 1.0 - titleProgress,
                          child: FadeTransition(
                            opacity: fadeAnimation,
                            child: SlideTransition(
                              position: slideAnimation,
                              child: _FloatingProfileImage(
                                profileState: profileState,
                                onCameraTap: onCameraTap,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
}

class _FloatingProfileImage extends StatelessWidget {
  const _FloatingProfileImage({
    required this.profileState,
    required this.onCameraTap,
  });

  final ProfileState profileState;
  final VoidCallback onCameraTap;

  @override
  Widget build(BuildContext context) {
    final isUpdating = profileState.status == ProfileStatus.updating;
    final displayName = context.profileCubit.displayName;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.secondary,
                    AppColors.tertiary,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(context.xs),
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: ClipOval(
                    child: ProfileImageWidget(
                      imageUrl:
                          context.profileCubit.state.user?.profilePhotoUrl,
                      size: 50,
                      showEditButton: false,
                    ),
                  ),
                ),
              ),
            ),
            if (!isUpdating)
              Positioned(
                bottom: 2,
                right: 2,
                child: GestureDetector(
                  onTap: onCameraTap,
                  child: Container(
                    padding: EdgeInsets.all(context.xs),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: context.sm),
        Text(
          displayName,
          textAlign: TextAlign.center,
          style: context.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: context.colorScheme.onPrimary,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

class _CompactProfileImage extends StatelessWidget {
  const _CompactProfileImage({required this.profileState});

  final ProfileState profileState;

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.all(context.xs),
        decoration: BoxDecoration(
          color: context.colorScheme.onPrimary.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: context.colorScheme.onPrimary.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: context.colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.secondary,
                AppColors.tertiary,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(1.5),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.5),
                color: context.colorScheme.onPrimary,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.5),
                child: ProfileImageWidget(
                  imageUrl: context.profileCubit.state.user?.profilePhotoUrl,
                  size: 16,
                  showEditButton: false,
                ),
              ),
            ),
          ),
        ),
      );
}

class ThemeToggle extends StatelessWidget {
  const ThemeToggle({
    super.key,
    required this.isDarkMode,
    required this.onChanged,
  });

  final bool isDarkMode;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.all(context.md),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(context.sm),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    context.colorScheme.secondary.withValues(alpha: 0.18),
                    context.colorScheme.tertiary.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: context.colorScheme.secondary.withValues(alpha: 0.22),
                ),
              ),
              child: Icon(
                isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: context.colorScheme.secondary,
                size: 20,
              ),
            ),
            SizedBox(width: context.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.darkMode,
                    style: context.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: context.xs),
                  Text(
                    context.l10n.switchBetweenLightAndDarkTheme,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 35,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: isDarkMode
                    ? LinearGradient(
                        colors: [
                          context.colorScheme.secondary,
                          context.colorScheme.tertiary,
                        ],
                      )
                    : LinearGradient(
                        colors: [
                          context.colorScheme.outlineVariant,
                          context.colorScheme.outline,
                        ],
                      ),
                boxShadow: [
                  BoxShadow(
                    color: (isDarkMode
                            ? context.colorScheme.secondary
                            : context.colorScheme.shadow)
                        .withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Transform.scale(
                scale: 0.6,
                child: Switch.adaptive(
                  value: isDarkMode,
                  onChanged: onChanged,
                  activeColor: context.colorScheme.onSecondary,
                  inactiveThumbColor: context.colorScheme.onPrimary,
                  inactiveTrackColor: Colors.transparent,
                  activeTrackColor: Colors.transparent,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
          ],
        ),
      );
}

/* ----------------------------------------------------------
   Model class (unchanged)
   ---------------------------------------------------------- */

class MenuItemData {
  const MenuItemData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool isDestructive;
}
