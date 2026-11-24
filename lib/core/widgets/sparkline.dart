import 'package:material_ui/material_ui.dart';

class Sparkline extends StatelessWidget {
  const Sparkline({
    super.key,
    required this.values,
    this.color,
    this.height = 56,
    this.lineWidth = 1.8,
  });

  final List<double> values;
  final Color? color;
  final double height;
  final double lineWidth;

  @override
  Widget build(BuildContext context) {
    final Color lineColor = color ?? Theme.of(context).colorScheme.primary;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _SparklinePainter(
          values: values,
          color: lineColor,
          lineWidth: lineWidth,
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.values,
    required this.color,
    required this.lineWidth,
  });

  final List<double> values;
  final Color color;
  final double lineWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    if (values.length < 2) {
      final Paint flat = Paint()
        ..color = color.withValues(alpha: 0.35)
        ..strokeWidth = lineWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(0, size.height * 0.6),
        Offset(size.width, size.height * 0.6),
        flat,
      );
      return;
    }

    double min = values.first;
    double max = values.first;
    for (final double value in values) {
      if (value < min) min = value;
      if (value > max) max = value;
    }
    final double range = (max - min) == 0 ? 1 : max - min;

    final Path line = Path();
    for (int i = 0; i < values.length; i++) {
      final double x = (i / (values.length - 1)) * size.width;
      final double normalized = (values[i] - min) / range;
      final double y =
          size.height -
          (normalized * size.height * 0.72) -
          (size.height * 0.14);
      if (i == 0) {
        line.moveTo(x, y);
      } else {
        line.lineTo(x, y);
      }
    }

    final Path fill = Path.from(line)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final Paint fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          color.withValues(alpha: 0.1),
          color.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fill, fillPaint);

    final Paint stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(line, stroke);
  }

  @override
  bool shouldRepaint(_SparklinePainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.color != color ||
        oldDelegate.lineWidth != lineWidth;
  }
}
