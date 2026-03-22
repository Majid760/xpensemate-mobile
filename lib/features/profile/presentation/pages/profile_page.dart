import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/route/utils/router_extension.dart';
import 'package:xpensemate/core/service/permission_service.dart';
import 'package:xpensemate/core/service/service_locator.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/widget/app_button.dart';
import 'package:xpensemate/core/widget/app_custom_dialog.dart';
import 'package:xpensemate/core/widget/app_dialogs.dart';
import 'package:xpensemate/core/widget/app_snackbar.dart';
import 'package:xpensemate/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:xpensemate/features/auth/presentation/widgets/background_decoration_widget.dart';
import 'package:xpensemate/features/auth/presentation/widgets/feel_card_widget.dart';
import 'package:xpensemate/features/profile/presentation/cubit/cubit/profile_cubit.dart';
import 'package:xpensemate/features/profile/presentation/cubit/cubit/profile_state.dart';
import 'package:xpensemate/features/profile/presentation/pages/profile_edit_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, this.onBackTap});

  final void Function()? onBackTap;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  // ── Same animation pattern as LoginPage ───────────────────────────────
  late final AnimationController _animController;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeIn = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0, 0.65, curve: Curves.easeOut),
    );

    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0, 0.65, curve: Curves.easeOutCubic),
    ),);

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleLogout(BuildContext context) {
    AppCustomDialogs.showLogout(
      context: context,
      onConfirm: () async {
        await context.read<AuthCubit>().signOut();
        if (context.mounted) context.goToLogin();
      },
    );
  }

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
              currentContext.read<ProfileCubit>().updateProfileImage(file);
            }
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = context.primaryColor;

    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileError) {
          AppSnackBar.show(
            context: context,
            message: state.message,
            type: SnackBarType.error,
          );
        } else if (state is ProfileLoaded && state.message != null) {
          AppSnackBar.show(
            context: context,
            message: state.message!,
            type: state.message == 'updated'
                ? SnackBarType.success
                : SnackBarType.info,
          );
          context.read<ProfileCubit>().clearError();
        }
      },
      child: BlocBuilder<ProfileCubit, ProfileState>(
        buildWhen: (previous, current) =>
            current is ProfileLoaded ||
            current is ProfileLoading ||
            current is ProfileError,
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (state is ProfileError) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message),
                    const SizedBox(height: 16),
                    AppButton.primary(
                      text: context.l10n.retry,
                      onPressed: () =>
                          context.read<ProfileCubit>().updateProfile({}),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is! ProfileLoaded) {
            return Scaffold(
              body: Center(child: Text(context.l10n.userSessionNotFound)),
            );
          }

          final profileState = state;

          return Scaffold(
            backgroundColor: scheme.surface,
            // ── Same Stack + BackgroundDecoration as LoginPage ──────────
            body: Stack(
              children: [
                BackgroundDecoration(isDark: isDark),

                SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) => SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(minHeight: constraints.maxHeight),
                        child: IntrinsicHeight(
                          child: FadeTransition(
                            opacity: _fadeIn,
                            child: SlideTransition(
                              position: _slideUp,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 24),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    const SizedBox(height: 16),

                                    // ── Top nav row ──────────────────
                                    _NavRow(
                                      onBackTap: widget.onBackTap,
                                      onEditTap: () =>
                                          _showEditProfile(context),
                                    ),

                                    const SizedBox(height: 28),

                                    // ── Avatar + name ────────────────
                                    _AvatarSection(
                                      profileState: profileState,
                                      onCameraTap: () =>
                                          _handleImagePicker(context),
                                    ),

                                    const SizedBox(height: 28),

                                    // ── Stats card ───────────────────
                                    // Uses same FormCard as login's form card
                                    FormCard(
                                      isDark: isDark,
                                      child: _StatsRow(
                                          profileState: profileState,),
                                    ),

                                    const SizedBox(height: 20),

                                    // ── Personal info card ───────────
                                    _SectionLabel(
                                        label: context.l10n.personalInfo,),
                                    const SizedBox(height: 10),
                                    FormCard(
                                      isDark: isDark,
                                      child: Column(
                                        children: [
                                          _InfoRow(
                                            icon: Icons.person_outline,
                                            label: context.l10n.fullName,
                                            value: profileState.displayName,
                                            primary: primary,
                                            onTap: () =>
                                                _showEditProfile(context),
                                          ),
                                          _Divider(),
                                          _InfoRow(
                                            icon: Icons.email_outlined,
                                            label: context.l10n.emailAddress,
                                            value: profileState.email,
                                            primary: primary,
                                            onTap: () =>
                                                _showEditProfile(context),
                                          ),
                                          _Divider(),
                                          _InfoRow(
                                            icon: Icons.phone_outlined,
                                            label: context.l10n.phone,
                                            value: profileState.phone ??
                                                context.l10n.notSet,
                                            primary: primary,
                                            onTap: () =>
                                                _showEditProfile(context),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 20),

                                    // ── Biometric row ────────────────
                                    // Mirrors _BiometricSection from LoginPage exactly
                                    _BiometricRow(isDark: isDark),

                                    const SizedBox(height: 20),

                                    // ── Preferences card ─────────────
                                    _SectionLabel(
                                        label: context.l10n.preferences,),
                                    const SizedBox(height: 10),
                                    FormCard(
                                      isDark: isDark,
                                      child: Column(
                                        children: [
                                          _ActionRow(
                                            icon: Icons.notifications_outlined,
                                            label:
                                                context.l10n.notifications,
                                            primary: primary,
                                            onTap: () {},
                                          ),
                                          _Divider(),
                                          _ActionRow(
                                            icon: Icons.settings_outlined,
                                            label: context.l10n.settings,
                                            primary: primary,
                                            onTap: () =>
                                                context.goToSettings(),
                                          ),
                                          _Divider(),
                                          _ActionRow(
                                            icon: Icons.shield_outlined,
                                            label: context
                                                .l10n.privacyAndSecurity,
                                            primary: primary,
                                            onTap: () {},
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 20),

                                    // ── Edit Profile button ──────────
                                    // Same AppButton.primary as LoginPage
                                    AppButton.primary(
                                      text: context.l10n.editProfile,
                                      onPressed: () =>
                                          _showEditProfile(context),
                                    ),

                                    const SizedBox(height: 12),

                                    // ── Sign out button ──────────────
                                    _SignOutButton(
                                      onTap: () => _handleLogout(context),
                                    ),

                                    const Spacer(),

                                    // ── Footer ───────────────────────
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 24, top: 20,),
                                      child: Text(
                                        context.l10n.appVersionWithValue('1.0.0'),
                                        textAlign: TextAlign.center,
                                        style: context.textTheme.bodySmall
                                            ?.copyWith(
                                          color: scheme.onSurfaceVariant
                                              .withValues(alpha: 0.5),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showEditProfile(BuildContext context) {
    // Navigate to edit profile — replace with your route
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ProfileCubit>(),
          child: const ProfileEditPage(),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Nav Row
// ─────────────────────────────────────────────────────────────────────────────

class _NavRow extends StatelessWidget {
  const _NavRow({required this.onBackTap, required this.onEditTap});

  final VoidCallback? onBackTap;
  final VoidCallback onEditTap;

  @override
  Widget build(BuildContext context) {
    final primary = context.primaryColor;
    final scheme = context.colorScheme;

    return Row(
      children: [
        // Back button — same ghost style as login's "Forgot password"
        GestureDetector(
          onTap: onBackTap,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: primary.withValues(alpha: 0.18),
                width: 0.5,
              ),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: primary,
            ),
          ),
        ),

        const Spacer(),

        // Page title — same style as LoginPage's headline
        Text(
          context.l10n.myProfile,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: primary,
          ),
        ),

        const Spacer(),

        // Edit icon button
        GestureDetector(
          onTap: onEditTap,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: primary.withValues(alpha: 0.18),
                width: 0.5,
              ),
            ),
            child: Icon(
              Icons.edit_outlined,
              size: 16,
              color: primary,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Avatar Section
// ─────────────────────────────────────────────────────────────────────────────

class _AvatarSection extends StatelessWidget {
  const _AvatarSection({
    required this.profileState,
    required this.onCameraTap,
  });

  final ProfileLoaded profileState;
  final VoidCallback onCameraTap;

  @override
  Widget build(BuildContext context) {
    final primary = context.primaryColor;
    final scheme = context.colorScheme;

    return Column(
      children: [
        // ── Avatar ring — mirrors biometric button container style ───────
        Stack(
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primary.withValues(alpha: 0.12),
                border: Border.all(
                  color: primary.withValues(alpha: 0.4),
                  width: 0.5,
                ),
              ),
              child: profileState.photoUrl != null
                  ? ClipOval(
                      child: Image.network(
                        profileState.photoUrl!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Center(
                      child: Text(
                        _initials(profileState.displayName),
                        style: context.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: primary,
                        ),
                      ),
                    ),
            ),

            // Camera button
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: onCameraTap,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primary,
                    border: Border.all(
                      color: scheme.surface,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Name — same headlineMedium style as "Welcome Back"
        Text(
          profileState.displayName,
          textAlign: TextAlign.center,
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: primary,
          ),
        ),

        const SizedBox(height: 4),

        // Email — same bodyMedium subtitle style as login
        Text(
          profileState.email,
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stats Row  (inside FormCard)
// ─────────────────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.profileState});

  final ProfileLoaded profileState;

  @override
  Widget build(BuildContext context) {
    final primary = context.primaryColor;
    final scheme = context.colorScheme;

    return IntrinsicHeight(
      child: Row(
        children: [
          _StatItem(
            value: profileState.totalTracked ?? '—',
            label: context.l10n.totalTracked,
          ),
          // Divider — same 0.5px style used throughout
          VerticalDivider(
            width: 1,
            thickness: 0.5,
            color: scheme.outlineVariant.withValues(alpha: 0.5),
          ),
          _StatItem(
            value: '${profileState.transactionCount ?? 0}',
            label: context.l10n.transactions,
          ),
          VerticalDivider(
            width: 1,
            thickness: 0.5,
            color: scheme.outlineVariant.withValues(alpha: 0.5),
          ),
          _StatItem(
            value: profileState.memberSince ?? '—',
            label: context.l10n.memberSince,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final primary = context.primaryColor;
    final scheme = context.colorScheme;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          children: [
            Text(
              value,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: primary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: context.textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Biometric Row — direct copy of _BiometricSection from LoginPage
// ─────────────────────────────────────────────────────────────────────────────

class _BiometricRow extends StatelessWidget {
  const _BiometricRow({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          // "or" divider — identical to login's biometric divider
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 28,
                height: 0.5,
                color: context.primaryColor.withValues(alpha: 0.4),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  context.l10n.quickAccess,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.7),
                  ),
                ),
              ),
              Container(
                width: 28,
                height: 0.5,
                color: context.primaryColor.withValues(alpha: 0.4),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Biometric button — identical container decoration to LoginPage
          GestureDetector(
            onTap: () {},
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: context.primaryColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: context.primaryColor.withValues(alpha: 0.4),
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Platform.isIOS
                        ? Icons.face_unlock_outlined
                        : Icons.fingerprint,
                    size: 22,
                    color: context.primaryColor,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    Platform.isIOS
                        ? context.l10n.faceIdEnabled
                        : context.l10n.fingerprintEnabled,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Section Label
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Text(
        label,
        style: context.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: context.colorScheme.onSurfaceVariant,
          letterSpacing: 0.5,
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Info Row (inside FormCard)
// ─────────────────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.primary,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            // Icon — same size + color pattern as login's prefixIcon
            Icon(
              icon,
              size: 18,
              color: primary.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Field label — same FieldLabel style as login
                  Text(
                    label,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Action Row (Settings / Notifications rows)
// ─────────────────────────────────────────────────────────────────────────────

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.primary,
    required this.onTap,
    this.isDanger = false,
  });

  final IconData icon;
  final String label;
  final Color primary;
  final VoidCallback onTap;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final color = isDanger ? scheme.error : primary;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color.withValues(alpha: 0.7)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDanger ? scheme.error : scheme.onSurface,
                ),
              ),
            ),
            if (!isDanger)
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sign Out Button — styled like "Create One" link in LoginPage
// ─────────────────────────────────────────────────────────────────────────────

class _SignOutButton extends StatelessWidget {
  const _SignOutButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: scheme.error.withValues(alpha: 0.35),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout_rounded,
              size: 18,
              color: scheme.error.withValues(alpha: 0.8),
            ),
            const SizedBox(width: 8),
            Text(
              context.l10n.signOut,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: scheme.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Thin divider between rows inside FormCard
// ─────────────────────────────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Divider(
        height: 1,
        thickness: 0.5,
        color: context.colorScheme.outlineVariant.withValues(alpha: 0.5),
      );
}