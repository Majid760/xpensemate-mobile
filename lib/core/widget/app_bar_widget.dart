import 'package:flutter/material.dart';
import 'package:xpensemate/core/enums.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/utils/app_utils.dart';

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
              gradient: LinearGradient(
                colors: [
                  context.primaryColor,
                  context.colorScheme.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(context.md),
              boxShadow: [
                BoxShadow(
                  color: context.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(context.md),
                onTap: () => showModalBottomSheet<void>(
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (context) => FilterDropdownSheetView(
                    defaultPeriod: defaultPeriod,
                    onChanged: onChanged,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(context.sm1),
                  child: Icon(
                    Icons.tune_rounded,
                    color: context.onPrimaryColor,
                    size: context.iconMd,
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
          'label': context.l10n.quarterlyInsights,
          'icon': Icons.calendar_view_month_rounded,
        },
        {
          'value': FilterValue.yearly,
          'label': context.l10n.yearlyInsights,
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(context.lg)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(top: context.sm1),
              width: context.xxl,
              height: context.xs,
              decoration: BoxDecoration(
                color: context.outlineColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(context.xs),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(context.md1),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(context.sm),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          context.primaryColor.withValues(alpha: 0.2),
                          context.colorScheme.secondary.withValues(alpha: 0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(context.sm1),
                    ),
                    child: Icon(
                      Icons.filter_list_rounded,
                      color: context.primaryColor,
                      size: context.iconMd,
                    ),
                  ),
                  context.sm.widthBox,
                  Text(
                    context.l10n.overview,
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.onSurfaceColor,
                    ),
                  ),
                ],
              ),
            ),
            ...items.map((item) {
              final isSelected = (item['value']! as FilterValue).name ==
                  widget.defaultPeriod.name;
              return Container(
                margin: EdgeInsets.symmetric(
                  horizontal: context.md,
                  vertical: context.xs,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            context.primaryColor,
                            context.colorScheme.secondary,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isSelected ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(context.md),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : context.outlineColor.withValues(alpha: 0.2),
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
                      padding: EdgeInsets.symmetric(
                        horizontal: context.md,
                        vertical: context.sm1,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(context.sm),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? context.onPrimaryColor
                                      .withValues(alpha: 0.2)
                                  : context.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(context.sm),
                            ),
                            child: Icon(
                              item['icon']! as IconData,
                              color: isSelected
                                  ? context.onPrimaryColor
                                  : context.primaryColor,
                              size: context.iconSm,
                            ),
                          ),
                          context.md.widthBox,
                          Expanded(
                            child: Text(
                              item['label']! as String,
                              style: context.textTheme.bodyLarge?.copyWith(
                                color: isSelected
                                    ? context.onPrimaryColor
                                    : context.onSurfaceColor,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Container(
                              padding: EdgeInsets.all(context.xs),
                              decoration: BoxDecoration(
                                color: context.onPrimaryColor,
                                borderRadius:
                                    BorderRadius.circular(context.sm1),
                              ),
                              child: Icon(
                                Icons.check_rounded,
                                color: context.primaryColor,
                                size: context.iconXs,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
            context.md1.heightBox,
          ],
        ),
      ),
    );
  }
}
