import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/service/service_locator.dart';
import 'package:xpensemate/core/theme/app_spacing.dart';
import 'package:xpensemate/core/widget/app_button.dart';
import 'package:xpensemate/core/widget/app_snackbar.dart';
import 'package:xpensemate/features/auth/presentation/widgets/custom_text_form_field.dart';
import 'package:xpensemate/features/budget/domain/entities/budget_goal_entity.dart';

class BudgetFormPage extends StatefulWidget {
  const BudgetFormPage({
    super.key,
    this.budget,
    required this.onSave,
    this.onCancel,
  });

  /// If provided, the form will be in edit mode with the budget data pre-filled
  final BudgetGoalEntity? budget;

  /// Callback when the form is saved
  final void Function(BudgetGoalEntity budget) onSave;

  /// Callback when the form is cancelled
  final VoidCallback? onCancel;

  @override
  State<BudgetFormPage> createState() => _BudgetFormPageState();
}

class _BudgetFormPageState extends State<BudgetFormPage> with TickerProviderStateMixin {
  late final FormGroup _form;
  late final AnimationController _fadeController;
  late final AnimationController _slideController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  bool _isCustomCategoryMode = false; // Add this flag for custom category mode

  static const _predefinedCategories = [
    'Food',
    'Transport',
    'Entertainment',
    'Shopping',
    'Utilities',
    'Healthcare',
    'Education',
    'Business',
    'Travel',
    'Subscription',
    'Rent',
    'Loan',
    'Other',
  ];

  static const _priorityOptions = ['High', 'Medium', 'Low', 'Critical'];
  static const _statusOptions = [
    'active',
    'achieved',
    'failed',
    'terminated',
    'other',
  ];

  // Icons for categories
  static const _categoryIcons = {
    'Food': Icons.restaurant_outlined,
    'Transport': Icons.directions_car_outlined,
    'Entertainment': Icons.movie_outlined,
    'Shopping': Icons.shopping_bag_outlined,
    'Utilities': Icons.bolt_outlined,
    'Healthcare': Icons.local_hospital_outlined,
    'Education': Icons.school_outlined,
    'Business': Icons.business_center_outlined,
    'Travel': Icons.flight_outlined,
    'Subscription': Icons.subscriptions_outlined,
    'Rent': Icons.home_outlined,
    'Loan': Icons.account_balance_outlined,
    'Other': Icons.category_outlined,
  };

  // Icons for priorities
  static const _priorityIcons = {
    'High': Icons.flag_outlined,
    'Medium': Icons.outlined_flag_outlined,
    'Low': Icons.flag_outlined,
    'Critical': Icons.error_outline,
  };

  // Colors for priorities
  Color _getPriorityColor(String priority, ColorScheme colorScheme) {
    switch (priority) {
      case 'Critical':
        return Colors.red;
      case 'High':
        return Colors.orange;
      case 'Medium':
        return Colors.blue;
      case 'Low':
        return Colors.green;
      default:
        return colorScheme.onSurface;
    }
  }

