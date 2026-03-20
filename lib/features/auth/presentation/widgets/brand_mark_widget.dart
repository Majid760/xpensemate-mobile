import 'package:flutter/material.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/utils/assset_path.dart';
import 'package:xpensemate/core/widget/app_image.dart';

/// Animated brand mark with logo + wordmark
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, required this.isDark, this.logoSize = 40.0, this.ringWidth = 1.5, this.ringPadding = 4.0, this.appNameSpacing = 10.0});
  final bool isDark;
  final double logoSize;
  final double ringWidth;
  final double ringPadding;
  final double appNameSpacing;

  @override
  Widget build(BuildContext context) => Column(
      children: [
        // Logo container with teal ring
        Container(
          width: 72,
          height: 72,
          padding: EdgeInsets.all(ringPadding),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.primaryColor.withValues(alpha: 0.12),
            border: Border.all(
              color: context.primaryColor.withValues(alpha: 0.3),
              width: ringWidth,
            ),
          ),
          child: Center(
            child: AppImage.asset(
              AssetPaths.logoOnly,
              height: logoSize,
              // color: context.primaryColor,
            ),
          ),
        ),
        SizedBox(height: appNameSpacing),
        // App name
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Xpense',
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.primaryColor,
                  letterSpacing: -0.3,
                ),
              ),
              TextSpan(
                text: 'Mate',
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w400,
                  color: context.colorScheme.secondary,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
}