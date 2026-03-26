import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/service/service_locator.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/widget/app_button.dart';
import 'package:xpensemate/core/widget/app_snackbar.dart';
import 'package:xpensemate/features/auth/presentation/widgets/background_decoration_widget.dart';
import 'package:xpensemate/features/auth/presentation/widgets/custom_text_form_field.dart';
import 'package:xpensemate/features/auth/presentation/widgets/feel_card_widget.dart';
import 'package:xpensemate/features/auth/presentation/widgets/feild_lable_widget.dart';
import 'package:xpensemate/features/budget/domain/entities/budget_goal_entity.dart';

class BudgetFormPage extends StatefulWidget {
  const BudgetFormPage({
    super.key,
    this.budget,
    required this.onSave,
    this.onCancel,
  });

  final BudgetGoalEntity? budget;
  final void Function(BudgetGoalEntity budget) onSave;
  final VoidCallback? onCancel;

  @override
  State<BudgetFormPage> createState() => _BudgetFormPageState();
}

class _BudgetFormPageState extends State<BudgetFormPage>
    with SingleTickerProviderStateMixin {
  late final FormGroup _form;
  late final List<String> _predefinedCategories;
  bool _isCustomCategoryMode = false;

  static const _priorityOptions = ['High', 'Medium', 'Low', 'Critical'];
  static const _statusOptions = [
    'active',
    'achieved',
    'failed',
    'terminated',
    'other',
  ];

  // ── Animation Controllers ───────────────────────────────
  late final AnimationController _animController;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _initializeForm();

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

    _form = FormGroup({
      'name': FormControl<String>(
        validators: [Validators.required, Validators.maxLength(100), Validators.minLength(2)],
      ),
      'amount': FormControl<String>(
        validators: [Validators.required, Validators.pattern(r'^(\d+(\.\d+)?|\.\d+|\d*)$')],
      ),
      'date': FormControl<DateTime>(validators: [Validators.required]),
      'category': FormControl<String>(validators: [Validators.required]),
      'customCategory': FormControl<String>(),
      'priority': FormControl<String>(validators: [Validators.required], value: 'Medium'),
      'status': FormControl<String>(validators: [Validators.required], value: 'active'),
      'detail': FormControl<String>(),
    });

    if (widget.budget != null) {
      _populateFormFromBudget(widget.budget!);
    } else {
      _form.control('date').value = DateTime.now().add(const Duration(days: 30));
    }
  }

  void _populateFormFromBudget(BudgetGoalEntity budget) {
    _form.control('name').value = budget.name;
    _form.control('amount').value = budget.amount.toStringAsFixed(2);
    _form.control('date').value = budget.date;
    _form.control('detail').value = budget.detail;

    // Handle priority
    final priorityInfo = _priorityOptions.firstWhere(
        (p) => p.toLowerCase() == budget.priority.toLowerCase(), 
        orElse: () => 'Medium',);
    _form.control('priority').value = priorityInfo;

    // Handle status
    final statusInfo = _statusOptions.firstWhere(
        (s) => s.toLowerCase() == budget.status.toLowerCase(), 
        orElse: () => 'active',);
    _form.control('status').value = statusInfo;

    // Handle category
    final cat = budget.category;
    if (_predefinedCategories.any((c) => c.toLowerCase() == cat.toLowerCase())) {
      final matchingCat = _predefinedCategories.firstWhere((c) => c.toLowerCase() == cat.toLowerCase());
      _form.control('category').value = matchingCat;
    } else if (cat.isNotEmpty) {
      _predefinedCategories.add(cat);
      _form.control('category').value = cat;
    }
  }

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
      if (amount == null || amount <= 0) {
        _form.control('amount').setErrors({'pattern': context.l10n.invalidAmount});
        return;
      }

      final budget = BudgetGoalEntity(
        id: widget.budget?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        userId: widget.budget?.userId ?? sl.authService.currentUser!.id,
        name: (_form.control('name').value as String?)?.trim() ?? '',
        amount: amount,
        date: _form.control('date').value as DateTime? ?? DateTime.now().add(const Duration(days: 30)),
        category: categoryValue,
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
      AppSnackBar.show(context: context, message: error.toString(), type: SnackBarType.error);
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

  List<DropdownMenuItem<String>> _buildPriorityDropdownItems() =>
      _priorityOptions.map((p) => DropdownMenuItem<String>(
            value: p,
            child: Text(p, style: TextStyle(color: context.colorScheme.onSurface)),
          ),).toList();

  List<DropdownMenuItem<String>> _buildStatusDropdownItems() {
    final l10n = context.l10n;
    return _statusOptions.map((s) {
      final displayText = s == 'active'
          ? l10n.statusActive
          : s == 'achieved'
              ? l10n.statusAchieved
              : s == 'failed'
                  ? l10n.statusFailed
                  : s == 'terminated'
                      ? l10n.statusTerminated
                      : s;
      return DropdownMenuItem<String>(
        value: s,
        child: Text(displayText, style: TextStyle(color: context.colorScheme.onSurface)),
      );
    }).toList();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _form.control('date').value as DateTime? ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) _form.control('date').value = picked;
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
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
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
                                    // ── Description ─────────────────
                                    FieldLabel(label: '${l10n.description} *'),
                                    const SizedBox(height: 6),
                                    ReactiveAppField(
                                      formControlName: 'name',
                                      hintText: l10n.description,
                                      prefixIcon: Icon(Icons.description_outlined, size: 18, color: primary.withValues(alpha: 0.7)),
                                      textInputAction: TextInputAction.next,
                                      validationMessages: {
                                        'required': (_) => l10n.fieldRequired,
                                        'minLength': (_) => l10n.fieldTooShort,
                                        'maxLength': (_) => l10n.fieldTooLong,
                                      },
                                    ),
          
                                    const SizedBox(height: 20),
          
                                    // ── Amount ──────────────────────
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
          
                                    // ── Date ──────────────────────
                                    FieldLabel(label: '${l10n.date} *'),
                                    const SizedBox(height: 6),
                                    ReactiveFormConsumer(
                                      builder: (context, form, _) {
                                        final date = form.control('date').value as DateTime?;
                                        return _PickerTile(
                                          icon: Icons.calendar_today_outlined,
                                          text: date != null
                                              ? '${date.day}/${date.month}/${date.year}'
                                              : l10n.selectTargetDate,
                                          hasValue: date != null,
                                          onTap: _selectDate,
                                        );
                                      },
                                    ),
          
                                    const SizedBox(height: 24),
          
                                    // ── Priority & Status ─────────
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              FieldLabel(label: l10n.priorityLabel),
                                              const SizedBox(height: 6),
                                              ReactiveAppField(
                                                formControlName: 'priority',
                                                hintText: l10n.selectPriority,
                                                fieldType: FieldType.dropdown,
                                                dropdownItems: _buildPriorityDropdownItems(),
                                                prefixIcon: Icon(Icons.flag_outlined, size: 18, color: primary.withValues(alpha: 0.7)),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              FieldLabel(label: l10n.statusLabel),
                                              const SizedBox(height: 6),
                                              ReactiveAppField(
                                                formControlName: 'status',
                                                hintText: l10n.selectStatus,
                                                fieldType: FieldType.dropdown,
                                                dropdownItems: _buildStatusDropdownItems(),
                                                prefixIcon: Icon(Icons.info_outline, size: 18, color: primary.withValues(alpha: 0.7)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
          
                                    const SizedBox(height: 24),
          
                                    // ── Extra Details ─────────────
                                    FieldLabel(label: l10n.note),
                                    const SizedBox(height: 6),
                                    ReactiveAppField(
                                      formControlName: 'detail',
                                      hintText: l10n.addNotes,
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
                                      text: (widget.budget == null ? l10n.add : l10n.save).toUpperCase(),
                                      onPressed: _submitForm,
                                    ),
                                  ),
                                  if (widget.onCancel != null) ...[
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: AppButton.secondary(
                                        text: l10n.cancel.toUpperCase(),
                                        onPressed: widget.onCancel,
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
