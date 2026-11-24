import 'package:material_ui/material_ui.dart';

import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';

class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
    this.borderRadius = AppRadii.lg,
    this.color,
    this.gradient,
    this.borderColor,
    this.shadows,
    this.clipBehavior = Clip.antiAlias,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? color;
  final Gradient? gradient;
  final Color? borderColor;
  final List<BoxShadow>? shadows;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    final Gradient defaultGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? <Color>[
              Colors.white.withValues(alpha: 0.075),
              Colors.white.withValues(alpha: 0.02),
            ]
          : <Color>[
              Colors.white.withValues(alpha: 0.92),
              Colors.white.withValues(alpha: 0.55),
            ],
    );

    final List<BoxShadow> defaultShadows = isDark
        ? <BoxShadow>[
            BoxShadow(
              color: AppPalette.black.withValues(alpha: 0.35),
              blurRadius: 30,
              offset: const Offset(0, 18),
            ),
          ]
        : <BoxShadow>[
            BoxShadow(
              color: AppPalette.ink.withValues(alpha: 0.07),
              blurRadius: 30,
              offset: const Offset(0, 18),
            ),
          ];

    return Container(
      clipBehavior: clipBehavior,
      decoration: BoxDecoration(
        color: color,
        gradient: gradient ?? (color == null ? defaultGradient : null),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color:
              borderColor ??
              (isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.06)),
        ),
        boxShadow: shadows ?? defaultShadows,
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
