import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpensemate/core/theme/colors/app_colors.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/widget/error_state_widget.dart';
import 'package:xpensemate/features/dashboard/domain/entities/product_weekly_analytics_entity.dart';
import 'package:xpensemate/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:xpensemate/features/dashboard/presentation/widgets/product_analytics_bar_chart.dart';
import 'package:xpensemate/features/dashboard/presentation/widgets/weekly_summary_cards.dart';

class ProductAnalyticsWidget extends StatefulWidget {
  const ProductAnalyticsWidget({
    super.key,
    this.initialCategory = 'Food',
  });

  final String initialCategory;

  @override
  State<ProductAnalyticsWidget> createState() => _ProductAnalyticsWidgetState();
}

class _ProductAnalyticsWidgetState extends State<ProductAnalyticsWidget> {
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ensure the selected category is valid after we have access to the state
    _syncCategoryWithState();
  }

  void _syncCategoryWithState() {
    final state = context.read<DashboardCubit>().state;
    if (state.productAnalytics != null &&
        state.productAnalytics!.availableCategories.isNotEmpty) {
      // Check if the currently selected category exists in available categories (case insensitive)
      bool categoryExists = false;
      for (final category in state.productAnalytics!.availableCategories) {
        if (category.toLowerCase() == _selectedCategory.toLowerCase()) {
          // Update to use the exact case from available categories
          if (_selectedCategory != category) {
            setState(() {
              _selectedCategory = category;
              print('Updated to match case: $_selectedCategory');
            });
          }
          categoryExists = true;
          break;
        }
      }

      // If the selected category doesn't exist in available categories
      if (!categoryExists) {
        // First try to use the current category from state
        if (state.productAnalytics!.availableCategories
            .contains(state.productAnalytics!.currentCategory)) {
          setState(() {
            _selectedCategory = state.productAnalytics!.currentCategory;
            print('Using current category from state: $_selectedCategory');
          });
        } else {
          // Otherwise use the first available category
          setState(() {
            _selectedCategory =
                state.productAnalytics!.availableCategories.first;
            print('Using first available category: $_selectedCategory');
          });
        }
      }
    }
  }

  void _onCategoryChanged(String category) {
    print('Category changed from $_selectedCategory to $category');
    if (_selectedCategory != category) {
      setState(() {
        _selectedCategory = category;
      });
    }
  }

  List<String> _getAvailableCategories(
    ProductWeeklyAnalyticsEntity? analytics,
  ) {
    if (analytics?.availableCategories.isNotEmpty ?? false) {
      return analytics!.availableCategories;
    }
    return [];
  }

  bool _isValidAnalyticsData(ProductWeeklyAnalyticsEntity? analytics) =>
      analytics?.days.isNotEmpty ?? false;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) => Container(
          margin: EdgeInsets.symmetric(horizontal: context.sm),
          decoration: BoxDecoration(
            color: context.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: context.colorScheme.outline.withValues(alpha: 0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: context.colorScheme.shadow.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              if (state.state == DashboardStates.loading)
                _buildLoadingState(context)
              else if (state.state == DashboardStates.error)
                ErrorStateSectionWidget(
                  errorMsg: state.errorMessage,
                  onRetry: () {
                    context.read<DashboardCubit>().loadProductAnalytics();
                  },
                )
              else if (state.productAnalytics != null &&
                  _isValidAnalyticsData(state.productAnalytics))
                _buildAnalyticsContent(context, state.productAnalytics!)
              else
                _buildEmptyState(context),
            ],
          ),
        ),
      );

  Widget _buildHeader(BuildContext context) =>
      BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          final availableCategories =
              _getAvailableCategories(state.productAnalytics);

          // Ensure selected category is valid
          if (availableCategories.isNotEmpty &&
              !availableCategories.contains(_selectedCategory)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  // Use the current category from state if it's available and valid
                  if (state.productAnalytics != null &&
                      availableCategories
                          .contains(state.productAnalytics!.currentCategory)) {
                    _selectedCategory = state.productAnalytics!.currentCategory;
                  } else {
                    // Otherwise use first available category
                    _selectedCategory = availableCategories.first;
                  }
                });
              }
            });
          }

          return Padding(
            padding: EdgeInsets.all(context.md),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.analytics_outlined,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
                SizedBox(width: context.sm),
                Expanded(
                  child: Text(
                    'Analytics',
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.colorScheme.onSurface,
                    ),
                  ),
                ),
                if (availableCategories.isNotEmpty)
                  _CategoryDropdown(
                    selectedCategory: _selectedCategory,
                    categories: availableCategories,
                    onChanged: _onCategoryChanged,
                  ),
              ],
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
          // Chart section with targeted rebuild
          const _ChartSection(),
          SizedBox(height: context.md),

          // Weekly Summary section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.md),
            child: Text(
              'Weekly Summary',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colorScheme.onSurface,
              ),
            ),
          ),
          SizedBox(height: context.sm),

          // Summary cards - mobile layout only
          WeeklySummaryHorizontalCards(productAnalytics: analytics),
          SizedBox(height: context.sm),
        ],
      );

  Widget _buildLoadingState(BuildContext context) => Container(
        height: 200,
        padding: EdgeInsets.all(context.lg),
        child: const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2,
          ),
        ),
      );

  Widget _buildEmptyState(BuildContext context) => Container(
        height: 200,
        padding: EdgeInsets.all(context.lg),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 32,
                color: context.colorScheme.onSurfaceVariant,
              ),
              SizedBox(height: context.sm),
              Text(
                'No analytics data available',
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: context.sm),
              ElevatedButton(
                onPressed: () {
                  context.read<DashboardCubit>().loadProductAnalytics();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: context.md,
                    vertical: context.sm,
                  ),
                ),
                child: const Text('Load Analytics'),
              ),
            ],
          ),
        ),
      );
}

