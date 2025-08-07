import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/route/utils/router_extension.dart';
import 'package:xpensemate/core/theme/app_spacing.dart';
import 'package:xpensemate/core/utils/app_logger.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      await context.read<AuthCubit>().loginWithEmail(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
    }
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
          if (state.state == AuthStates.error) {
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
                    child: Form(
                      key: _formKey,
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
                          CustomTextFormField(
                            labelText: l10n.email,
                            hintText:
                                l10n.hintEmail, // Updated to use hintEmail
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            controller: _emailController,
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.6),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return l10n
                                    .emailRequired; // Updated to use emailRequired
                              }
                             if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                                  .hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          // Password Field
                          CustomTextFormField(
                            labelText: l10n.password,
                            hintText: l10n
                                .hintPassword, // Updated to use hintPassword
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            controller: _passwordController,
                            prefixIcon: Icon(
                              Icons.lock_outline_rounded,
                              color: colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.6),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.6),
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return l10n.passwordRequired;
                              }
                              if (value.length < 4) {
                                return l10n.passwordTooShort;
                              }
                              return null;
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
                            onPressed: _submitForm,
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
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
                          const SizedBox(height: 24),

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
                                const SizedBox(width: 4),
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
