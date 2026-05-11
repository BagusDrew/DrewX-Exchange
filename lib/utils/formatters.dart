import 'package:intl/intl.dart';

String formatCurrency(double value, {String symbol = '\$'}) {
  if (value >= 1) {
    return '$symbol${NumberFormat('#,##0.00').format(value)}';
  } else if (value >= 0.01) {
    return '$symbol${value.toStringAsFixed(4)}';
  } else {
    return '$symbol${value.toStringAsFixed(6)}';
  }
}

String formatLargeNumber(double value) {
  if (value >= 1e12) {
    return '\$${(value / 1e12).toStringAsFixed(2)}T';
  } else if (value >= 1e9) {
    return '\$${(value / 1e9).toStringAsFixed(2)}B';
  } else if (value >= 1e6) {
    return '\$${(value / 1e6).toStringAsFixed(2)}M';
  } else if (value >= 1e3) {
    return '\$${(value / 1e3).toStringAsFixed(2)}K';
  }
  return '\$${value.toStringAsFixed(2)}';
}

String formatQuantity(double value) {
  if (value >= 1) {
    return NumberFormat('#,##0.####').format(value);
  } else {
    return value.toStringAsFixed(6);
  }
}

String formatDate(DateTime date) {
  return DateFormat('MMM dd, HH:mm').format(date);
}
