import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xpensemate/core/utils/app_logger.dart';
import 'package:xpensemate/core/widget/app_dialogs.dart';

enum AppPermission {
  camera,
  gallery,
  photos,
  notification,
  location,
  locationWhenInUse,
  storage,
  mediaLibrary,
}

class PermissionResult {
  const PermissionResult({
    required this.isGranted,
    required this.isPermanentlyDenied,
    required this.isRestricted,
    required this.message,
    required this.permission,
  });

  final bool isGranted;
  final bool isPermanentlyDenied;
  final bool isRestricted;
  final String message;
  final AppPermission permission;

  bool get canRequest => !isPermanentlyDenied && !isRestricted;
  bool get needsSettings => isPermanentlyDenied;
}

class StartupPermissionConfig {
  const StartupPermissionConfig({
    this.requiredPermissions = const [
      AppPermission.notification,
      AppPermission.camera,
      AppPermission.gallery,
    ],
    this.showRationaleDialog = true,
    this.rationaleTitle,
    this.rationaleMessage,
  });

  final List<AppPermission> requiredPermissions;
  final bool showRationaleDialog;
  final String? rationaleTitle;
  final String? rationaleMessage;
}

class PermissionService {
  factory PermissionService() => _instance;
  PermissionService._internal();
  static final PermissionService _instance = PermissionService._internal();

  static const String _prefKeyPrefix = 'permission_denied_';
  static const String _prefKeyAppLaunchCount = 'app_launch_count';

  static const Map<AppPermission, Permission> _permissionMap = {
    AppPermission.camera: Permission.camera,
    AppPermission.gallery: Permission.photos,
    AppPermission.photos: Permission.photos,
    AppPermission.notification: Permission.notification,
    AppPermission.location: Permission.location,
    AppPermission.locationWhenInUse: Permission.locationWhenInUse,
    AppPermission.storage: Permission.storage,
    AppPermission.mediaLibrary: Permission.mediaLibrary,
  };

  static const Map<AppPermission, String> _permissionNames = {
    AppPermission.camera: 'Camera',
    AppPermission.gallery: 'Photo Gallery',
    AppPermission.photos: 'Photos',
    AppPermission.notification: 'Notifications',
    AppPermission.location: 'Location',
    AppPermission.locationWhenInUse: 'Location (When in Use)',
    AppPermission.storage: 'Storage',
    AppPermission.mediaLibrary: 'Media Library',
  };

  /// Explain → Request → Return Result
  Future<PermissionResult> showAndRequestPermission(
    AppPermission permission, {
    BuildContext? context,
    String? rationaleTitle,
    String? rationaleMessage,
  }) async {
    final currentStatus = await checkPermission(permission);
    if (currentStatus.isGranted) return currentStatus;

    if (currentStatus.isPermanentlyDenied) {
      if (context != null && context.mounted) {
        return requestPermissionWithSettings(
          permission,
          context: context,
          customMessage: rationaleMessage,
        );
      } else {
        return currentStatus;
      }
    }

    if (context != null && context.mounted) {
      final proceed = await _showGenericRationaleDialog(
        context,
        permission,
        title: rationaleTitle ??
            '${_getPermissionName(permission)} Permission Required',
        message: rationaleMessage ??
            'We need this permission to provide you with the best experience.',
      );
      if (!proceed) {
        return PermissionResult(
          isGranted: false,
          isPermanentlyDenied: false,
          isRestricted: false,
          message: 'User declined permission request',
          permission: permission,
        );
      }
    }

    // Request permission immediately after user agrees
    AppLogger.breadcrumb(
        'PermissionService: Requesting ${_getPermissionName(permission)}');
    final result = await requestPermission(permission);

    // Debug logging
    AppLogger.breadcrumb(
        'PermissionService: ${_getPermissionName(permission)} result - granted: ${result.isGranted}');

    // If permission is granted, clear the denied status
    if (result.isGranted) {
      await _clearPermissionDeniedStatus(permission);
    } else if (!result.isPermanentlyDenied) {
      // If permission is denied but not permanently, mark it as user denied
      await _markPermissionAsUserDenied(permission);
    }

    return result;
  }

