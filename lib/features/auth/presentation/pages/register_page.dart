import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/route/utils/router_extension.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/utils/app_utils.dart';
import 'package:xpensemate/core/widget/app_button.dart';
import 'package:xpensemate/core/widget/app_dialogs.dart';
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

// ─────────────────────────────────────────────────────────────────────────────
// RegisterPage
//
// Architecture mirrors LoginPage exactly:
//   • Same Stack(BackgroundDecoration, SafeArea) shell
//   • Same SingleChildScrollView + ConstrainedBox + IntrinsicHeight pattern
//   • Same FadeTransition + SlideTransition entrance
//   • Same shared widgets: BrandMark, FormCard, FieldLabel
//   • Private helpers (_OrDivider) match LoginPage naming convention
//   • All strings via context.l10n — no hardcoded English
//   • All colors via context.primaryColor / colorScheme — no hardcoded hex
// ─────────────────────────────────────────────────────────────────────────────
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  // ── Form ──────────────────────────────────────────────────────────────────
  late final FormGroup _form;

  // ── Animation ─────────────────────────────────────────────────────────────
  late final AnimationController _animController;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  // ── Derived helper — avoids repeated casts throughout ─────────────────────
  String get _email =>
      (_form.control('email').value as String?)?.trim().toLowerCase() ?? '';

  // ─────────────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();

    _form = FormGroup(
      {
        'name': FormControl<String>(
          validators: [Validators.required],
        ),
        'email': FormControl<String>(
          validators: [Validators.required, Validators.email],
        ),
        'password': FormControl<String>(
          validators: [Validators.required, Validators.minLength(8)],
        ),
        'confirmPassword': FormControl<String>(
          validators: [Validators.required],
        ),
      },
      validators: [
        Validators.mustMatch('password', 'confirmPassword'),
      ],
    );

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

    await context.read<AuthCubit>().registerWithEmail(
          email: _email,
          password:
              (_form.control('password').value as String?)?.trim() ?? '',
          fullName:
              (_form.control('name').value as String?)?.trim() ?? '',
        );
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
            AppDialogs.showTopSnackBar(
              context,
              message: context.l10n.registerSuccess,
              type: MessageType.info,
            );
            context.goToVerifyEmail(email: _email);
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
                            child: ReactiveForm(
                              formGroup: _form,
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.stretch,
                                children: [
                                  const SizedBox(height: 48),

                                  // ── Brand ───────────────────────────
                                  BrandMark(isDark: isDark),

                                  const SizedBox(height: 28),

                                  // ── Headline ─────────────────────────
                                  Text(
                                    context.l10n.createAccount,
                                    textAlign: TextAlign.center,
                                    style: context.textTheme.headlineMedium
                                        ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: primary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    context.l10n
                                        .startTrackingYourFinancesSmarter,
                                    textAlign: TextAlign.center,
                                    style: context.textTheme.bodyMedium
                                        ?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                      letterSpacing: 0.1,
                                    ),
                                  ),

                                  const SizedBox(height: 28),

                                  // ── Form card ────────────────────────
                                  FormCard(
                                    isDark: isDark,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        // Full name
                                        FieldLabel(
                                          label: context.l10n.fullName,
                                        ),
                                        const SizedBox(height: 6),
                                        ReactiveAppField(
                                          formControlName: 'name',
                                          hintText: context.l10n.hintName,
                                          textInputAction:
                                              TextInputAction.next,
                                          prefixIcon: Icon(
                                            Icons.person_outline_rounded,
                                            size: 18,
                                            color: primary.withValues(
                                              alpha: 0.7,
                                            ),
                                          ),
                                          validationMessages: {
                                            'required': (_) =>
                                                context.l10n.nameIsRequired,
                                          },
                                        ),

                                        const SizedBox(height: 16),

                                        // Email
                                        FieldLabel(
                                          label: context.l10n.emailAddress,
                                        ),
                                        const SizedBox(height: 6),
                                        ReactiveAppField(
                                          formControlName: 'email',
                                          fieldType: FieldType.email,
                                          hintText: context.l10n.hintEmail,
                                          textInputAction:
                                              TextInputAction.next,
                                          prefixIcon: Icon(
                                            Icons.email_outlined,
                                            size: 18,
                                            color: primary.withValues(
                                              alpha: 0.7,
                                            ),
                                          ),
                                          validationMessages: {
                                            'required': (_) =>
                                                context.l10n.emailRequired,
                                            'email': (_) =>
                                                context.l10n.invalidEmail,
                                          },
                                        ),

                                        const SizedBox(height: 16),

                                        // Password
                                        FieldLabel(
                                          label: context.l10n.password,
                                        ),
                                        const SizedBox(height: 6),
                                        ReactiveAppField(
                                          formControlName: 'password',
                                          fieldType: FieldType.password,
                                          hintText: context.l10n.hintPassword,
                                          textInputAction:
                                              TextInputAction.next,
                                          prefixIcon: Icon(
                                            Icons.lock_outline,
                                            size: 18,
                                            color: primary.withValues(
                                              alpha: 0.7,
                                            ),
                                          ),
                                          validationMessages: {
                                            'required': (_) =>
                                                context.l10n.passwordRequired,
                                            'minLength': (_) =>
                                                context.l10n.passwordTooShort,
                                          },
                                        ),

                                        const SizedBox(height: 16),

                                        // Confirm password
                                        FieldLabel(
                                          label: context.l10n.confirmPassword,
                                        ),
                                        const SizedBox(height: 6),
                                        ReactiveAppField(
                                          formControlName: 'confirmPassword',
                                          fieldType: FieldType.password,
                                          hintText:
                                              context.l10n.hintConfirmPassword,
                                          textInputAction:
                                              TextInputAction.done,
                                          prefixIcon: Icon(
                                            Icons.lock_outline,
                                            size: 18,
                                            color: primary.withValues(
                                              alpha: 0.7,
                                            ),
                                          ),
                                          validationMessages: {
                                            'required': (_) => context
                                                .l10n.confirmPasswordRequired,
                                            'mustMatch': (_) => context
                                                .l10n.passwordsDoNotMatch,
                                          },
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  // ── Register CTA ─────────────────────
                                  BlocBuilder<AuthCubit, AuthState>(
                                    buildWhen: (p, c) =>
                                        p is AuthLoading || c is AuthLoading,
                                    builder: (context, state) =>
                                        AppButton.primary(
                                      text: context.l10n.createAccount,
                                      isLoading: state is AuthLoading,
                                      onPressed: state is AuthLoading
                                          ? null
                                          : () => AppUtils.throttle(
                                                _submitForm,
                                              ),
                                    ),
                                  ),

                                  const SizedBox(height: 24),

                                  // ── Social divider ────────────────────
                                  OrDivider(scheme: scheme),

                                  const SizedBox(height: 20),

                                  // ── Social buttons ────────────────────
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

                                  // ── Sign-in link ──────────────────────
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
                                          context.l10n.alreadyHaveAccount,
                                          style: context
                                              .textTheme.bodyMedium
                                              ?.copyWith(
                                            color: scheme.onSurfaceVariant,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        GestureDetector(
                                          onTap: context.pop,
                                          child: Text(
                                            context.l10n.signIn,
                                            style: context
                                                .textTheme.bodyMedium
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
            ),
          ],
        ),
      ),
    );
  }
}

