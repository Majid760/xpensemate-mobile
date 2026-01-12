// import 'package:xpensemate/core/localization/locale_manager.dart';
// import 'package:xpensemate/core/localization/supported_locales.dart';
// import 'package:xpensemate/core/service/storage_service.dart';
// import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart' as top_snack_bar;
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/service/permission_service.dart';
import 'package:xpensemate/core/service/service_locator.dart';
import 'package:xpensemate/core/theme/app_spacing.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/widget/app_button.dart';
import 'package:xpensemate/core/widget/image_picker_bottom_sheet.dart';
import 'package:xpensemate/features/profile/presentation/widgets/permission_view.dart';

enum MessageType { error, info, success, warning, primary, defaultType }

class AppDialogs {
  static void showTopSnackBar(
    BuildContext context, {
    required String message,
    MessageType type = MessageType.defaultType,
  }) {
    final theme = Theme.of(context);

    // Define the primary button gradient
    const primaryGradient = LinearGradient(
      colors: [
        Color(0xFF6366F1), // indigo-500
        Color(0xFFA855F7), // purple-500
      ],
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
    );

    // Determine background color and gradient based on type
    Color backgroundColor;
    LinearGradient? gradient;

    switch (type) {
      case MessageType.success:
      case MessageType.info:
      case MessageType.defaultType:
        backgroundColor = theme.colorScheme.primary;
        gradient = primaryGradient;
        break;
      default:
        backgroundColor = getColorFromType(type, context);
        gradient = null;
        break;
    }

    const textColor = Colors.white; // Always use white text for better contrast

    top_snack_bar.showTopSnackBar(
      Overlay.of(context),
      Material(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 18,
          ),
          decoration: BoxDecoration(
            gradient: gradient,
            color: gradient == null ? backgroundColor : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              message,
              style: const TextStyle(color: textColor, fontSize: 16),
            ),
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      reverseAnimationDuration: const Duration(milliseconds: 800),
    );
  }

  // get the color from the type

  static Color getColorFromType(MessageType type, BuildContext context) {
    final theme = Theme.of(context);
    switch (type) {
      case MessageType.error:
        return theme.colorScheme.error;
      case MessageType.info:
        return theme.colorScheme.primary;
      case MessageType.success:
        return Colors.green;
      case MessageType.warning:
        return Colors.orange;
      case MessageType.primary:
        return Colors.blue;
      case MessageType.defaultType:
        return Colors.blue;
    }
  }

  // get icons from the type

  static IconData getIconFromType(MessageType type) {
    switch (type) {
      case MessageType.error:
        return Icons.error;
      case MessageType.info:
        return Icons.info;
      case MessageType.success:
        return Icons.check_circle;
      case MessageType.warning:
        return Icons.warning;
      case MessageType.primary:
        return Icons.info;
      case MessageType.defaultType:
        return Icons.info;
    }
  }

  static Future<void> showImagePicker({
    required BuildContext context,
    required dynamic Function(File?) onImageSelected,
  }) async {
    try {
      final result = await sl.permissions.requestMultiplePermissions(
        [AppPermission.camera, AppPermission.gallery],
      );

      final cameraGranted = result[AppPermission.camera]?.isGranted ?? false;
      final galleryGranted = result[AppPermission.gallery]?.isGranted ?? false;
      final cameraDenied =
          result[AppPermission.camera]?.isPermanentlyDenied ?? false;
      final galleryDenied =
          result[AppPermission.gallery]?.isPermanentlyDenied ?? false;

      if (context.mounted && (cameraGranted || galleryGranted)) {
        await showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => ImagePickerBottomSheet(
            onImageSelected: onImageSelected,
          ),
        );
      } else {
        if (context.mounted) {
          // Show modern permission dialog
          await showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (context) => _ModernPermissionDialog(
              cameraGranted: cameraGranted,
              galleryGranted: galleryGranted,
              cameraDenied: cameraDenied,
              galleryDenied: galleryDenied,
              onTryAgain: () {
                Navigator.pop(context);
                showImagePicker(
                  context: context,
                  onImageSelected: onImageSelected,
                );
              },
              onOpenSettings: () async {
                Navigator.pop(context);
                await _openSpecificSettings(context);
              },
              onCancel: () => Navigator.pop(context),
            ),
          );
        }
      }
    } on Exception catch (e) {
      // Show error dialog to user
      if (context.mounted) {
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(
              'An error occurred while trying to access the camera and gallery: $e',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  static Future<void> showPermissionManagementDialog(BuildContext context) =>
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const PermissionManagementDialog(),
      );
}

class PermissionDialog extends StatefulWidget {
  const PermissionDialog({
    super.key,
    required this.title,
    required this.message,
    this.permission,
    this.showSettings = false,
  });

  final String title;
  final String message;
  final AppPermission? permission;
  final bool showSettings;

  @override
  State<PermissionDialog> createState() => _PermissionDialogState();

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    AppPermission? permission,
    bool showSettings = false,
  }) =>
      showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => PermissionDialog(
          title: title,
          message: message,
          permission: permission,
          showSettings: showSettings,
        ),
      );
}