  /// Handle startup permissions
  Future<Map<AppPermission, PermissionResult>> handleStartupPermissions({
    BuildContext? context,
    StartupPermissionConfig? config,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final launchCount = prefs.getInt(_prefKeyAppLaunchCount) ?? 0;
    await prefs.setInt(_prefKeyAppLaunchCount, launchCount + 1);

    final permissionConfig = config ?? const StartupPermissionConfig();
    final results = <AppPermission, PermissionResult>{};

    final permissionsToRequest =
        await _getPermissionsToRequest(permissionConfig.requiredPermissions);

    if (permissionsToRequest.isEmpty) {
      for (final p in permissionConfig.requiredPermissions) {
        results[p] = await checkPermission(p);
      }
      return results;
    }

    if (permissionConfig.showRationaleDialog &&
        context != null &&
        context.mounted) {
      final proceed = await _showGenericRationaleDialog(
        context,
        null,
        title: permissionConfig.rationaleTitle ?? 'Permissions Required',
        message: permissionConfig.rationaleMessage ??
            'We need access to: ${permissionsToRequest.map(_getPermissionName).join(', ')} to provide the best experience.',
      );
      if (!proceed) {
        for (final p in permissionsToRequest) {
          await _markPermissionAsUserDenied(p);
          results[p] = PermissionResult(
            isGranted: false,
            isPermanentlyDenied: false,
            isRestricted: false,
            message: 'User declined permission request',
            permission: p,
          );
        }
        return results;
      }
    }

    final requestResults =
        await requestMultiplePermissions(permissionsToRequest);
    for (final entry in requestResults.entries) {
      if (!entry.value.isGranted && !entry.value.isPermanentlyDenied) {
        await _markPermissionAsUserDenied(entry.key);
      }
      results[entry.key] = entry.value;
    }

    for (final p in permissionConfig.requiredPermissions) {
      results[p] ??= await checkPermission(p);
    }
    return results;
  }

  Future<List<AppPermission>> _getPermissionsToRequest(
    List<AppPermission> requiredPermissions,
  ) async {
    final permissionsToRequest = <AppPermission>[];
    for (final permission in requiredPermissions) {
      final status = await checkPermission(permission);
      final wasDenied = await _wasPermissionUserDenied(permission);
      if (!status.isGranted && !status.isPermanentlyDenied && !wasDenied) {
        permissionsToRequest.add(permission);
      }
    }
    return permissionsToRequest;
  }

  Future<bool> _showGenericRationaleDialog(
    BuildContext context,
    AppPermission? permission, {
    required String title,
    required String message,
  }) async {
    if (!context.mounted) return false;
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => PermissionDialog(
            title: title,
            message: message,
            permission: permission,
          ),
        ) ??
        false;
  }

