// import 'package:xpensemate/core/localization/locale_manager.dart';
// import 'package:xpensemate/core/localization/supported_locales.dart';
// import 'package:xpensemate/core/service/storage_service.dart';
// import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart' as top_snack_bar;
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/service/permission_service.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/widget/app_button.dart';
import 'package:xpensemate/core/widget/image_picker_bottom_sheet.dart';

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
          child: Center(child: Text(message, style: const TextStyle(color: textColor, fontSize: 16))),
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

  static void showImagePicker({
    required BuildContext context,
    required dynamic Function(File?) onImageSelected,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ImagePickerBottomSheet(
        onImageSelected: onImageSelected,
      ),
    );
  }
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
  }) => showDialog<bool>(
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
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ),);

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ),);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ),);

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
                margin: EdgeInsets.symmetric(horizontal: context.sm, vertical: context.md),
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
                            context.colorScheme.secondary.withValues(alpha: 0.05),
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
                                  color: context.colorScheme.primary.withValues(alpha: 0.3),
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
                                  text: widget.showSettings ? context.l10n.cancel : context.l10n.notNow,
                                  onPressed: () => Navigator.pop(context, false),
                                  borderRadius: 16,
                                ),
                              ),
                              SizedBox(width: context.sm),
                              Expanded(
                                child: AppButton.primary(
                                  text: widget.showSettings ? context.l10n.openSettings : 'Continue',
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


