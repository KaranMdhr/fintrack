import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/preferences_provider.dart';
import 'app_currency.dart';

final NotifierProvider<CurrencyNotifier, AppCurrency> currencyProvider =
    NotifierProvider<CurrencyNotifier, AppCurrency>(CurrencyNotifier.new);

class CurrencyNotifier extends Notifier<AppCurrency> {
  static const String _storageKey = 'currency_code';

  @override
  AppCurrency build() {
    final String? savedCode = ref
        .watch(sharedPreferencesProvider)
        .getString(_storageKey);
    return AppCurrencies.byCode(savedCode) ?? AppCurrencies.usd;
  }

  Future<void> setCurrency(AppCurrency currency) async {
    if (state.code == currency.code) return;
    state = currency;
    await ref
        .read(sharedPreferencesProvider)
        .setString(_storageKey, currency.code);
  }
}
