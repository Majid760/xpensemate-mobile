import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';

import 'package:xpensemate/core/route/utils/router_extension.dart';
import 'package:xpensemate/core/service/permission_service.dart';
import 'package:xpensemate/core/service/service_locator.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/widget/app_custom_dialog.dart';
import 'package:xpensemate/core/widget/app_dialogs.dart';
import 'package:xpensemate/core/widget/app_image.dart';
import 'package:xpensemate/core/widget/app_snackbar.dart';
import 'package:xpensemate/core/widget/morphic_button.dart';
import 'package:xpensemate/core/widget/profile_image_widget.dart';
import 'package:xpensemate/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:xpensemate/features/profile/presentation/cubit/cubit/profile_cubit.dart';
import 'package:xpensemate/features/profile/presentation/cubit/cubit/profile_state.dart';
import 'package:xpensemate/features/profile/presentation/pages/profile_edit_page.dart';
import 'package:xpensemate/features/profile/presentation/widgets/profile_content_item_widget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, this.onBackTap});

  final void Function()? onBackTap;

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
          if (state.status == ProfileStatus.error && state.message != null) {
            AppSnackBar.show(
              context: context,
              message: state.message!,
              type: SnackBarType.error,
            );
          }
        },
        builder: (context, profileState) => Scaffold(
          backgroundColor: context.colorScheme.surface,
          body: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  context.colorScheme.primary,
                  context.colorScheme.secondary,
                  context.colorScheme.tertiary,
                ],
                stops: const [0.0, 0.5, 1.0],
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
                      onTap: widget.onBackTap,
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
                          onLogoutTap: () => AppCustomDialogs.showLogout(
                            context: context,
                            onConfirm: () async {
                              await context.authCubit.signOut();
                              if (context.mounted) context.goToLogin();
                            },
                          ),
                          onComingSoon: (str) => showEditProfile(context),
                          isDarkMode: profileState.themeMode == ThemeMode.dark,
                          onThemeChanged: (bool value) {
                            context
                                .read<ProfileCubit>()
                                .toggleTheme(isDark: value);
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
      if (currentContext.mounted) {
        await AppDialogs.showImagePicker(
          context: currentContext,
          onImageSelected: (file) {
            if (file != null) {
              currentContext.profileCubit.updateProfileImage(file);
            }
          },
        );
      }
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
              ignoring: progress > 0.5,
              child: GlassmorphicButton(
                icon: Icons.edit_rounded,
                onTap: onEditTap,
              ),
            ),
          ),
          IgnorePointer(
            ignoring: progress < 0.5,
            child: Opacity(
              opacity: progress,
              child: _CompactProfileImage(profileState: profileState),
            ),
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
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                context.colorScheme.primary,
                context.colorScheme.secondary,
                context.colorScheme.tertiary,
              ],
              stops: const [0.0, 0.5, 1.0],
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
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                context.colorScheme.primary,
                                context.colorScheme.secondary,
                                context.colorScheme.tertiary,
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
    final displayName = context.profileCubit.displayName;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            ProfileImageWidget(
              imageUrl: context.profileCubit.state.user?.profilePhotoUrl,
              showEditButton: false,
            ),
          ],
        ),
        SizedBox(height: context.sm),
        Text(
          displayName,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                context.colorScheme.primary,
                context.colorScheme.secondary,
                context.colorScheme.tertiary,
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
              child: Hero(
                tag: 'profilePic',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.5),
                  child: AppImage.network(
                    profileState.user?.profilePhotoUrl ?? '',
                  ),
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
                  activeThumbColor: context.colorScheme.onSecondary,
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
