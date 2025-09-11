import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/app_spacing.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/widget/app_button.dart';
import 'package:xpensemate/features/auth/presentation/widgets/custom_text_form_field.dart';
import 'package:xpensemate/features/expense/domain/entities/expense_entity.dart';

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

class _ExpenseFormWidgetState extends State<ExpenseFormWidget> {
  late final FormGroup _form;
  late final List<Map<String, dynamic>> _categories;
  late final List<String> _paymentMethods;

  @override
  void initState() {
    super.initState();

    // Initialize categories - in a real app, these would come from an API
    _categories = [
      {'id': '1', 'name': 'Food & Dining'},
      {'id': '2', 'name': 'Transportation'},
      {'id': '3', 'name': 'Shopping'},
      {'id': '4', 'name': 'Entertainment'},
      {'id': '5', 'name': 'Utilities'},
      {'id': '6', 'name': 'Healthcare'},
      {'id': '7', 'name': 'Travel'},
      {'id': '8', 'name': 'Education'},
      {'id': '9', 'name': 'Personal Care'},
      {'id': '10', 'name': 'Other'},
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
          Validators.pattern(r'^\d*\.?\d*$'), // Allow only numeric input
        ],
      ),
      'categoryId': FormControl<String>(
        validators: [Validators.required],
      ),
      'date': FormControl<DateTime>(
        validators: [Validators.required],
      ),
      'time': FormControl<String>(
        validators: [Validators.required],
      ),
      'location': FormControl<String>(),
      'paymentMethod': FormControl<String>(),
      'detail': FormControl<String>(),
      'isRecurring': FormControl<bool>(value: false),
      'frequency': FormControl<String>(value: 'monthly'),
    });

    // If editing an existing expense, populate the form
    if (widget.expense != null) {
      _populateFormFromExpense(widget.expense!);
    } else {
      // Set default values for new expense
      _form.control('date').value = DateTime.now();
      _form.control('time').value = _formatTime(DateTime.now());
    }
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  void _populateFormFromExpense(ExpenseEntity expense) {
    _form.control('name').value = expense.name;
    _form.control('amount').value = expense.amount.toStringAsFixed(2);
    _form.control('categoryId').value = expense.categoryId;
    _form.control('date').value = expense.date;
    _form.control('time').value = expense.time;
    _form.control('location').value = expense.location;
    _form.control('paymentMethod').value = expense.paymentMethod;
    _form.control('detail').value = expense.detail;
    _form.control('isRecurring').value = expense.recurring.isRecurring;
    _form.control('frequency').value = expense.recurring.frequency;
  }

  String _formatTime(DateTime dateTime) =>
      '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

  Future<void> _submitForm() async {
    _form.markAllAsTouched();

    if (!_form.valid) return;

    // Parse amount from string to double
    final amountString =
        (_form.control('amount').value as String?)?.trim() ?? '0';
    final amount = double.tryParse(amountString);

    // Validate amount
    if (amount == null || amount < 0) {
      _form
          .control('amount')
          .setErrors({'invalid': 'Please enter a valid amount'});
      return;
    }

    // Create or update expense entity
    final expense = ExpenseEntity(
      id: widget.expense?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      userId: widget.expense?.userId ??
          'current_user_id', // This would come from auth in real app
      name: (_form.control('name').value as String?)?.trim() ?? '',
      amount: amount,
      budgetGoalId: widget.expense?.budgetGoalId,
      date: _form.control('date').value as DateTime? ?? DateTime.now(),
      time:
          _form.control('time').value as String? ?? _formatTime(DateTime.now()),
      location: (_form.control('location').value as String?)?.trim() ?? '',
      categoryId: _form.control('categoryId').value as String? ?? '',
      categoryName:
          _getCategoryName(_form.control('categoryId').value as String? ?? ''),
      detail: (_form.control('detail').value as String?)?.trim() ?? '',
      paymentMethod: _form.control('paymentMethod').value as String? ?? '',
      attachments: widget.expense?.attachments ?? [],
      isDeleted: widget.expense?.isDeleted ?? false,
      createdAt: widget.expense?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      recurring: RecurringEntity(
        isRecurring: _form.control('isRecurring').value as bool? ?? false,
        frequency: _form.control('frequency').value as String? ?? 'monthly',
      ),
    );

    widget.onSave(expense);
  }

  String _getCategoryName(String categoryId) {
    final category = _categories.firstWhere(
      (cat) => cat['id'] == categoryId,
      orElse: () => {'name': 'Other'},
    );
    return category['name'] as String;
  }

  List<DropdownMenuItem<String>> _buildCategoryDropdownItems() => _categories
      .map(
        (category) => DropdownMenuItem<String>(
          value: category['id'] as String,
          child: Text(category['name'] as String),
        ),
      )
      .toList();

  List<DropdownMenuItem<String>> _buildPaymentMethodDropdownItems() =>
      _paymentMethods
          .map(
            (method) => DropdownMenuItem<String>(
              value: method,
              child: Text(method),
            ),
          )
          .toList();

  List<DropdownMenuItem<String>> _buildFrequencyDropdownItems() => [
        const DropdownMenuItem(value: 'daily', child: Text('Daily')),
        const DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
        const DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
        const DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
      ];

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

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: SingleChildScrollView(
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
                    labelText: '${l10n.name} *',
                    hintText: 'Enter expense name',
                    prefixIcon: Icon(
                      Icons.description_outlined,
                      color:
                          colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
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
                    labelText: 'Amount *',
                    hintText: '0.00',
                    fieldType: FieldType.decimal,
                    prefixIcon: Icon(
                      Icons.attach_money_outlined,
                      color:
                          colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                    textInputAction: TextInputAction.next,
                    validationMessages: {
                      'required': (error) => l10n.fieldRequired,
                      'pattern': (error) => 'Please enter a valid amount',
                    },
                    showErrors: (control) {
                      final hasError = control.hasError == true;
                      final touched = control.touched == true;
                      return hasError && touched;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Category
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Category *',
                        style: textTheme.labelLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: context.colorScheme.surfaceContainer
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
                        child: ReactiveDropdownField<String>(
                          formControlName: 'categoryId',
                          items: _buildCategoryDropdownItems(),
                          hint: const Text('Select category'),
                          isExpanded: true,
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.category_outlined,
                              color: colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.6),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                          ),
                          validationMessages: {
                            'required': (error) => l10n.fieldRequired,
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Date and Time row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date *',
                              style: textTheme.labelLarge?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: context.colorScheme.surfaceContainer
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
                                  final date = formModel.control('date').value
                                      as DateTime?;
                                  return InkWell(
                                    onTap: _selectDate,
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.md,
                                        vertical: AppSpacing.sm,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today_outlined,
                                            color: colorScheme.onSurfaceVariant
                                                .withValues(alpha: 0.6),
                                            size: 20,
                                          ),
                                          const SizedBox(width: AppSpacing.sm),
                                          Text(
                                            date != null
                                                ? '${date.day}/${date.month}/${date.year}'
                                                : 'Select date',
                                            style:
                                                textTheme.bodyLarge?.copyWith(
                                              color: date != null
                                                  ? colorScheme.onSurface
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
                              'Time *',
                              style: textTheme.labelLarge?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: context.colorScheme.surfaceContainer
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
                                  final time = formModel.control('time').value
                                      as String?;
                                  return InkWell(
                                    onTap: _selectTime,
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.md,
                                        vertical: AppSpacing.sm,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.access_time_outlined,
                                            color: colorScheme.onSurfaceVariant
                                                .withValues(alpha: 0.6),
                                            size: 20,
                                          ),
                                          const SizedBox(width: AppSpacing.sm),
                                          Text(
                                            time ?? 'Select time',
                                            style:
                                                textTheme.bodyLarge?.copyWith(
                                              color: time != null
                                                  ? colorScheme.onSurface
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

                  // Location
                  ReactiveAppField(
                    formControlName: 'location',
                    labelText: 'Location',
                    hintText: 'Enter location',
                    prefixIcon: Icon(
                      Icons.location_on_outlined,
                      color:
                          colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Payment method
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment Method',
                        style: textTheme.labelLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: context.colorScheme.surfaceContainer
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
                        child: ReactiveDropdownField<String>(
                          formControlName: 'paymentMethod',
                          items: _buildPaymentMethodDropdownItems(),
                          hint: const Text('Select payment method'),
                          isExpanded: true,
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.account_balance_wallet_outlined,
                              color: colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.6),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Details
                  ReactiveAppField(
                    formControlName: 'detail',
                    labelText: 'Details',
                    hintText: 'Enter details',
                    fieldType: FieldType.textarea,
                    maxLines: 3,
                    prefixIcon: Icon(
                      Icons.notes_outlined,
                      color:
                          colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                    textInputAction: TextInputAction.newline,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  const SizedBox(height: AppSpacing.xxl),

                  // Action buttons
                  Row(
                    children: [
                      if (widget.onCancel != null)
                        Expanded(
                          child: AppButton.secondary(
                            onPressed: widget.onCancel,
                            text: l10n.cancel.toUpperCase(),
                          ),
                        ),
                      if (widget.onCancel != null)
                        const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: AppButton.primary(
                          onPressed: _submitForm,
                          text: (widget.expense == null ? l10n.add : l10n.save)
                              .toUpperCase(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
