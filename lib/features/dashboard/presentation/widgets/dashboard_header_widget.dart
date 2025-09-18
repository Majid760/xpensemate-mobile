// Separate widget for the dashboard header
import 'package:flutter/material.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:xpensemate/features/dashboard/presentation/widgets/financial_overview_card_widget.dart';

class DashboardHeaderWidget extends StatelessWidget {
  const DashboardHeaderWidget({
    super.key,
    required this.state,
    required this.getGreeting,
  });
  final DashboardState state;
  final String Function() getGreeting;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 50, 24, 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                context.colorScheme.primary,
                context.colorScheme.secondary.withValues(alpha: 0.9),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: context.colorScheme.primary.withValues(alpha: 0.2),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Greeting Text
              Row(
                children: [
                  Text(
                    '${getGreeting()} ',
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.colorScheme.onPrimary,
                      letterSpacing: -0.5,
                      shadows: [
                        Shadow(
                          color: context.colorScheme.primaryContainer
                              .withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '👋',
                    style: context.textTheme.headlineMedium?.copyWith(
                      color: context.colorScheme.onPrimary,
                      shadows: [
                        Shadow(
                          color: context.colorScheme.onPrimary
                              .withValues(alpha: 0.2),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                context.l10n.financialOverviewSubtitle,
                style: context.textTheme.titleMedium?.copyWith(
                  color: context.colorScheme.onPrimary.withValues(alpha: 0.95),
                  fontWeight: FontWeight.w400,
                  shadows: [
                    Shadow(
                      color: context.colorScheme.primary.withValues(alpha: 0.2),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Financial Overview Card (now using separate widget)
              FinancialOverviewCardWidget(state: state),
            ],
          ),
        ),
      );
}
