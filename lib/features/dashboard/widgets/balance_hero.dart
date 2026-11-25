import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/animated_amount.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../core/widgets/sparkline.dart';
import '../../../core/widgets/tilt_card.dart';

class BalanceHero extends StatelessWidget {
  const BalanceHero({
    super.key,
    required this.total,
    required this.count,
    required this.month,
    required this.cumulative,
    required this.isCurrentMonth,
    this.previousTotal,
    this.fillHeight = false,
  });

  final double total;
  final int count;
  final DateTime month;
  final List<double> cumulative;
  final bool isCurrentMonth;
  final double? previousTotal;
  final bool fillHeight;

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.sizeOf(context).width >= 760;
    final double? delta = (previousTotal != null && previousTotal! > 0)
        ? ((total - previousTotal!) / previousTotal!) * 100
        : null;

    return TiltCard(
      child: GlassPanel(
        padding: EdgeInsets.all(wide ? 30 : 24),
        borderRadius: AppRadii.xl,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF121615), Color(0xFF080A09)],
        ),
        borderColor: Colors.white.withValues(alpha: 0.08),
        shadows: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: fillHeight
              ? MainAxisAlignment.spaceBetween
              : MainAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppPalette.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'TOTAL SPENT',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                        color: Colors.white.withValues(alpha: 0.58),
                      ),
                    ),
                    const Spacer(),
                    if (delta != null) _DeltaChip(delta: delta),
                  ],
                ),
                const SizedBox(height: 18),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: AnimatedAmount(
                    value: total,
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: wide ? 58 : 44,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -2.6,
                      height: 1,
                      color: AppPalette.white,
                    ),
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  '${count == 1 ? '1 transaction' : '$count transactions'} · ${AppFormatters.month(month)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Sparkline(
                    values: cumulative,
                    color: AppPalette.accent,
                    height: wide ? 74 : 60,
                    lineWidth: 1.8,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          isCurrentMonth
                              ? 'Cumulative spend so far'
                              : 'Cumulative spend',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.4,
                            color: Colors.white.withValues(alpha: 0.38),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'DAY 1 – ${cumulative.length}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: Colors.white.withValues(alpha: 0.38),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeltaChip extends StatelessWidget {
  const _DeltaChip({required this.delta});

  final double delta;

  @override
  Widget build(BuildContext context) {
    final bool up = delta > 0;
    final Color color = up ? AppPalette.coral : AppPalette.accent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            up ? Icons.north_east_rounded : Icons.south_east_rounded,
            size: 13,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            '${delta.abs().toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
