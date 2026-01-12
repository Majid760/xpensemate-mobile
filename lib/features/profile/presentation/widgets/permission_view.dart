import 'package:flutter/material.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/service/permission_service.dart';
import 'package:xpensemate/core/service/service_locator.dart';
import 'package:xpensemate/core/theme/app_spacing.dart';
import 'package:xpensemate/core/theme/colors/app_colors.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/widget/app_button.dart';
import 'package:xpensemate/core/widget/app_dialogs.dart';
import 'package:xpensemate/l10n/app_localizations.dart';

class PermissionManagementDialog extends StatefulWidget {
  const PermissionManagementDialog({super.key});

  @override
  State<PermissionManagementDialog> createState() =>
      _PermissionManagementDialogState();
}

class _PermissionManagementDialogState
    extends State<PermissionManagementDialog> {
  bool _isLoading = true;
  final Map<AppPermission, PermissionResult> _permissionStatuses = {};

  @override
  void initState() {
    super.initState();
    _loadPermissions();
  }

  Future<void> _loadPermissions() async {
    setState(() => _isLoading = true);
    for (final permission in AppPermission.values) {
      final result = await sl.permissions.checkPermission(permission);
      _permissionStatuses[permission] = result;
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handlePermissionToggle(AppPermission permission) async {
    final currentStatus = _permissionStatuses[permission];
    if (currentStatus == null) return;

    if (currentStatus.isGranted) {
      // Cannot programmatically disable permissions
      AppDialogs.showTopSnackBar(
        context,
        message: context.l10n.disablePermissionManual,
        type: MessageType.info,
      );
      await sl.permissions.openSettings();
    } else if (currentStatus.isPermanentlyDenied) {
      await sl.permissions.openSettings();
    } else {
      final result = await sl.permissions.requestPermission(permission);
      setState(() {
        _permissionStatuses[permission] = result;
      });
    }
    // Refresh all permissions after potential changes
    await _loadPermissions();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
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
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary.withValues(alpha: 0.1),
                    colorScheme.secondary.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.shield_outlined,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      context.l10n.appPermissions,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon:
                        Icon(Icons.close, color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      shrinkWrap: true,
                      itemCount: AppPermission.values.length,
                      separatorBuilder: (context, index) => Divider(
                          color: colorScheme.outlineVariant
                              .withValues(alpha: 0.5)),
                      itemBuilder: (context, index) {
                        final permission = AppPermission.values[index];
                        final status = _permissionStatuses[permission];
                        return _PermissionListItem(
                          permission: permission,
                          status: status,
                          onToggle: () => _handlePermissionToggle(permission),
                        );
                      },
                    ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: AppButton.primary(
                text: context.l10n.done,
                textColor: context.colorScheme.onPrimary,
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionListItem extends StatelessWidget {
  const _PermissionListItem({
    required this.permission,
    required this.status,
    required this.onToggle,
  });

  final AppPermission permission;
  final PermissionResult? status;
  final VoidCallback onToggle;

  IconData _getIcon() {
    switch (permission) {
      case AppPermission.camera:
        return Icons.camera_alt_outlined;
      case AppPermission.gallery:
      case AppPermission.photos:
        return Icons.photo_library_outlined;
      case AppPermission.notification:
        return Icons.notifications_none_outlined;
      case AppPermission.location:
      case AppPermission.locationWhenInUse:
        return Icons.location_on_outlined;
      case AppPermission.storage:
        return Icons.storage_outlined;
      case AppPermission.mediaLibrary:
        return Icons.perm_media_outlined;
    }
  }

  String _getLabel(AppLocalizations l10n) {
    switch (permission) {
      case AppPermission.camera:
        return l10n.camera;
      case AppPermission.gallery:
        return l10n.gallery;
      case AppPermission.photos:
        return l10n.photos;
      case AppPermission.notification:
        return l10n.notifications;
      case AppPermission.location:
        return l10n.location;
      case AppPermission.locationWhenInUse:
        return l10n.locationInUse;
      case AppPermission.storage:
        return l10n.storage;
      case AppPermission.mediaLibrary:
        return l10n.mediaLibrary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final l10n = context.l10n;
    final isGranted = status?.isGranted ?? false;
    final isPermanentlyDenied = status?.isPermanentlyDenied ?? false;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getIcon(),
              size: 20,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getLabel(l10n),
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  isGranted
                      ? l10n.allowed
                      : (isPermanentlyDenied
                          ? l10n.permanentlyDenied
                          : l10n.denied),
                  style: textTheme.bodySmall?.copyWith(
                    color: isGranted
                        ? AppColors.success
                        : (isPermanentlyDenied
                            ? colorScheme.error
                            : colorScheme.onSurfaceVariant),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (isPermanentlyDenied)
            TextButton(
              onPressed: onToggle,
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: Text(l10n.openSettings),
            )
          else
            Switch(
              value: isGranted,
              onChanged: (_) => onToggle(),
              activeColor: colorScheme.primary,
            ),
        ],
      ),
    );
  }
}
