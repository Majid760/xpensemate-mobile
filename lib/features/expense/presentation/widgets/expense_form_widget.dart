import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/app_spacing.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/widget/app_button.dart';
import 'package:xpensemate/core/widget/app_snackbar.dart';
import 'package:xpensemate/features/auth/presentation/widgets/custom_text_form_field.dart';
import 'package:xpensemate/features/dashboard/domain/entities/budgets_list_entity.dart';
import 'package:xpensemate/features/expense/domain/entities/expense_entity.dart';
import 'package:xpensemate/features/expense/presentation/cubit/expense_cubit.dart';

class ExpenseFormWidget extends StatefulWidget {
  const ExpenseFormWidget({
    super.key,
    this.expense,
    required this.onSave,
    this.onCancel,
  });

  /// If provided, the form will be in edit mode with the expense data pre-filled
  final ExpenseEntity? expense;

  /// Callback when the form is saved
  final void Function(ExpenseEntity expense) onSave;

  /// Callback when the form is cancelled
  final VoidCallback? onCancel;

  @override
  State<ExpenseFormWidget> createState() => _ExpenseFormWidgetState();
}

class _ExpenseFormWidgetState extends State<ExpenseFormWidget>
    with TickerProviderStateMixin {
  late final FormGroup _form;
  late final List<String> _predefinedCategories;
  late final List<String> _paymentMethods;
  bool _isCustomCategoryMode = false;
  BudgetsListEntity? _budgets;
  bool _isBudgetsLoading = true;

  // Animation controllers and animations
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeForm();
    _loadBudgets();
    _initializeAnimations();
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

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOutCubic,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeOutCubic,
      ),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  void _initializeForm() {
    // Initialize predefined categories - in a real app, these would come from an API
    _predefinedCategories = [
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

    // Initialize payment methods
    _paymentMethods = [
      'Cash',
      'Credit Card',
      'Debit Card',
      'Bank Transfer',
      'Digital Wallet',
      'other',
    ];

    _form = FormGroup({
      'name': FormControl<String>(
        validators: [Validators.required],
      ),
      'amount': FormControl<String>(
        validators: [
          Validators.required,
          Validators.pattern(
              r'^(\d+(\.\d+)?|\.\d+|\d*)$'), // Allow only valid numeric input
        ],
      ),
      'category': FormControl<String>(
        validators: [Validators.required],
      ),
      'customCategory': FormControl<String>(),
      'budgetGoalId': FormControl<String>(), // Add budget form control
      'date': FormControl<DateTime>(
        validators: [Validators.required],
      ),
      'time': FormControl<String>(
        validators: [Validators.required],
      ),
      'location': FormControl<String>(),
      'paymentMethod': FormControl<String>(
        value: 'Cash', // Set Cash as default payment method
      ),
      'detail': FormControl<String>(),
    });

    // If editing an existing expense, populate the form
    if (widget.expense != null) {
      _populateFormFromExpense(widget.expense!);
    } else {
      // Set default values for new expense
      _form.control('date').value = DateTime.now();
      _form.control('time').value = _formatTime(DateTime.now());
      _form.control('budgetGoalId').value = 'NO_BUDGET';
      // Payment method is already set to 'Cash' by default above
    }
  }

  Future<void> _loadBudgets() async {
    try {
      setState(() {
        _isBudgetsLoading = true;
      });

      await context.expenseCubit.loadBudgets();

      if (mounted) {
        final budgets = context.expenseCubit.state.budgets;
        setState(() {
          _budgets = budgets ??
              const BudgetsListEntity(
                budgets: [],
                total: 0,
                page: 0,
                totalPages: 0,
              );
          _isBudgetsLoading = false;
        });

        // If editing an expense and budgets are now loaded, set the budget
        if (widget.expense?.budgetGoalId != null && _budgets != null) {
          _setBudgetFromExpense(widget.expense!.budgetGoalId!);
        } else if (widget.expense?.budgetGoalId == null) {
          // If no budget in expense, set to NO_BUDGET
          _form.control('budgetGoalId').value = 'NO_BUDGET';
        }
      }
    } on Exception catch (error) {
      if (mounted) {
        setState(() {
          _isBudgetsLoading = false;
          _budgets = const BudgetsListEntity(
            budgets: [],
            total: 0,
            page: 0,
            totalPages: 0,
          );
        });
        AppSnackBar.show(
          context: context,
          message: 'Failed to load budgets: $error',
        );
      }
    }
  }

  void _setBudgetFromExpense(String budgetGoalId) {
    if (_budgets?.budgets.isNotEmpty != true) {
      // No budgets available, set to no budget
      _form.control('budgetGoalId').value = 'NO_BUDGET';
      return;
    }

    try {
      // Find the budget by ID and set the dropdown to show its name
      final matchingBudget = _budgets!.budgets.firstWhere(
        (budget) => budget.id == budgetGoalId,
      );
      _form.control('budgetGoalId').value = matchingBudget.name;
    } on Exception catch (e) {
      // If the budget ID doesn't exist in current budgets, set to no budget
      debugPrint(
        'Warning: Budget with ID "$budgetGoalId" not found in budget list',
      );
      _form.control('budgetGoalId').value = 'NO_BUDGET';
    }
  }

  @override
  void dispose() {
    _form.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _populateFormFromExpense(ExpenseEntity expense) {
    _form.control('name').value = expense.name;
    _form.control('amount').value = expense.amount.toStringAsFixed(2);

    final categoryName = expense.categoryName;

    // Check if the expense category exists in our predefined list
    if (_predefinedCategories
        .any((cat) => cat.toLowerCase() == categoryName.toLowerCase())) {
      // Category exists in predefined list - just select it
      _form.control('category').value = categoryName;
      _isCustomCategoryMode = false;
    } else if (categoryName.isNotEmpty) {
      // Category doesn't exist in predefined list - add it and select it
      _predefinedCategories.add(categoryName);
      _form.control('category').value = categoryName;
      _isCustomCategoryMode = false;
    }

    // Don't set budget here - it will be set after budgets are loaded and validated
    // This prevents showing the raw ID in the dropdown

    _form.control('date').value = expense.date;
    _form.control('time').value = expense.time;
    _form.control('location').value = expense.location;
    _form.control('paymentMethod').value = expense.paymentMethod;
    _form.control('detail').value = expense.detail;
  }

  String _formatTime(DateTime dateTime) =>
      '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

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

        // Add the custom category to predefined list for future use
        if (!_predefinedCategories
            .any((cat) => cat.toLowerCase() == categoryValue.toLowerCase())) {
          _predefinedCategories.add(categoryValue);
        }
      } else {
        final selectedCategory = _form.control('category').value as String?;
        if (selectedCategory == null || selectedCategory.isEmpty) {
          _form.control('category').setErrors({'required': true});
          return;
        }
        categoryValue = selectedCategory;
      }

      final amountString =
          (_form.control('amount').value as String?)?.trim() ?? '0';
      final amount = double.tryParse(amountString);
      if (amount == null || amount < 0) {
        // Check if this is a pattern validation error first
        if (_form.control('amount').hasError('pattern')) {
          // Let the pattern validator handle the error message
          return;
        } else {
          // Otherwise, set a generic error
          _form
              .control('amount')
              .setErrors({'pattern': 'Please enter a valid amount'});
          return;
        }
      }

      // Get selected budget ID and handle the special "NO_BUDGET" case safely
      final selectedBudgetId = _form.control('budgetGoalId').value as String?;
      String? budgetGoalId;

      if (selectedBudgetId == null || selectedBudgetId == 'NO_BUDGET') {
        // No budget selected or explicitly "NO_BUDGET"
        budgetGoalId = null;
      } else {
        // Find the budget by name and get its ID
        try {
          final matchingBudget = _budgets?.budgets.firstWhere(
            (budget) => budget.name == selectedBudgetId,
          );
          budgetGoalId = matchingBudget?.id;
        } on Exception catch (_) {
          // If no matching budget found, log warning and set to null
          debugPrint(
            'Warning: Selected budget "$selectedBudgetId" not found in budget list',
          );
          budgetGoalId = null;
        }
      }

      // Create or update expense entity
      final expense = ExpenseEntity(
        id: widget.expense?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        userId: widget.expense?.userId ??
            'current_user_id', // This would come from auth in real app
        name: (_form.control('name').value as String?)?.trim() ?? '',
        amount: amount,
        budgetGoalId:
            budgetGoalId, // Use processed budget ID (null if NO_BUDGET selected)
        date: _form.control('date').value as DateTime? ?? DateTime.now(),
        time: _form.control('time').value as String? ??
            _formatTime(DateTime.now()),
        location: (_form.control('location').value as String?)?.trim() ?? '',
        categoryId: categoryValue,
        categoryName: categoryValue,
        detail: (_form.control('detail').value as String?)?.trim() ?? '',
        paymentMethod:
            _form.control('paymentMethod').value as String? ?? 'cash',
        attachments: widget.expense?.attachments ?? [],
        isDeleted: widget.expense?.isDeleted ?? false,
        createdAt: widget.expense?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        recurring: RecurringEntity(
          isRecurring: widget.expense?.recurring.isRecurring ?? false,
          frequency: widget.expense?.recurring.frequency ?? 'monthly',
        ),
      );

      widget.onSave(expense);
    } on Exception catch (error) {
      AppSnackBar.show(context: context, message: error.toString());
    }
  }

  List<DropdownMenuItem<String>> _buildCategoryDropdownItems() {
    final items = <DropdownMenuItem<String>>[];

    // Add "Add Custom Category" option at the top
    items.add(
      DropdownMenuItem<String>(
        value: 'ADD_CUSTOM_CATEGORY',
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Text(
            '+ Add Custom Category',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );

    // Add separator
    items.add(
      DropdownMenuItem<String>(
        enabled: false,
        child: Divider(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          height: 1,
        ),
      ),
    );

    // Add the predefined categories
    items.addAll(
      _predefinedCategories
          .map(
            (category) => DropdownMenuItem<String>(
              value: category,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  category,
                  style: TextStyle(
                    color: context.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );

    return items;
  }

  List<DropdownMenuItem<String>> _buildBudgetDropdownItems() {
    final items = <DropdownMenuItem<String>>[];

    // Add "No Budget" option
    items.add(
      DropdownMenuItem<String>(
        value:
            'NO_BUDGET', // Use a special value instead of null for better handling
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'No Budget Goal',
            style: context.textTheme.bodyMedium,
          ),
        ),
      ),
    );

    // Add available budgets - use budget name as value but store budget ID internally
    if (_budgets?.budgets.isNotEmpty == true) {
      items.addAll(
        _budgets!.budgets.map(
          (budget) => DropdownMenuItem<String>(
            value: budget.name, // Display value is the budget name
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    budget.name,
                    style: TextStyle(
                      color: context.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (budget.detail.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      budget.detail,
                      style: TextStyle(
                        color: context.colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    }

    return items;
  }

  List<DropdownMenuItem<String>> _buildPaymentMethodDropdownItems() =>
      _paymentMethods
          .map(
            (method) => DropdownMenuItem<String>(
              value: method,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  method,
                  style: TextStyle(
                    color: context.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          )
          .toList();

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _form.control('date').value as DateTime? ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      _form.control('date').value = picked;
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _getTimeOfDay(
        _form.control('time').value as String? ?? _formatTime(DateTime.now()),
      ),
    );

    if (picked != null) {
      final timeString =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      _form.control('time').value = timeString;
    }
  }

  TimeOfDay _getTimeOfDay(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 0,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Form fields
                    ReactiveForm(
                      formGroup: _form,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Expense name
                          ReactiveAppField(
                            formControlName: 'name',
                            labelText: '${l10n.description} *',
                            hintText: l10n.description,
                            prefixIcon: Icon(
                              Icons.description_outlined,
                              color: colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.6),
                            ),
                            textInputAction: TextInputAction.next,
                            validationMessages: {
                              'required': (error) => l10n.fieldRequired,
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Amount
                          ReactiveAppField(
                            formControlName: 'amount',
                            labelText: '${l10n.amount} *',
                            hintText: '0.00',
                            fieldType: FieldType.number,
                            prefixIcon: Icon(
                              Icons.attach_money_outlined,
                              color: colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.6),
                            ),
                            textInputAction: TextInputAction.next,
                            validationMessages: {
                              'required': (error) => l10n.fieldRequired,
                              'pattern': (error) => l10n.invalidAmount,
                            },
                            showErrors: (control) {
                              final hasError = control.hasError('required') ||
                                  control.hasError('pattern');
                              final touched = control.touched == true;
                              return hasError && touched;
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Category field with custom category support
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ReactiveAppField(
                                formControlName: 'category',
                                labelText: '${l10n.category} *',
                                hintText: l10n.category,
                                dropdownItems: _buildCategoryDropdownItems(),
                                fieldType: FieldType.dropdown,
                                validationMessages: {
                                  'required': (error) => l10n.fieldRequired,
                                },
                                onDropdownChanged: (value) {
                                  if (value.value == 'ADD_CUSTOM_CATEGORY') {
                                    setState(() {
                                      _isCustomCategoryMode = true;
                                    });
                                    // Clear the dropdown selection when entering custom mode
                                    _form.control('category').value = null;
                                    // Clear any validation errors
                                    _form.control('category').setErrors({});
                                  } else if (value.value != null) {
                                    setState(() {
                                      _isCustomCategoryMode = false;
                                    });
                                    // Clear custom category field when selecting from dropdown
                                    _form.control('customCategory').value =
                                        null;
                                    _form
                                        .control('customCategory')
                                        .setErrors({});
                                  }
                                },
                              ),

                              // Custom category text field
                              if (_isCustomCategoryMode) ...[
                                const SizedBox(height: AppSpacing.md),
                                ReactiveAppField(
                                  formControlName: 'customCategory',
                                  labelText: 'Custom Category *',
                                  hintText: 'Enter custom category name',
                                  prefixIcon: Icon(
                                    Icons.category_outlined,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant
                                        .withValues(alpha: 0.6),
                                  ),
                                  textInputAction: TextInputAction.next,
                                  validationMessages: {
                                    'required': (error) => l10n.fieldRequired,
                                  },
                                  showErrors: (control) {
                                    final hasError = control.hasError == true;
                                    final touched = control.touched == true;
                                    return hasError && touched;
                                  },
                                ),
                              ],
                            ],
                          ),

                          const SizedBox(height: AppSpacing.md),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${l10n.date} *',
                                      style: textTheme.labelLarge?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: context
                                            .colorScheme.surfaceContainer
                                            .withValues(alpha: 0.7),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: context.colorScheme.primary
                                                .withValues(alpha: 0.1),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: ReactiveFormConsumer(
                                        builder: (context, formModel, child) {
                                          final date = formModel
                                              .control('date')
                                              .value as DateTime?;
                                          return InkWell(
                                            onTap: _selectDate,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 14,
                                                vertical: 14,
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .calendar_today_outlined,
                                                    color: colorScheme
                                                        .onSurfaceVariant
                                                        .withValues(alpha: 0.6),
                                                    size: 20,
                                                  ),
                                                  const SizedBox(
                                                    width: AppSpacing.sm,
                                                  ),
                                                  Text(
                                                    date != null
                                                        ? '${date.day}/${date.month}/${date.year}'
                                                        : l10n.date,
                                                    style: textTheme.bodyLarge
                                                        ?.copyWith(
                                                      color: date != null
                                                          ? colorScheme
                                                              .onSurface
                                                          : colorScheme
                                                              .onSurfaceVariant,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${l10n.time} *',
                                      style: textTheme.labelLarge?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: context
                                            .colorScheme.surfaceContainer
                                            .withValues(alpha: 0.7),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: context.colorScheme.primary
                                                .withValues(alpha: 0.1),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: ReactiveFormConsumer(
                                        builder: (context, formModel, child) {
                                          final time = formModel
                                              .control('time')
                                              .value as String?;
                                          return InkWell(
                                            onTap: _selectTime,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 14,
                                                vertical: 14,
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.access_time_outlined,
                                                    color: colorScheme
                                                        .onSurfaceVariant
                                                        .withValues(alpha: 0.6),
                                                    size: 20,
                                                  ),
                                                  const SizedBox(
                                                    width: AppSpacing.sm,
                                                  ),
                                                  Text(
                                                    time ?? l10n.time,
                                                    style: textTheme.bodyLarge
                                                        ?.copyWith(
                                                      color: time != null
                                                          ? colorScheme
                                                              .onSurface
                                                          : colorScheme
                                                              .onSurfaceVariant,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          // Budget selection
                          if (_isBudgetsLoading)
                            Center(
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Text(
                                      'Loading budgets...',
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            ReactiveAppField(
                              formControlName: 'budgetGoalId',
                              labelText: 'Link to Budget',
                              hintText: 'Select budget goal (optional)',
                              fieldType: FieldType.dropdown,
                              dropdownItems: _buildBudgetDropdownItems(),
                              prefixIcon: Icon(
                                Icons.account_balance_wallet_outlined,
                                color: colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                          const SizedBox(height: AppSpacing.md),

                          // Location
                          ReactiveAppField(
                            formControlName: 'location',
                            labelText: l10n.location,
                            hintText: l10n.location,
                            prefixIcon: Icon(
                              Icons.location_on_outlined,
                              color: colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.6),
                            ),
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          ReactiveAppField(
                            formControlName: 'paymentMethod',
                            labelText: l10n.paymentMethod,
                            hintText: l10n.paymentMethod,
                            fieldType: FieldType.dropdown,
                            dropdownItems: _buildPaymentMethodDropdownItems(),
                          ),

                          const SizedBox(height: AppSpacing.md),
                          // Details
                          ReactiveAppField(
                            formControlName: 'detail',
                            labelText: l10n.details,
                            hintText: l10n.details,
                            fieldType: FieldType.textarea,
                            maxLines: 3,
                            prefixIcon: Icon(
                              Icons.notes_outlined,
                              color: colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.6),
                            ),
                            textInputAction: TextInputAction.newline,
                          ),
                          const SizedBox(height: AppSpacing.md),

                          const SizedBox(height: AppSpacing.xxl),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Action buttons
              SizedBox(
                height: 48,
                child: Row(
                  children: [
                    if (widget.onCancel != null)
                      Expanded(
                        child: AppButton.secondary(
                          onPressed: widget.onCancel,
                          text: l10n.cancel.toUpperCase(),
                          textColor: Colors.white,
                        ),
                      ),
                    if (widget.onCancel != null)
                      const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppButton.primary(
                        onPressed: _submitForm,
                        text: (widget.expense == null ? l10n.add : l10n.save)
                            .toUpperCase(),
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
    );
  }
}
