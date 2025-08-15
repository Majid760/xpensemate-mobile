import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:reactive_phone_form_field/reactive_phone_form_field.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';

enum FieldType {
  text,
  email,
  password,
  number,
  decimal,
  phone,
  textarea,
  search,
}

class ReactiveAppField extends StatefulWidget {
  const ReactiveAppField({
    super.key,
    required this.formControlName,
    required this.labelText,
    this.fieldType = FieldType.text,
    this.hintText,
    this.suffixIcon,
    this.prefixIcon,
    this.autofocus = false,
    this.maxLines,
    this.minLines,
    this.maxLength,
    this.showCounter = false,
    this.readOnly = false,
    this.onTap,
    this.textCapitalization = TextCapitalization.none,
    this.focusNode,
    this.filled = false,
    this.fillColor,
    this.border,
    this.contentPadding,
    this.isDense = true,
    this.helperText,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.validationMessages,
    this.showErrors,
    this.textInputAction,
    // Phone specific
    this.defaultCountry = 'US',
    this.priorityListByIsoCode,
    this.onCountryChanged,
  });

  final String formControlName;
  final String labelText;
  final FieldType fieldType;
  final String? hintText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool autofocus;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool showCounter;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextCapitalization textCapitalization;
  final FocusNode? focusNode;
  final bool filled;
  final Color? fillColor;
  final InputBorder? border;
  final EdgeInsetsGeometry? contentPadding;
  final bool isDense;
  final String? helperText;
  final bool autocorrect;
  final bool enableSuggestions;
  final Map<String, String Function(Object)>? validationMessages;
  final ShowErrorsFunction<dynamic>? showErrors;
  final TextInputAction? textInputAction;
  
  // Phone specific properties
  final String defaultCountry;
  final List<String>? priorityListByIsoCode;
  final ValueChanged<dynamic>? onCountryChanged;

  @override
  State<ReactiveAppField> createState() => _ReactiveAppFieldState();
}

