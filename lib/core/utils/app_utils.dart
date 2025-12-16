// lib/core/utils/app_utils.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/widget/app_custom_dialog.dart';

class AppUtils {
  AppUtils._(); // Prevent instantiation

  // ============ DEBOUNCER ============
  static final Map<String, Timer> _debounceTimers = {};

  /// Debounces function calls with optional key for multiple debouncers
  /// The debounce function is used to delay the execution of a callback function:
  static void debounce(
    VoidCallback callback, {
    Duration delay = const Duration(milliseconds: 500),
    String key = 'default',
  }) {
    _debounceTimers[key]?.cancel();
    _debounceTimers[key] = Timer(delay, callback);
  }

  /// Cancel specific debouncer
  static void cancelDebounce([String key = 'default']) {
    _debounceTimers[key]?.cancel();
    _debounceTimers.remove(key);
  }

  // ============ THROTTLER ============
  static final Map<String, DateTime> _lastExecuted = {};

  /// Throttles function calls - prevents rapid successive calls
  /// The throttle function limits how frequently a function can be called:
  static void throttle(
    VoidCallback callback, {
    Duration delay = const Duration(milliseconds: 1500),
    String key = 'default',
  }) {
    final now = DateTime.now();
    final lastTime = _lastExecuted[key];

    if (lastTime == null || now.difference(lastTime) >= delay) {
      _lastExecuted[key] = now;
      // callback();b nm,. mncbn,k
    }
  }

  // ============ VALIDATOR UTILS ============

