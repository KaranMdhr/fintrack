import 'package:material_ui/material_ui.dart';

import '../theme/app_motion.dart';

class TiltCard extends StatefulWidget {
  const TiltCard({
    super.key,
    required this.child,
    this.maxTilt = 0.09,
    this.perspective = 0.0014,
  });

  final Widget child;
  final double maxTilt;
  final double perspective;

  @override
  State<TiltCard> createState() => _TiltCardState();
}

class _TiltCardState extends State<TiltCard> {
  Offset _tilt = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) {
        final Size? size = context.size;
        if (size == null || size.width <= 0 || size.height <= 0) return;

        final double dx = ((event.localPosition.dx / size.width) - 0.5) * 2;
        final double dy = ((event.localPosition.dy / size.height) - 0.5) * 2;
        setState(() {
          _tilt = Offset(
            dx.clamp(-1.0, 1.0).toDouble(),
            dy.clamp(-1.0, 1.0).toDouble(),
          );
        });
      },
      onExit: (_) => setState(() => _tilt = Offset.zero),
      child: TweenAnimationBuilder<Offset>(
        tween: Tween<Offset>(end: _tilt),
        duration: AppMotion.medium,
        curve: AppMotion.enter,
        builder: (context, tilt, child) {
          final Matrix4 matrix = Matrix4.identity()
            ..setEntry(3, 2, widget.perspective)
            ..rotateX(-tilt.dy * widget.maxTilt)
            ..rotateY(tilt.dx * widget.maxTilt);

          return Transform(
            alignment: Alignment.center,
            transform: matrix,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}