  // Icons for status
  static const _statusIcons = {
    'active': Icons.play_circle_outline,
    'achieved': Icons.check_circle_outline,
    'failed': Icons.cancel_outlined,
    'terminated': Icons.stop_circle_outlined,
    'other': Icons.help_outline,
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeForm();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  void _initializeForm() {
    _form = FormGroup({
      'name': FormControl<String>(
        validators: [
          Validators.required,
          Validators.maxLength(100),
          Validators.minLength(2),
        ],
      ),
      'amount': FormControl<String>(
        validators: [
          Validators.required,
          Validators.pattern(r'^(\d+(\.\d+)?|\.\d+|\d*)$'),
        ],
      ),
      'date': FormControl<DateTime>(validators: [Validators.required]),
      'category': FormControl<String>(validators: [Validators.required]),
      'customCategory': FormControl<String>(), // Add custom category control
      'priority': FormControl<String>(validators: [Validators.required]),
      'status': FormControl<String>(validators: [Validators.required]),
      'detail': FormControl<String>(),
    });

    if (widget.budget != null) {
      _populateFormFromBudget(widget.budget!);
    } else {
      _form.control('date').value = DateTime.now().add(const Duration(days: 30));
      _form.control('priority').value = 'High';
      _form.control('status').value = 'active';
    }
  }

  @override
  void dispose() {
    _form.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _populateFormFromBudget(BudgetGoalEntity budget) {
    _form.control('name').value = budget.name;
    _form.control('amount').value = budget.amount.toStringAsFixed(2);
    _form.control('date').value = budget.date;
    _form.control('detail').value = budget.detail;

    // Handle priority value with proper normalization
    final priority = budget.priority;
    if (priority != null) {
      // Normalize the priority to match our predefined options
      String normalizedPriority = priority;

      for (final predefined in _priorityOptions) {
        if (predefined.toLowerCase() == priority.toLowerCase()) {
          normalizedPriority = predefined; // Use the properly cased predefined option
          break;
        }
      }

      _form.control('priority').value = normalizedPriority;
    }

    // Handle status value with proper normalization
    final status = budget.status;
    if (status != null) {
      // Normalize the status to match our predefined options
      String normalizedStatus = status;

      for (final predefined in _statusOptions) {
        if (predefined.toLowerCase() == status.toLowerCase()) {
          normalizedStatus = predefined; // Use the properly cased predefined option
          break;
        }
      }

      _form.control('status').value = normalizedStatus;
    }

    // Handle category value with proper normalization
    final category = budget.category;
    if (category != null) {
      // Normalize the category to match our predefined categories
      // Find a case-insensitive match with predefined categories
      String normalizedCategory = category;

      for (final predefined in _predefinedCategories) {
        if (predefined.toLowerCase() == category.toLowerCase()) {
          normalizedCategory = predefined; // Use the properly cased predefined category
          break;
        }
      }

      _form.control('category').value = normalizedCategory;

      // If it's a custom category (not in predefined list), enable custom mode
      final isPredefined =
          _predefinedCategories.any((predefined) => predefined.toLowerCase() == normalizedCategory.toLowerCase());

      if (!isPredefined) {
        setState(() {
          _isCustomCategoryMode = true;
        });
      }
    }
  }

  Future<void> _submitForm() async {
    try {
      if (!_form.valid) {
        AppSnackBar.show(
          context: context,
          message: "Please fill out all required fields",
          type: SnackBarType.error,
        );
        _form.markAllAsTouched();
        return;
      }

      final amountString = (_form.control('amount').value as String?)?.trim() ?? '0';
      final amount = double.tryParse(amountString);

      if (amount == null || amount <= 0) {
        if (!_form.control('amount').hasError('pattern')) {
          _form.control('amount').setErrors({'pattern': 'Please enter a valid amount'});
        }
        return;
      }

      // Determine the category value based on which field is being used
      String categoryValue;
      if (_isCustomCategoryMode) {
        // If in custom category mode, use the custom category field
        final customCategory = _form.control('customCategory').value as String?;
        if (customCategory == null || customCategory.trim().isEmpty) {
          _form.control('customCategory').setErrors({'required': true});
          return;
        }
        categoryValue = customCategory.trim();
      } else {
        final selectedCategory = _form.control('category').value as String?;
        if (selectedCategory == null || selectedCategory.isEmpty) {
          _form.control('category').setErrors({'required': true});
          return;
        }
        categoryValue = selectedCategory;
      }

      final budget = BudgetGoalEntity(
        id: widget.budget?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        userId: widget.budget?.userId ?? sl.authService.currentUser!.id,
        name: (_form.control('name').value as String?)?.trim() ?? '',
        amount: amount,
        date: _form.control('date').value as DateTime? ?? DateTime.now().add(const Duration(days: 30)),
        category: categoryValue, // Use the determined category value
        detail: (_form.control('detail').value as String?)?.trim() ?? '',
        status: (_form.control('status').value as String? ?? 'active').toLowerCase(),
        priority: (_form.control('priority').value as String? ?? 'Medium').toLowerCase(),
        progress: widget.budget?.progress ?? 0,
        isDeleted: widget.budget?.isDeleted ?? false,
        createdAt: widget.budget?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        remainingBalance: widget.budget?.remainingBalance ?? amount,
        currentSpending: widget.budget?.currentSpending ?? 0.0,
      );

      widget.onSave(budget);
    } on Exception catch (error) {
      AppSnackBar.show(context: context, message: error.toString());
    }
  }

  Future<void> _selectDate() async {
    final currentDate = _form.control('date').value as DateTime? ?? DateTime.now().add(const Duration(days: 30));

    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (picked != null) {
      _form.control('date').value = picked;
    }
  }

  // Create a method to build category dropdown items with custom category option
  List<DropdownOption> _buildCategoryDropdownOptions() {
    final options = <DropdownOption>[];

    // Add "Add Custom Category" option at the top
    options.add(
      const DropdownOption(
        value: 'ADD_CUSTOM_CATEGORY',
        label: '+ Add Custom Category',
      ),
    );

    // Add the predefined categories
    options.addAll(
      _predefinedCategories
          .map(
            (cat) => DropdownOption(
              value: cat,
              label: cat,
              icon: _categoryIcons[cat],
            ),
          )
          .toList(),
    );

    return options;
  }

  // Modified dropdown builder to handle custom category functionality
  Widget _buildCategoryDropdown({
    required String formControlName,
    required String label,
    required String hint,
    required Map<String, String? Function(Object)> validationMessages,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final options = _buildCategoryDropdownOptions();

    return ReactiveFormConsumer(
      builder: (context, formModel, child) {
        final control = formModel.control(formControlName);
        final value = control.value as String?;
        final hasError = control.hasError('required') && control.touched == true;

        List<Widget> children = [
          Text(
            label,
            style: textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasError ? colorScheme.error : colorScheme.outline.withValues(alpha: 0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                hint: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Row(
                    children: [
                      Icon(
                        Icons.arrow_drop_down_circle_outlined,
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                        size: 18,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        hint,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                icon: Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ),
                borderRadius: BorderRadius.circular(12),
                dropdownColor: colorScheme.surface,
                menuMaxHeight: 300,
                style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                // Add a safety check for the value
                selectedItemBuilder: (BuildContext context) => options.map((option) {
                  if (option.icon != null) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            option.icon,
                            color: colorScheme.primary,
                            size: 18,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              option.label,
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      child: Text(
                        option.label,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    );
                  }
                }).toList(),
                items: options.map((option) {
                  // Special handling for the "Add Custom Category" option
                  if (option.value == 'ADD_CUSTOM_CATEGORY') {
                    return DropdownMenuItem<String>(
                      value: option.value,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          AppSpacing.sm,
                          AppSpacing.md,
                          AppSpacing.sm,
                        ),
                        child: Text(
                          option.label,
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }

                  return DropdownMenuItem<String>(
                    value: option.value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              option.icon,
                              color: colorScheme.primary,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              option.label,
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue == 'ADD_CUSTOM_CATEGORY') {
                    setState(() {
                      _isCustomCategoryMode = true;
                    });
                    // Clear the dropdown selection when entering custom mode
                    control.value = null;
                    // Clear any validation errors
                    control.setErrors({});
                  } else if (newValue != null) {
                    setState(() {
                      _isCustomCategoryMode = false;
                    });
                    // Clear custom category field when selecting from dropdown
                    _form.control('customCategory').value = null;
                    _form.control('customCategory').setErrors({});
                    control.value = newValue;
                    control.markAsTouched();
                  }
                },
              ),
            ),
          ),
        ];

        // Add error message if needed
        if (hasError) {
          children.add(const SizedBox(height: AppSpacing.xs));
          children.add(
            Padding(
              padding: const EdgeInsets.only(left: AppSpacing.md),
              child: Text(
                validationMessages['required']?.call(control.errors) ?? 'This field is required',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.error,
                ),
              ),
            ),
          );
        }

        // Add custom category field if in custom mode
        if (_isCustomCategoryMode) {
          children.add(const SizedBox(height: AppSpacing.md));
          children.add(
            ReactiveAppField(
              formControlName: 'customCategory',
              labelText: '${context.l10n.category} *',
              hintText: context.l10n.category,
              prefixIcon: Icon(
                Icons.category_outlined,
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
              textInputAction: TextInputAction.next,
              validationMessages: {
                'required': (error) => context.l10n.fieldRequired,
              },
              showErrors: (control) {
                final hasError = control.hasError == true;
                final touched = control.touched == true;
                return hasError && touched;
              },
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        );
      },
    );
  }

  Widget _buildModernDropdown({
    required String formControlName,
    required String label,
    required String hint,
    required List<DropdownOption> options,
    required Map<String, String? Function(Object)> validationMessages,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ReactiveFormConsumer(
      builder: (context, formModel, child) {
        final control = formModel.control(formControlName);
        final value = control.value as String?;
        final hasError = control.hasError('required') && control.touched == true;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasError ? colorScheme.error : colorScheme.outline.withValues(alpha: 0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: value,
                  isExpanded: true,
                  hint: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Row(
                      children: [
                        Icon(
                          Icons.arrow_drop_down_circle_outlined,
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                          size: 18,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          hint,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  icon: Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  ),
                  borderRadius: BorderRadius.circular(12),
                  dropdownColor: colorScheme.surface,
                  menuMaxHeight: 300,
                  style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                  selectedItemBuilder: (BuildContext context) => options
                      .map(
                        (option) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                          child: Row(
                            children: [
                              if (option.icon != null) ...[
                                Icon(
                                  option.icon,
                                  color: option.color ?? colorScheme.primary,
                                  size: 18,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                              ],
                              Expanded(
                                child: Text(
                                  option.label,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  items: options
                      .map(
                        (option) => DropdownMenuItem<String>(
                          value: option.value,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: (option.color ?? colorScheme.primary).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(
                                    option.icon,
                                    color: option.color ?? colorScheme.primary,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Text(
                                    option.label,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (newValue) {
                    control.value = newValue;
                    control.markAsTouched();
                  },
                ),
              ),
            ),
            if (hasError) ...[
              const SizedBox(height: AppSpacing.xs),
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.md),
                child: Text(
                  validationMessages['required']?.call(control.errors) ?? 'This field is required',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.error,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                SingleChildScrollView(
                  child: ReactiveForm(
                    formGroup: _form,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Budget name
                        ReactiveAppField(
                          formControlName: 'name',
                          labelText: '${l10n.description} *',
                          hintText: l10n.description,
                          prefixIcon: Icon(
                            Icons.description_outlined,
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                          ),
                          textInputAction: TextInputAction.next,
                          validationMessages: {
                            'required': (error) => l10n.fieldRequired,
                            'minLength': (error) => l10n.fieldTooShort,
                            'maxLength': (error) => l10n.fieldTooLong,
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Amount
                        ReactiveAppField(
                          formControlName: 'amount',
                          labelText: '${l10n.amount} *',
                          hintText: l10n.amount,
                          fieldType: FieldType.number,
                          prefixIcon: Icon(
                            Icons.attach_money_outlined,
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                          ),
                          textInputAction: TextInputAction.next,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d*$'),
                            ),
                          ],
                          validationMessages: {
                            'required': (error) => l10n.fieldRequired,
                            'pattern': (error) => l10n.invalidAmount,
                          },
                          showErrors: (control) {
                            final hasError = control.hasError('required') || control.hasError('pattern');
                            return hasError && control.touched == true;
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Target Date
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${l10n.date} *',
                              style: textTheme.labelLarge?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            ReactiveFormConsumer(
                              builder: (context, formModel, child) {
                                final date = formModel.control('date').value as DateTime?;
                                return InkWell(
                                  onTap: _selectDate,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.md,
                                      vertical: AppSpacing.sm1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorScheme.surfaceContainer.withValues(alpha: 0.7),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: colorScheme.outline.withValues(alpha: 0.2),
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: colorScheme.primary.withValues(alpha: 0.08),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: colorScheme.primary.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Icon(
                                            Icons.calendar_today_outlined,
                                            color: colorScheme.primary,
                                            size: 16,
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.sm),
                                        Expanded(
                                          child: Text(
                                            date != null
                                                ? '${date.day}/${date.month}/${date.year}'
                                                : 'Select Target Date',
                                            style: textTheme.bodyMedium?.copyWith(
                                              color: date != null
                                                  ? colorScheme.onSurface
                                                  : colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                                              fontWeight: date != null ? FontWeight.w500 : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                                          size: 14,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Category Dropdown
                        _buildCategoryDropdown(
                          formControlName: 'category',
                          label: '${l10n.category} *',
                          hint: l10n.category,
                          validationMessages: {
                            'required': (error) => l10n.fieldRequired,
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Priority Dropdown
                        _buildModernDropdown(
                          formControlName: 'priority',
                          label: 'Priority ',
                          hint: 'Select priority',
                          options: _priorityOptions.map((priority) {
                            final displayText = priority == 'High'
                                ? l10n.highPriority
                                : priority == 'Medium'
                                    ? l10n.mediumPriority
                                    : priority == 'Low'
                                        ? l10n.lowPriority
                                        : priority;

                            return DropdownOption(
                              value: priority,
                              label: displayText,
                              icon: _priorityIcons[priority],
                              color: _getPriorityColor(priority, colorScheme),
                            );
                          }).toList(),
                          validationMessages: {
                            'required': (error) => l10n.fieldRequired,
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Status Dropdown
                        _buildModernDropdown(
                          formControlName: 'status',
                          label: 'Status ',
                          hint: 'Select status',
                          options: _statusOptions.map((status) {
                            final displayText = status == 'active'
                                ? l10n.active
                                : status == 'achieved'
                                    ? l10n.achieved
                                    : status == 'failed'
                                        ? l10n.failedTerminated.split('/')[0]
                                        : status == 'terminated'
                                            ? l10n.failedTerminated.split('/')[1]
                                            : status;

                            return DropdownOption(
                              value: status,
                              label: displayText,
                              icon: _statusIcons[status],
                            );
                          }).toList(),
                          validationMessages: {
                            'required': (error) => l10n.fieldRequired,
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Note
                        ReactiveAppField(
                          formControlName: 'detail',
                          labelText: 'Note',
                          hintText: 'Add any additional notes',
                          fieldType: FieldType.textarea,
                          maxLines: 3,
                          prefixIcon: Icon(
                            Icons.notes_outlined,
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                          ),
                          textInputAction: TextInputAction.newline,
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                      ],
                    ),
                  ),
                ),

                // Action buttons
                SizedBox(
                  height: 48,
                  child: Row(
                    children: [
                      if (widget.onCancel != null) ...[
                        Expanded(
                          child: AppButton.secondary(
                            onPressed: widget.onCancel,
                            text: l10n.cancel.toUpperCase(),
                            textColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                      ],
                      Expanded(
                        child: AppButton.primary(
                          onPressed: _submitForm,
                          text: (widget.budget == null ? l10n.add : l10n.save).toUpperCase(),
                          textColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DropdownOption {
  final String value;
  final String label;
  final IconData? icon;
  final Color? color;

  const DropdownOption({
    required this.value,
    required this.label,
    this.icon,
    this.color,
  });
}