  /// Email validation
  static bool isValidEmail(String email) =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);

  /// Phone validation (basic)
  static bool isValidPhone(String phone) =>
      RegExp(r'^\+?[\d\s\-\(\)]{10,}$').hasMatch(phone);

  /// URL validation
  static bool isValidUrl(String url) =>
      Uri.tryParse(url)?.hasAbsolutePath ?? false;

  /// Strong password validation
  static bool isStrongPassword(String password) =>
      password.length >= 8 &&
      password.contains(RegExp('[A-Z]')) &&
      password.contains(RegExp('[a-z]')) &&
      password.contains(RegExp('[0-9]')) &&
      password.contains(RegExp(r'[!@#$&*~]'));

  // ============ STRING UTILS ============

  /// Capitalize first letter
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Title case
  static String titleCase(String text) =>
      text.split(' ').map(capitalize).join(' ');

  /// Remove special characters
  static String removeSpecialChars(String text) =>
      text.replaceAll(RegExp(r'[^\w\s]'), '');

  /// Generate random string
  static String randomString(int length) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(
      length,
      (index) => chars[Random().nextInt(chars.length)],
    ).join();
  }

  /// Truncate text with ellipsis
  static String truncate(String text, int maxLength) =>
      text.length <= maxLength ? text : '${text.substring(0, maxLength)}...';

  // ============ NUMBER UTILS ============

  /// Format currency
  static String formatCurrency(double amount, {String symbol = r'$'}) =>
      '$symbol${amount.toStringAsFixed(2)}';

  /// Format large numbers with k/M notation
  static String formatLargeNumber(double amount, {String symbol = r'$'}) {
    if (amount >= 1000000) {
      // Format as millions
      final formatted = (amount / 1000000).toStringAsFixed(1);
      return '$symbol$formatted M';
    } else if (amount >= 1000) {
      // Format as thousands
      final formatted = (amount / 1000).toStringAsFixed(1);
      return '$symbol$formatted k';
    }
    return '$symbol${amount.toStringAsFixed(1)}';
  }

  /// Format file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Generate random number in range
  static int randomInt(int min, int max) =>
      min + Random().nextInt(max - min + 1);

  /// Check if number is in range
  static bool inRange(num value, num min, num max) =>
      value >= min && value <= max;

  // ============ FILE UTILS ============

  /// Maximum file size constants
  static const int maxImageSizeBytes = 10 * 1024 * 1024; // 10MB
  static const double maxImageSizeMB = 10;

  /// Validate file size
  static bool isValidFileSize(int fileSizeInBytes, {int? maxSizeInBytes}) {
    final maxSize = maxSizeInBytes ?? maxImageSizeBytes;
    return fileSizeInBytes <= maxSize;
  }

  /// Get file size in MB
  static double getFileSizeInMB(int fileSizeInBytes) =>
      fileSizeInBytes / (1024 * 1024);

  /// Validate image file
  static FileValidationResult validateImageFile(File file) {
    try {
      final fileSizeInBytes = file.lengthSync();
      final isValid = isValidFileSize(fileSizeInBytes);
      final sizeInMB = getFileSizeInMB(fileSizeInBytes);

      return FileValidationResult(
        isValid: isValid,
        fileSizeInBytes: fileSizeInBytes,
        fileSizeInMB: sizeInMB,
        maxAllowedSizeMB: maxImageSizeMB,
      );
    } on Exception catch (e) {
      return FileValidationResult(
        isValid: false,
        fileSizeInBytes: 0,
        fileSizeInMB: 0,
        maxAllowedSizeMB: maxImageSizeMB,
        error: e.toString(),
      );
    }
  }

  // ============ DATE/TIME UTILS ============

  /// Format date to readable string
  static String formatDate(DateTime date, {String format = 'dd/MM/yyyy'}) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return format
        .replaceAll('dd', day)
        .replaceAll('MM', month)
        .replaceAll('yyyy', year);
  }

  /// Get time ago string
  static String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year${difference.inDays >= 730 ? 's' : ''} ago';
    }
    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${difference.inDays >= 60 ? 's' : ''} ago';
    }
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    }
    if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    }
    if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    }
    return 'Just now';
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // ============ COLLECTION UTILS ============

  /// Check if list is null or empty
  static bool isNullOrEmpty<T>(List<T>? list) => list == null || list.isEmpty;

  /// Get safe list item
  static T? safeGet<T>(List<T>? list, int index) {
    if (list == null || index < 0 || index >= list.length) return null;
    return list[index];
  }

  /// Remove duplicates from list
  static List<T> removeDuplicates<T>(List<T> list) => list.toSet().toList();

  /// Chunk list into smaller lists
  static List<List<T>> chunk<T>(List<T> list, int size) => List.generate(
        (list.length / size).ceil(),
        (index) => list.skip(index * size).take(size).toList(),
      );

  // ============ DEVICE UTILS ============

  /// Check if device is tablet
  static bool isTablet(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final diagonal = sqrt(pow(size.width, 2) + pow(size.height, 2));
    return diagonal > 1100.0;
  }

  /// Get device type
  static String getDeviceType() {
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isLinux) return 'Linux';
    return 'Unknown';
  }

  /// Haptic feedback
  static void hapticFeedback({
    HapticFeedbackType type = HapticFeedbackType.lightImpact,
  }) {
    switch (type) {
      case HapticFeedbackType.lightImpact:
        HapticFeedback.lightImpact();
        break;
      case HapticFeedbackType.mediumImpact:
        HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackType.heavyImpact:
        HapticFeedback.heavyImpact();
        break;
      case HapticFeedbackType.selectionClick:
        HapticFeedback.selectionClick();
        break;
      case HapticFeedbackType.vibrate:
        HapticFeedback.vibrate();
        break;
    }
  }

  // ============ COLOR UTILS ============

  /// Convert hex string to Color
  static Color hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  /// Generate random color
  static Color randomColor() => Color(Random().nextInt(0xFFFFFFFF));

  // ============ JSON UTILS ============

  /// Safe JSON decode
  static Map<String, dynamic>? safeJsonDecode(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return null;
    try {
      return json.decode(jsonString) as Map<String, dynamic>;
    } on FormatException catch (e) {
      debugPrint('JSON decode error: $e');
      return null;
    }
  }

  /// Safe JSON encode
  static String? safeJsonEncode(dynamic object) {
    try {
      return json.encode(object);
    } on FormatException catch (e) {
      debugPrint('JSON encode error: $e');
      return null;
    }
  }

  // ============ UI UTILS ============

  /// Show loading dialog
  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(message),
            ],
          ],
        ),
      ),
    );
  }

  /// Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  // ============ STORAGE UTILS ============

  /// Copy to clipboard
  static Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  /// Get from clipboard
  static Future<String?> getFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    return data?.text;
  }

  // ============ NETWORK UTILS ============

  /// Check internet connectivity (basic)
  static Future<bool> hasInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  // ============ LOGGER UTILS ============

  /// Custom logger
  static void log(
    dynamic message, {
    String tag = 'APP',
    LogLevel level = LogLevel.info,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final emoji = _getLogEmoji(level);
    debugPrint('$emoji [$timestamp] [$tag] $message');
  }

  static String _getLogEmoji(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '🐛';
      case LogLevel.info:
        return 'ℹ️';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '❌';
    }
  }

  // ============ URL LAUNCHER UTILS ============

  /// Launch URL with comprehensive error handling
  static Future<bool> launchURL(
    String url, {
    LaunchMode mode = LaunchMode.platformDefault,
    bool showErrorDialog = true,
    BuildContext? context,
  }) async {
    try {
      final uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        return await launchUrl(
          uri,
          mode: mode,
        );
      } else {
        if (showErrorDialog && context != null && context.mounted) {
          _showURLErrorDialog(context, 'Cannot launch URL: $url');
        }
        debugPrint('Cannot launch URL: $url');
        return false;
      }
    } on Exception catch (e) {
      if (showErrorDialog && context != null && context.mounted) {
        _showURLErrorDialog(context, 'Error launching URL: $e');
      }
      debugPrint('Error launching URL: $e');
      return false;
    }
  }

  /// Launch email with optional subject and body
  static Future<bool> launchEmail(
    String email, {
    String? subject,
    String? body,
    List<String>? cc,
    List<String>? bcc,
    bool showErrorDialog = true,
    BuildContext? context,
  }) async {
    try {
      final uri = Uri(
        scheme: 'mailto',
        path: email,
        query: _buildEmailQuery(
          subject: subject,
          body: body,
          cc: cc,
          bcc: bcc,
        ),
      );

      return await launchURL(
        uri.toString(),
        showErrorDialog: showErrorDialog,
        context: context,
      );
    } on Exception catch (e) {
      if (showErrorDialog && context != null && context.mounted) {
        _showURLErrorDialog(context, 'Error launching email: $e');
      }
      debugPrint('Error launching email: $e');
      return false;
    }
  }

  /// Launch phone call
  static Future<bool> launchPhone(
    String phoneNumber, {
    bool showErrorDialog = true,
    BuildContext? context,
  }) async {
    try {
      // Remove all non-digit characters except +
      final cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      final uri = Uri(scheme: 'tel', path: cleanedNumber);

      return await launchURL(
        uri.toString(),
        showErrorDialog: showErrorDialog,
        context: context,
      );
    } on Exception catch (e) {
      if (showErrorDialog && context != null && context.mounted) {
        _showURLErrorDialog(context, 'Error launching phone: $e');
      }
      debugPrint('Error launching phone: $e');
      return false;
    }
  }

  /// Launch SMS with optional message
  static Future<bool> launchSMS(
    String phoneNumber, {
    String? message,
    bool showErrorDialog = true,
    BuildContext? context,
  }) async {
    try {
      final cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      final uri = Uri(
        scheme: 'sms',
        path: cleanedNumber,
        query: message != null ? 'body=${Uri.encodeComponent(message)}' : null,
      );

      return await launchURL(
        uri.toString(),
        showErrorDialog: showErrorDialog,
        context: context,
      );
    } on Exception catch (e) {
      if (showErrorDialog && context != null && context.mounted) {
        _showURLErrorDialog(context, 'Error launching SMS: $e');
      }
      debugPrint('Error launching SMS: $e');
      return false;
    }
  }

  /// Launch WhatsApp with optional message
  static Future<bool> launchWhatsApp(
    String phoneNumber, {
    String? message,
    bool showErrorDialog = true,
    BuildContext? context,
  }) async {
    try {
      // Remove all non-digit characters except +
      final cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      final encodedMessage =
          message != null ? Uri.encodeComponent(message) : '';

      final url =
          'https://wa.me/$cleanedNumber${message != null ? '?text=$encodedMessage' : ''}';

      return await launchURL(
        url,
        mode: LaunchMode.externalApplication,
        showErrorDialog: showErrorDialog,
        context: context,
      );
    } on Exception catch (e) {
      if (showErrorDialog && context != null && context.mounted) {
        _showURLErrorDialog(context, 'Error launching WhatsApp: $e');
      }
      debugPrint('Error launching WhatsApp: $e');
      return false;
    }
  }

  /// Launch maps with coordinates or address
  static Future<bool> launchMaps({
    double? latitude,
    double? longitude,
    String? address,
    String? query,
    bool showErrorDialog = true,
    BuildContext? context,
  }) async {
    try {
      String url;

      if (latitude != null && longitude != null) {
        // Open with coordinates
        if (Platform.isIOS) {
          url = 'maps:$latitude,$longitude';
        } else {
          url = 'geo:$latitude,$longitude';
        }
      } else if (address != null) {
        // Open with address
        final encodedAddress = Uri.encodeComponent(address);
        if (Platform.isIOS) {
          url = 'maps:?q=$encodedAddress';
        } else {
          url = 'geo:0,0?q=$encodedAddress';
        }
      } else if (query != null) {
        // Open with search query
        final encodedQuery = Uri.encodeComponent(query);
        if (Platform.isIOS) {
          url = 'maps:?q=$encodedQuery';
        } else {
          url = 'geo:0,0?q=$encodedQuery';
        }
      } else {
        throw ArgumentError(
          'Either coordinates, address, or query must be provided',
        );
      }

      return await launchURL(
        url,
        mode: LaunchMode.externalApplication,
        showErrorDialog: showErrorDialog,
        context: context,
      );
    } on Exception catch (e) {
      if (showErrorDialog && context != null && context.mounted) {
        _showURLErrorDialog(context, 'Error launching maps: $e');
      }
      debugPrint('Error launching maps: $e');
      return false;
    }
  }

  /// Launch app store/play store for app rating
  static Future<bool> launchAppStore({
    required String appId,
    bool showErrorDialog = true,
    BuildContext? context,
  }) async {
    try {
      String url;

      if (Platform.isIOS) {
        url = 'https://apps.apple.com/app/id$appId';
      } else {
        url = 'https://play.google.com/store/apps/details?id=$appId';
      }

      return await launchURL(
        url,
        mode: LaunchMode.externalApplication,
        showErrorDialog: showErrorDialog,
        context: context,
      );
    } on Exception catch (e) {
      if (showErrorDialog && context != null && context.mounted) {
        _showURLErrorDialog(context, 'Error launching app store: $e');
      }
      debugPrint('Error launching app store: $e');
      return false;
    }
  }

  // Helper methods
  static String? _buildEmailQuery({
    String? subject,
    String? body,
    List<String>? cc,
    List<String>? bcc,
  }) {
    final params = <String>[];

    if (subject != null) {
      params.add('subject=${Uri.encodeComponent(subject)}');
    }
    if (body != null) {
      params.add('body=${Uri.encodeComponent(body)}');
    }
    if (cc != null && cc.isNotEmpty) {
      params.add('cc=${cc.map(Uri.encodeComponent).join(',')}');
    }
    if (bcc != null && bcc.isNotEmpty) {
      params.add('bcc=${bcc.map(Uri.encodeComponent).join(',')}');
    }

    return params.isEmpty ? null : params.join('&');
  }

  static void _showURLErrorDialog(BuildContext context, String message) {
    AppCustomDialogs.showSingleAction(
      context: context,
      title: context.l10n.errorWhileOpeningUrl,
      message: message,
      actionText: context.l10n.proceed,
      onAction: () {},
    );
  }

  /// disable the text field
  static void unFocus() =>
      WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
}

