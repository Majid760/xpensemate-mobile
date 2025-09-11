import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:reactive_phone_form_field/reactive_phone_form_field.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/widget/app_bottom_sheet.dart';
import 'package:xpensemate/core/widget/app_button.dart';
import 'package:xpensemate/core/widget/app_dialogs.dart';
import 'package:xpensemate/core/widget/app_snackbar.dart';
import 'package:xpensemate/core/widget/profile_image_widget.dart';
import 'package:xpensemate/features/auth/domain/entities/user.dart';
import 'package:xpensemate/features/auth/presentation/widgets/custom_text_form_field.dart';
import 'package:xpensemate/features/profile/presentation/cubit/cubit/profile_cubit.dart';
import 'package:xpensemate/features/profile/presentation/cubit/cubit/profile_state.dart';

class ProfileEditWidget extends StatefulWidget {
  const ProfileEditWidget({
    super.key,
  });

  @override
  State<ProfileEditWidget> createState() => _ProfileEditWidgetState();
}

class _ProfileEditWidgetState extends State<ProfileEditWidget>
    with TickerProviderStateMixin {
  late final FormGroup _form;

  DateTime? _selectedDateOfBirth;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    final profileCubit = context.profileCubit;
    final user = profileCubit.state.user;

    // Parse date from string if available
    DateTime? parsedDate;
    if (user?.dob != null && user!.dob!.isNotEmpty) {
      try {
        parsedDate = DateTime.parse(user.dob!);
      } on Exception catch (_) {
        // Keep null if parsing fails
      }
    }
    // Parse and set initial phone number from stored user data
    final storedPhone = user?.phoneNumber;
    PhoneNumber? parsedPhone;

    // Parse and set initial phone number from stored user data
    if (storedPhone != null && storedPhone.isNotEmpty) {
      try {
        // Try parsing assuming international format (e.g., "+1 ...")
        parsedPhone = PhoneNumber.parse(storedPhone);
      } on Exception catch (_) {
        // Fallback: try parsing with locale-based ISO country
        final localeCountry = Localizations.maybeLocaleOf(context)?.countryCode;
        var fallbackIso = IsoCode.US;
        if (localeCountry != null && localeCountry.isNotEmpty) {
          try {
            fallbackIso = IsoCode.values.firstWhere(
              (c) => c.name.toUpperCase() == localeCountry.toUpperCase(),
              orElse: () => IsoCode.US,
            );
          } on Exception catch (_) {}
        }
        try {
          parsedPhone = PhoneNumber.parse(
            storedPhone,
            destinationCountry: fallbackIso,
          );
        } on Exception catch (_) {}
      }
    }

    // Parse gender from string if available
    String? parsedGender;
    if (user?.gender != null && user!.gender!.isNotEmpty) {
      // Map gender enum to display name
      switch (user.gender!.toLowerCase()) {
        case 'male':
          parsedGender = 'Male';
          break;
        case 'female':
          parsedGender = 'Female';
          break;
        case 'other':
          parsedGender = 'Other';
          break;
        default:
          parsedGender = 'Other';
      }
    }

    _form = FormGroup({
      'name': FormControl<String>(
        value: user?.name ?? '',
        validators: [
          Validators.required,
          Validators.minLength(4),
        ],
      ),
      'gender': FormControl<String>(
        value: parsedGender ?? '',
      ),
      'dob': FormControl<String>(
        value: parsedDate != null
            ? '${parsedDate.day}/${parsedDate.month}/${parsedDate.year}'
            : '',
      ),
      'about': FormControl<String>(
        value: user?.about ?? '',
      ),
      'contactNumber': FormControl<PhoneNumber>(
        value: parsedPhone,
      ),
    });

    _selectedDateOfBirth = parsedDate;
    _initializeAnimations();
  }

  @override
  void dispose() {
    _form.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
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

  Future<void> _selectDate() async {
    // Calculate date ranges: 7 years to 100 years old
    final now = DateTime.now();
    final sevenYearsAgo = DateTime(now.year - 7, now.month, now.day);
    final hundredYearsAgo = DateTime(now.year - 100, now.month, now.day);

    // Set initial date: use selected date, or 7 years ago if no date set
    final initialDate = _selectedDateOfBirth ?? sevenYearsAgo;

    // Ensure initial date is within valid range
    final validInitialDate = initialDate.isAfter(hundredYearsAgo) &&
            initialDate.isBefore(sevenYearsAgo)
        ? initialDate
        : sevenYearsAgo;

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: validInitialDate,
      firstDate: hundredYearsAgo,
      lastDate: sevenYearsAgo,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          datePickerTheme: DatePickerThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            headerBackgroundColor: Theme.of(context).colorScheme.primary,
            headerForegroundColor: Theme.of(context).colorScheme.onPrimary,
            backgroundColor: context.colorScheme.surface,
            surfaceTintColor: Colors.transparent,
          ),
        ),
        child: child!,
      ),
    );

    if (selectedDate != null) {
      // Validate the selected date
      final now = DateTime.now();
      final sevenYearsAgo = DateTime(now.year - 7, now.month, now.day);
      final hundredYearsAgo = DateTime(now.year - 100, now.month, now.day);
      if (selectedDate.isAfter(sevenYearsAgo) && mounted) {
        AppSnackBar.show(
          context: context,
          message: 'You must be at least 7 years old',
          type: SnackBarType.error,
        );

        return;
      }
      if (selectedDate.isBefore(hundredYearsAgo) && mounted) {
        AppSnackBar.show(
          context: context,
          message: 'You cannot be more than 100 years old',
          type: SnackBarType.error,
        );

        return;
      }

      setState(() {
        _selectedDateOfBirth = selectedDate;
      });
      // Update the form control
      _form.control('dob').value =
          '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}';
      await HapticFeedback.selectionClick();
    }
  }

  Future<void> _handleSave(ProfileCubit profileCubit) async {
    _form.markAllAsTouched();

    if (!_form.valid) return;
    // Parse gender from form

    final formdata = Map<String, Object?>.from(_form.value);
    formdata['dob'] = DateFormat("d/M/yyyy")
        .parse(formdata['dob']! as String)
        .toIso8601String();
    formdata['gender'] = formdata['gender'].toString().toLowerCase();
    formdata['firstName'] = formdata['name'].toString().split(' ').first;
    formdata['lastName'] = formdata['name'].toString().split(' ').last;

    // Serialize contactNumber as required by API: { "isoCode": "US", "nsn": "74745" }
    final contact = formdata['contactNumber'];
    if (contact is PhoneNumber) {
      formdata['contactNumber'] = {
        'isoCode': contact.isoCode.name,
        'nsn': contact.nsn,
      };
    }
    await profileCubit.updateProfile(formdata);
  }

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state.status == ProfileStatus.error &&
              state.message != null &&
              state.message!.isNotEmpty) {
            AppSnackBar.show(
              context: context,
              message: state.message!,
              type: SnackBarType.error,
            );
          }
          if (state.status == ProfileStatus.loaded &&
              (state.message?.isNotEmpty ?? false)) {
            AppSnackBar.show(
              context: context,
              message: context.l10n.profileUpdatedSuccessfully,
              type: SnackBarType.success,
            );
            Navigator.pop(context);
          }
        },
        builder: (context, state) => FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ReactiveForm(
              formGroup: _form,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    Center(
                      child: ProfileImageWidget(
                        imageFile: state.imageFile,
                        imageUrl:
                            context.profileCubit.state.user?.profilePhotoUrl,
                        onImageTap: () {
                          AppDialogs.showImagePicker(
                            context: context,
                            onImageSelected: (file) {
                              if (file != null) {
                                context.profileCubit.setImageFile(file);
                              }
                            },
                          );
                        },
                      ),
                    ),
                    SizedBox(height: context.xl),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: context.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ReactiveAppField(
                            formControlName: 'name',
                            labelText: context.l10n.fullName,
                            hintText: context.l10n.hintName,
                            prefixIcon: const Icon(
                              Icons.person_outline_rounded,
                              size: 20,
                            ),
                            validationMessages: {
                              'required': (error) =>
                                  context.l10n.nameIsRequired,
                              'minLength': (error) =>
                                  context.l10n.nameMustBeAtLeast4Characters,
                            },
                          ),
                          SizedBox(height: context.lg),
                          ReactiveAppField(
                            formControlName: 'contactNumber',
                            labelText: context.l10n.phoneNumber,
                            fieldType: FieldType.phone,
                            hintText: context.l10n.enterPhoneNumber,
                            prefixIcon:
                                const Icon(Icons.phone_outlined, size: 20),
                            validationMessages: {
                              'phoneValidation': (error) =>
                                  context.l10n.phoneNumberMustBeAtLeast10Digits,
                            },
                          ),
                          SizedBox(height: context.lg),
                          ReactiveAppField(
                            formControlName: 'dob',
                            labelText: context.l10n.dateOfBirth,
                            hintText: context.l10n.selectDateOfBirth,
                            readOnly: true,
                            onTap: _selectDate,
                            prefixIcon: const Icon(
                              Icons.calendar_today_rounded,
                              size: 20,
                            ),
                            validationMessages: {
                              'required': (error) =>
                                  'Date of birth is required',
                            },
                          ),
                          SizedBox(height: context.lg),
                          ReactiveAppField(
                            formControlName: 'gender',
                            labelText: context.l10n.gender,
                            fieldType: FieldType.dropdown,
                            hintText: context.l10n.selectGender,
                            prefixIcon:
                                const Icon(Icons.person_4_rounded, size: 20),
                            onDropdownChanged: (value) {
                              HapticFeedback.selectionClick();
                            },
                          ),
                          SizedBox(height: context.lg),
                          ReactiveAppField(
                            formControlName: 'about',
                            labelText: context.l10n.about,
                            fieldType: FieldType.textarea,
                            hintText: context.l10n.enterYourBio,
                            maxLines: 3,
                            maxLength: 150,
                            fillColor: context
                                .colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.7),
                          ),
                          SizedBox(height: context.xl),
                          AppButton.primary(
                            text: context.l10n.save,
                            isLoading: state.isUpdating,
                            textStyle: context.textTheme.titleMedium?.copyWith(
                              color: context.colorScheme.onPrimary,
                            ),
                            onPressed: () => _handleSave(context.profileCubit),
                          ),
                          SizedBox(height: context.md),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}

void showEditProfile(BuildContext context) {
  final screenHeight = MediaQuery.of(context).size.height;

  AppBottomSheet.show<UserEntity>(
    context: context,
    title: context.l10n.editProfile,
    config: BottomSheetConfig(
      minHeight: screenHeight * 0.7,
      maxHeight: screenHeight * 0.95,
      padding: EdgeInsets.zero,
    ),
    child: const ProfileEditWidget(),
  );
}
