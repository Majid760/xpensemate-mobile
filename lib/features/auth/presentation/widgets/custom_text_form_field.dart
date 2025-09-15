import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:reactive_image_picker/reactive_image_picker.dart';
import 'package:reactive_phone_form_field/reactive_phone_form_field.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
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
  dropdown,
  imagePicker,
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
    // Dropdown specific
    this.dropdownItems,
    this.onDropdownChanged,
    // Image picker specific
    this.imagePickerDecoration,
    this.allowMultiple = false,
    this.maxImages,
    this.imageQuality,
    this.onImageChanged,
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

  // Dropdown specific properties
  final List<DropdownMenuItem<String>>? dropdownItems;
  final ReactiveFormFieldCallback<String>? onDropdownChanged;

  // Image picker specific properties
  final InputDecoration? imagePickerDecoration;
  final bool allowMultiple;
  final int? maxImages;
  final int? imageQuality;
  final ValueChanged<dynamic>? onImageChanged;

  @override
  State<ReactiveAppField> createState() => _ReactiveAppFieldState();
}

class _ReactiveAppFieldState extends State<ReactiveAppField> {
  bool _obscureText = true;

  // Default gender options
  static const List<String> genderOptions = ['Male', 'Female', 'Other'];

  // Gender enum for dropdown
  static const Map<String, Map<String, dynamic>> genderOptionsWithIcons = {
    'Male': {
      'icon': Icons.male_rounded,
      'displayName': 'Male',
    },
    'Female': {
      'icon': Icons.female_rounded,
      'displayName': 'Female',
    },
    'Other': {
      'icon': Icons.transgender_rounded,
      'displayName': 'Other',
    },
  };

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
          child: _buildField(theme, colorScheme),
        ),
      ],
    );
  }

  Widget _buildField(ThemeData theme, ColorScheme colorScheme) {
    switch (widget.fieldType) {
      case FieldType.phone:
        return _buildPhoneField(theme, colorScheme);
      case FieldType.dropdown:
        return _buildDropdownField(theme, colorScheme);
      case FieldType.imagePicker:
        return _buildImagePickerField(theme, colorScheme);
      default:
        return _buildTextField(theme, colorScheme);
    }
  }

  bool get _shouldObscureText =>
      widget.fieldType == FieldType.password && _obscureText;

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
      case FieldType.dropdown:
        return 'Select an option';
      case FieldType.imagePicker:
        return 'Select image(s)';
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
      case FieldType.dropdown:
        return const Icon(Icons.arrow_drop_down);
      case FieldType.imagePicker:
        return const Icon(Icons.image_outlined);
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

  Widget _buildPhoneField(ThemeData theme, ColorScheme colorScheme) =>
      ReactivePhoneFormField<PhoneNumber>(
        formControlName: widget.formControlName,
        decoration: _getInputDecoration(theme, colorScheme).copyWith(
          // Slightly reduce left padding for better alignment with selector
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 14,
          ),
        ),
        onChanged: widget.onCountryChanged != null
            ? (phoneNumber) {
                if (phoneNumber.value != null) {
                  widget.onCountryChanged!(phoneNumber.value?.countryCode);
                }
              }
            : null,
        showErrors: widget.showErrors,
        autofocus: widget.autofocus,
        validationMessages: widget.validationMessages ?? {},
        countrySelectorNavigator: CountrySelectorNavigator.draggableBottomSheet(
          searchAutofocus: true,
          showDialCode: true,
          sortCountries: true,
          noResultMessage: context.l10n.noCountryFound,
          subtitleStyle: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          titleStyle: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface,
          ),
          searchBoxDecoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: context.colorScheme.outline.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: context.colorScheme.outline.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            hintText: context.l10n.searchCountry,
            hintStyle: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          searchBoxTextStyle: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface,
          ),
          searchBoxIconColor: colorScheme.onSurface,
          scrollPhysics: const BouncingScrollPhysics(),
          flagSize: 24,
          backgroundColor: colorScheme.surfaceContainerHighest,
          countries: IsoCode.values,
          // favorites: [IsoCode.US, IsoCode.CA, IsoCode.GB],
        ),
        style: theme.textTheme.bodyLarge?.copyWith(
          color: colorScheme.onSurface,
        ),
      );

  Widget _buildDropdownField(ThemeData theme, ColorScheme colorScheme) {
    // Use provided dropdown items or default gender options with icons
    final items = widget.dropdownItems ??
        genderOptions
            .map(
              (String value) => DropdownMenuItem<String>(
                value: value,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Icon(
                        genderOptionsWithIcons[value]?['icon'] as IconData? ??
                            Icons.circle,
                        size: 20,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        genderOptionsWithIcons[value]?['displayName']
                                as String? ??
                            value,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList();

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: ReactiveDropdownField<String>(
        formControlName: widget.formControlName,
        decoration: InputDecoration(
          hintText: _getHintText(),
          hintStyle: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
          prefixIcon: _getPrefixIcon(),
          filled: false,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          suffixIcon: Container(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 24,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          suffixIconConstraints: const BoxConstraints(
            minWidth: 24,
            minHeight: 24,
          ),
        ),
        items: items,
        onChanged: widget.onDropdownChanged,
        showErrors: widget.showErrors,
        validationMessages: widget.validationMessages ?? {},
        style: theme.textTheme.bodyLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
        dropdownColor: colorScheme.surface,
        icon: const SizedBox.shrink(), // Hide default icon
        isExpanded: true,
        menuMaxHeight: 300,
        borderRadius: BorderRadius.circular(12),
        selectedItemBuilder: (BuildContext context) => items
            .map<Widget>(
              (DropdownMenuItem<String> item) => Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.zero,
                child: Row(
                  children: [
                    // Get the icon from the original item
                    if (item.value != null &&
                        genderOptionsWithIcons.containsKey(item.value))
                      Icon(
                        genderOptionsWithIcons[item.value!]?['icon']
                                as IconData? ??
                            Icons.circle,
                        size: 20,
                        color: colorScheme.primary,
                      ),
                    if (item.value != null &&
                        genderOptionsWithIcons.containsKey(item.value))
                      const SizedBox(width: 12),
                    Text(
                      item.value != null &&
                              genderOptionsWithIcons.containsKey(item.value)
                          ? (genderOptionsWithIcons[item.value!]?['displayName']
                                  as String? ??
                              item.value!)
                          : item.value ?? '',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildImagePickerField(ThemeData theme, ColorScheme colorScheme) =>
      ReactiveImagePicker(
        formControlName: widget.formControlName,
        decoration: widget.imagePickerDecoration ??
            _getImagePickerDecoration(theme, colorScheme),
        inputBuilder: (onPressed) => Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: context.colorScheme.outline.withValues(alpha: 0.2),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add_a_photo_outlined,
                  size: 48,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  _getHintText() ?? 'Select image(s)',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
        showErrors: widget.showErrors,
        validationMessages: widget.validationMessages ?? {},
        // allowMultiple: widget.allowMultiple,
        // maxImages: widget.maxImages,
        imageQuality: widget.imageQuality,
        // onChanged: widget.onImageChanged,
      );

  Widget _buildTextField(ThemeData theme, ColorScheme colorScheme) =>
      ReactiveTextField<String>(
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

  InputDecoration _getInputDecoration(
    ThemeData theme,
    ColorScheme colorScheme,
  ) =>
      InputDecoration(
        hintText: _getHintText(),
        hintStyle: theme.textTheme.bodyLarge?.copyWith(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
        ),
        suffixIcon: _getSuffixIcon(),
        prefixIcon: _getPrefixIcon(),
        filled: widget.filled,
        fillColor: widget.fillColor ??
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 44,
          minHeight: 48,
        ),
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
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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

  InputDecoration _getImagePickerDecoration(
    ThemeData theme,
    ColorScheme colorScheme,
  ) =>
      InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: context.colorScheme.outline.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
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
        contentPadding: EdgeInsets.zero,
        errorStyle: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.error,
        ),
      );
}
