import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/currency/app_currency.dart';
import '../../../core/currency/currency_provider.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/category_style.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../core/widgets/section_heading.dart';

class MonthPaceCard extends ConsumerWidget {
  const MonthPaceCard({
    super.key,
    required this.total,
    required this.activeDays,
    required this.daysElapsed,
    required this.daysInMonth,
    required this.largest,
    this.topCategory,
    this.topCategoryAmount = 0,
  });

  final double total;
  final int activeDays;
  final int daysElapsed;
  final int daysInMonth;
  final double largest;
  final String? topCategory;
  final double topCategoryAmount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AppCurrency currency = ref.watch(currencyProvider);
    final Brightness brightness = theme.brightness;
    final double progress = daysInMonth == 0
        ? 0
        : (daysElapsed / daysInMonth).clamp(0.0, 1.0);
    final double dailyAverage = daysElapsed == 0 ? 0 : total / daysElapsed;
    final Color topColor = topCategory == null
        ? theme.colorScheme.onSurfaceVariant
        : CategoryStyle.color(topCategory!, brightness);

    return GlassPanel(
      padding: const EdgeInsets.all(22),
      borderRadius: AppRadii.xl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeading(
            title: 'Month rhythm',
            subtitle: 'A quiet read on your pace.',
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                'PERIOD PROGRESS',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 1.4,
                ),
              ),
              const Spacer(),
              Text(
                '$daysElapsed / $daysInMonth days',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 18),
          _StatRow(
            label: 'Daily average',
            value: AppFormatters.currency(dailyAverage, currency: currency),
          ),
          Divider(
            height: 1,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
          ),
          _StatRow(label: 'Active days', value: '$activeDays'),
          Divider(
            height: 1,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
          ),
          _StatRow(
            label: 'Largest expense',
            value: AppFormatters.currency(largest, currency: currency),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: topColor.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: topColor.withValues(alpha: 0.16)),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: topColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(
                    topCategory == null
                        ? Icons.auto_awesome_rounded
                        : CategoryStyle.icon(topCategory!),
                    size: 17,
                    color: topColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TOP CATEGORY',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 8,
                          letterSpacing: 1.4,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        topCategory ?? 'No spend yet',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                if (topCategory != null)
                  Text(
                    AppFormatters.currency(
                      topCategoryAmount,
                      currency: currency,
                    ),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: topColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.bolt_rounded,
                size: 14,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  total == 0
                      ? 'Add an expense to start your rhythm.'
                      : 'You are tracking $activeDays active ${activeDays == 1 ? 'day' : 'days'} this period.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
