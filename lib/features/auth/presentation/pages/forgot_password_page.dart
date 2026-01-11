import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';

import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/utils/assset_path.dart';
import 'package:xpensemate/core/widget/app_button.dart';
import 'package:xpensemate/core/widget/app_image.dart';
import 'package:xpensemate/core/widget/app_snackbar.dart';
import 'package:xpensemate/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:xpensemate/features/auth/presentation/cubit/auth_state.dart';
import 'package:xpensemate/features/auth/presentation/widgets/custom_text_form_field.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
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
    });
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_form.valid) {
      await context.read<AuthCubit>().forgotPassword(
            email: (_form.control('email').value as String?)?.trim() ?? '',
          );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => context.pop(),
          ),
        ),
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
              AppSnackBar.show(
                context: context,
                message: context.l10n.resetPasswordSuccess,
                type: SnackBarType.success,
              );
              final currentContext = context;
              Future.delayed(const Duration(seconds: 2), () {
                if (mounted) {
                  currentContext.pop();
                }
              });
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
                            const Spacer(),
                            AppImage.asset(
                              AssetPaths.logo,
                              height: 72,
                              color: context.primaryColor,
                            ),
                            SizedBox(height: context.xxxl),
                            Text(
                              context.l10n.forgotPasswordTitle,
                              style: context.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: context.onSurfaceColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: context.md),
                            Text(
                              context.l10n.forgotPasswordSubtitle,
                              style: context.bodyMedium?.copyWith(
                                color: context.colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: context.xxl),

                            // Email Field
                            ReactiveAppField(
                              formControlName: 'email',
                              labelText: context.l10n.email,
                              fieldType: FieldType.email,
                              hintText: context.l10n.hintEmail,
                              textInputAction: TextInputAction.done,
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
                            SizedBox(height: context.xxl),

                            // Reset Password Button
                            BlocBuilder<AuthCubit, AuthState>(
                              buildWhen: (_, state) => state is AuthLoading,
                              builder: (context, state) {
                                final isLoading = state is AuthLoading;
                                return AppButton.primary(
                                  onPressed: isLoading ? null : _submitForm,
                                  text: context.l10n.resetPassword,
                                  isLoading: isLoading,
                                  textColor: context.onPrimaryColor,
                                );
                              },
                            ),
                            const Spacer(),

                            // Back to Login
                            Padding(
                              padding: EdgeInsets.only(bottom: context.xxl),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    context.l10n.rememberPassword,
                                    style: context.bodyMedium?.copyWith(
                                      color:
                                          context.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
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
