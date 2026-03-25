// Small uppercase field label
import 'package:flutter/material.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';

class FieldLabel extends StatelessWidget {
  const FieldLabel({super.key, required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Text(
      label.toUpperCase(),
      style: context.textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: context.colorScheme.onSurfaceVariant,
      ),
    );
}             