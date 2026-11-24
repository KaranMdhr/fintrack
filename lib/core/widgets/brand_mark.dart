import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.3),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[AppPalette.accent, AppPalette.mint],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: CustomPaint(painter: _MarkPainter()),
    );
  }
}

class _MarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final Paint stroke = Paint()
      ..color = AppPalette.night
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.11
      ..strokeCap = StrokeCap.round;

    final Rect orbit = Rect.fromCircle(
      center: center,
      radius: size.width * 0.25,
    );
    canvas.drawArc(orbit, -math.pi * 0.18, math.pi * 1.38, false, stroke);

    final Paint slash = Paint()
      ..color = AppPalette.night
      ..strokeWidth = size.width * 0.09
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.34, size.height * 0.68),
      Offset(size.width * 0.66, size.height * 0.32),
      slash,
    );

    final Paint dot = Paint()..color = AppPalette.night;
    canvas.drawCircle(
      Offset(size.width * 0.72, size.height * 0.34),
      size.width * 0.045,
      dot,
    );
  }

  @override
  bool shouldRepaint(_MarkPainter oldDelegate) => false;
}

class BrandLockup extends StatelessWidget {
  const BrandLockup({
    super.key,
    this.markSize = 38,
    this.color,
    this.compact = false,
  });

  final double markSize;
  final Color? color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color textColor = color ?? theme.colorScheme.onSurface;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        BrandMark(size: markSize),
        if (!compact) ...[
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'FINTRACK',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.6,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'PERSONAL FINANCE',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: textColor.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.6,
                  fontSize: 8,
                  height: 1,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
