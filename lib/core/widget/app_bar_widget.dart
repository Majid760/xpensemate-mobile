import 'package:flutter/material.dart';
import 'package:xpensemate/core/enums.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key, this.onChanged, required this.defaultPeriod});
  final ValueChanged<FilterValue>? onChanged;
  final FilterValue defaultPeriod;

  @override
  Widget build(BuildContext context) => SliverAppBar(
        expandedHeight: 60,
        pinned: true,
        automaticallyImplyLeading: false,
        elevation: 0,
        flexibleSpace: FlexibleSpaceBar(
          titlePadding: EdgeInsets.only(left: context.md, bottom: context.md),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: context.md),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => showModalBottomSheet<void>(
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (context) => FilterDropdownSheetView(
                    defaultPeriod: defaultPeriod,
                    onChanged: onChanged,
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Icon(
                    Icons.tune_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
}

class FilterDropdownSheetView extends StatefulWidget {
  const FilterDropdownSheetView({
    super.key,
    required this.defaultPeriod,
    this.onChanged,
  });
  final FilterValue defaultPeriod;
  final ValueChanged<FilterValue>? onChanged;

  @override
  State<FilterDropdownSheetView> createState() =>
      _FilterDropdownSheetViewState();
}

class _FilterDropdownSheetViewState extends State<FilterDropdownSheetView> {
  late List<Map<String, dynamic>> items;

  List<Map<String, dynamic>> _buildItems(BuildContext context) => [
        {
          'value': FilterValue.weekly,
          'label': context.l10n.weeklyInsights,
          'icon': Icons.view_week_rounded,
        },
        {
          'value': FilterValue.monthly,
          'label': context.l10n.monthlyInsight,
          'icon': Icons.calendar_month_rounded,
        },
        {
          'value': FilterValue.quarterly,
          'label': context.l10n.quarterInsight,
          'icon': Icons.calendar_view_month_rounded,
        },
        {
          'value': FilterValue.yearly,
          'label': context.l10n.yearlyInsight,
          'icon': Icons.calendar_today_rounded,
        },
      ];

  @override
  void initState() {
    super.initState();
    // Don't initialize items here as context.l10n is not available yet
  }

  @override
  Widget build(BuildContext context) {
    // Build items here where context is available
    items = _buildItems(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEADDFF), Color(0xFFE8DEF8)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.filter_list_rounded,
                      color: Color(0xFF6366F1),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    context.l10n.overview, // Using a localized string directly
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ...items.map((item) {
              final isSelected = (item['value']! as FilterValue).name ==
                  widget.defaultPeriod.name;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isSelected ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : Colors.grey.withValues(alpha: 0.2),
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.pop(context);
                      widget.onChanged?.call(item['value']! as FilterValue);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.2)
                                  : const Color(0xFFEADDFF)
                                      .withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              item['icon']! as IconData,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF6366F1),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              item['label']! as String,
                              style: context.textTheme.bodyLarge?.copyWith(
                                color: isSelected
                                    ? Colors.white
                                    : context.textTheme.bodyLarge?.color,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                color: Color(0xFF6366F1),
                                size: 16,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
