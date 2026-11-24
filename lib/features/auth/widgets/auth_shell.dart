import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/theme_toggle_button.dart';
import '../../../core/widgets/app_background.dart';
import '../../../core/widgets/brand_mark.dart';
import '../../../core/widgets/glass_panel.dart';

class AuthShell extends StatelessWidget {
  const AuthShell({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.form,
    required this.footer,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final Widget form;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.sizeOf(context).width >= 980;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(wide ? 32 : 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: wide ? 1080 : 440),
                child: wide
                    ? IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Expanded(flex: 5, child: _BrandPanel()),
                            const SizedBox(width: 24),
                            Expanded(
                              flex: 4,
                              child: _FormPanel(
                                eyebrow: eyebrow,
                                title: title,
                                subtitle: subtitle,
                                form: form,
                                footer: footer,
                                showBrand: false,
                              ),
                            ),
                          ],
                        ),
                      )
                    : _FormPanel(
                        eyebrow: eyebrow,
                        title: title,
                        subtitle: subtitle,
                        form: form,
                        footer: footer,
                        showBrand: true,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return GlassPanel(
      padding: const EdgeInsets.all(36),
      borderRadius: AppRadii.xl,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[Color(0xFF121615), Color(0xFF080A09)],
      ),
      borderColor: Colors.white.withValues(alpha: 0.08),
      shadows: <BoxShadow>[
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.28),
          blurRadius: 32,
          offset: const Offset(0, 18),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BrandLockup(markSize: 42, color: AppPalette.silver),
          const SizedBox(height: 52),
          Text(
            'Spend with\nintention.',
            style: theme.textTheme.displayMedium?.copyWith(
              color: AppPalette.white,
              fontWeight: FontWeight.w600,
              height: 0.94,
              letterSpacing: -2.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'A quieter, sharper way to see where your money goes.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.52),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),
          const _Feature(
            text: 'Private by default',
            caption: 'Your ledger belongs to you.',
          ),
          const SizedBox(height: 18),
          const _Feature(
            text: 'Real-time clarity',
            caption: 'Every entry updates instantly.',
          ),
          const SizedBox(height: 18),
          const _Feature(
            text: 'Designed for daily use',
            caption: 'Fast, quiet, and out of your way.',
          ),
          const SizedBox(height: 48),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(AppRadii.pill),
              border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
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
                  'CLARITY IS A FEATURE',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 8,
                    letterSpacing: 1.8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature({required this.text, required this.caption});

  final String text;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 5),
          width: 7,
          height: 7,
          decoration: const BoxDecoration(
            color: AppPalette.accent,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppPalette.silver,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                caption,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FormPanel extends StatelessWidget {
  const _FormPanel({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.form,
    required this.footer,
    required this.showBrand,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final Widget form;
  final Widget footer;
  final bool showBrand;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return GlassPanel(
      padding: const EdgeInsets.all(28),
      borderRadius: AppRadii.xl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (showBrand)
                const BrandLockup(markSize: 34)
              else
                const SizedBox.shrink(),
              const Spacer(),
              const ThemeToggleButton(),
            ],
          ),
          const SizedBox(height: 30),
          Text(
            eyebrow,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              letterSpacing: 1.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 26),
          form,
          const SizedBox(height: 18),
          footer,
        ],
      ),
    );
  }
}
