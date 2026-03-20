import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/route/utils/router_extension.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/utils/app_utils.dart';
import 'package:xpensemate/core/widget/app_button.dart';
import 'package:xpensemate/core/widget/app_snackbar.dart';
import 'package:xpensemate/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:xpensemate/features/auth/presentation/cubit/auth_state.dart';
import 'package:xpensemate/features/auth/presentation/widgets/background_decoration_widget.dart';
import 'package:xpensemate/features/auth/presentation/widgets/brand_mark_widget.dart';
import 'package:xpensemate/features/auth/presentation/widgets/custom_text_form_field.dart';
import 'package:xpensemate/features/auth/presentation/widgets/diver_widget.dart';
import 'package:xpensemate/features/auth/presentation/widgets/feel_card_widget.dart';
import 'package:xpensemate/features/auth/presentation/widgets/feild_lable_widget.dart';
import 'package:xpensemate/features/auth/presentation/widgets/social_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late final FormGroup _form;
  late final AnimationController _animController;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();

    _form = FormGroup({
      'email': FormControl<String>(
        validators: [Validators.required, Validators.email],
      ),
      'password': FormControl<String>(
        validators: [Validators.required, Validators.minLength(6)],
      ),
    });

    // Entrance animation — staggered fade + slide
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
    _form.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    _form.markAllAsTouched();
    if (!_form.valid) return;

    final email = (_form.control('email').value as String).trim();
    final password = _form.control('password').value as String;

    await context.read<AuthCubit>().loginWithEmail(
          email: email,
          password: password,
        );
  }

  Future<void> _biometricLogin() async {
    await context.read<AuthCubit>().loginWithBiometrics();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Brand tokens
    final primary = context.primaryColor;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: BlocListener<AuthCubit, AuthState>(
        listenWhen: (_, s) => s is AuthError || s is AuthAuthenticated,
        listener: (context, state) {
          if (state is AuthError) {
            AppSnackBar.show(
              context: context,
              message: state.message,
              type: SnackBarType.error,
            );
          }
          if (state is AuthAuthenticated) context.goToHome();
        },
        child: Stack(
          children: [
            // ── Decorative background geometry ──────────────────────────
            BackgroundDecoration(isDark: isDark),

            // ── Main content ────────────────────────────────────────────
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
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: ReactiveForm(
                              formGroup: _form,
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.stretch,
                                children: [
                                  const SizedBox(height: 48),

                                  // ── Brand mark ──────────────────────
                                  BrandMark(isDark: isDark),

                                  const SizedBox(height: 36),

                                  // ── Headline ────────────────────────
                                  Text(
                                    context.l10n.welcomeBack,
                                    textAlign: TextAlign.center,
                                    style: context.textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: context.primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    context.l10n.signInToYourFinancialWorkspace,
                                    textAlign: TextAlign.center,
                                    style: context.textTheme.bodyMedium?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                      letterSpacing: 0.1,
                                    ),
                                  ),

                                  const SizedBox(height: 36),
                                  // ── Form card ───────────────────────
                                  FormCard(
                                    isDark: isDark,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        // Email
                                        FieldLabel(label: context.l10n.emailAddress),
                                        const SizedBox(height: 6),
                                        ReactiveAppField(
                                          formControlName: 'email',
                                          fieldType: FieldType.email,
                                          hintText: context.l10n.hintEmail,
                                          prefixIcon: Icon(
                                            Icons.email_outlined,
                                            size: 18,
                                            color: primary.withValues(
                                                alpha: 0.7,),
                                          ),
                                          validationMessages: {
                                            'required': (_) =>
                                                context.l10n.emailRequired,
                                            'email': (_) =>
                                                context.l10n.invalidEmail,
                                          },
                                        ),
                                        const SizedBox(height: 18),
                                        // Password
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            FieldLabel(
                                                label: context.l10n.password,),
                                            GestureDetector(
                                              onTap:
                                                  context.pushForgotPasword,
                                              child: Text(
                                                context.l10n.forgotPassword,
                                                style: context.textTheme.labelMedium?.copyWith(
                                                  color: primary,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        ReactiveAppField(
                                          formControlName: 'password',
                                          fieldType: FieldType.password,
                                          hintText: context.l10n.hintPassword,
                                          prefixIcon: Icon(
                                            Icons.lock_outline,
                                            size: 18,
                                            color: primary.withValues(
                                                alpha: 0.7,),
                                          ),
                                          validationMessages: {
                                            'required': (_) =>
                                                context.l10n.passwordRequired,
                                            'minLength': (_) =>
                                                context.l10n.passwordTooShort,
                                          },
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  // ── Primary Button─────────────────────
                                  BlocBuilder<AuthCubit, AuthState>(
                                    buildWhen: (p, c) =>
                                        p is AuthLoading ||
                                        c is AuthLoading,
                                    builder: (context, state) =>
                                     AppButton.primary(
                                      text: context.l10n.signIn,
                                      isLoading: state is AuthLoading,
                                      onPressed: () =>
                                          AppUtils.throttle(_submit),
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  // ── Biometric login ──────────────────
                                  _BiometricSection(
                                    onBiometricTap: _biometricLogin,
                                    isDark: isDark,
                                  ),

                                  const SizedBox(height: 24),

                                  // ── Divider ─────────────────────────
                                  OrDivider(scheme: scheme),

                                  const SizedBox(height: 20),

                                  // ── Social buttons ───────────────────
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      SocialButton.google(onPressed: () {}),
                                      const SizedBox(width: 16),
                                      if (Platform.isIOS)
                                        SocialButton.apple(onPressed: () {}),
                                    ],
                                  ),

                                  const Spacer(),

                                  // ── Register link ────────────────────
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 24, top: 20,),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          context.l10n.dontHaveAccount,
                                          style: context.textTheme.bodyMedium?.copyWith(
                                            color: scheme.onSurfaceVariant,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        GestureDetector(
                                          onTap: context.pushRegister,
                                          child: Text(
                                            context.l10n.createOne,
                                            style: context.textTheme.bodyMedium?.copyWith(
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
            ),
          ],
        ),
      ),
    );
  }
}


/// Biometric section with fingerprint + face id options
class _BiometricSection extends StatelessWidget {
  const _BiometricSection({
    required this.onBiometricTap,
    required this.isDark,
  });
  final VoidCallback onBiometricTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) => Column(
      children: [
        // Label
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
                'or sign in instantly',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
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

        // Biometric button
        GestureDetector(
          onTap: onBiometricTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
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
                  // Show face ID icon on iOS, fingerprint on Android
                  Platform.isIOS
                      ? Icons.face_unlock_outlined
                      : Icons.fingerprint,
                  size: 22,
                  color: context.primaryColor,
                ),
                const SizedBox(width: 10),
                Text(
                  Platform.isIOS
                      ? 'Sign in with Face ID'
                      : 'Sign in with fingerprint',
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


