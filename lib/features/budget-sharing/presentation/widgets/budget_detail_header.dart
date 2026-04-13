import 'package:flutter/material.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/features/budget-sharing/presentation/widgets/share_budget_sheet.dart';

class BudgetDetailHeader extends StatelessWidget {
  const BudgetDetailHeader({
    super.key,
    required this.category,
    required this.name,
    required this.amount,
  });

  final String category;
  final String name;
  final String amount;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return Container(
       decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.primaryColor,
              context.secondaryColor,
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: context.primaryColor.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.toUpperCase(),
                      style: context.textTheme.labelMedium?.copyWith(
                        color: scheme.onPrimary.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      name,
                      style: context.textTheme.headlineMedium?.copyWith(
                        color: scheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // just share icon in circle avatar
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                ShareBudgetSheet.show(context: context);
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.share_outlined, size: 20, color: scheme.onPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            amount,
            style: context.textTheme.displayMedium?.copyWith(
              color: scheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: scheme.onPrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Owner: You',
                  style: context.textTheme.labelMedium?.copyWith(
                    color: scheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Simulating member overlapping avatars
              SizedBox(
                width: 90,
                height: 32,
                child: Stack(
                  children: [
                    _buildAvatarCircle('SR', Colors.blue.shade300, 0, context),
                    _buildAvatarCircle('AK', Colors.pink.shade200, 24, context),
                    _buildAvatarCircle('+2', Colors.grey.shade400, 48, context),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '4 members',
                style: context.textTheme.labelMedium?.copyWith(
                  color: scheme.onPrimary.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarCircle(String initials, Color color, double left, BuildContext context) => Positioned(
      left: left,
      child: Container(
        height: 32,
        width: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: context.colorScheme.primary, width: 2),
        ),
        alignment: Alignment.center,
        child: Text(
          initials,
          style: context.textTheme.labelSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
}
