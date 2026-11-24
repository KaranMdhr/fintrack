import 'package:material_ui/material_ui.dart';

import 'app_palette.dart';
import 'app_spacing.dart';

abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light);

  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final ColorScheme scheme = _scheme(isDark);
    final TextTheme textTheme = _textTheme(isDark, scheme);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      canvasColor: scheme.surface,
      fontFamily: 'Inter',
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: AppBarThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontFamily: 'SpaceGrotesk',
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLow,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: scheme.surfaceContainerHigh.withValues(alpha: 0.72),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
        ),
        prefixIconColor: scheme.onSurfaceVariant,
        suffixIconColor: scheme.onSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: scheme.primary, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: scheme.error, width: 1.4),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size.fromHeight(56),
          elevation: 0,
          textStyle: textTheme.labelLarge?.copyWith(
            fontFamily: 'SpaceGrotesk',
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          minimumSize: const Size.fromHeight(56),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.8)),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHigh.withValues(alpha: 0.58),
        selectedColor: scheme.primary,
        disabledColor: scheme.surfaceContainerHigh.withValues(alpha: 0.3),
        labelStyle: textTheme.labelMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        secondaryLabelStyle: textTheme.labelMedium?.copyWith(
          color: scheme.onPrimary,
          fontWeight: FontWeight.w700,
        ),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.55)),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        showCheckmark: false,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: 0.45),
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onInverseSurface,
        ),
        actionTextColor: scheme.inversePrimary,
        behavior: SnackBarBehavior.floating,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.surfaceContainerHighest,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }

  static ColorScheme _scheme(bool isDark) {
    if (isDark) {
      return ColorScheme.fromSeed(
        seedColor: AppPalette.accent,
        brightness: Brightness.dark,
      ).copyWith(
        primary: AppPalette.accent,
        onPrimary: AppPalette.night,
        primaryContainer: const Color(0xFF24352D),
        onPrimaryContainer: AppPalette.accentSoft,
        secondary: AppPalette.mint,
        onSecondary: AppPalette.night,
        secondaryContainer: const Color(0xFF1B2E28),
        onSecondaryContainer: const Color(0xFFD8E8DE),
        tertiary: AppPalette.gold,
        onTertiary: AppPalette.night,
        error: AppPalette.coral,
        onError: AppPalette.night,
        errorContainer: const Color(0xFF3A201C),
        onErrorContainer: const Color(0xFFFFDAD4),
        surface: AppPalette.night,
        onSurface: AppPalette.silver,
        onSurfaceVariant: AppPalette.mist,
        surfaceContainerLowest: const Color(0xFF050707),
        surfaceContainerLow: AppPalette.nightSoft,
        surfaceContainer: const Color(0xFF111617),
        surfaceContainerHigh: AppPalette.graphite,
        surfaceContainerHighest: AppPalette.graphiteHigh,
        outline: const Color(0xFF3A4340),
        outlineVariant: const Color(0xFF232B29),
        shadow: AppPalette.black,
        scrim: AppPalette.black,
      );
    }

    return ColorScheme.fromSeed(
      seedColor: AppPalette.accentDeep,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppPalette.accentDeep,
      onPrimary: AppPalette.white,
      primaryContainer: const Color(0xFFD8E8DE),
      onPrimaryContainer: const Color(0xFF182A22),
      secondary: AppPalette.mintDeep,
      onSecondary: AppPalette.white,
      secondaryContainer: const Color(0xFFDCEBE4),
      onSecondaryContainer: const Color(0xFF16352B),
      tertiary: const Color(0xFF7A6436),
      onTertiary: AppPalette.white,
      error: const Color(0xFFB3261E),
      onError: AppPalette.white,
      errorContainer: const Color(0xFFFFDAD6),
      onErrorContainer: const Color(0xFF410002),
      surface: AppPalette.ivory,
      onSurface: AppPalette.ink,
      onSurfaceVariant: AppPalette.inkMuted,
      surfaceContainerLowest: AppPalette.white,
      surfaceContainerLow: AppPalette.paper,
      surfaceContainer: const Color(0xFFF0EDE4),
      surfaceContainerHigh: const Color(0xFFE8E4DA),
      surfaceContainerHighest: const Color(0xFFDDD9CF),
      outline: const Color(0xFF7B827C),
      outlineVariant: const Color(0xFFC9C5BB),
      shadow: AppPalette.black,
      scrim: AppPalette.black,
    );
  }

  static TextTheme _textTheme(bool isDark, ColorScheme scheme) {
    final TextTheme base =
        ThemeData(
          brightness: isDark ? Brightness.dark : Brightness.light,
          fontFamily: 'Inter',
        ).textTheme.apply(
          bodyColor: scheme.onSurface,
          displayColor: scheme.onSurface,
        );

    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontFamily: 'SpaceGrotesk',
        fontWeight: FontWeight.w600,
        letterSpacing: -3.4,
        height: 0.92,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontFamily: 'SpaceGrotesk',
        fontWeight: FontWeight.w600,
        letterSpacing: -2.4,
        height: 0.95,
      ),
      displaySmall: base.displaySmall?.copyWith(
        fontFamily: 'SpaceGrotesk',
        fontWeight: FontWeight.w600,
        letterSpacing: -1.6,
        height: 1,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        fontFamily: 'SpaceGrotesk',
        fontWeight: FontWeight.w600,
        letterSpacing: -1.2,
        height: 1.05,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontFamily: 'SpaceGrotesk',
        fontWeight: FontWeight.w600,
        letterSpacing: -0.9,
        height: 1.08,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontFamily: 'SpaceGrotesk',
        fontWeight: FontWeight.w600,
        letterSpacing: -0.6,
        height: 1.12,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontFamily: 'SpaceGrotesk',
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
      ),
      titleSmall: base.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      labelLarge: base.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 1.4,
      ),
      bodyLarge: base.bodyLarge?.copyWith(height: 1.45),
      bodyMedium: base.bodyMedium?.copyWith(height: 1.45),
      bodySmall: base.bodySmall?.copyWith(height: 1.4),
    );
  }
}
