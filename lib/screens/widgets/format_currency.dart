import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kipgo/controllers/locale_provider.dart';
import 'package:provider/provider.dart';

String formatCurrency({
  required double amount,
  required String currencyCode, // TRY, USD, EUR, GBP
  required BuildContext context, // en, tr, ru
  int decimalDigits = 2,
}) {
  final locale = Provider.of<LocaleProvider>(context, listen: false).locale;
  final format = NumberFormat.currency(
    locale: '$locale',
    name: currencyCode,
    symbol: _currencySymbol(currencyCode),
    decimalDigits: decimalDigits,
  );

  return format.format(amount);
}

String _currencySymbol(String code) {
  switch (code) {
    case 'TRY':
      return '₺';
    case 'USD':
      return '\$';
    case 'EUR':
      return '€';
    case 'GBP':
      return '£';
    default:
      return code;
  }
}
