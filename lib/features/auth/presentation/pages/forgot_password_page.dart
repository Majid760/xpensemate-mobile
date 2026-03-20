import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/utils/app_utils.dart';
import 'package:xpensemate/core/widget/app_button.dart';
import 'package:xpensemate/core/widget/app_snackbar.dart';
import 'package:xpensemate/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:xpensemate/features/auth/presentation/cubit/auth_state.dart';
import 'package:xpensemate/features/auth/presentation/widgets/background_decoration_widget.dart';
import 'package:xpensemate/features/auth/presentation/widgets/brand_mark_widget.dart';
import 'package:xpensemate/features/auth/presentation/widgets/custom_text_form_field.dart';
import 'package:xpensemate/features/auth/presentation/widgets/feel_card_widget.dart';
import 'package:xpensemate/features/auth/presentation/widgets/feild_lable_widget.dart';

// ─────────────────────────────────────────────────────────────────────────────
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage>
    with SingleTickerProviderStateMixin {
  // ── Form ──────────────────────────────────────────────────────────────────
  late final FormGroup _form;

  // ── Animation ─────────────────────────────────────────────────────────────
  late final AnimationController _animController;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  // ── Success state — drives the sent-confirmation UI ───────────────────────
  bool _emailSent = false;

  // ── Derived helper — avoids repeated casts ────────────────────────────────
  String get _email =>
      (_form.control('email').value as String?)?.trim().toLowerCase() ?? '';

  // ─────────────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();

    _form = FormGroup({
      'email': FormControl<String>(
        validators: [Validators.required, Validators.email],
      ),
    });

    // Entrance animation — identical timing to LoginPage
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
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0, 0.65, curve: Curves.easeOutCubic),
      ),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _form.dispose();
    _animController.dispose();
    super.dispose();
  }

  // ── Submit ────────────────────────────────────────────────────────────────
  Future<void> _submitForm() async {
    _form.markAllAsTouched();
    if (!_form.valid) return;

    await context.read<AuthCubit>().forgotPassword(email: _email);
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = context.primaryColor;

    return Scaffold(
      // No AppBar — back navigation is inline, matching LoginPage's style
      backgroundColor: scheme.surface,
      body: BlocListener<AuthCubit, AuthState>(
        listenWhen: (_, state) =>
            state is AuthError || state is AuthUnauthenticated,
        listener: (context, state) {
          if (state is AuthError) {
            AppSnackBar.show(
              context: context,
              message: state.message,
              type: SnackBarType.error,
            );
            return;
          }
          if (state is AuthUnauthenticated) {
            // Show inline success state instead of a snackbar + delayed pop.
            // Keeps the user on the page so they can see the confirmation
            // and navigate back themselves.
            setState(() => _emailSent = true);
          }
        },
        child: Stack(
          children: [
            // ── Background blobs ────────────────────────────────────────
            BackgroundDecoration(isDark: isDark),

            // ── Scrollable body ─────────────────────────────────────────
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
                                const SizedBox(height: 16),

                                // ── Inline back button ───────────────
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: _BackButton(
                                    isDark: isDark,
                                    onTap: () => context.pop(),
                                  ),
                                ),

                                const SizedBox(height: 32),

                                // ── Brand ────────────────────────────
                                BrandMark(isDark: isDark),

                                const SizedBox(height: 36),

                                // ── Headline ─────────────────────────
                                Text(
                                  _emailSent
                                      ? context.l10n.checkYourEmail
                                      : context.l10n.forgotPasswordTitle,
                                  textAlign: TextAlign.center,
                                  style: context.textTheme.headlineMedium
                                      ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _emailSent
                                      ? context.l10n.resetLinkSentTo(_email)
                                      : context.l10n.forgotPasswordSubtitle,
                                  textAlign: TextAlign.center,
                                  style: context.textTheme.bodyMedium
                                      ?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                    letterSpacing: 0.1,
                                    height: 1.5,
                                  ),
                                ),

                                const SizedBox(height: 36),

                                // ── Sent confirmation OR form ─────────
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 400),
                                  switchInCurve: Curves.easeOut,
                                  switchOutCurve: Curves.easeIn,
                                  child: _emailSent
                                      ? _SentConfirmation(
                                          key: const ValueKey('sent'),
                                          isDark: isDark,
                                          email: _email,
                                          onResend: () {
                                            setState(() => _emailSent = false);
                                          },
                                        )
                                      : _ResetForm(
                                          key: const ValueKey('form'),
                                          form: _form,
                                          isDark: isDark,
                                          onSubmit: _submitForm,
                                        ),
                                ),

                                const Spacer(),

                                // ── Back to sign-in link ─────────────
                                Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 24,
                                    top: 20,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        context.l10n.rememberPassword,
                                        style: context.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: scheme.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      GestureDetector(
                                        onTap: () => context.pop(),
                                        child: Text(
                                          context.l10n.signIn,
                                          style: context.textTheme.bodyMedium
                                              ?.copyWith(
                                            color: primary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
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
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ResetForm
// The email input + submit button shown before the link is sent.
// Extracted so AnimatedSwitcher can cross-fade to _SentConfirmation.
// ─────────────────────────────────────────────────────────────────────────────
class _ResetForm extends StatelessWidget {
  const _ResetForm({
    super.key,
    required this.form,
    required this.isDark,
    required this.onSubmit,
  });

  final FormGroup form;
  final bool isDark;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final primary = context.primaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Form card ───────────────────────────────────────────────────
        ReactiveForm(
          formGroup: form,
          child: FormCard(
            isDark: isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FieldLabel(label: context.l10n.emailAddress),
                const SizedBox(height: 6),
                ReactiveAppField(
                  formControlName: 'email',
                  fieldType: FieldType.email,
                  hintText: context.l10n.hintEmail,
                  textInputAction: TextInputAction.done,
                   onSubmitted: (_) => AppUtils.throttle(onSubmit),
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    size: 18,
                    color: primary.withValues(alpha: 0.7),
                  ),
                  validationMessages: {
                    'required': (_) => context.l10n.emailRequired,
                    'email': (_) => context.l10n.invalidEmail,
                  },
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // ── CTA ─────────────────────────────────────────────────────────
        BlocBuilder<AuthCubit, AuthState>(
          buildWhen: (p, c) => p is AuthLoading || c is AuthLoading,
          builder: (context, state) => AppButton.primary(
            text: context.l10n.resetPassword,
            isLoading: state is AuthLoading,
            onPressed: state is AuthLoading
                ? null
                : () => AppUtils.throttle(onSubmit),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SentConfirmation
// Shown after the reset link is dispatched.
// Replaces the form via AnimatedSwitcher — no navigation required.
// ─────────────────────────────────────────────────────────────────────────────
class _SentConfirmation extends StatelessWidget {
  const _SentConfirmation({
    super.key,
    required this.isDark,
    required this.email,
    required this.onResend,
  });

  final bool isDark;
  final String email;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    final primary = context.primaryColor;
    final scheme = context.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Success card ────────────────────────────────────────────────
        FormCard(
          isDark: isDark,
          child: Column(
            children: [
              // Icon badge
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primary.withValues(alpha: 0.12),
                  border: Border.all(
                    color: primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Icon(
                  Icons.mark_email_read_outlined,
                  size: 26,
                  color: primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.resetLinkSentTo(email),
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              // Tip row
              Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      context.l10n.checkSpamFolder,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ── Resend CTA ──────────────────────────────────────────────────
        AppButton.primary(
          text: context.l10n.openEmailApp,
          onPressed: () {
            // Platform email-app launch can be wired here via url_launcher.
            // e.g. launchUrl(Uri.parse('mailto:'));
          },
        ),

        const SizedBox(height: 12),

        // ── Resend link ─────────────────────────────────────────────────
        Center(
          child: GestureDetector(
            onTap: onResend,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: context.l10n.didntReceiveEmail,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const WidgetSpan(child: SizedBox(width: 4)),
                  TextSpan(
                    text: context.l10n.resend,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _BackButton
// Replaces the AppBar back button — consistent with LoginPage's no-AppBar style.
// ─────────────────────────────────────────────────────────────────────────────
class _BackButton extends StatelessWidget {
  const _BackButton({required this.isDark, required this.onTap});

  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF122436)
                : const Color(0xFFF0FAFA),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF1E4A5A)
                  : const Color(0xFFB2D8E8),
              width: 0.5,
            ),
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 15,
            color: context.colorScheme.onSurface,
          ),
        ),
      );
}