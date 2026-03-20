import 'package:flutter/material.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';

/// Subtle geometric blobs in the background using brand colors
class BackgroundDecoration extends StatelessWidget {
  const BackgroundDecoration({super.key, required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) => Stack(
      children: [
        // Top-right blob — primary teal
        Positioned(
          top: -80,
          right: -60,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.primaryColor.withValues(
                alpha: isDark ? 0.08 : 0.10,
              ),
            ),
          ),
        ),
        // Bottom-left blob — deep ocean
        Positioned(
          bottom: -100,
          left: -80,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.colorScheme.secondary.withValues(
                alpha: isDark ? 0.10 : 0.07,
              ),
            ),
          ),
        ),
        // Small mint accent — top left
        Positioned(
          top: 60,
          left: -30,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.colorScheme.tertiary.withValues(
                alpha: isDark ? 0.06 : 0.08,
              ),
            ),
          ),
        ),
      ],
    );
}