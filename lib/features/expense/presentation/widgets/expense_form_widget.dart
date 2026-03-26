import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/service/service_locator.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/utils/app_logger.dart';
import 'package:xpensemate/core/widget/app_button.dart';
import 'package:xpensemate/core/widget/app_snackbar.dart';
import 'package:xpensemate/core/widget/custom_app_loader.dart';
import 'package:xpensemate/features/auth/presentation/widgets/background_decoration_widget.dart';
import 'package:xpensemate/features/auth/presentation/widgets/custom_text_form_field.dart';
import 'package:xpensemate/features/auth/presentation/widgets/feel_card_widget.dart';
import 'package:xpensemate/features/auth/presentation/widgets/feild_lable_widget.dart';
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

  final ExpenseEntity? expense;
  final void Function(ExpenseEntity expense) onSave;
  final VoidCallback? onCancel;

  @override
  State<ExpenseFormWidget> createState() => _ExpenseFormWidgetState();
}

class _ExpenseFormWidgetState extends State<ExpenseFormWidget>
    with SingleTickerProviderStateMixin {
  late final FormGroup _form;
  late final List<String> _predefinedCategories;
  late final List<String> _paymentMethods;
  bool _isCustomCategoryMode = false;
  BudgetsListEntity? _budgets;
  bool _isBudgetsLoading = true;

  // ── Animation Controllers ───────────────────────────────
  late final AnimationController _animController;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _initializeForm();
    _loadBudgets();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeIn = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0, 0.65, curve: Curves.easeOut),
    );

    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0, 0.65, curve: Curves.easeOutCubic),
    ),);

    _animController.forward();
  }

  @override
  void dispose() {
    _form.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _initializeForm() {
    _predefinedCategories = [
      'Food', 'Transport', 'Entertainment', 'Shopping',
      'Utilities', 'Healthcare', 'Education', 'Business',
      'Travel', 'Subscription', 'Rent', 'Loan', 'Other',
    ];

    _paymentMethods = [
      'Cash', 'Credit Card', 'Debit Card',
      'Bank Transfer', 'Digital Wallet', 'other',
    ];

    _form = FormGroup({
      'name': FormControl<String>(
        validators: [Validators.required, Validators.maxLength(100), Validators.minLength(2)],
      ),
      'amount': FormControl<String>(
        validators: [Validators.required, Validators.pattern(r'^(\d+(\.\d+)?|\.\d+|\d*)$')],
      ),
      'category': FormControl<String>(validators: [Validators.required]),
      'customCategory': FormControl<String>(),
      'budgetGoalId': FormControl<String>(),
      'date': FormControl<DateTime>(validators: [Validators.required]),
      'time': FormControl<String>(validators: [Validators.required]),
      'location': FormControl<String>(),
      'paymentMethod': FormControl<String>(value: 'Cash'),
      'detail': FormControl<String>(),
    });

    if (widget.expense != null) {
      _populateFormFromExpense(widget.expense!);
    } else {
      _form.control('date').value = DateTime.now();
      _form.control('time').value = _formatTime(DateTime.now());
      _form.control('budgetGoalId').value = 'NO_BUDGET';
    }
  }

  Future<void> _loadBudgets() async {
    try {
      setState(() => _isBudgetsLoading = true);
      await context.expenseCubit.loadBudgets();
      if (mounted) {
        final budgets = context.expenseCubit.state.budgets;
        setState(() {
          _budgets = budgets ?? const BudgetsListEntity(budgets: [], total: 0, page: 0, totalPages: 0);
          _isBudgetsLoading = false;
        });
        if (widget.expense?.budgetGoalId != null && _budgets != null) {
          _setBudgetFromExpense(widget.expense!.budgetGoalId!);
        } else if (widget.expense?.budgetGoalId == null) {
          _form.control('budgetGoalId').value = 'NO_BUDGET';
        }
      }
    } on Exception catch (error) {
      if (mounted) {
        setState(() {
          _isBudgetsLoading = false;
          _budgets = const BudgetsListEntity(budgets: [], total: 0, page: 0, totalPages: 0);
        });
        AppSnackBar.show(context: context, message: '${context.l10n.failedToLoadBudgets}: $error');
      }
    }
  }

  void _setBudgetFromExpense(String budgetGoalId) {
    if (_budgets?.budgets.isNotEmpty != true) {
      _form.control('budgetGoalId').value = 'NO_BUDGET';
      return;
    }
    try {
      final match = _budgets!.budgets.firstWhere((b) => b.id == budgetGoalId);
      _form.control('budgetGoalId').value = match.name;
    } on Exception catch (_) {
      AppLogger.e('Budget with ID "$budgetGoalId" not found');
      _form.control('budgetGoalId').value = 'NO_BUDGET';
    }
  }

  void _populateFormFromExpense(ExpenseEntity expense) {
    _form.control('name').value = expense.name;
    _form.control('amount').value = expense.amount.toStringAsFixed(2);
    final cat = expense.categoryName;
    if (_predefinedCategories.any((c) => c.toLowerCase() == cat.toLowerCase())) {
      _form.control('category').value = cat;
    } else if (cat.isNotEmpty) {
      _predefinedCategories.add(cat);
      _form.control('category').value = cat;
    }
    _form.control('date').value = expense.date;
    _form.control('time').value = expense.time;
    _form.control('location').value = expense.location;
    _form.control('paymentMethod').value = expense.paymentMethod;
    _form.control('detail').value = expense.detail;
  }

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  Future<void> _submitForm() async {
    try {
      if (!_form.valid) {
        _form.markAllAsTouched();
        AppSnackBar.show(context: context, message: context.l10n.pleaseFillRequired, type: SnackBarType.error);
        return;
      }
      String categoryValue;
      if (_isCustomCategoryMode) {
        final custom = _form.control('customCategory').value as String?;
        if (custom == null || custom.trim().isEmpty) {
          _form.control('customCategory').setErrors({'required': true});
          return;
        }
        categoryValue = custom.trim();
        if (!_predefinedCategories.any((c) => c.toLowerCase() == categoryValue.toLowerCase())) {
          _predefinedCategories.add(categoryValue);
        }
      } else {
        final sel = _form.control('category').value as String?;
        if (sel == null || sel.isEmpty) {
          _form.control('category').setErrors({'required': true});
          return;
        }
        categoryValue = sel;
      }

      final amountStr = (_form.control('amount').value as String?)?.trim() ?? '0';
      final amount = double.tryParse(amountStr);
      if (amount == null || amount < 0) {
        _form.control('amount').setErrors({'pattern': context.l10n.invalidAmount});
        return;
      }

      final selBudget = _form.control('budgetGoalId').value as String?;
      String? budgetGoalId;
      if (selBudget != null && selBudget != 'NO_BUDGET') {
        try {
          final match = _budgets?.budgets.firstWhere((b) => b.name == selBudget);
          budgetGoalId = match?.id;
        } on Exception catch (_) {
          AppLogger.e('Selected budget "$selBudget" not found');
        }
      }

      final expense = ExpenseEntity(
        id: widget.expense?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        userId: widget.expense?.userId ?? sl.authService.currentUser!.id,
        name: (_form.control('name').value as String?)?.trim() ?? '',
        amount: amount,
        budgetGoalId: budgetGoalId,
        date: _form.control('date').value as DateTime? ?? DateTime.now(),
        time: _form.control('time').value as String? ?? _formatTime(DateTime.now()),
        location: (_form.control('location').value as String?)?.trim() ?? '',
        categoryId: categoryValue,
        categoryName: categoryValue,
        detail: (_form.control('detail').value as String?)?.trim() ?? '',
        paymentMethod: _form.control('paymentMethod').value as String? ?? 'cash',
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
    final primary = context.primaryColor;
    final scheme = context.colorScheme;
    return [
      DropdownMenuItem<String>(
        value: 'ADD_CUSTOM_CATEGORY',
        child: Text(
          context.l10n.addCustomCategory,
          style: TextStyle(color: primary, fontWeight: FontWeight.w600),
        ),
      ),
      DropdownMenuItem<String>(
        enabled: false,
        child: Divider(color: scheme.outlineVariant.withValues(alpha: 0.4), height: 1, thickness: 0.5),
      ),
      ..._predefinedCategories.map((cat) => DropdownMenuItem<String>(
            value: cat,
            child: Text(cat, style: TextStyle(color: scheme.onSurface)),
          ),),
    ];
  }

  List<DropdownMenuItem<String>> _buildBudgetDropdownItems() {
    final scheme = context.colorScheme;
    return [
      DropdownMenuItem<String>(
        value: 'NO_BUDGET',
        child: Text(context.l10n.noBudgetGoal, style: context.textTheme.bodyMedium),
      ),
      if (_budgets?.budgets.isNotEmpty ?? false)
        ..._budgets!.budgets.map((budget) => DropdownMenuItem<String>(
              value: budget.name,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(budget.name, style: TextStyle(color: scheme.onSurface, fontWeight: FontWeight.w500)),
                  if (budget.detail.isNotEmpty)
                    Text(budget.detail, style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),),
    ];
  }

  List<DropdownMenuItem<String>> _buildPaymentMethodDropdownItems() =>
      _paymentMethods.map((m) => DropdownMenuItem<String>(
            value: m,
            child: Text(m, style: TextStyle(color: context.colorScheme.onSurface)),
          ),).toList();

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _form.control('date').value as DateTime? ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) _form.control('date').value = picked;
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _getTimeOfDay(_form.control('time').value as String? ?? _formatTime(DateTime.now())),
    );
    if (picked != null) {
      _form.control('time').value =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    }
  }

  TimeOfDay _getTimeOfDay(String t) {
    final parts = t.split(':');
    return TimeOfDay(hour: int.tryParse(parts[0]) ?? 0, minute: int.tryParse(parts[1]) ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = context.primaryColor;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: Stack(
        children: [
          BackgroundDecoration(isDark: isDark),
          LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: FadeTransition(
                    opacity: _fadeIn,
                    child: SlideTransition(
                      position: _slideUp,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: ReactiveForm(
                          formGroup: _form,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              FormCard(
                                isDark: isDark,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // ── Basic Info ─────────────────
                                    FieldLabel(label: '${l10n.description} *'),
                                    const SizedBox(height: 6),
                                    ReactiveAppField(
                                      formControlName: 'name',
                                      hintText: l10n.description,
                                      prefixIcon: Icon(Icons.receipt_outlined, size: 18, color: primary.withValues(alpha: 0.7)),
                                      textInputAction: TextInputAction.next,
                                      validationMessages: {
                                        'required': (_) => l10n.fieldRequired,
                                        'minLength': (_) => l10n.fieldTooShort,
                                        'maxLength': (_) => l10n.fieldTooLong,
                                      },
                                    ),
          
                                    const SizedBox(height: 20),
          
                                    FieldLabel(label: '${l10n.amount} *'),
                                    const SizedBox(height: 6),
                                    ReactiveAppField(
                                      formControlName: 'amount',
                                      hintText: l10n.amount,
                                      fieldType: FieldType.number,
                                      prefixIcon: Icon(Icons.attach_money_outlined, size: 18, color: primary.withValues(alpha: 0.7)),
                                      textInputAction: TextInputAction.next,
                                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))],
                                      validationMessages: {
                                        'required': (_) => l10n.fieldRequired,
                                        'pattern': (_) => l10n.invalidAmount,
                                      },
                                      showErrors: (c) => (c.hasError('required') || c.hasError('pattern')) && c.touched,
                                    ),
          
                                    const SizedBox(height: 24),
          
                                    // ── Category ──────────────────
                                    FieldLabel(label: '${l10n.category} *'),
                                    const SizedBox(height: 6),
                                    ReactiveAppField(
                                      formControlName: 'category',
                                      hintText: l10n.category,
                                      fieldType: FieldType.dropdown,
                                      dropdownItems: _buildCategoryDropdownItems(),
                                      prefixIcon: Icon(Icons.category_outlined, size: 18, color: primary.withValues(alpha: 0.7)),
                                      validationMessages: {'required': (_) => l10n.fieldRequired},
                                      onDropdownChanged: (value) {
                                        if (value.value == 'ADD_CUSTOM_CATEGORY') {
                                          setState(() => _isCustomCategoryMode = true);
                                          _form.control('category').value = null;
                                          _form.control('category').setErrors({});
                                        } else if (value.value != null) {
                                          setState(() => _isCustomCategoryMode = false);
                                          _form.control('customCategory').value = null;
                                          _form.control('customCategory').setErrors({});
                                        }
                                      },
                                    ),
          
                                    if (_isCustomCategoryMode) ...[
                                      const SizedBox(height: 18),
                                      FieldLabel(label: '${l10n.category} *'),
                                      const SizedBox(height: 6),
                                      ReactiveAppField(
                                        formControlName: 'customCategory',
                                        hintText: l10n.category,
                                        prefixIcon: Icon(Icons.edit_outlined, size: 18, color: primary.withValues(alpha: 0.7)),
                                        textInputAction: TextInputAction.next,
                                        validationMessages: {'required': (_) => l10n.fieldRequired},
                                        showErrors: (c) => c.invalid && c.touched,
                                      ),
                                    ],
          
                                    const SizedBox(height: 24),
          
                                    // ── Date & Time ───────────────
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              FieldLabel(label: '${l10n.date} *'),
                                              const SizedBox(height: 6),
                                              ReactiveFormConsumer(
                                                builder: (context, form, _) {
                                                  final date = form.control('date').value as DateTime?;
                                                  return _PickerTile(
                                                    icon: Icons.calendar_today_outlined,
                                                    text: date != null
                                                        ? '${date.day}/${date.month}/${date.year}'
                                                        : l10n.date,
                                                    hasValue: date != null,
                                                    onTap: _selectDate,
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              FieldLabel(label: '${l10n.time} *'),
                                              const SizedBox(height: 6),
                                              ReactiveFormConsumer(
                                                builder: (context, form, _) {
                                                  final time = form.control('time').value as String?;
                                                  return _PickerTile(
                                                    icon: Icons.access_time_outlined,
                                                    text: time ?? l10n.time,
                                                    hasValue: time != null,
                                                    onTap: _selectTime,
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
          
                                    const SizedBox(height: 24),
          
                                    // ── Budget & Payment ──────────
                                    FieldLabel(label: l10n.budget),
                                    const SizedBox(height: 6),
                                    if (_isBudgetsLoading)
                                      const _BudgetLoader()
                                    else
                                      ReactiveAppField(
                                        formControlName: 'budgetGoalId',
                                        hintText: l10n.noBudgetGoal,
                                        fieldType: FieldType.dropdown,
                                        dropdownItems: _buildBudgetDropdownItems(),
                                        prefixIcon: Icon(Icons.account_balance_wallet_outlined, size: 18, color: primary.withValues(alpha: 0.7)),
                                      ),
          
                                    const SizedBox(height: 18),
          
                                    FieldLabel(label: l10n.paymentMethod),
                                    const SizedBox(height: 6),
                                    ReactiveAppField(
                                      formControlName: 'paymentMethod',
                                      hintText: l10n.paymentMethod,
                                      fieldType: FieldType.dropdown,
                                      dropdownItems: _buildPaymentMethodDropdownItems(),
                                      prefixIcon: Icon(Icons.credit_card_outlined, size: 18, color: primary.withValues(alpha: 0.7)),
                                    ),
          
                                    const SizedBox(height: 24),
          
                                    // ── Extra Details ─────────────
                                    FieldLabel(label: l10n.location),
                                    const SizedBox(height: 6),
                                    ReactiveAppField(
                                      formControlName: 'location',
                                      hintText: l10n.location,
                                      prefixIcon: Icon(Icons.location_on_outlined, size: 18, color: primary.withValues(alpha: 0.7)),
                                      textInputAction: TextInputAction.next,
                                    ),
          
                                    const SizedBox(height: 18),
          
                                    FieldLabel(label: l10n.details),
                                    const SizedBox(height: 6),
                                    ReactiveAppField(
                                      formControlName: 'detail',
                                      hintText: l10n.details,
                                      fieldType: FieldType.textarea,
                                      maxLines: 3,
                                      prefixIcon: Icon(Icons.notes_outlined, size: 18, color: primary.withValues(alpha: 0.7)),
                                      textInputAction: TextInputAction.newline,
                                    ),
                                  ],
                                ),
                              ),
          
                              const SizedBox(height: 24),
          
                              // ── Action Buttons ───────────────────────
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: AppButton.primary(
                                      text: (widget.expense == null ? l10n.add : l10n.save).toUpperCase(),
                                      onPressed: _submitForm,
                                      textColor: context.colorScheme.onPrimary,
                                    ),
                                  ),
                                  if (widget.onCancel != null) ...[
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: AppButton.secondary(
                                      text: l10n.cancel.toUpperCase(),
                                      onPressed: widget.onCancel,
                                      textColor: context.colorScheme.onPrimary,
                                    ),
                                  ),
                                ],
                                ],
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.icon,
    required this.text,
    required this.hasValue,
    required this.onTap,
  });

  final IconData icon;
  final String text;
  final bool hasValue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = context.primaryColor;
    final scheme = context.colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isDark
              ? scheme.surfaceContainerHighest.withValues(alpha: 0.4)
              : scheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: scheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: primary.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: hasValue ? scheme.onSurface : scheme.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetLoader extends StatelessWidget {
  const _BudgetLoader();

  @override
  Widget build(BuildContext context) {
    final primary = context.primaryColor;
    final scheme = context.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CustomAppLoader(strokeWidth: 2, size: 16, color: primary),
        ),
        const SizedBox(width: 10),
        Text(
          '${context.l10n.loading} ${context.l10n.budget.toLowerCase()}...',
          style: context.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}