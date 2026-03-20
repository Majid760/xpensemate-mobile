import 'package:flutter/material.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';

/// Or divider row
class OrDivider extends StatelessWidget {
  const OrDivider({super.key, required this.scheme});
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) => Row(
      children: [
        Expanded(
          child: Divider(
            color: scheme.outlineVariant.withValues(alpha: 0.5),
            thickness: 0.5,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'or continue with',
            style: context.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: scheme.outlineVariant.withValues(alpha: 0.5),
            thickness: 0.5,
          ),
        ),
      ],
    );
}