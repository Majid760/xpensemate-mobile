// lib/core/utils/app_utils.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppUtils {
  AppUtils._(); // Prevent instantiation

  // ============ DEBOUNCER ============
  static final Map<String, Timer> _debounceTimers = {};

  /// Debounces function calls with optional key for multiple debouncers
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
  static void throttle(
    VoidCallback callback, {
    Duration delay = const Duration(milliseconds: 1000),
    String key = 'default',
  }) {
    final now = DateTime.now();
    final lastTime = _lastExecuted[key];

    if (lastTime == null || now.difference(lastTime) >= delay) {
      _lastExecuted[key] = now;
      callback();
    }
  }

  // ============ VALIDATOR UTILS ============

  /// Email validation
  static bool isValidEmail(String email) => RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);

  /// Phone validation (basic)
  static bool isValidPhone(String phone) => RegExp(r'^\+?[\d\s\-\(\)]{10,}$').hasMatch(phone);

  /// URL validation
  static bool isValidUrl(String url) => Uri.tryParse(url)?.hasAbsolutePath ?? false;

  /// Strong password validation
  static bool isStrongPassword(String password) => password.length >= 8 &&
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
  static String titleCase(String text) => text.split(' ').map(capitalize).join(' ');

  /// Remove special characters
  static String removeSpecialChars(String text) => text.replaceAll(RegExp(r'[^\w\s]'), '');

  /// Generate random string
  static String randomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(length, (index) => chars[Random().nextInt(chars.length)]).join();
  }

  /// Truncate text with ellipsis
  static String truncate(String text, int maxLength) => text.length <= maxLength ? text : '${text.substring(0, maxLength)}...';

  // ============ NUMBER UTILS ============

  /// Format currency
  static String formatCurrency(double amount, {String symbol = r'$'}) => '$symbol${amount.toStringAsFixed(2)}';

  /// Format file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Generate random number in range
  static int randomInt(int min, int max) => min + Random().nextInt(max - min + 1);

  /// Check if number is in range
  static bool inRange(num value, num min, num max) => value >= min && value <= max;

  // ============ DATE/TIME UTILS ============

  /// Format date to readable string
  static String formatDate(DateTime date, {String format = 'dd/MM/yyyy'}) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return format.replaceAll('dd', day).replaceAll('MM', month).replaceAll('yyyy', year);
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
    if (difference.inDays > 0) return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    if (difference.inHours > 0) return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    return 'Just now';
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
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
  static void hapticFeedback({HapticFeedbackType type = HapticFeedbackType.lightImpact}) {
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

  /// Show snackbar
  static void showSnackBar(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 2),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
        action: action,
      ),
    );
  }

  /// Hide keyboard
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

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
}

// ============ ENUMS ============

enum LogLevel { debug, info, warning, error }

enum HapticFeedbackType { lightImpact, mediumImpact, heavyImpact, selectionClick, vibrate }

// ============ EXTENSIONS ============

extension StringExtension on String {
  /// Check if string is null or empty
  bool get isNullOrEmpty => isEmpty;

  /// Capitalize first letter
  String get capitalize => AppUtils.capitalize(this);

  /// Title case
  String get titleCase => AppUtils.titleCase(this);

  /// Remove special characters
  String get removeSpecialChars => AppUtils.removeSpecialChars(this);

  /// Convert to Color
  Color get toColor => AppUtils.hexToColor(this);
}

extension ListExtension<T> on List<T>? {
  /// Check if list is null or empty
  bool get isNullOrEmpty => AppUtils.isNullOrEmpty(this);

  /// Safe get item at index
  T? safeGet(int index) => AppUtils.safeGet(this, index);
}

extension DateTimeExtension on DateTime {
  /// Format date
  String format([String format = 'dd/MM/yyyy']) => AppUtils.formatDate(this, format: format);

  /// Time ago string
  String get timeAgo => AppUtils.timeAgo(this);

  /// Check if date is today
  bool get isToday => AppUtils.isToday(this);
}
