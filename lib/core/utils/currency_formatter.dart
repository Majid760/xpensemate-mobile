import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _formatter = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 0,
  );

  static final NumberFormat _preciseFormatter = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );

  /// Format currency with no decimal places for whole numbers
  static String format(double amount) {
    if (amount % 1 == 0) {
      return _formatter.format(amount);
    } else {
      return _preciseFormatter.format(amount);
    }
  }

  /// Format currency with specified decimal places
  static String formatWithDecimals(double amount, int decimalPlaces) {
    final formatter = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: decimalPlaces,
    );
    return formatter.format(amount);
  }

  /// Format compact currency (e.g., \$1.2K, \$1.5M)
  static String formatCompact(double amount) {
    final compactFormatter = NumberFormat.compactCurrency(
      symbol: '\$',
    );
    return compactFormatter.format(amount);
  }

  /// Format percentage
  static String formatPercentage(double percentage) {
    final percentFormatter = NumberFormat.percentPattern();
    return percentFormatter.format(percentage / 100);
  }
}