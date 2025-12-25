import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/widget/app_custom_dropdown_widget.dart';
import 'package:xpensemate/features/dashboard/domain/entities/product_weekly_analytics_entity.dart';
import 'package:xpensemate/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:xpensemate/features/dashboard/presentation/widgets/product_analytics_bar_chart.dart';
import 'package:xpensemate/features/dashboard/presentation/widgets/section_header_widget.dart';
import 'package:xpensemate/features/dashboard/presentation/widgets/weekly_summary_cards.dart';
import 'package:xpensemate/core/widget/custom_app_loader.dart';

class ProductAnalyticsWidget extends StatefulWidget {
  const ProductAnalyticsWidget({super.key});

  @override
  State<ProductAnalyticsWidget> createState() => _ProductAnalyticsWidgetState();
}

class _ProductAnalyticsWidgetState extends State<ProductAnalyticsWidget> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<DashboardCubit, DashboardState>(
        buildWhen: (previous, current) =>
            previous.productAnalytics != current.productAnalytics,
        builder: (context, state) {
          if (state.productAnalytics == null) {
            return const SizedBox.shrink();
          }

          final analytics = state.productAnalytics!;

          // Initialize selected category if null or not in list
          if (_selectedCategory == null ||
              !analytics.categories.contains(_selectedCategory)) {
            if (analytics.categories.isNotEmpty) {
              _selectedCategory = analytics.categories.first;
            }
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
                  // Header and Dropdown
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: SectionHeaderWidget(
                            title: context.l10n.productAnalytic,
                            icon: Icons.analytics,
                          ),
                        ),
                        if (analytics.categories.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          CustomDropDown(
                            items: analytics.categories,
                            initialValue: _selectedCategory,
                            onChanged: (value) {
                              setState(() {
                                _selectedCategory = value;
                              });
                            },
                          ),
                        ],
                      ],
                    ),
                  ),

                  SizedBox(height: context.lg),

                  if (state.state == DashboardStates.loading)
                    _buildLoadingState(context)
                  else
                    _buildAnalyticsContent(context, analytics),
                ],
              ),
            ),
          );
        },
      );

  Widget _buildAnalyticsContent(
    BuildContext context,
    ProductWeeklyAnalyticsEntity analytics,
  ) {
    if (analytics.categoriesData.isEmpty) {
      return const SizedBox.shrink();
    }

    // Find the data for selected category
    // Safe lookup: if selected category not found in data, use first available
    // We cast to CategoryDataEntity to avoid runtime TypeError if the list is covariant (List<CategoryDataModel>)
    final categoryData =
        analytics.categoriesData.cast<CategoryDataEntity>().firstWhere(
              (e) => e.category == _selectedCategory,
              orElse: () => analytics.categoriesData.first,
            );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chart section
        DecoratedBox(
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ProductAnalyticsBarChart(
            key: ValueKey(
              'chart_${categoryData.category}_${analytics.hashCode}',
            ),
            categoryData: categoryData,
            height: 280,
          ),
        ),
        SizedBox(height: context.md),

        // Summary cards - mobile layout only
        // Pass the summary specific to this category
        WeeklySummaryHorizontalCards(summary: categoryData.summary),
        SizedBox(height: context.sm),
      ],
    );
  }

  Widget _buildLoadingState(BuildContext context) => Container(
        height: 200,
        padding: EdgeInsets.all(context.lg),
        child: Center(
          child: CustomAppLoader(
            color: context.primaryColor,
            strokeWidth: 2,
          ),
        ),
      );
}
