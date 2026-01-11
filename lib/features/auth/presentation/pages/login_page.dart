import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reactive_forms/reactive_forms.dart';

import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/route/utils/router_extension.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
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
  Widget build(BuildContext context) => Scaffold(
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
                      padding: EdgeInsets.all(context.md),
                      child: ReactiveForm(
                        formGroup: _form,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: context.lg),
                            AppImage.asset(
                              AssetPaths.logo,
                              height: 64,
                              color: context.primaryColor,
                            ),
                            SizedBox(height: context.lg),
                            Text(
                              context.l10n.welcomeBack,
                              textAlign: TextAlign.center,
                              style: context.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: context.xl),
                            ReactiveAppField(
                              formControlName: 'email',
                              labelText: context.l10n.email,
                              fieldType: FieldType.email,
                              hintText: context.l10n.hintEmail,
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: context.colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.6),
                              ),
                              validationMessages: {
                                'required': (_) => context.l10n.emailRequired,
                                'email': (_) => context.l10n.invalidEmail,
                              },
                            ),
                            SizedBox(height: context.lg),
                            ReactiveAppField(
                              formControlName: 'password',
                              labelText: context.l10n.password,
                              fieldType: FieldType.password,
                              hintText: context.l10n.hintPassword,
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: context.colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.6),
                              ),
                              validationMessages: {
                                'required': (_) =>
                                    context.l10n.passwordRequired,
                                'minLength': (_) =>
                                    context.l10n.passwordTooShort,
                              },
                            ),
                            SizedBox(height: context.sm),
                            Align(
                              alignment: Alignment.centerRight,
                              child: AppButton.textButton(
                                text: context.l10n.forgotPassword,
                                textColor: context.primaryColor,
                                onPressed: context.pushForgotPasword,
                              ),
                            ),
                            SizedBox(height: context.md),
                            BlocBuilder<AuthCubit, AuthState>(
                              buildWhen: (previous, current) =>
                                  previous is AuthLoading ||
                                  current is AuthLoading,
                              builder: (context, state) => AppButton.primary(
                                text: context.l10n.login.toUpperCase(),
                                textColor: context.onPrimaryColor,
                                isLoading: state is AuthLoading,
                                onPressed: () => AppUtils.throttle(_submit),
                              ),
                            ),
                            SizedBox(height: context.lg),
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: context.outlineColor.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: context.md,
                                  ),
                                  child: Text(context.l10n.or),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: context.outlineColor.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: context.lg),
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
                                Text(context.l10n.dontHaveAccount),
                                SizedBox(width: context.xs),
                                AppButton.textButton(
                                  text: context.l10n.register,
                                  textColor: context.primaryColor,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: context.sm,
                                  ),
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
