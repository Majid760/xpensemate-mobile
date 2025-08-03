import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {

  const CustomTextFormField({
    super.key,
    required this.labelText,
    this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.validator,
    this.controller,
    this.suffixIcon,
    this.prefixIcon,
    this.autofocus = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.showCounter = false,
    this.readOnly = false,
    this.onTap,
    this.expands = false,
    this.textCapitalization = TextCapitalization.none,
    this.focusNode,
    this.initialValue,
    this.filled = true,
    this.fillColor,
    this.border,
    this.contentPadding,
    this.isDense = true,
    this.errorText,
    this.helperText,
    this.autovalidateMode = false,
    this.autocorrect = true,
    this.enableSuggestions = true,
  });
  final String labelText;
  final String? hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final TextEditingController? controller;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool autofocus;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool showCounter;
  final bool readOnly;
  final VoidCallback? onTap;
  final bool expands;
  final TextCapitalization textCapitalization;
  final FocusNode? focusNode;
  final String? initialValue;
  final bool filled;
  final Color? fillColor;
  final InputBorder? border;
  final EdgeInsetsGeometry? contentPadding;
  final bool isDense;
  final String? errorText;
  final String? helperText;
  final bool autovalidateMode;
  final bool autocorrect;
  final bool enableSuggestions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: theme.textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onChanged: onChanged,
          validator: validator,
          autofocus: autofocus,
          enabled: enabled,
          maxLines: maxLines,
          minLines: minLines,
          maxLength: maxLength,
          readOnly: readOnly,
          onTap: onTap,
          expands: expands,
          textCapitalization: textCapitalization,
          focusNode: focusNode,
          initialValue: initialValue,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: enabled ? colorScheme.onSurface : colorScheme.onSurface.withValues(alpha: 0.38),
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,
            filled: filled,
            fillColor: fillColor ?? colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            border: border ??
                OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
            enabledBorder: border ??
                OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colorScheme.error,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colorScheme.error,
                width: 2,
              ),
            ),
            contentPadding: contentPadding ??
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            isDense: isDense,
            errorText: errorText,
            helperText: helperText,
            counterText: showCounter ? null : '',
            errorStyle: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.error,
            ),
            helperStyle: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          autovalidateMode:
              autovalidateMode ? AutovalidateMode.onUserInteraction : null,
          autocorrect: autocorrect,
          enableSuggestions: enableSuggestions,
        ),
      ],
    );
  }
}