// ============ ENUMS ============

enum LogLevel { debug, info, warning, error }

enum HapticFeedbackType {
  lightImpact,
  mediumImpact,
  heavyImpact,
  selectionClick,
  vibrate
}

// ============ DATA CLASSES ============

/// Result of file validation
class FileValidationResult {
  const FileValidationResult({
    required this.isValid,
    required this.fileSizeInBytes,
    required this.fileSizeInMB,
    required this.maxAllowedSizeMB,
    this.error,
  });
  final bool isValid;
  final int fileSizeInBytes;
  final double fileSizeInMB;
  final double maxAllowedSizeMB;
  final String? error;

  /// Get formatted file size string
  String get formattedFileSize => '${fileSizeInMB.toStringAsFixed(1)} MB';

  /// Get error message for oversized file
  String getErrorMessage() {
    if (error != null) return 'Error reading file: $error';
    if (!isValid) {
      return 'File size ($formattedFileSize) exceeds the maximum limit of ${maxAllowedSizeMB.toStringAsFixed(0)} MB.';
    }
    return '';
  }
}

// ============ EXTENSIONS ============

extension StringExtension on String {
  /// Check if string is null or empty
  bool get isNullOrEmpty => isEmpty;

  /// Format payment type: remove special chars and capitalize first letter
  String get toFormattedPaymentType {
    final cleaned = removeSpecialChars;
    if (cleaned.isEmpty) return cleaned;
    return cleaned[0].toUpperCase() + cleaned.substring(1).toLowerCase();
  }

