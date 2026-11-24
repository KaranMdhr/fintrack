import 'package:intl/intl.dart';

import '../currency/app_currency.dart';

abstract final class AppFormatters {
  static final Map<String, NumberFormat> _currencyFormats =
      <String, NumberFormat>{};
  static final DateFormat _month = DateFormat('MMMM yyyy');
  static final DateFormat _day = DateFormat('EEEE, MMM d');
  static final DateFormat _shortDate = DateFormat('MMM d, yyyy');

  static String currency(
    num value, {
    AppCurrency? currency,
    int? decimalDigits,
  }) {
    final AppCurrency selected = currency ?? AppCurrencies.usd;
    final int digits = decimalDigits ?? selected.decimalDigits;
    final String key = '${selected.code}:$digits';
    final NumberFormat formatter = _currencyFormats.putIfAbsent(
      key,
      () => NumberFormat.currency(
        locale: selected.locale,
        symbol: selected.symbol,
        decimalDigits: digits,
      ),
    );
    return formatter.format(value);
  }

  static String month(DateTime date) => _month.format(date);

  static String day(DateTime date) => _day.format(date);

  static String shortDate(DateTime date) => _shortDate.format(date);
}
