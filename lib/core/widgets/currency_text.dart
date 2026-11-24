import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../currency/currency_provider.dart';
import '../utils/formatters.dart';

class CurrencyText extends ConsumerWidget {
  const CurrencyText(
    this.value, {
    super.key,
    this.style,
    this.decimalDigits,
    this.textAlign = TextAlign.start,
  });

  final num value;
  final TextStyle? style;
  final int? decimalDigits;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(currencyProvider);
    return Text(
      AppFormatters.currency(
        value,
        currency: currency,
        decimalDigits: decimalDigits,
      ),
      style: style,
      textAlign: textAlign,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
