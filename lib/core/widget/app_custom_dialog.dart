import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/widget/app_button.dart';

class AppCustomDialog extends StatefulWidget {
  const AppCustomDialog({
    super.key,
    this.title,
    this.message,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.isDestructive = true,
    this.icon,
    this.showAnimation = true,
  });

  final String? title;
  final String? message;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isDestructive;
  final IconData? icon;
  final bool showAnimation;

  @override
  State<AppCustomDialog> createState() => _AppCustomDialogState();
}

class _AppCustomDialogState extends State<AppCustomDialog>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late AnimationController _slideController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.showAnimation) {
      _initializeAnimations();
    }
  }

  @override
  void dispose() {
    if (widget.showAnimation) {
      _scaleController.dispose();
      _fadeController.dispose();
      _slideController.dispose();
    }
    super.dispose();
  }

  void _initializeAnimations() {
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.7,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Start animations
    _fadeController.forward();
    _scaleController.forward();
    _slideController.forward();
  }

  Future<void> _handleConfirm() async {
    await HapticFeedback.mediumImpact();
    if (widget.showAnimation) {
      await _scaleController.reverse();
      await _fadeController.reverse();
    }
    widget.onConfirm?.call();
    if (mounted) Navigator.of(context).pop(true);
  }

  Future<void> _handleCancel() async {
    await HapticFeedback.selectionClick();
    if (widget.showAnimation) {
      await _scaleController.reverse();
      await _fadeController.reverse();
    }
    widget.onCancel?.call();
    if (mounted) Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    final content = _DialogContent(
      title: widget.title ?? context.l10n.logout,
      message: widget.message ?? context.l10n.logoutConfirmationMessage,
      confirmText: widget.confirmText ?? context.l10n.logout,
      cancelText: widget.cancelText ?? context.l10n.cancel,
      onConfirm: widget.onConfirm != null ? _handleConfirm : null,
      onCancel: widget.onCancel != null ? _handleCancel : null,
      isDestructive: widget.isDestructive,
      icon: widget.icon ?? Icons.logout_rounded,
    );

    if (!widget.showAnimation) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: context.lg),
        child: content,
      );
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: context.lg),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: content,
          ),
        ),
      ),
    );
  }
}

