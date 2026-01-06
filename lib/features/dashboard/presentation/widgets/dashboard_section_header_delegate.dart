import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:xpensemate/core/theme/colors/app_colors.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';

class DashboardSectionHeaderDelegate extends SliverPersistentHeaderDelegate {
  DashboardSectionHeaderDelegate({
    required this.title,
    required this.icon,
    this.action,
    this.child,
    this.height = 60.0,
  });

  final String title;
  final IconData icon;
  final Widget? action;
  final Widget? child;
  final double height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    // Calculate opacity based on shrinkOffset to create a smooth transition
    // for the background color/blur when it becomes sticky
    final isSticky = shrinkOffset > 0;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: isSticky ? 10 : 0,
          sigmaY: isSticky ? 10 : 0,
        ),
        child: Container(
          height: height,
          padding: EdgeInsets.symmetric(horizontal: context.md),
          decoration: BoxDecoration(
            color: context.colorScheme.surface.withValues(
              alpha: isSticky ? 0.8 : 1.0,
            ),
            border: isSticky
                ? Border(
                    bottom: BorderSide(
                      color: context.colorScheme.outline.withValues(alpha: 0.1),
                    ),
                  )
                : null,
          ),
          child: child ??
              Row(
                children: [
                  Icon(
                    icon,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  SizedBox(width: context.sm),
                  Expanded(
                    child: Text(
                      title,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: context.colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  if (action != null) action!,
                ],
              ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant DashboardSectionHeaderDelegate oldDelegate) =>
      oldDelegate.title != title ||
      oldDelegate.icon != icon ||
      oldDelegate.action != action ||
      oldDelegate.child != child;
}
