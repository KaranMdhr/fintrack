import 'package:fl_chart/fl_chart.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/widgets/currency_text.dart';

class CategoryBreakdownCard extends StatelessWidget {
  const CategoryBreakdownCard({
    super.key,
    required this.totals,
    required this.total,
  });

  final Map<String, double> totals;
  final double total;

  static const Map<String, Color> _colors = <String, Color>{
    'Food': Color(0xFFE76F51),
    'Transport': Color(0xFF2A9D8F),
    'Shopping': Color(0xFFE9C46A),
    'Bills': Color(0xFF457B9D),
    'Health': Color(0xFF9B5DE5),
    'Entertainment': Color(0xFFF15BB5),
    'Other': Color(0xFF6C757D),
  };

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<MapEntry<String, double>> entries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'By category',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Spending split by category.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final Widget chart = SizedBox(
                  height: 220,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 48,
                      startDegreeOffset: -90,
                      sections: entries.map((entry) {
                        final Color color = _colorFor(entry.key);
                        final double share = total == 0
                            ? 0
                            : entry.value / total;
                        final Brightness brightness =
                            ThemeData.estimateBrightnessForColor(color);

                        return PieChartSectionData(
                          value: entry.value,
                          color: color,
                          radius: 42,
                          showTitle: share >= 0.08,
                          title: '${(share * 100).round()}%',
                          titleStyle: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black87,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );

                final Widget legend = _Legend(entries: entries, total: total);

                if (constraints.maxWidth >= 520) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: chart),
                      const SizedBox(width: 24),
                      Expanded(child: legend),
                    ],
                  );
                }

                return Column(
                  children: [chart, const SizedBox(height: 16), legend],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  static Color _colorFor(String category) {
    return _colors[category] ?? _colors['Other']!;
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.entries, required this.total});

  final List<MapEntry<String, double>> entries;
  final double total;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Column(
      children: [
        for (final MapEntry<String, double> entry in entries)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: CategoryBreakdownCard._colorFor(entry.key),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    entry.key,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                CurrencyText(
                  entry.value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 48,
                  child: Text(
                    '${(total == 0 ? 0 : entry.value / total * 100).toStringAsFixed(0)}%',
                    textAlign: TextAlign.right,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
