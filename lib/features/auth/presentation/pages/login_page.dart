import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reactive_forms/reactive_forms.dart';

import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/route/utils/router_extension.dart';
import 'package:xpensemate/core/theme/app_spacing.dart';
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
        validators: [Validators.required, Validators.email],
      ),
      'password': FormControl<String>(
        validators: [Validators.required, Validators.minLength(6)],
      ),
    });
  }

  @override
  void dispose() {
    _form.dispose();
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
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
          }
          if (state is AuthAuthenticated) {
            context.goToHome();
          }
        },
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: ReactiveForm(
                      formGroup: _form,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: AppSpacing.lg),
                          AppImage.asset(
                            AssetPaths.logo,
                            height: 64,
                            color: colors.primary,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            l10n.welcomeBack,
                            textAlign: TextAlign.center,
                            style: textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          ReactiveAppField(
                            formControlName: 'email',
                            labelText: l10n.email,
                            fieldType: FieldType.email,
                            hintText: l10n.hintEmail,
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: colors.onSurfaceVariant
                                  .withValues(alpha: 0.6),
                            ),
                            validationMessages: {
                              'required': (_) => l10n.emailRequired,
                              'email': (_) => l10n.invalidEmail,
                            },
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          ReactiveAppField(
                            formControlName: 'password',
                            labelText: l10n.password,
                            fieldType: FieldType.password,
                            hintText: l10n.hintPassword,
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: colors.onSurfaceVariant
                                  .withValues(alpha: 0.6),
                            ),
                            validationMessages: {
                              'required': (_) => l10n.passwordRequired,
                              'minLength': (_) => l10n.passwordTooShort,
                            },
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Align(
                            alignment: Alignment.centerRight,
                            child: AppButton.textButton(
                              text: l10n.forgotPassword,
                              onPressed: context.pushForgotPasword,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          BlocBuilder<AuthCubit, AuthState>(
                            buildWhen: (previous, current) =>
                                previous is AuthLoading ||
                                current is AuthLoading,
                            builder: (context, state) => AppButton.primary(
                              text: l10n.login.toUpperCase(),
                              isLoading: state is AuthLoading,
                              onPressed: () => AppUtils.throttle(_submit),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Row(
                            children: [
                              Expanded(
                                child: Divider(color: colors.outlineVariant),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                ),
                                child: Text(l10n.or),
                              ),
                              Expanded(
                                child: Divider(color: colors.outlineVariant),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SocialButton.google(onPressed: () {}),
                              const SizedBox(width: 16),
                              if (Platform.isIOS)
                                SocialButton.apple(onPressed: () {}),
                            ],
                          ),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(l10n.dontHaveAccount),
                              const SizedBox(width: AppSpacing.xs),
                              AppButton.textButton(
                                text: l10n.register,
                                onPressed: context.pushRegister,
                              ),
                            ],
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
