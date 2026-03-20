import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/route/utils/router_extension.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/widget/app_button.dart';
import 'package:xpensemate/core/widget/app_snackbar.dart';
import 'package:xpensemate/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:xpensemate/features/auth/presentation/cubit/auth_state.dart';
import 'package:xpensemate/features/auth/presentation/widgets/background_decoration_widget.dart';
import 'package:xpensemate/features/auth/presentation/widgets/brand_mark_widget.dart';
import 'package:xpensemate/features/auth/presentation/widgets/feel_card_widget.dart';


class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({
    super.key,
    required this.email,
  });

  final String email;

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen>
    with TickerProviderStateMixin {
  // ── Entrance animation (fade + slide — same as all auth pages) ────────────
  late final AnimationController _entranceController;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  // ── Envelope pulse (gentle breathe loop) ──────────────────────────────────
  late final AnimationController _pulseController;
  late final Animation<double> _pulse;

  // ── Resend cooldown ────────────────────────────────────────────────────────
  // Prevents the user hammering resend. Counts down from [_cooldownSeconds].
  static const int _cooldownSeconds = 30;
  int _secondsLeft = 0;
  bool get _canResend => _secondsLeft == 0;

  @override
  void initState() {
    super.initState();

    // ── Entrance ─────────────────────────────────────────────────────────────
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeIn = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0, 0.65, curve: Curves.easeOut),
    );

    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0, 0.65, curve: Curves.easeOutCubic),
    ),);

    _entranceController.forward();

    // ── Pulse ─────────────────────────────────────────────────────────────────
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulse = Tween<double>(begin: 0.93, end: 1.07).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // ── Resend ────────────────────────────────────────────────────────────────
  Future<void> _resend() async {
    if (!_canResend) return;

    await context.read<AuthCubit>().sendVerificationEmail(
          email: widget.email,
        );

    // Start cooldown regardless of success/failure —
    // the BlocListener handles the error snackbar.
    _startCooldown();
  }

  void _startCooldown() {
    setState(() => _secondsLeft = _cooldownSeconds);

    // Tick every second using a post-frame Future chain.
    _tick();
  }

  void _tick() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _secondsLeft = (_secondsLeft - 1).clamp(0, _cooldownSeconds));
      if (_secondsLeft > 0) _tick();
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = context.primaryColor;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: BlocListener<AuthCubit, AuthState>(
        listenWhen: (_, state) =>
            state is AuthError || state is AuthAuthenticated,
        listener: (context, state) {
          if (state is AuthError) {
            AppSnackBar.show(
              context: context,
              message: state.message,
              type: SnackBarType.error,
            );
            return;
          }
          if (state is AuthAuthenticated) {
            // Email verified — navigate to home
            context.goToHome();
          }
        },
        child: Stack(
          children: [
            // ── Background blobs ──────────────────────────────────────
            BackgroundDecoration(isDark: isDark),

            // ── Scrollable body ───────────────────────────────────────
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: FadeTransition(
                        opacity: _fadeIn,
                        child: SlideTransition(
                          position: _slideUp,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 48),

                                // ── Brand ────────────────────────────
                                BrandMark(isDark: isDark),

                                const SizedBox(height: 36),

                                // ── Animated envelope ────────────────
                                Center(
                                  child: _EnvelopeBadge(
                                    pulse: _pulse,
                                    isDark: isDark,
                                    primary: primary,
                                  ),
                                ),

                                const SizedBox(height: 32),

                                // ── Headline ─────────────────────────
                                Text(
                                  context.l10n.verifyYourEmail,
                                  textAlign: TextAlign.center,
                                  style: context.textTheme.headlineMedium
                                      ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text.rich(
                                  TextSpan(
                                    style: context.textTheme.bodyMedium
                                        ?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                      height: 1.55,
                                    ),
                                    children: [
                                      TextSpan(
                                        text:
                                            '${context.l10n.verificationEmailSentTo} ',
                                      ),
                                      TextSpan(
                                        text: widget.email,
                                        style: TextStyle(
                                          color: primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            '. ${context.l10n.verificationInstructions}',
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),

                                const SizedBox(height: 32),

                                // ── Info card ─────────────────────────
                                FormCard(
                                  isDark: isDark,
                                  child: Column(
                                    children: [
                                      _InfoRow(
                                        icon:
                                            Icons.touch_app_outlined,
                                        text: context
                                            .l10n.tapLinkInEmail,
                                        primary: primary,
                                        scheme: scheme,
                                      ),
                                      const SizedBox(height: 14),
                                      _InfoRow(
                                        icon: Icons.folder_outlined,
                                        text: context
                                            .l10n.checkSpamFolder,
                                        primary: primary,
                                        scheme: scheme,
                                      ),
                                      const SizedBox(height: 14),
                                      _InfoRow(
                                        icon: Icons.timer_outlined,
                                        text: context
                                            .l10n.linkExpiresIn24Hours,
                                        primary: primary,
                                        scheme: scheme,
                                      ),
                                    ],
                                  ),
                                ),

                                const Spacer(),

                                // ── Resend CTA ────────────────────────
                                BlocBuilder<AuthCubit, AuthState>(
                                  buildWhen: (p, c) =>
                                      p is AuthLoading || c is AuthLoading,
                                  builder: (context, state) {
                                    final isLoading = state is AuthLoading;
                                    return AppButton.primary(
                                      text: _canResend
                                          ? context
                                              .l10n.resendVerificationEmail
                                          : context.l10n
                                              .resendIn(_secondsLeft),
                                      isLoading: isLoading,
                                      onPressed:
                                          (isLoading || !_canResend)
                                              ? null
                                              : _resend,
                                    );
                                  },
                                ),

                                const SizedBox(height: 12),

                                // ── Back to login ─────────────────────
                                AppButton.outline(
                                  text: context.l10n.backToLogin,
                                  onPressed: context.goToLogin,
                                ),

                                const SizedBox(height: 24),
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
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _EnvelopeBadge
// Replaces the bare 120px icon with a branded ring + glow + pulse.
// Three concentric circles create depth without being heavy.
// ─────────────────────────────────────────────────────────────────────────────
class _EnvelopeBadge extends StatelessWidget {
  const _EnvelopeBadge({
    required this.pulse,
    required this.isDark,
    required this.primary,
  });

  final Animation<double> pulse;
  final bool isDark;
  final Color primary;

  @override
  Widget build(BuildContext context) => ScaleTransition(
        scale: pulse,
        child: SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer glow ring
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primary.withValues(
                    alpha: isDark ? 0.06 : 0.08,
                  ),
                ),
              ),
              // Mid ring
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primary.withValues(
                    alpha: isDark ? 0.10 : 0.12,
                  ),
                  border: Border.all(
                    color: primary.withValues(alpha: 0.15),
                    width: 0.5,
                  ),
                ),
              ),
              // Icon container
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primary.withValues(
                    alpha: isDark ? 0.18 : 0.15,
                  ),
                  border: Border.all(
                    color: primary.withValues(alpha: 0.35),
                  ),
                ),
                child: Icon(
                  Icons.mark_email_read_outlined,
                  size: 28,
                  color: primary,
                ),
              ),
            ],
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _InfoRow
// A single icon + text row used inside the info card.
// Icon uses a small tinted badge, text uses onSurfaceVariant.
// ─────────────────────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.text,
    required this.primary,
    required this.scheme,
  });

  final IconData icon;
  final String text;
  final Color primary;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: primary.withValues(alpha: 0.10),
            ),
            child: Icon(icon, size: 16, color: primary),
          ),
          const SizedBox(width: 12),
          // Text
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                text,
                style: context.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      );
}