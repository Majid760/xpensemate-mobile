import 'package:flutter/material.dart';
import 'package:xpensemate/core/theme/app_spacing.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';

/// Displays the member's avatar, name, and email at the top of the options sheet.
class MemberOptionsHeader extends StatelessWidget {
  const MemberOptionsHeader({
    super.key,
    required this.name,
    required this.email,
    required this.initials,
    required this.avatarColor,
    required this.avatarTextColor,
  });

  final String name;
  final String email;
  final String initials;
  final Color avatarColor;
  final Color avatarTextColor;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return Row(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: avatarColor,
          child: Text(
            initials,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: avatarTextColor,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                email,
                style: context.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.55),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
