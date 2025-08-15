import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/app_spacing.dart';
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
    _form.markAllAsTouched();

    if (!_form.valid) return;

    await context.read<AuthCubit>().forgotPassword(
          email: (_form.control('email').value as String?)?.trim() ?? '',
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.state == AuthStates.error) {
            AppSnackBar.show(
              context: context,
              message: state.errorMessage ?? l10n.errorGeneric,
              type: SnackBarType.error,
            );
          } else if (state.state == AuthStates.loaded) {
            AppSnackBar.show(
              context: context,
              message: l10n.resetPasswordSuccess,
              type: SnackBarType.success,
              duration: const Duration(seconds: 4),
            );
            final currentContext = context;
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                currentContext.pop();
              }
            });
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
                          const Spacer(),
                          AppImage.asset(
                            AssetPaths.logo,
                            height: 72,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(height: AppSpacing.xxxl),
                          Text(
                            l10n.forgotPasswordTitle,
                            style: textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            l10n.forgotPasswordSubtitle,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.xxl),

                          // Email Field
                          ReactiveAppField(
                            formControlName: 'email',
                            labelText: l10n.email,
                            fieldType: FieldType.email,
                            hintText: l10n.hintEmail,
                            textInputAction: TextInputAction.done,
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
                          const SizedBox(height: AppSpacing.xxl),

                          // Reset Password Button
                          AppButton.primary(
                            onPressed: state.state == AuthStates.loading
                                ? null
                                : _submitForm,
                            text: l10n.resetPassword,
                            isLoading: state.state == AuthStates.loading,
                            textColor: colorScheme.onPrimary,
                          ),
                          const Spacer(),

                          // Back to Login
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.xxl),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  l10n.rememberPassword,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                AppButton.textButton(
                                  onPressed: () => context.pop(),
                                  text: l10n.login,
                                  textColor: colorScheme.primary,
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