class _CategoryDropdown extends StatelessWidget {
  const _CategoryDropdown({
    required this.selectedCategory,
    required this.categories,
    this.onChanged,
  });

  final String selectedCategory;
  final List<String> categories;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    // Ensure the selected category exactly matches one in the categories list
    String effectiveSelectedCategory = selectedCategory;

    // If the selected category is not in the list (case sensitive),
    // try to find a case-insensitive match
    if (!categories.contains(selectedCategory)) {
      for (final category in categories) {
        if (category.toLowerCase() == selectedCategory.toLowerCase()) {
          effectiveSelectedCategory = category;
          print(
              'Dropdown using case-matched category: $category instead of $selectedCategory');
          break;
        }
      }
    }

    // If still not found, default to first category if available
    if (!categories.contains(effectiveSelectedCategory) &&
        categories.isNotEmpty) {
      effectiveSelectedCategory = categories.first;
      print(
          'Dropdown defaulting to first category: $effectiveSelectedCategory');
    }

    return Container(
      height: 32, // Fixed smaller height
      padding: EdgeInsets.symmetric(
        horizontal: context.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colorScheme.outline.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: effectiveSelectedCategory,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: context.colorScheme.onSurfaceVariant,
            size: 16,
          ),
          style: context.textTheme.labelMedium?.copyWith(
            color: context.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
          isDense: true,
          menuMaxHeight: 200,
          borderRadius: BorderRadius.circular(12),
          dropdownColor: context.colorScheme.surface,
          onChanged: onChanged != null
              ? (String? value) {
                  print('Dropdown selected: $value');
                  if (value != null) onChanged!(value);
                }
              : null,
          items: categories
              .map(
                (category) => DropdownMenuItem(
                  value: category,
                  child: Text(
                    category,
                    style: context.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _ChartSection extends StatelessWidget {
  const _ChartSection();

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<DashboardCubit, DashboardState>(
        buildWhen: (previous, current) {
          final shouldRebuild =
              previous.productAnalytics != current.productAnalytics ||
                  previous.state != current.state;

          print(
              '🔄 _ChartSection - buildWhen check: ${shouldRebuild ? 'REBUILDING' : 'SKIPPING'}');
          if (previous.productAnalytics != null &&
              current.productAnalytics != null) {
            print(
                '🔄 _ChartSection - Previous category: ${previous.productAnalytics!.currentCategory}');
            print(
                '🔄 _ChartSection - Current category: ${current.productAnalytics!.currentCategory}');
            print(
                '🔄 _ChartSection - Previous hash: ${previous.productAnalytics!.hashCode}');
            print(
                '🔄 _ChartSection - Current hash: ${current.productAnalytics!.hashCode}');
            print(
                '🔄 _ChartSection - Previous days count: ${previous.productAnalytics!.days.length}');
            print(
                '🔄 _ChartSection - Current days count: ${current.productAnalytics!.days.length}');
          }

          return shouldRebuild;
        },
        builder: (context, state) {
          print('🔄 _ChartSection - Building chart section');

          if (state.productAnalytics != null) {
            print(
                '🔄 _ChartSection - Category: ${state.productAnalytics!.currentCategory}');
            print(
                '🔄 _ChartSection - Days count: ${state.productAnalytics!.days.length}');
            print(
                '🔄 _ChartSection - Values: ${state.productAnalytics!.days.map((day) => day.total).toList()}');
            print(
                '🔄 _ChartSection - Using ValueKey: chart_${state.productAnalytics!.currentCategory}_${state.productAnalytics!.hashCode}');

            return Container(
              margin: EdgeInsets.symmetric(horizontal: context.sm),
              decoration: BoxDecoration(
                color:
                    context.colorScheme.surfaceContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ProductAnalyticsBarChart(
                key: ValueKey(
                  'chart_${state.productAnalytics!.currentCategory}_${state.productAnalytics!.hashCode}',
                ),
                productAnalytics: state.productAnalytics!,
                height: 280,
              ),
            );
          }

          print('🔄 _ChartSection - No analytics data available');
          return const SizedBox.shrink();
        },
      );
}
