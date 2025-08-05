import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';

import 'package:xpensemate/core/route/utils/router_extension.dart';
import 'package:xpensemate/core/theme/app_spacing.dart';
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
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

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
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ),);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
          // Handle state changes if needed
          if (state.state == AuthStates.loaded) {
            AppDialogs.showTopSnackBar(context, message: '${l10n.verificationEmailSentTo} ${widget.email}', type: MessageType.success);
          }else if (state.state == AuthStates.error) {
            AppSnackBar.show(context:context, message:state.errorMessage ?? '' ,type: SnackBarType.error);
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo and Title
                        const Spacer(),
                        AppImage.asset(
                          AssetPaths.logo,
                          height: 64,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        Text(
                          l10n.verifyYourEmail,
                          style: textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Email Illustration
                        ScaleTransition(
                          scale: _animation,
                          child: Icon(
                            Icons.mark_email_read_outlined,
                            size: 120,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        Text(
                          '${l10n.verificationEmailSentTo} ${widget.email}',
                          style: textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          l10n.verificationInstructions,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const Spacer(),

                        // Resend Button
                        AppButton.primary(
                          onPressed: () async {
                            await context.read<AuthCubit>().sendVerificationEmail(
                                  email: widget.email,
                                );
                          },
                          text: l10n.resendVerificationEmail,
                          isLoading: state.state == AuthStates.loading,
                          textColor: colorScheme.onPrimary,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        // Back to Login Button
                        AppButton.outline(
                          onPressed: () => context.goToLogin(),
                          text: l10n.backToLogin,
                        ),
                        const SizedBox(height: AppSpacing.lg),
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
}