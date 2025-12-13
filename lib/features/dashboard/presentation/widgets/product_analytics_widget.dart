import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/features/dashboard/domain/entities/product_weekly_analytics_entity.dart';
import 'package:xpensemate/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:xpensemate/features/dashboard/presentation/widgets/product_analytics_bar_chart.dart';
import 'package:xpensemate/features/dashboard/presentation/widgets/section_header_widget.dart';
import 'package:xpensemate/features/dashboard/presentation/widgets/weekly_summary_cards.dart';

class ProductAnalyticsWidget extends StatelessWidget {
  const ProductAnalyticsWidget({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<DashboardCubit, DashboardState>(
        buildWhen: (previous, current) =>
            previous.productAnalytics != current.productAnalytics ||
            previous.state != current.state,
        builder: (context, state) {
          if (state.productAnalytics == null) {
            return const SizedBox.shrink();
          }

          return Container(
            padding: EdgeInsets.all(context.md),
            decoration: BoxDecoration(
              color: context.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: context.colorScheme.outline.withValues(alpha: 0.1),
              ),
              boxShadow: [
                BoxShadow(
                  color: context.colorScheme.shadow.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: context.colorScheme.primary.withValues(alpha: 0.02),
                  blurRadius: 8,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: context.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: context.colorScheme.outline.withValues(alpha: 0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: context.colorScheme.shadow.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: SectionHeaderWidget(
                      title: context.l10n.productAnalytic,
                      icon: Icons.analytics,
                    ),
                  ),
                  SizedBox(height: context.lg),

                  if (state.state == DashboardStates.loading)
                    _buildLoadingState(context)
                  else
                    _buildAnalyticsContent(context, state.productAnalytics!),
                ],
              ),
            ),
          );
        },
      );

  Widget _buildAnalyticsContent(
    BuildContext context,
    ProductWeeklyAnalyticsEntity analytics,
  ) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chart section
          DecoratedBox(
            decoration: BoxDecoration(
              color:
                  context.colorScheme.surfaceContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ProductAnalyticsBarChart(
              key: ValueKey(
                'chart_${analytics.currentCategory}_${analytics.hashCode}',
              ),
              productAnalytics: analytics,
              height: 280,
            ),
          ),
          SizedBox(height: context.md),

          // Summary cards - mobile layout only
          WeeklySummaryHorizontalCards(productAnalytics: analytics),
          SizedBox(height: context.sm),
        ],
      );

  Widget _buildLoadingState(BuildContext context) => Container(
        height: 200,
        padding: EdgeInsets.all(context.lg),
        child: Center(
          child: CircularProgressIndicator(
            color: context.primaryColor,
            strokeWidth: 2,
          ),
        ),
      );
}