  Future<bool> _wasPermissionUserDenied(AppPermission permission) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_prefKeyPrefix${permission.name}') ?? false;
  }

  Future<void> _markPermissionAsUserDenied(AppPermission permission) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_prefKeyPrefix${permission.name}', true);
  }

  Future<void> _clearPermissionDeniedStatus(AppPermission permission) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefKeyPrefix${permission.name}');
  }

  Future<PermissionResult> checkPermission(AppPermission appPermission) async {
    final permission = _permissionMap[appPermission];
    if (permission == null) {
      return PermissionResult(
        isGranted: false,
        isPermanentlyDenied: false,
        isRestricted: false,
        message: 'Permission not supported',
        permission: appPermission,
      );
    }
    final status = await permission.status;
    return _mapPermissionStatus(status, appPermission);
  }

  Future<PermissionResult> requestPermission(
      AppPermission appPermission) async {
    final permission = _permissionMap[appPermission];
    if (permission == null) {
      return PermissionResult(
        isGranted: false,
        isPermanentlyDenied: false,
        isRestricted: false,
        message: 'Permission not supported',
        permission: appPermission,
      );
    }

    final status = await permission.request();

    final result = _mapPermissionStatus(status, appPermission);
    return result;
  }

  Future<Map<AppPermission, PermissionResult>> requestMultiplePermissions(
    List<AppPermission> appPermissions,
  ) async {
    final permissions = <Permission>[];
    final validAppPermissions = <AppPermission>[];

    for (final appPermission in appPermissions) {
      final permission = _permissionMap[appPermission];
      if (permission != null) {
        permissions.add(permission);
        validAppPermissions.add(appPermission);
      }
    }

    final statuses = await permissions.request();
    final results = <AppPermission, PermissionResult>{};

    for (var i = 0; i < validAppPermissions.length; i++) {
      final appPermission = validAppPermissions[i];
      final permission = permissions[i];
      final status = statuses[permission] ?? PermissionStatus.denied;
      results[appPermission] = _mapPermissionStatus(status, appPermission);
    }
    return results;
  }

  Future<PermissionResult> requestPermissionWithSettings(
    AppPermission appPermission, {
    BuildContext? context,
    String? customMessage,
  }) async {
    final name = _getPermissionName(appPermission);
    if (context != null && context.mounted) {
      final result = await PermissionDialog.show(
        context,
        title: '$name Permission Required',
        message: customMessage ??
            'Please enable $name permission from settings to use this feature.',
        permission: appPermission,
        showSettings: true,
      );

      if (result ?? false) {
        await openAppSettings();
      }

      return checkPermission(appPermission);
    }
    return checkPermission(appPermission);
  }

  PermissionResult _mapPermissionStatus(
    PermissionStatus status,
    AppPermission appPermission,
  ) {
    switch (status) {
      case PermissionStatus.granted:
        return PermissionResult(
          isGranted: true,
          isPermanentlyDenied: false,
          isRestricted: false,
          message: '${_getPermissionName(appPermission)} granted',
          permission: appPermission,
        );
      case PermissionStatus.denied:
        return PermissionResult(
          isGranted: false,
          isPermanentlyDenied: false,
          isRestricted: false,
          message: '${_getPermissionName(appPermission)} denied',
          permission: appPermission,
        );
      case PermissionStatus.permanentlyDenied:
        return PermissionResult(
          isGranted: false,
          isPermanentlyDenied: true,
          isRestricted: false,
          message: '${_getPermissionName(appPermission)} permanently denied',
          permission: appPermission,
        );
      case PermissionStatus.restricted:
        return PermissionResult(
          isGranted: false,
          isPermanentlyDenied: false,
          isRestricted: true,
          message: '${_getPermissionName(appPermission)} restricted',
          permission: appPermission,
        );
      case PermissionStatus.limited:
        return PermissionResult(
          isGranted: true,
          isPermanentlyDenied: false,
          isRestricted: false,
          message: '${_getPermissionName(appPermission)} granted (limited)',
          permission: appPermission,
        );
      case PermissionStatus.provisional:
        return PermissionResult(
          isGranted: true,
          isPermanentlyDenied: false,
          isRestricted: false,
          message: '${_getPermissionName(appPermission)} granted (provisional)',
          permission: appPermission,
        );
    }
  }

  String _getPermissionName(AppPermission appPermission) =>
      _permissionNames[appPermission] ?? appPermission.name;

  Future<bool> _showSettingsDialog(
    BuildContext context,
    AppPermission appPermission,
    String? customMessage,
  ) async {
    final name = _getPermissionName(appPermission);
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => PermissionDialog(
            title: '$name Permission Required',
            message: customMessage ??
                'Please enable $name permission from settings to use this feature.',
            permission: appPermission,
            showSettings: true,
          ),
        ) ??
        false;
  }
}

extension PermissionServiceExtensions on PermissionService {
  Future<Map<AppPermission, PermissionResult>> requestMediaPermissions() =>
      requestMultiplePermissions([AppPermission.camera, AppPermission.gallery]);

  Future<Map<AppPermission, PermissionResult>>
      requestMediaPermissionsWhenNeeded({
    BuildContext? context,
  }) async {
    final results = <AppPermission, PermissionResult>{};
    results[AppPermission.camera] = await showAndRequestPermission(
      AppPermission.camera,
      context: context,
      rationaleMessage: 'We need camera access to take photos.',
    );
    results[AppPermission.gallery] = await showAndRequestPermission(
      AppPermission.gallery,
      context: context,
      rationaleMessage: 'We need gallery access to choose photos.',
    );
    return results;
  }
}
