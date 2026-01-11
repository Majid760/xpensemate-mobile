import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/utils/app_utils.dart';
import 'package:xpensemate/core/widget/app_image.dart';
import 'package:xpensemate/core/widget/morphic_button.dart';
import 'package:xpensemate/core/widget/profile_image_widget.dart';
import 'package:xpensemate/features/profile/presentation/cubit/cubit/profile_state.dart';

class AppBarTitle extends StatelessWidget {
  const AppBarTitle({
    super.key,
    required this.displayName,
    required this.progress,
  });

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

class AppBarActions extends StatelessWidget {
  const AppBarActions({
    super.key,
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
              child: CompactProfileImage(profileState: profileState),
            ),
          ),
        ],
      );
}

class CustomFlexibleSpace extends StatelessWidget {
  const CustomFlexibleSpace({
    super.key,
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
              colors: [
                context.colorScheme.primary,
                context.colorScheme.tertiary,
              ],
              stops: const [0.0, 0.5],
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
                              child: FloatingProfileImage(
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

class FloatingProfileImage extends StatelessWidget {
  const FloatingProfileImage({
    super.key,
    required this.profileState,
    required this.onCameraTap,
  });

  final ProfileState profileState;
  final VoidCallback onCameraTap;

  @override
  Widget build(BuildContext context) {
    if (profileState is! ProfileLoaded) return const SizedBox.shrink();
    final loadedState = profileState as ProfileLoaded;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ProfileImageWidget(
          imageUrl: loadedState.user.profilePhotoUrl,
          showEditButton: false,
        ),
        context.sm.heightBox,
        Text(
          loadedState.displayName,
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

class CompactProfileImage extends StatelessWidget {
  const CompactProfileImage({super.key, required this.profileState});

  final ProfileState profileState;

  @override
  Widget build(BuildContext context) {
    if (profileState is! ProfileLoaded) return const SizedBox.shrink();
    final loadedState = profileState as ProfileLoaded;

    return Container(
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
                  loadedState.user.profilePhotoUrl ?? '',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
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
            context.md.widthBox,
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
                  context.xs.heightBox,
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
