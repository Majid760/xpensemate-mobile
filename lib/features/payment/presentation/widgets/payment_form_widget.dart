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
import 'package:xpensemate/features/payment/domain/entities/payment_entity.dart';

class PaymentFormWidget extends StatefulWidget {
  const PaymentFormWidget({
    super.key,
    this.payment,
    required this.onSave,
    this.onCancel,
  });

  /// If provided, the form will be in edit mode with the payment data pre-filled
  final PaymentEntity? payment;

  /// Callback when the form is saved
  final void Function(PaymentEntity payment) onSave;

  /// Callback when the form is cancelled
  final VoidCallback? onCancel;

  @override
  State<PaymentFormWidget> createState() => _PaymentFormWidgetState();
}

class _PaymentFormWidgetState extends State<PaymentFormWidget>
    with SingleTickerProviderStateMixin {
  late final FormGroup _form;
  late final List<String> _paymentTypes;
  bool _isCustomPaymentTypeMode = false;

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
    _paymentTypes = [
      'Salary',
      'Subscription',
      'Installment',
      'Advance Payment',
      'Bonus',
      'Refund',
      'Donation',
      'Commission',
    ];

    _form = FormGroup({
      'name': FormControl<String>(
        validators: [
          Validators.required,
          Validators.minLength(2),
          Validators.maxLength(100),
        ],
      ),
      'amount': FormControl<String>(
        validators: [
          Validators.required,
          Validators.pattern(r'^(\d+(\.\d+)?|\.\d+|\d*)$'),
        ],
      ),
      'payer': FormControl<String>(
        validators: [
          Validators.required,
          Validators.minLength(2),
        ],
      ),
      'paymentType': FormControl<String>(
        validators: [Validators.required],
      ),
      'customPaymentType': FormControl<String>(),
      'notes': FormControl<String>(),
      'date': FormControl<DateTime>(
        validators: [Validators.required],
        value: DateTime.now(),
      ),
    });

    if (widget.payment != null) {
      _populateFormFromPayment(widget.payment!);
    }
  }

  void _populateFormFromPayment(PaymentEntity payment) {
    _form.control('name').value = payment.name;
    _form.control('amount').value = payment.amount.toStringAsFixed(2);
    _form.control('payer').value = payment.payer;
    _form.control('notes').value = payment.notes;
    _form.control('date').value = payment.date;

    final type = payment.paymentType;
    // Normalize type comparison
    final existingType = _paymentTypes.firstWhere(
      (t) => t.toLowerCase() == type.toLowerCase(),
      orElse: () => '',
    );

    if (existingType.isNotEmpty) {
      _form.control('paymentType').value = existingType;
      _isCustomPaymentTypeMode = false;
    } else {
      _paymentTypes.add(type[0].toUpperCase() + type.substring(1));
      _form.control('paymentType').value = _paymentTypes.last;
      _isCustomPaymentTypeMode = false;
    }
  }

  Future<void> _submitForm() async {
    try {
      if (!_form.valid) {
        _form.markAllAsTouched();
        AppSnackBar.show(
          context: context,
          message: context.l10n.fillAllRequired,
          type: SnackBarType.error,
        );
        return;
      }

      final amountString = (_form.control('amount').value as String?)?.trim() ?? '0';
      final amount = double.tryParse(amountString);
      if (amount == null || amount < 0) {
        _form.control('amount').setErrors({'pattern': true});
        return;
      }

      String paymentTypeValue;
      if (_isCustomPaymentTypeMode) {
        final customType = _form.control('customPaymentType').value as String?;
        if (customType == null || customType.trim().isEmpty) {
          _form.control('customPaymentType').setErrors({'required': true});
          return;
        }
        paymentTypeValue = customType.trim();
      } else {
        paymentTypeValue = _form.control('paymentType').value as String;
      }

      final payment = PaymentEntity(
        id: widget.payment?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        userId: widget.payment?.userId ?? sl.authService.currentUser!.id,
        name: (_form.control('name').value as String).trim(),
        amount: amount,
        date: _form.control('date').value as DateTime,
        payer: (_form.control('payer').value as String).trim(),
        paymentType: paymentTypeValue.toLowerCase(),
        notes: (_form.control('notes').value as String?)?.trim() ?? '',
        isDeleted: widget.payment?.isDeleted ?? false,
        createdAt: widget.payment?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      widget.onSave(payment);
    } on Exception catch (error) {
      AppSnackBar.show(context: context, message: error.toString());
    }
  }

  List<DropdownMenuItem<String>> _buildPaymentTypeDropdownItems() {
    final primary = context.primaryColor;
    final scheme = context.colorScheme;
    
    return [
      DropdownMenuItem<String>(
        value: 'ADD_CUSTOM_TYPE',
        child: Text(
          context.l10n.addCustomCategory,
          style: TextStyle(color: primary, fontWeight: FontWeight.w600),
        ),
      ),
      DropdownMenuItem<String>(
        enabled: false,
        child: Divider(color: scheme.outlineVariant.withValues(alpha: 0.4), height: 1, thickness: 0.5),
      ),
      ..._paymentTypes.map(
        (type) => DropdownMenuItem<String>(
          value: type,
          child: Text(type, style: TextStyle(color: scheme.onSurface)),
        ),
      ),
    ];
  }

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
                                    // ── Payment Name ─────────────────
                                    FieldLabel(label: '${l10n.paymentName} *'),
                                    const SizedBox(height: 6),
                                    ReactiveAppField(
                                      formControlName: 'name',
                                      hintText: l10n.paymentName,
                                      prefixIcon: Icon(Icons.description_outlined, size: 18, color: primary.withValues(alpha: 0.7)),
                                      textInputAction: TextInputAction.next,
                                      validationMessages: {
                                        'required': (_) => l10n.fieldRequired,
                                        'minLength': (_) => l10n.fieldTooShort,
                                      },
                                    ),

                                    const SizedBox(height: 20),

                                    // ── Amount ───────────────────────
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
                                    ),

                                    const SizedBox(height: 20),

                                    // ── Payer ────────────────────────
                                    FieldLabel(label: '${l10n.payer} *'),
                                    const SizedBox(height: 6),
                                    ReactiveAppField(
                                      formControlName: 'payer',
                                      hintText: l10n.payer,
                                      prefixIcon: Icon(Icons.person_outline, size: 18, color: primary.withValues(alpha: 0.7)),
                                      textInputAction: TextInputAction.next,
                                      validationMessages: {
                                        'required': (_) => l10n.fieldRequired,
                                        'minLength': (_) => l10n.fieldTooShort,
                                      },
                                    ),

                                    const SizedBox(height: 24),

                                    // ── Payment Type ─────────────────
                                    FieldLabel(label: '${l10n.paymentType} *'),
                                    const SizedBox(height: 6),
                                    ReactiveAppField(
                                      formControlName: 'paymentType',
                                      hintText: l10n.selectPaymentType,
                                      fieldType: FieldType.dropdown,
                                      dropdownItems: _buildPaymentTypeDropdownItems(),
                                      prefixIcon: Icon(Icons.category_outlined, size: 18, color: primary.withValues(alpha: 0.7)),
                                      validationMessages: {'required': (_) => l10n.fieldRequired},
                                      onDropdownChanged: (value) {
                                        if (value.value == 'ADD_CUSTOM_TYPE') {
                                          setState(() => _isCustomPaymentTypeMode = true);
                                          _form.control('paymentType').value = null;
                                          _form.control('paymentType').setErrors({});
                                        } else if (value.value != null) {
                                          setState(() => _isCustomPaymentTypeMode = false);
                                          _form.control('customPaymentType').value = null;
                                          _form.control('customPaymentType').setErrors({});
                                        }
                                      },
                                    ),

                                    if (_isCustomPaymentTypeMode) ...[
                                      const SizedBox(height: 18),
                                      FieldLabel(label: '${l10n.paymentType} *'),
                                      const SizedBox(height: 6),
                                      ReactiveAppField(
                                        formControlName: 'customPaymentType',
                                        hintText: l10n.paymentType,
                                        prefixIcon: Icon(Icons.edit_outlined, size: 18, color: primary.withValues(alpha: 0.7)),
                                        textInputAction: TextInputAction.next,
                                        validationMessages: {'required': (_) => l10n.fieldRequired},
                                      ),
                                    ],

                                    const SizedBox(height: 24),

                                    // ── Date ─────────────────────────
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

                                    const SizedBox(height: 24),

                                    // ── Notes ────────────────────────
                                    FieldLabel(label: '${l10n.note} (${l10n.optional})'),
                                    const SizedBox(height: 6),
                                    ReactiveAppField(
                                      formControlName: 'notes',
                                      hintText: l10n.addNotes,
                                      fieldType: FieldType.textarea,
                                      maxLines: 3,
                                      prefixIcon: Icon(Icons.note_alt_outlined, size: 18, color: primary.withValues(alpha: 0.7)),
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
                                      text: (widget.payment == null ? l10n.save : l10n.update).toUpperCase(),
                                      textColor: context.colorScheme.onPrimary,
                                      onPressed: _submitForm,
                                    ),
                                  ),
                                  if (widget.onCancel != null) ...[
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: AppButton.secondary(
                                        text: l10n.cancel.toUpperCase(),
                                        textColor: context.colorScheme.secondary,
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

