import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';

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
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack,
    ),);

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ),);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ),);

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
      onConfirm: _handleConfirm,
      onCancel: _handleCancel,
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
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final bool isDestructive;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.shadow.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: context.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 48,
            offset: const Offset(0, 16),
          ),
        ],
        border: Border.all(
          color: context.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with icon
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(context.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDestructive
                    ? [
                        context.colorScheme.errorContainer.withValues(alpha: 0.3),
                        context.colorScheme.errorContainer.withValues(alpha: 0.5),
                      ]
                    : [
                        context.colorScheme.primaryContainer.withValues(alpha: 0.3),
                        context.colorScheme.secondaryContainer.withValues(alpha: 0.3),
                      ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isDestructive
                        ? context.colorScheme.errorContainer.withValues(alpha: 0.3)
                        : context.colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDestructive
                          ? context.colorScheme.error.withValues(alpha: 0.4)
                          : context.colorScheme.primary.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: 28,
                    color: isDestructive
                        ? context.colorScheme.error
                        : context.colorScheme.primary,
                  ),
                ),
                SizedBox(height: context.md),
                Text(
                  title,
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: context.colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.all(context.lg),
            child: Column(
              children: [
                Text(
                  message,
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: context.lg),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: _DialogButton(
                        text: cancelText,
                        onPressed: onCancel,
                        isPrimary: false,
                        isDestructive: false,
                      ),
                    ),
                    SizedBox(width: context.sm),
                    Expanded(
                      child: _DialogButton(
                        text: confirmText,
                        onPressed: onConfirm,
                        isPrimary: true,
                        isDestructive: isDestructive,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
}

class _DialogButton extends StatefulWidget {
  const _DialogButton({
    required this.text,
    required this.onPressed,
    required this.isPrimary,
    required this.isDestructive,
  });

  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool isDestructive;

  @override
  State<_DialogButton> createState() => _DialogButtonState();
}

class _DialogButtonState extends State<_DialogButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _pressController,
      curve: Curves.easeInOut,
    ),);
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    await _pressController.forward();
    await _pressController.reverse();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    Color borderColor;
    List<Color> gradientColors;

    if (widget.isPrimary) {
      if (widget.isDestructive) {
        backgroundColor = context.colorScheme.error;
        textColor = context.colorScheme.onError;
        borderColor = context.colorScheme.error;
        gradientColors = [
          context.colorScheme.error,
          context.colorScheme.error.withValues(alpha: 0.8),
        ];
      } else {
        backgroundColor = context.colorScheme.primary;
        textColor = context.colorScheme.onPrimary;
        borderColor = context.colorScheme.primary;
        gradientColors = [
          context.colorScheme.primary,
          context.colorScheme.secondary,
        ];
      }
    } else {
      backgroundColor = context.colorScheme.surface;
      textColor = context.colorScheme.onSurface;
      borderColor = context.colorScheme.outline.withValues(alpha: 0.3);
      gradientColors = [
        context.colorScheme.surface,
        context.colorScheme.surface,
      ];
    }

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) => _pressController.forward(),
        onTapUp: (_) => _pressController.reverse(),
        onTapCancel: () => _pressController.reverse(),
        onTap: _handleTap,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            gradient: widget.isPrimary
                ? LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: widget.isPrimary ? null : backgroundColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: widget.isPrimary
                ? [
                    BoxShadow(
                      color: (widget.isDestructive
                              ? context.colorScheme.error
                              : context.colorScheme.primary)
                          .withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: context.colorScheme.shadow.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Center(
            child: Text(
              widget.text,
              style: context.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: textColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
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
  }) => showDialog<bool>(
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
  }) => show(
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
  }) => show(
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
  }) => show(
      context: context,
      title: title,
      message: message,
      confirmText: context.l10n.delete,
      cancelText: context.l10n.cancel,
      onConfirm: onConfirm,
      onCancel: onCancel,
      icon: Icons.delete_outline_rounded,
    );
}