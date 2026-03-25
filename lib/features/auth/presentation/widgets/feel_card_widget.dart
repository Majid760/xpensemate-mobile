import 'package:flutter/material.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';

/// Elevated glass-feel form card
class FormCard extends StatelessWidget {
  const FormCard({super.key, required this.child, required this.isDark, this.padding});
  final Widget child;
  final bool isDark;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) => Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF122436)
            : const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? const Color(0xFF1E4A5A)
              : const Color(0xFFB2D8E8),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: context.primaryColor.withValues(
              alpha: isDark ? 0.04 : 0.06,
            ),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
}