class _ReactiveAppFieldState extends State<ReactiveAppField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.labelText,
          style: theme.textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        DecoratedBox(
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceContainer.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: context.colorScheme.primary.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: widget.fieldType == FieldType.phone 
              ? _buildPhoneField(theme, colorScheme)
              : _buildTextField(theme, colorScheme),
        ),
      ],
    );
  }

  bool get _shouldObscureText => widget.fieldType == FieldType.password && _obscureText;

  TextInputType _getKeyboardType() {
    switch (widget.fieldType) {
      case FieldType.email:
        return TextInputType.emailAddress;
      case FieldType.password:
        return TextInputType.visiblePassword;
      case FieldType.number:
        return TextInputType.number;
      case FieldType.decimal:
        return const TextInputType.numberWithOptions(decimal: true);
      case FieldType.phone:
        return TextInputType.phone;
      case FieldType.textarea:
        return TextInputType.multiline;
      case FieldType.search:
        return TextInputType.text;
      case FieldType.text:
      default:
        return TextInputType.text;
    }
  }

  TextInputAction? _getTextInputAction() {
    if (widget.textInputAction != null) {
      return widget.textInputAction;
    }
    
    switch (widget.fieldType) {
      case FieldType.textarea:
        return TextInputAction.newline;
      case FieldType.search:
        return TextInputAction.search;
      default:
        return TextInputAction.next;
    }
  }

  int? _getMaxLines() {
    if (widget.maxLines != null) {
      return widget.maxLines;
    }
    
    switch (widget.fieldType) {
      case FieldType.textarea:
        return 5;
      default:
        return 1;
    }
  }

  int? _getMinLines() {
    if (widget.minLines != null) {
      return widget.minLines;
    }
    
    switch (widget.fieldType) {
      case FieldType.textarea:
        return 3;
      default:
        return null;
    }
  }

  TextCapitalization _getTextCapitalization() {
    switch (widget.fieldType) {
      case FieldType.email:
        return TextCapitalization.none;
      case FieldType.password:
        return TextCapitalization.none;
      case FieldType.text:
        return widget.textCapitalization;
      default:
        return widget.textCapitalization;
    }
  }

  String? _getHintText() {
    if (widget.hintText != null) {
      return widget.hintText;
    }
    
    switch (widget.fieldType) {
      case FieldType.email:
        return 'Enter your email address';
      case FieldType.password:
        return 'Enter your password';
      case FieldType.phone:
        return 'Enter your phone number';
      case FieldType.search:
        return 'Search...';
      case FieldType.number:
      case FieldType.decimal:
        return 'Enter a number';
      case FieldType.textarea:
        return 'Enter your message';
      default:
        return null;
    }
  }

  Widget? _getPrefixIcon() {
    if (widget.prefixIcon != null) {
      return widget.prefixIcon;
    }
    
    switch (widget.fieldType) {
      case FieldType.email:
        return const Icon(Icons.email_outlined);
      case FieldType.password:
        return const Icon(Icons.lock_outline);
      case FieldType.phone:
        return const Icon(Icons.phone_outlined);
      case FieldType.search:
        return const Icon(Icons.search_outlined);
      default:
        return null;
    }
  }

  Widget? _getSuffixIcon() {
    if (widget.suffixIcon != null) {
      return widget.suffixIcon;
    }
    
    if (widget.fieldType == FieldType.password) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }
    
    return null;
  }

  bool _getAutocorrect() {
    switch (widget.fieldType) {
      case FieldType.email:
      case FieldType.password:
        return false;
      default:
        return widget.autocorrect;
    }
  }

  bool _getEnableSuggestions() {
    switch (widget.fieldType) {
      case FieldType.password:
        return false;
      default:
        return widget.enableSuggestions;
    }
  }

  Widget _buildPhoneField(ThemeData theme, ColorScheme colorScheme) => ReactivePhoneFormField<PhoneNumber>(
      formControlName: widget.formControlName,
      decoration: _getInputDecoration(theme, colorScheme),
      // priorityListByIsoCode: widget.priorityListByIsoCode ?? ['US', 'CA', 'GB'],
      // defaultCountry: IsoCode.fromJson(widget.defaultCountry),
      onChanged: widget.onCountryChanged != null 
          ? (phoneNumber) {
              if (phoneNumber.value != null) {
                widget.onCountryChanged!(phoneNumber.value?.countryCode);
              }
            }
          : null,
      showErrors: widget.showErrors,
      validationMessages: widget.validationMessages ?? {},
      style: theme.textTheme.bodyLarge?.copyWith(
        color: colorScheme.onSurface,
      ),

    );

  Widget _buildTextField(ThemeData theme, ColorScheme colorScheme) => ReactiveTextField<String>(
      formControlName: widget.formControlName,
      obscureText: _shouldObscureText,
      keyboardType: _getKeyboardType(),
      textInputAction: _getTextInputAction(),
      autofocus: widget.autofocus,
      maxLines: _getMaxLines(),
      minLines: _getMinLines(),
      maxLength: widget.maxLength,
      readOnly: widget.readOnly,
      onTap: widget.onTap != null ? (_) => widget.onTap!() : null,
      expands: false,
      textCapitalization: _getTextCapitalization(),
      focusNode: widget.focusNode,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: colorScheme.onSurface,
      ),
      validationMessages: widget.validationMessages ?? {},
      showErrors: widget.showErrors,
      decoration: _getInputDecoration(theme, colorScheme),
      autocorrect: _getAutocorrect(),
      enableSuggestions: _getEnableSuggestions(),
    );

  InputDecoration _getInputDecoration(ThemeData theme, ColorScheme colorScheme) => InputDecoration(
      hintText: _getHintText(),
      hintStyle: theme.textTheme.bodyLarge?.copyWith(
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
      ),
      suffixIcon: _getSuffixIcon(),
      prefixIcon: _getPrefixIcon(),
      filled: widget.filled,
      fillColor: widget.fillColor ??
          colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      border: widget.border ??
          OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: context.colorScheme.outline.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
      enabledBorder: widget.border ??
          OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: context.colorScheme.outline.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: context.colorScheme.outline.withValues(alpha: 0.8),
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
      contentPadding: widget.contentPadding ??
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      isDense: widget.isDense,
      helperText: widget.helperText,
      counterText: widget.showCounter ? null : '',
      errorStyle: theme.textTheme.bodySmall?.copyWith(
        color: colorScheme.error,
      ),
      helperStyle: theme.textTheme.bodySmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
    );
}