class _PermissionDialogState extends State<PermissionDialog>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeOutCubic,
      ),
    );

    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: context.sm,
                  vertical: context.md,
                ),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.95,
                  minWidth: MediaQuery.of(context).size.width * 0.8,
                ),
                decoration: BoxDecoration(
                  color: context.colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: context.colorScheme.shadow.withValues(alpha: 0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with gradient
                    Container(
                      padding: EdgeInsets.all(context.md),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            context.colorScheme.primary.withValues(alpha: 0.1),
                            context.colorScheme.secondary
                                .withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        children: [
                          // Permission icon
                          Container(
                            padding: EdgeInsets.all(context.md),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  context.colorScheme.primary,
                                  context.colorScheme.secondary,
                                ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: context.colorScheme.primary
                                      .withValues(alpha: 0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Icon(
                              _getPermissionIcon(widget.permission),
                              color: context.colorScheme.onPrimary,
                              size: 24,
                            ),
                          ),
                          SizedBox(height: context.md),
                          // Title
                          Text(
                            widget.title,
                            style: context.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: context.colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    // Content
                    Padding(
                      padding: EdgeInsets.all(context.md),
                      child: Column(
                        children: [
                          Text(
                            widget.message,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: context.lg),
                          // Buttons
                          Row(
                            children: [
                              Expanded(
                                child: AppButton.outline(
                                  text: widget.showSettings
                                      ? context.l10n.cancel
                                      : context.l10n.notNow,
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  borderRadius: 16,
                                ),
                              ),
                              SizedBox(width: context.sm),
                              Expanded(
                                child: AppButton.primary(
                                  text: widget.showSettings
                                      ? context.l10n.openSettings
                                      : 'Continue',
                                  onPressed: () => Navigator.pop(context, true),
                                  borderRadius: 16,
                                  isFullWidth: false,
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
        ),
      );

  IconData _getPermissionIcon(AppPermission? permission) {
    switch (permission) {
      case AppPermission.camera:
        return Icons.camera_alt_rounded;
      case AppPermission.gallery:
      case AppPermission.photos:
        return Icons.photo_library_rounded;
      case AppPermission.notification:
        return Icons.notifications_rounded;
      case AppPermission.location:
      case AppPermission.locationWhenInUse:
        return Icons.location_on_rounded;
      case AppPermission.storage:
        return Icons.storage_rounded;
      case AppPermission.mediaLibrary:
        return Icons.media_bluetooth_on_rounded;
      default:
        return Icons.security_rounded;
    }
  }
}

// ------------------------------------------------------------------
//  Modern Permission Dialog
// ------------------------------------------------------------------

class _ModernPermissionDialog extends StatefulWidget {
  const _ModernPermissionDialog({
    required this.cameraGranted,
    required this.galleryGranted,
    required this.cameraDenied,
    required this.galleryDenied,
    required this.onTryAgain,
    required this.onOpenSettings,
    required this.onCancel,
  });

  final bool cameraGranted;
  final bool galleryGranted;
  final bool cameraDenied;
  final bool galleryDenied;
  final VoidCallback onTryAgain;
  final VoidCallback onOpenSettings;
  final VoidCallback onCancel;

  @override
  State<_ModernPermissionDialog> createState() =>
      _ModernPermissionDialogState();
}

class _ModernPermissionDialogState extends State<_ModernPermissionDialog>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final isPermanentlyDenied = widget.cameraDenied || widget.galleryDenied;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: context.lg),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.08),
              blurRadius: 48,
              offset: const Offset(0, 16),
            ),
          ],
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with gradient and icon
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(context.lg),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primary.withValues(alpha: 0.1),
                    colorScheme.secondary.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.25),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      isPermanentlyDenied
                          ? Icons.settings_outlined
                          : Icons.photo_camera_outlined,
                      size: 28,
                      color: colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: context.md),
                  Text(
                    isPermanentlyDenied
                        ? l10n.permissionRequired
                        : '${l10n.camera} & ${l10n.gallery} ${l10n.permissionRequired}',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(context.lg),
              child: Column(
                children: [
                  Text(
                    isPermanentlyDenied
                        ? l10n.permissionDeniedMessage
                        : '${l10n.cameraPermissionMessage} ${l10n.galleryPermissionMessage}',
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  if (isPermanentlyDenied) ...[
                    SizedBox(height: context.md),

                    // Permission status indicators
                    Container(
                      padding: EdgeInsets.all(context.sm),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          _SimplePermissionRow(
                            icon: Icons.camera_alt_outlined,
                            label: l10n.camera,
                            isGranted: widget.cameraGranted,
                          ),
                          SizedBox(height: context.xs),
                          _SimplePermissionRow(
                            icon: Icons.photo_library_outlined,
                            label: l10n.gallery,
                            isGranted: widget.galleryGranted,
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: context.lg),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: _PermissionDialogButton(
                          text: l10n.cancel,
                          onPressed: widget.onCancel,
                          isPrimary: false,
                        ),
                      ),
                      SizedBox(width: context.sm),
                      Expanded(
                        child: _PermissionDialogButton(
                          text: isPermanentlyDenied
                              ? l10n.openSettings
                              : l10n.proceed,
                          onPressed: isPermanentlyDenied
                              ? widget.onOpenSettings
                              : widget.onTryAgain,
                          isPrimary: true,
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

class _PermissionDialogButton extends StatefulWidget {
  const _PermissionDialogButton({
    required this.text,
    required this.onPressed,
    required this.isPrimary,
  });

  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;

  @override
  State<_PermissionDialogButton> createState() =>
      _PermissionDialogButtonState();
}

class _PermissionDialogButtonState extends State<_PermissionDialogButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1,
      end: 0.95,
    ).animate(
      CurvedAnimation(
        parent: _pressController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    await _pressController.forward();
    await _pressController.reverse();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Color backgroundColor;
    Color textColor;
    Color borderColor;
    List<Color> gradientColors;

    if (widget.isPrimary) {
      backgroundColor = colorScheme.primary;
      textColor = colorScheme.onPrimary;
      borderColor = colorScheme.primary;
      gradientColors = [colorScheme.primary, colorScheme.secondary];
    } else {
      backgroundColor = colorScheme.surface;
      textColor = colorScheme.onSurface;
      borderColor = colorScheme.outline.withValues(alpha: 0.3);
      gradientColors = [
        colorScheme.surface,
        colorScheme.surface,
      ];
    }

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) => _pressController.forward(),
        onTapUp: (_) => _pressController.reverse(),
        onTapCancel: () => _pressController.reverse(),
        onTap: _handleTap,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            gradient: widget.isPrimary
                ? LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: widget.isPrimary ? null : backgroundColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: widget.isPrimary
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Center(
            child: Text(
              widget.text,
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: textColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SimplePermissionRow extends StatelessWidget {
  const _SimplePermissionRow({
    required this.icon,
    required this.label,
    required this.isGranted,
  });

  final IconData icon;
  final String label;
  final bool isGranted;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(
          icon,
          color: colorScheme.onSurfaceVariant,
          size: 20,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ),
        Icon(
          isGranted ? Icons.check_circle : Icons.cancel,
          color: isGranted
              ? colorScheme.primary.withValues(alpha: 0.8)
              : colorScheme.error,
          size: 20,
        ),
      ],
    );
  }
}

// ------------------------------------------------------------------
//  Settings Navigation Helper
// ------------------------------------------------------------------

Future<void> _openSpecificSettings(BuildContext context) async {
  // Show guidance dialog first, then open settings
  final shouldOpenSettings = await showDialog<bool>(
    context: context,
    builder: (context) => _SettingsGuidanceDialog(),
  );

  // If user chose to open settings, do it
  if (shouldOpenSettings ?? false) {
    await openAppSettings();
  }
}

class _SettingsGuidanceDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: context.lg),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(context.lg),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primary.withValues(alpha: 0.1),
                    colorScheme.secondary.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.25),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      Icons.settings_applications_outlined,
                      size: 28,
                      color: colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: context.md),
                  Text(
                    'Privacy Settings Guide',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(context.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'To enable camera and gallery permissions:',
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: context.md),

                  // Step-by-step guide
                  const _SettingsStep(
                    step: '1',
                    title: 'Open Privacy & Security',
                    description:
                        'In Settings app, scroll down and tap "Privacy & Security"',
                    icon: Icons.privacy_tip_outlined,
                  ),
                  SizedBox(height: context.sm),

                  const _SettingsStep(
                    step: '2',
                    title: 'Select Camera or Photos',
                    description:
                        'Tap "Camera" for camera access or "Photos" for gallery access',
                    icon: Icons.photo_camera_outlined,
                  ),
                  SizedBox(height: context.sm),

                  const _SettingsStep(
                    step: '3',
                    title: 'Enable Xpensemate',
                    description:
                        'Find "Xpensemate" in the list and toggle it ON',
                    icon: Icons.toggle_on,
                  ),

                  SizedBox(height: context.lg),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: _PermissionDialogButton(
                          text: l10n.cancel,
                          onPressed: () => Navigator.pop(context, false),
                          isPrimary: false,
                        ),
                      ),
                      SizedBox(width: context.sm),
                      Expanded(
                        child: _PermissionDialogButton(
                          text: 'Open Settings',
                          onPressed: () => Navigator.pop(context, true),
                          isPrimary: true,
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

class _SettingsStep extends StatelessWidget {
  const _SettingsStep({
    required this.step,
    required this.title,
    required this.description,
    required this.icon,
  });

  final String step;
  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step number
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              step,
              style: textTheme.labelMedium?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(width: context.sm),

        // Icon
        Container(
          padding: EdgeInsets.all(context.xs),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: colorScheme.primary,
          ),
        ),
        SizedBox(width: context.sm),

        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: context.xs),
              Text(
                description,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
