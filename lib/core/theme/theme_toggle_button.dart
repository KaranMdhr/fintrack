import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'theme_mode_provider.dart';

class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode mode = ref.watch(themeModeProvider);
    final ThemeData theme = Theme.of(context);

    return IconButton(
      tooltip: 'Toggle theme',
      onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
      style: IconButton.styleFrom(
        backgroundColor: theme.colorScheme.surfaceContainerHigh.withValues(
          alpha: 0.5,
        ),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minimumSize: const Size(40, 40),
      ),
      icon: Icon(
        mode == ThemeMode.dark
            ? Icons.light_mode_outlined
            : Icons.dark_mode_outlined,
        size: 19,
      ),
    );
  }
}
