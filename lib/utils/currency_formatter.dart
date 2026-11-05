/// Utility for formatting currency in Philippine Pesos (₱) with thousands separators.
class CurrencyFormatter {
  CurrencyFormatter._();

  /// Formats an amount as Philippine Pesos (e.g. ₱2,450 or ₱150.00).
  static String format(double amount, {bool showDecimals = false}) {
    final fixed = showDecimals
        ? amount.toStringAsFixed(2)
        : amount.toStringAsFixed(0);
    final parts = fixed.split('.');
    final integerPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
    if (showDecimals && parts.length > 1) {
      return '₱$integerPart.${parts[1]}';
    }
    return '₱$integerPart';
  }
}
