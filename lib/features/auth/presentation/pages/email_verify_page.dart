import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({
    super.key,
    required this.email,
  });

  final String email;

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onResendPressed(BuildContext context) {
    // context.read<AuthCubit>().sed(
    //       email: widget.email,
    //     );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: BlocListener<AuthCubit, AuthState>(
          listenWhen: (_, state) =>
              state is AuthError || state is AuthAuthenticated,
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              AppDialogs.showTopSnackBar(
                context,
                message:
                    '${context.l10n.verificationEmailSentTo} ${widget.email}',
                type: MessageType.success,
              );
            }

            if (state is AuthError) {
              AppSnackBar.show(
                context: context,
                message: state.message,
                type: SnackBarType.error,
              );
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Spacer(),
                          AppImage.asset(
                            AssetPaths.logo,
                            height: 64,
                            color: context.primaryColor,
                          ),
                          SizedBox(height: context.xxl),
                          Text(
                            context.l10n.verifyYourEmail,
                            style: context.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.onSurfaceColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: context.lg),
                          ScaleTransition(
                            scale: _animation,
                            child: Icon(
                              Icons.mark_email_read_outlined,
                              size: 120,
                              color: context.primaryColor,
                            ),
                          ),
                          SizedBox(height: context.xl),
                          Text(
                            '${context.l10n.verificationEmailSentTo} ${widget.email}',
                            style: context.bodyLarge?.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: context.md),
                          Text(
                            context.l10n.verificationInstructions,
                            style: context.bodyMedium?.copyWith(
                              color: context.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const Spacer(),
                          BlocBuilder<AuthCubit, AuthState>(
                            buildWhen: (_, state) => state is AuthLoading,
                            builder: (context, state) {
                              final isLoading = state is AuthLoading;
                              return AppButton.primary(
                                onPressed: isLoading
                                    ? null
                                    : () => _onResendPressed(context),
                                text: context.l10n.resendVerificationEmail,
                                isLoading: isLoading,
                                textColor: context.onPrimaryColor,
                              );
                            },
                          ),
                          SizedBox(height: context.md),
                          AppButton.outline(
                            onPressed: () => context.goToLogin(),
                            text: context.l10n.backToLogin,
                          ),
                          SizedBox(height: context.lg),
                        ],
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
