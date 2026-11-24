import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../currency/app_currency.dart';
import '../currency/currency_provider.dart';
import '../theme/app_motion.dart';

class AnimatedAmount extends ConsumerWidget {
  const AnimatedAmount({
    super.key,
    required this.value,
    this.style,
    this.compact = false,
    this.decimalDigits = 0,
    this.textAlign = TextAlign.start,
  });

  final double value;
  final TextStyle? style;
  final bool compact;
  final int decimalDigits;
  final TextAlign textAlign;

  String _format(double amount, AppCurrency currency) {
    final NumberFormat formatter = compact
        ? NumberFormat.compactCurrency(
            locale: currency.locale,
            symbol: currency.symbol,
            decimalDigits: decimalDigits,
          )
        : NumberFormat.currency(
            locale: currency.locale,
            symbol: currency.symbol,
            decimalDigits: decimalDigits,
          );
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppCurrency currency = ref.watch(currencyProvider);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: value),
      duration: AppMotion.slow,
      curve: AppMotion.enter,
      builder: (context, animatedValue, child) {
        return Text(
          _format(animatedValue, currency),
          style: style,
          textAlign: textAlign,
          maxLines: 1,
          overflow: TextOverflow.fade,
          softWrap: false,
        );
      },
    );
  }
}