  /// Capitalize first letter
  String get capitalize => AppUtils.capitalize(this);

  /// Title case
  String get titleCase => AppUtils.titleCase(this);

  /// Remove special characters
  String get removeSpecialChars => AppUtils.removeSpecialChars(this);

  /// Convert to Color
  Color get toColor => AppUtils.hexToColor(this);

  /// Convert date string from 'Nov 26, 2025' format to '26/11/25' format (2-digit year)
  String get toFormattedDate {
    try {
      // Define the input format
      final months = {
        'Jan': '01',
        'Feb': '02',
        'Mar': '03',
        'Apr': '04',
        'May': '05',
        'Jun': '06',
        'Jul': '07',
        'Aug': '08',
        'Sep': '09',
        'Oct': '10',
        'Nov': '11',
        'Dec': '12',
      };

      // Split the string by spaces and comma
      final parts = split(RegExp(r'[,\s]+'));
      if (parts.length < 3) return this;

      final monthStr = parts[0];
      final dayStr = parts[1];
      final yearStr = parts[2];

      final monthNum = months[monthStr];
      if (monthNum == null) return this;

      // Ensure day is zero-padded if needed
      final day = dayStr.padLeft(2, '0');

      // Extract last 2 digits of year
      final twoDigitYear =
          yearStr.length >= 2 ? yearStr.substring(yearStr.length - 2) : yearStr;

      return '$day/$monthNum/$twoDigitYear';
    } on Exception catch (_) {
      // Return original string if conversion fails
      return this;
    }
  }
}

extension ListExtension<T> on List<T>? {
  /// Check if list is null or empty
  bool get isNullOrEmpty => AppUtils.isNullOrEmpty(this);

  /// Safe get item at index
  T? safeGet(int index) => AppUtils.safeGet(this, index);
}

extension DateTimeExtension on DateTime {
  /// Format date
  String format([String format = 'dd/MM/yyyy']) =>
      AppUtils.formatDate(this, format: format);

  /// Time ago string
  String get timeAgo => AppUtils.timeAgo(this);

  /// Check if date is today
  bool get isToday => AppUtils.isToday(this);
}
