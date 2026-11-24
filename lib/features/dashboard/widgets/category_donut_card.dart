import 'package:fl_chart/fl_chart.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/category_style.dart';
import '../../../core/widgets/currency_text.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../core/widgets/press_scale.dart';
import '../../../core/widgets/section_heading.dart';

class CategoryDonutCard extends StatefulWidget {
  const CategoryDonutCard({
    super.key,
    required this.totals,
    required this.total,
  });

  final Map<String, double> totals;
  final double total;

  @override
  State<CategoryDonutCard> createState() => _CategoryDonutCardState();
}

class _CategoryDonutCardState extends State<CategoryDonutCard> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Brightness brightness = theme.brightness;
    final List<MapEntry<String, double>> entries =
        widget.totals.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    return GlassPanel(
      padding: const EdgeInsets.all(22),
      borderRadius: AppRadii.xl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeading(
            title: 'Spending mix',
            subtitle: 'Where this period went.',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHigh.withValues(
                  alpha: 0.5,
                ),
                borderRadius: BorderRadius.circular(AppRadii.pill),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.5,
                  ),
                ),
              ),
              child: Text(
                '${entries.length} ${entries.length == 1 ? 'category' : 'categories'}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          if (entries.isEmpty)
            _EmptyMix(theme: theme)
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final Widget chart = _DonutChart(
                  entries: entries,
                  total: widget.total,
                  brightness: brightness,
                  selectedIndex: _selectedIndex,
                  onTouch: (index) {
                    setState(() {
                      _selectedIndex = index == _selectedIndex ? null : index;
                    });
                  },
                );

                final Widget legend = _Legend(
                  entries: entries,
                  total: widget.total,
                  brightness: brightness,
                  selectedIndex: _selectedIndex,
                  onSelect: (index) {
                    setState(() {
                      _selectedIndex = index == _selectedIndex ? null : index;
                    });
                  },
                );

                if (constraints.maxWidth >= 480) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      chart,
                      const SizedBox(width: 22),
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
    );
  }
}

class _DonutChart extends StatelessWidget {
  const _DonutChart({
    required this.entries,
    required this.total,
    required this.brightness,
    required this.selectedIndex,
    required this.onTouch,
  });

  final List<MapEntry<String, double>> entries;
  final double total;
  final Brightness brightness;
  final int? selectedIndex;
  final ValueChanged<int> onTouch;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MapEntry<String, double>? selected = selectedIndex == null
        ? null
        : entries[selectedIndex!];
    final double centerValue = selected?.value ?? total;
    final String centerLabel = selected?.key ?? 'Total';
    final double share = selected == null || total == 0
        ? 100
        : (selected.value / total) * 100;

    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 3,
              centerSpaceRadius: 62,
              startDegreeOffset: -90,
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  if (!event.isInterestedForInteractions ||
                      response == null ||
                      response.touchedSection == null) {
                    return;
                  }
                  final int index =
                      response.touchedSection!.touchedSectionIndex;
                  if (index < 0 || index >= entries.length) return;
                  onTouch(index);
                },
              ),
              sections: [
                for (int i = 0; i < entries.length; i++)
                  _section(
                    context,
                    entry: entries[i],
                    index: i,
                    selected: i == selectedIndex,
                  ),
              ],
            ),
          ),
          IgnorePointer(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  centerLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                CurrencyText(
                  centerValue,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${share.toStringAsFixed(0)}%',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PieChartSectionData _section(
    BuildContext context, {
    required MapEntry<String, double> entry,
    required int index,
    required bool selected,
  }) {
    final ThemeData theme = Theme.of(context);
    final Color color = CategoryStyle.color(entry.key, brightness);
    final double share = total == 0 ? 0 : entry.value / total;
    final Brightness colorBrightness = ThemeData.estimateBrightnessForColor(
      color,
    );
    final Color titleColor = colorBrightness == Brightness.dark
        ? Colors.white
        : AppPalette.night;

    return PieChartSectionData(
      value: entry.value,
      color: color,
      radius: selected ? 44 : 36,
      showTitle: selected || share >= 0.09,
      title: '${(share * 100).round()}%',
      titlePositionPercentageOffset: 0.62,
      titleStyle: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        color: titleColor,
        shadows: const <Shadow>[
          Shadow(color: Color(0x33000000), blurRadius: 3),
        ],
      ),
      badgeWidget: selected
          ? Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.surface,
                  width: 1.5,
                ),
              ),
            )
          : null,
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({
    required this.entries,
    required this.total,
    required this.brightness,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<MapEntry<String, double>> entries;
  final double total;
  final Brightness brightness;
  final int? selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      children: [
        for (int i = 0; i < entries.length; i++)
          PressScale(
            onTap: () => onSelect(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
              decoration: BoxDecoration(
                color: i == selectedIndex
                    ? CategoryStyle.soft(entries[i].key, brightness)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: CategoryStyle.color(entries[i].key, brightness),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entries[i].key,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: i == selectedIndex
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                  CurrencyText(
                    entries[i].value,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 34,
                    child: Text(
                      '${total == 0 ? 0 : (entries[i].value / total * 100).round()}%',
                      textAlign: TextAlign.right,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _EmptyMix extends StatelessWidget {
  const _EmptyMix({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 230,
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.donut_large_rounded,
              color: theme.colorScheme.primary,
              size: 26,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No category mix yet',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add an expense to see where your money goes.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
