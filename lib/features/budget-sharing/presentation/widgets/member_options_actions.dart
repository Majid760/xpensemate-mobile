import 'package:flutter/material.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/app_spacing.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/widget/app_button.dart';

/// "Save changes" and "Revoke access" action buttons for the member options sheet.
class MemberOptionsActions extends StatelessWidget {
  const MemberOptionsActions({
    super.key,
    required this.onSave,
    required this.onRevoke,
    this.isSaving = false,
  });

  final VoidCallback onSave;
  final VoidCallback onRevoke;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Save changes button
        AppButton.outline(
          text: context.l10n.saveChanges2,
          isLoading: isSaving,
          backgroundColor: scheme.primaryContainer.withValues(alpha: 0.6),
          borderColor: scheme.primary,
          textColor: scheme.primary,
          onPressed: onSave,
        ),
        const SizedBox(height: AppSpacing.sm1),
        // Revoke access button
        AppButton.outline(
          text: context.l10n.revokeAccess,
          backgroundColor: scheme.errorContainer.withValues(alpha: 0.6),
          borderColor: scheme.error,
          textColor: scheme.error,
          onPressed: onRevoke,
        ),
      ],
    );
  }
}

class _ActionButton extends StatefulWidget {
  const _ActionButton({
    required this.label,
    required this.onPressed,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final bool isLoading;

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) => GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        height: 52,
        decoration: BoxDecoration(
          color: _isPressed
              ? widget.backgroundColor.withValues(alpha: 0.8)
              : widget.backgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: widget.borderColor),
        ),
        alignment: Alignment.center,
        child: widget.isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: widget.textColor,
                ),
              )
            : Text(
                widget.label,
                style: context.textTheme.labelLarge?.copyWith(
                  color: widget.textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
}