class _DialogContent extends StatelessWidget {
  const _DialogContent({
    required this.title,
    required this.message,
    required this.confirmText,
    required this.cancelText,
    required this.onConfirm,
    required this.onCancel,
    required this.isDestructive,
    required this.icon,
  });

  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isDestructive;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final primary = context.primaryColor;

    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.15),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(context.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Floating icon container
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDestructive
                        ? scheme.errorContainer.withValues(alpha: 0.3)
                        : scheme.primaryContainer.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDestructive
                          ? scheme.error.withValues(alpha: 0.2)
                          : primary.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: isDestructive ? scheme.error : primary,
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),

                // Message
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // Action Buttons
                _buildActionButtons(context),
              ],
            ),
          ),
          Positioned(
            right: 8,
            top: 8,
            child: IconButton(
              onPressed: () {
                if (onCancel != null) {
                  onCancel!();
                  Navigator.of(context).pop(false);
                } else {
                  Navigator.of(context).pop();
                }
              },
              icon: Icon(
                Icons.close_rounded,
                color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
                size: 24,
              ),
              splashRadius: 20,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (onConfirm == null && onCancel == null) return const SizedBox.shrink();

    final primaryBg =
        isDestructive ? context.colorScheme.error : context.primaryColor;
    final primaryText = isDestructive
        ? context.colorScheme.onError
        : context.colorScheme.onPrimary;

    if (onConfirm != null && onCancel == null) {
      return SizedBox(
        width: double.infinity,
        child: AppButton.primary(
          text: confirmText,
          onPressed: onConfirm,
          backgroundColor: primaryBg,
          textColor: primaryText,
        ),
      );
    }

    if (onCancel != null && onConfirm == null) {
      return SizedBox(
        width: double.infinity,
        child: AppButton.primary(
          text: cancelText,
          onPressed: onCancel,
          backgroundColor: primaryBg,
          textColor: primaryText,
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: AppButton.secondary(
            text: cancelText,
            onPressed: onCancel,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AppButton.primary(
            text: confirmText,
            onPressed: onConfirm,
            backgroundColor: primaryBg,
            textColor: primaryText,
          ),
        ),
      ],
    );
  }
}

// Helper class for easy usage
class AppCustomDialogs {
  static Future<bool?> show({
    required BuildContext context,
    String? title,
    String? message,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool isDestructive = true,
    IconData? icon,
    bool showAnimation = true,
  }) =>
      showDialog<bool>(
        context: context,
        barrierColor: context.colorScheme.scrim.withValues(alpha: 0.5),
        builder: (context) => AppCustomDialog(
          title: title,
          message: message,
          confirmText: confirmText,
          cancelText: cancelText,
          onConfirm: onConfirm,
          onCancel: onCancel,
          isDestructive: isDestructive,
          icon: icon,
          showAnimation: showAnimation,
        ),
      );

  // Predefined logout dialog
  static Future<bool?> showLogout({
    required BuildContext context,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) =>
      show(
        context: context,
        title: context.l10n.logout,
        message: context.l10n.logoutConfirmationMessage,
        confirmText: context.l10n.logout,
        cancelText: context.l10n.cancel,
        onConfirm: onConfirm,
        onCancel: onCancel,
        icon: Icons.logout_rounded,
      );

  // Generic confirmation dialog
  static Future<bool?> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool isDestructive = false,
    IconData? icon,
  }) =>
      show(
        context: context,
        title: title,
        message: message,
        confirmText: confirmText ?? context.l10n.confirm,
        cancelText: cancelText ?? context.l10n.cancel,
        onConfirm: onConfirm,
        onCancel: onCancel,
        isDestructive: isDestructive,
        icon: icon ?? Icons.help_outline_rounded,
      );

  // Delete confirmation dialog
  static Future<bool?> showDelete({
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) =>
      show(
        context: context,
        title: title,
        message: message,
        confirmText: context.l10n.delete,
        cancelText: context.l10n.cancel,
        onConfirm: onConfirm,
        onCancel: onCancel,
        icon: Icons.delete_outline_rounded,
      );

  // Information dialog without action buttons
  static Future<bool?> showInfo({
    required BuildContext context,
    required String title,
    required String message,
    IconData? icon,
    bool showAnimation = true,
  }) =>
      show(
        context: context,
        title: title,
        message: message,
        isDestructive: false,
        icon: icon ?? Icons.info_outline_rounded,
        showAnimation: showAnimation,
      );

  // Single action dialog (confirm only)
  static Future<bool?> showSingleAction({
    required BuildContext context,
    required String title,
    required String message,
    required String actionText,
    required VoidCallback onAction,
    bool isDestructive = false,
    IconData? icon,
    bool showAnimation = true,
  }) =>
      show(
        context: context,
        title: title,
        message: message,
        confirmText: actionText,
        onConfirm: onAction,
        isDestructive: isDestructive,
        icon: icon ?? (isDestructive ? Icons.warning_rounded : Icons.help_outline_rounded),
        showAnimation: showAnimation,
      );

  // Dismissible dialog (cancel/close only)
  static Future<bool?> showDismissible({
    required BuildContext context,
    required String title,
    required String message,
    String? dismissText,
    VoidCallback? onDismiss,
    IconData? icon,
    bool showAnimation = true,
  }) =>
      show(
        context: context,
        title: title,
        message: message,
        cancelText: dismissText ?? context.l10n.close,
        onCancel: onDismiss,
        isDestructive: false,
        icon: icon ?? Icons.info_outline_rounded,
        showAnimation: showAnimation,
      );
}