import 'package:material_ui/material_ui.dart';

abstract final class CategoryStyle {
  static const Map<String, Color> _colors = <String, Color>{
    'Food': Color(0xFFFF7A6B),
    'Transport': Color(0xFF4FD1B5),
    'Shopping': Color(0xFFE7C87A),
    'Bills': Color(0xFF7FA7FF),
    'Health': Color(0xFFB99CFF),
    'Entertainment': Color(0xFFFF8FCB),
    'Other': Color(0xFF9DA7A2),
  };

  static Color color(String category, Brightness brightness) {
    final Color base = _colors[category] ?? _colors['Other']!;
    if (brightness == Brightness.light) {
      return Color.lerp(base, Colors.black, 0.22)!;
    }
    return base;
  }

  static Color soft(String category, Brightness brightness) {
    return color(
      category,
      brightness,
    ).withValues(alpha: brightness == Brightness.dark ? 0.18 : 0.12);
  }

  static IconData icon(String category) {
    return switch (category) {
      'Food' => Icons.restaurant_rounded,
      'Transport' => Icons.directions_bus_rounded,
      'Shopping' => Icons.shopping_bag_rounded,
      'Bills' => Icons.receipt_long_rounded,
      'Health' => Icons.favorite_rounded,
      'Entertainment' => Icons.movie_rounded,
      _ => Icons.more_horiz_rounded,
    };
  }
}
