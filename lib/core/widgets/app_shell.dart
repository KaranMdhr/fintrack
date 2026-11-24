import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../features/auth/providers/auth_providers.dart';
import '../theme/app_motion.dart';
import '../theme/app_spacing.dart';
import 'app_background.dart';
import 'app_bottom_bar.dart';
import 'brand_mark.dart';
import 'glass_panel.dart';
import 'press_scale.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.sizeOf(context).width >= 960;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: wide
              ? Row(
                  children: [
                    _SideNav(
                      index: navigationShell.currentIndex,
                      onTap: _goBranch,
                    ),
                    Expanded(child: navigationShell),
                  ],
                )
              : navigationShell,
        ),
        bottomNavigationBar: wide
            ? null
            : AppBottomBar(
                index: navigationShell.currentIndex,
                onTap: _goBranch,
              ),
      ),
    );
  }
}

class _SideNav extends ConsumerWidget {
  const _SideNav({required this.index, required this.onTap});

  final int index;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final user = ref.watch(authStateProvider).asData?.value;
    final String displayName = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!
        : user?.email?.split('@').first ?? 'Guest';
    final String email = user?.email ?? 'Not signed in';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: 250,
        height: double.infinity,
        child: GlassPanel(
          padding: const EdgeInsets.all(18),
          borderRadius: AppRadii.xl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: BrandLockup(markSize: 38),
              ),
              const SizedBox(height: 34),
              for (int i = 0; i < appNavItems.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: _SideNavItem(
                    item: appNavItems[i],
                    selected: i == index,
                    onTap: () => onTap(i),
                  ),
                ),
              const Spacer(),
              Container(
                height: 1,
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 14),
              PressScale(
                onTap: () => onTap(2),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: theme.colorScheme.primary.withValues(
                          alpha: 0.16,
                        ),
                        child: Text(
                          displayName.characters.first.toUpperCase(),
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SideNavItem extends StatelessWidget {
  const _SideNavItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final AppNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color activeColor = theme.colorScheme.primary;

    return PressScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        curve: AppMotion.enter,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? activeColor.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(
            color: selected
                ? activeColor.withValues(alpha: 0.14)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? item.activeIcon : item.icon,
              size: 20,
              color: selected
                  ? activeColor
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: selected
                      ? activeColor
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
