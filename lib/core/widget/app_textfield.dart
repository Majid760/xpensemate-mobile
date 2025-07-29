// lib/core/widgets/custom_text_field.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {

  const CustomTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.inputFormatters,
    this.onChanged,
    this.onTap,
    this.validator,
    this.contentPadding,
    this.borderRadius,
    this.fillColor,
    this.filled = false,
    this.textStyle,
    this.hintStyle,
  });
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final bool readOnly;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final FormFieldValidator<String>? validator;
  final EdgeInsetsGeometry? contentPadding;
  final double? borderRadius;
  final Color? fillColor;
  final bool filled;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;

  @override
  Widget build(BuildContext context) => TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      maxLines: maxLines,
      maxLength: maxLength,
      enabled: enabled,
      readOnly: readOnly,
      inputFormatters: inputFormatters,
      style: textStyle,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: hintStyle,
        errorText: errorText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        filled: filled,
        fillColor: fillColor,
        contentPadding: contentPadding ?? 
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 8),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 8),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
      onChanged: onChanged,
      onTap: onTap,
      validator: validator,
    );
}

// Common specialized fields
class EmailField extends StatelessWidget {

  const EmailField({
    super.key,
    this.controller,
    this.label,
    this.onChanged,
    this.validator,
  });
  final TextEditingController? controller;
  final String? label;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) => CustomTextField(
      controller: controller,
      label: label ?? 'Email',
      hint: 'Enter your email',
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      prefixIcon: const Icon(Icons.email_outlined),
      validator: validator ?? _emailValidator,
      onChanged: onChanged,
    );

  String? _emailValidator(String? value) {
    if (value?.isEmpty ?? true) return 'Email is required';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
      return 'Enter valid email';
    }
    return null;
  }
}

class PasswordField extends StatefulWidget {

  const PasswordField({
    super.key,
    this.controller,
    this.label,
    this.onChanged,
    this.validator,
  });
  final TextEditingController? controller;
  final String? label;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) => CustomTextField(
      controller: widget.controller,
      label: widget.label ?? 'Password',
      hint: 'Enter your password',
      obscureText: _obscureText,
      prefixIcon: const Icon(Icons.lock_outlined),
      suffixIcon: IconButton(
        icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
        onPressed: () => setState(() => _obscureText = !_obscureText),
      ),
      validator: widget.validator ?? _passwordValidator,
      onChanged: widget.onChanged,
    );

  String? _passwordValidator(String? value) {
    if (value?.isEmpty ?? true) return 'Password is required';
    if (value!.length < 6) return 'Minimum 6 characters';
    return null;
  }
}

class SearchField extends StatelessWidget {

  const SearchField({
    super.key,
    this.controller,
    this.hint,
    this.onChanged,
    this.onClear,
  });
  final TextEditingController? controller;
  final String? hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) => CustomTextField(
      controller: controller,
      hint: hint ?? 'Search...',
      prefixIcon: const Icon(Icons.search),
      suffixIcon: controller?.text.isNotEmpty ?? false
          ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {      
                controller?.clear();
                onClear?.call();
              },
            )
          : null,
      filled: true,
      fillColor: Colors.grey.shade100,
      borderRadius: 25,
      onChanged: onChanged,
    );
}

class PhoneField extends StatelessWidget {

  const PhoneField({
    super.key,
    this.controller,
    this.label,
    this.onChanged,
    this.validator,
  });
  final TextEditingController? controller;
  final String? label;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) => CustomTextField(
      controller: controller,
      label: label ?? 'Phone',
      hint: 'Enter phone number',
      keyboardType: TextInputType.phone,
      prefixIcon: const Icon(Icons.phone_outlined),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: validator ?? _phoneValidator,
      onChanged: onChanged,
    );

  String? _phoneValidator(String? value) {
    if (value?.isEmpty ?? true) return 'Phone is required';
    if (value!.length < 10) return 'Enter valid phone';
    return null;
  }
}

// Simple form wrapper
class SimpleForm extends StatelessWidget {

  const SimpleForm({
    super.key,
    this.formKey,
    required this.children,
    this.padding,
    this.spacing = 16,
  });
  final GlobalKey<FormState>? formKey;
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final double spacing;

  @override
  Widget build(BuildContext context) => Form(
      key: formKey,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: Column(
          children: children
              .expand((widget) => [widget, SizedBox(height: spacing)])
              .take(children.length * 2 - 1)
              .toList(),
        ),
      ),
    );
}

// Usage Examples:

/*
// Basic usage
CustomTextField(
  label: 'Name',
  hint: 'Enter your name',
  prefixIcon: Icon(Icons.person),
)

// Email field
EmailField(
  controller: emailController,
  onChanged: (value) => print(value),
)

// Password field
PasswordField(
  controller: passwordController,
)

// Search field
SearchField(
  hint: 'Search products...',
  onChanged: (query) => searchProducts(query),
)

// Form example
class LoginForm extends StatefulWidget {
  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SimpleForm(
      formKey: _formKey,
      children: [
        EmailField(
          controller: _emailController,
        ),
        PasswordField(
          controller: _passwordController,
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              // Handle login
            }
          },
          child: Text('Login'),
        ),
      ],
    );
  }
}

// Custom styled field
CustomTextField(
  label: 'Message',
  maxLines: 3,
  filled: true,
  fillColor: Colors.blue.shade50,
  borderRadius: 12,
  textStyle: TextStyle(fontSize: 16),
)
*/