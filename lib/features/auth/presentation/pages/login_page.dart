import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/route/utils/router_extension.dart';
import 'package:xpensemate/core/theme/app_spacing.dart';
import 'package:xpensemate/core/utils/app_logger.dart';
import 'package:xpensemate/core/utils/app_utils.dart';
import 'package:xpensemate/core/utils/assset_path.dart';
import 'package:xpensemate/core/widget/app_button.dart';
import 'package:xpensemate/core/widget/app_image.dart';
import 'package:xpensemate/core/widget/app_snackbar.dart';
import 'package:xpensemate/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:xpensemate/features/auth/presentation/cubit/auth_state.dart';
import 'package:xpensemate/features/auth/presentation/widgets/custom_text_form_field.dart';
import 'package:xpensemate/features/auth/presentation/widgets/social_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final FormGroup _form;

  @override
  void initState() {
    super.initState();
    _form = FormGroup({
      'email': FormControl<String>(
        validators: [
          Validators.required,
          Validators.email,
        ],
      ),
      'password': FormControl<String>(
        validators: [
          Validators.required,
          Validators.minLength(6),
          //special character including
        ],
      ),
    });
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    // Mark all fields as touched to trigger validation display
    _form.markAllAsTouched();
    // Check if form is valid
    if (!_form.valid) return;

    // Form is valid, proceed with login
    await context.read<AuthCubit>().loginWithEmail(
          email: (_form.control('email').value as String?)?.trim() ?? '',
          password: _form.control('password').value as String? ?? '',
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.state == AuthStates.error &&
              state.errorMessage != null &&
              state.errorMessage!.isNotEmpty) {
            AppLogger.e(state.stackTrace.toString());

            AppSnackBar.show(
              context: context,
              message: state.errorMessage ?? l10n.errorGeneric,
              type: SnackBarType.error,
            );
          } else if (state.state == AuthStates.loaded) {
            context.goToHome();
          }
        },
        builder: (context, state) => SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: ReactiveForm(
                      formGroup: _form,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Logo and Welcome Text
                          const SizedBox(height: AppSpacing.lg),
                          AppImage.asset(
                            AssetPaths.logo,
                            height: 64,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            l10n.welcomeBack,
                            style: textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: AppSpacing.xl),
                          // Email Field
                          ReactiveAppField(
                            formControlName: 'email',
                            labelText: l10n.email,
                            fieldType: FieldType.email,
                            hintText: l10n.hintEmail,
                            textInputAction: TextInputAction.next,
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.6),
                            ),
                            validationMessages: {
                              'required': (error) => l10n.emailRequired,
                              'email': (error) => l10n.invalidEmail,
                            },
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          // Password Field
                          ReactiveAppField(
                            formControlName: 'password',
                            labelText: l10n.password,
                            fieldType: FieldType.password,
                            hintText: l10n.hintPassword,
                            textInputAction: TextInputAction.done,
                            prefixIcon: Icon(
                              Icons.lock_outline_rounded,
                              color: colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.6),
                            ),
                            validationMessages: {
                              'required': (error) => l10n.passwordRequired,
                              'minLength': (error) => l10n.passwordTooShort,
                            },
                          ),
                          const SizedBox(height: AppSpacing.sm),

                          // Forgot Password
                          Align(
                            alignment: Alignment.centerRight,
                            child: AppButton.textButton(
                              text: l10n.forgotPassword,
                              textColor: colorScheme.primary,
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                context.pushForgotPasword();
                              },
                            ),
                          ),

                          const SizedBox(height: AppSpacing.md1),

                          // Sign In Button
                          AppButton.primary(
                            text: l10n.login.toUpperCase(),
                            onPressed: () => AppUtils.throttle(_submitForm),
                            textColor: colorScheme.onPrimary,
                            isLoading: state.state == AuthStates.loading,
                          ),

                          const SizedBox(height: AppSpacing.lg),
                          // Divider with "or"
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: colorScheme.outlineVariant,
                                  thickness: 1,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                ),
                                child: Text(
                                  l10n.or,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: colorScheme.outlineVariant,
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          // Social Login Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Google Button
                              SocialButton.google(
                                onPressed: () {
                                  // context.read<AuthCubit>().loginWithGoogle();
                                },
                              ),
                              const SizedBox(width: 16),
                              // Apple Button
                              if (Platform.isIOS)
                                SocialButton.apple(
                                  onPressed: () {
                                    // context.read<AuthCubit>().loginWithApple();
                                  },
                                ),
                            ],
                          ),
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.baseUnit,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  l10n.dontHaveAccount,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                AppButton.textButton(
                                  text: l10n.register,
                                  textColor: colorScheme.primary,
                                  onPressed: () {
                                    context.pushRegister();
                                  },
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
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
    );
  }
}
