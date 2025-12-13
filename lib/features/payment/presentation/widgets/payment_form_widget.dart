import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:xpensemate/core/service/service_locator.dart';
import 'package:xpensemate/core/theme/app_spacing.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/widget/app_button.dart';
import 'package:xpensemate/core/widget/app_snackbar.dart';
import 'package:xpensemate/features/auth/presentation/widgets/custom_text_form_field.dart';
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
    with TickerProviderStateMixin {
  late final FormGroup _form;
  late final List<String> _paymentTypes;
  bool _isCustomPaymentTypeMode = false;

  // Animation controllers and animations
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeForm();
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
          Validators.pattern(
            r'^(\d+(\.\d+)?|\.\d+|\d*)$',
          ), // Allow only valid numeric input
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
        value: DateTime.now(), // Default value
      ),
    });

    if (widget.payment != null) {
      _populateFormFromPayment(widget.payment!);
    } else {
      // Additional defaults just in case, though defined in control
      // Payment type not set by default to force selection or could set first
    }
  }

  void _populateFormFromPayment(PaymentEntity payment) {
    _form.control('name').value = payment.name;
    _form.control('amount').value = payment.amount.toStringAsFixed(2);
    _form.control('payer').value = payment.payer;
    _form.control('notes').value = payment.notes;
    _form.control('date').value = payment.date;

    final type = payment.paymentType;
    if (_paymentTypes.contains(type)) {
      _form.control('paymentType').value = type;
      _isCustomPaymentTypeMode = false;
    } else {
      // If it's a custom type or one not in our static list anymore
      // We can add it or just treat as custom mode
      if (!_paymentTypes.contains(type)) {
        _paymentTypes.add(type);
        _form.control('paymentType').value = type;
      }
    }
  }

  @override
  void dispose() {
    _form.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
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

      // Check amount validity specifically for negative values if pattern passed
      final amountString =
          (_form.control('amount').value as String?)?.trim() ?? '0';
      final amount = double.tryParse(amountString);
      if (amount == null || amount < 0) {
        _form.control('amount').setErrors({
          'min': true,
        }); // Manually set error if negative logic missed by pattern (pattern usually allows positive, but ensure)
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
        // Add to list for internal consistency if needed again
        if (!_paymentTypes
            .any((t) => t.toLowerCase() == paymentTypeValue.toLowerCase())) {
          _paymentTypes.add(paymentTypeValue);
        }
      } else {
        paymentTypeValue = _form.control('paymentType').value as String;
      }

      final payment = PaymentEntity(
        id: widget.payment?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
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
    final items = <DropdownMenuItem<String>>[];
    final colorScheme = Theme.of(context).colorScheme;

    // Add "Add Custom Type" option
    items.add(
      DropdownMenuItem<String>(
        value: 'ADD_CUSTOM_TYPE',
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            0,
          ),
          child: Text(
            '+ Add Custom Payment Type',
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );

    items.add(
      DropdownMenuItem<String>(
        enabled: false,
        child: Divider(
          color: colorScheme.outline.withValues(alpha: 0.2),
          height: 1,
        ),
      ),
    );

    items.addAll(
      _paymentTypes
          .map(
            (type) => DropdownMenuItem<String>(
              value: type,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                child: Text(
                  type,
                  style: TextStyle(color: colorScheme.onSurface),
                ),
              ),
            ),
          )
          .toList(),
    );

    return items;
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                ReactiveForm(
                  formGroup: _form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Name Field
                      ReactiveAppField(
                        formControlName: 'name',
                        labelText: 'Payment Name *',
                        hintText: 'Enter payment name',
                        prefixIcon: Icon(
                          Icons.description_outlined,
                          color: colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.6),
                        ),
                        textInputAction: TextInputAction.next,
                        validationMessages: {
                          'required': (error) => 'Name is required',
                          'minLength': (error) =>
                              'Must be at least 2 characters',
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Amount Field
                      ReactiveAppField(
                        formControlName: 'amount',
                        labelText: 'Amount *',
                        hintText: 'e.g 5000',
                        fieldType: FieldType.number,
                        prefixIcon: Icon(
                          Icons.attach_money_outlined,
                          color: colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.6),
                        ),
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*$'),
                          ),
                        ],
                        validationMessages: {
                          'required': (error) => 'Amount is required',
                          'pattern': (error) => 'Invalid amount',
                          'min': (error) => 'Amount must be positive',
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Payer Field
                      ReactiveAppField(
                        formControlName: 'payer',
                        labelText: 'Payer *',
                        hintText: 'Enter payer name',
                        prefixIcon: Icon(
                          Icons.person_outline,
                          color: colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.6),
                        ),
                        textInputAction: TextInputAction.next,
                        validationMessages: {
                          'required': (error) => 'Payer is required',
                          'minLength': (error) =>
                              'Must be at least 3 characters',
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Payment Type Dropdown
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ReactiveAppField(
                            formControlName: 'paymentType',
                            labelText: 'Payment Type *',
                            hintText: 'Select Payment Type',
                            dropdownItems: _buildPaymentTypeDropdownItems(),
                            fieldType: FieldType.dropdown,
                            validationMessages: {
                              'required': (error) => 'Payment Type is required',
                            },
                            onDropdownChanged: (value) {
                              if (value.value == 'ADD_CUSTOM_TYPE') {
                                setState(() {
                                  _isCustomPaymentTypeMode = true;
                                });
                                _form.control('paymentType').value = null;
                                _form.control('paymentType').setErrors({});
                              } else if (value.value != null) {
                                setState(() {
                                  _isCustomPaymentTypeMode = false;
                                });
                                _form.control('customPaymentType').value = null;
                                _form
                                    .control('customPaymentType')
                                    .setErrors({});
                              }
                            },
                          ),
                          if (_isCustomPaymentTypeMode) ...[
                            const SizedBox(height: AppSpacing.md),
                            ReactiveAppField(
                              formControlName: 'customPaymentType',
                              labelText: 'Custom Payment Type *',
                              hintText: 'Enter custom type',
                              prefixIcon: Icon(
                                Icons.category_outlined,
                                color: colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.6),
                              ),
                              textInputAction: TextInputAction.next,
                              validationMessages: {
                                'required': (error) =>
                                    'Custom type is required',
                              },
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Date Field (Custom Look akin to ExpenseForm)
                      Column(
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
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: context.colorScheme.outline
                                    .withValues(alpha: 0.2),
                                width: 1.5,
                              ),
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
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.md,
                                      vertical: AppSpacing.md,
                                    ),
                                    // decoration is in decorated box for shadow
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
                                              : 'Select Date',
                                          style: textTheme.bodyLarge?.copyWith(
                                            color: date != null
                                                ? colorScheme.onSurface
                                                : colorScheme.onSurfaceVariant,
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
                      const SizedBox(height: AppSpacing.md),

                      // Notes Field
                      ReactiveAppField(
                        formControlName: 'notes',
                        labelText: 'Notes (Optional)',
                        hintText: 'Add a note',
                        prefixIcon: Icon(
                          Icons.note_alt_outlined,
                          color: colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.6),
                        ),
                        textInputAction: TextInputAction.done,
                        maxLines: 3,
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Buttons
                      Row(
                        children: [
                          if (widget.onCancel != null) ...[
                            Expanded(
                              child: AppButton.outline(
                                text: "Cancel",
                                onPressed: widget.onCancel!,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                          ],
                          Expanded(
                            child: AppButton.primary(
                              text: widget.payment == null
                                  ? "Save Payment"
                                  : "Update Payment",
                              onPressed: _submitForm,
                              textColor: colorScheme.onPrimary,
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
        ),
      ),
    );
  }
}
