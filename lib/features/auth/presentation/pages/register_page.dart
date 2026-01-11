import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/route/utils/router_extension.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/utils/assset_path.dart';
import 'package:xpensemate/core/widget/app_button.dart';
import 'package:xpensemate/core/widget/app_dialogs.dart';
import 'package:xpensemate/core/widget/app_image.dart';
import 'package:xpensemate/core/widget/app_snackbar.dart';
import 'package:xpensemate/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:xpensemate/features/auth/presentation/cubit/auth_state.dart';
import 'package:xpensemate/features/auth/presentation/widgets/custom_text_form_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late final FormGroup _form;

  @override
  void initState() {
    super.initState();
    _form = FormGroup(
      {
        'name': FormControl<String>(
          validators: [
            Validators.required,
          ],
        ),
        'email': FormControl<String>(
          validators: [
            Validators.required,
            Validators.email,
          ],
        ),
        'password': FormControl<String>(
          validators: [
            Validators.required,
            Validators.minLength(8),
          ],
        ),
        'confirmPassword': FormControl<String>(
          validators: [
            Validators.required,
          ],
        ),
      },
      validators: [
        Validators.mustMatch('password', 'confirmPassword'),
      ],
    );
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    _form.markAllAsTouched();
    // Check if form is valid
    if (!_form.valid) return;

    await context.read<AuthCubit>().registerWithEmail(
          email: (_form.control('email').value as String?)?.trim() ?? '',
          password: (_form.control('password').value as String?)?.trim() ?? '',
          fullName: (_form.control('name').value as String?)?.trim() ?? '',
        );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
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
            } else if (state is AuthUnauthenticated) {
              AppDialogs.showTopSnackBar(
                context,
                message: context.l10n.registerSuccess,
                type: MessageType.info,
              );
              context.goToVerifyEmail(
                email: (_form.control('email').value as String?)
                        ?.trim()
                        .toLowerCase() ??
                    '',
              );
            }
          },
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: EdgeInsets.all(context.md),
                      child: ReactiveForm(
                        formGroup: _form,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Logo and Welcome Text
                            SizedBox(height: context.xl),
                            AppImage.asset(
                              AssetPaths.logo,
                              height: 64,
                              color: context.primaryColor,
                            ),
                            SizedBox(height: context.lg),
                            Text(
                              context.l10n.registerNow,
                              style: context.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: context.onSurfaceColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: context.xl),

                            // Name Field
                            ReactiveAppField(
                              formControlName: 'name',
                              labelText: context.l10n.name,
                              hintText: context.l10n.hintName,
                              textInputAction: TextInputAction.next,
                              prefixIcon: Icon(
                                Icons.person_outline_rounded,
                                color: context.colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.6),
                              ),
                              validationMessages: {
                                'required': (error) =>
                                    context.l10n.nameIsRequired,
                              },
                            ),
                            SizedBox(height: context.lg),

                            // Email Field
                            ReactiveAppField(
                              formControlName: 'email',
                              labelText: context.l10n.email,
                              fieldType: FieldType.email,
                              hintText: context.l10n.hintEmail,
                              textInputAction: TextInputAction.next,
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: context.colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.6),
                              ),
                              validationMessages: {
                                'required': (error) =>
                                    context.l10n.emailRequired,
                                'email': (error) => context.l10n.invalidEmail,
                              },
                            ),
                            SizedBox(height: context.lg),

                            // Password Field
                            ReactiveAppField(
                              formControlName: 'password',
                              labelText: context.l10n.password,
                              fieldType: FieldType.password,
                              hintText: context.l10n.hintPassword,
                              textInputAction: TextInputAction.next,
                              prefixIcon: Icon(
                                Icons.lock_outline_rounded,
                                color: context.colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.6),
                              ),
                              validationMessages: {
                                'required': (error) =>
                                    context.l10n.passwordRequired,
                                'minLength': (error) =>
                                    context.l10n.passwordTooShort,
                              },
                            ),
                            SizedBox(height: context.lg),

                            // Confirm Password Field
                            ReactiveAppField(
                              formControlName: 'confirmPassword',
                              labelText: context.l10n.confirmPassword,
                              fieldType: FieldType.password,
                              hintText: context.l10n.hintConfirmPassword,
                              textInputAction: TextInputAction.done,
                              prefixIcon: Icon(
                                Icons.lock_outline_rounded,
                                color: context.colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.6),
                              ),
                              validationMessages: {
                                'required': (error) =>
                                    context.l10n.confirmPasswordRequired,
                                'passwordMismatch': (error) =>
                                    context.l10n.passwordsDoNotMatch,
                                'mustMatch': (error) =>
                                    context.l10n.passwordsDoNotMatch,
                              },
                            ),
                            SizedBox(height: context.xxl),
                            // Register Button
                            BlocBuilder<AuthCubit, AuthState>(
                              buildWhen: (_, state) => state is AuthLoading,
                              builder: (context, state) {
                                final isLoading = state is AuthLoading;
                                return AppButton.primary(
                                  onPressed: isLoading ? null : _submitForm,
                                  text: context.l10n.register.toUpperCase(),
                                  textColor: context.onPrimaryColor,
                                  isLoading: isLoading,
                                );
                              },
                            ),

                            const Spacer(),

                            // Already have an account? Login
                            Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: context.xxl,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    context.l10n.alreadyHaveAccount,
                                    style: context.bodyMedium?.copyWith(
                                      color:
                                          context.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  SizedBox(width: context.xs),
                                  AppButton.textButton(
                                    onPressed: () => context.pop(),
                                    text: context.l10n.login,
                                    textColor: context.primaryColor,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: context.sm,
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
