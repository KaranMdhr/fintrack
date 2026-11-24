import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/currency/app_currency.dart';
import '../../../core/currency/currency_provider.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/theme_mode_provider.dart';
import '../../../core/utils/error_messages.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/error_banner.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../core/widgets/press_scale.dart';
import '../../../core/widgets/section_heading.dart';
import '../../auth/providers/auth_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isSigningOut = false;
  String? _error;

  Future<void> _signOut() async {
    if (_isSigningOut) return;
    setState(() {
      _isSigningOut = true;
      _error = null;
    });

    try {
      await ref.read(authRepositoryProvider).signOut();
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _error = authErrorMessage(error));
    } finally {
      if (mounted) setState(() => _isSigningOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).asData?.value;
    final ThemeMode mode = ref.watch(themeModeProvider);
    final AppCurrency currency = ref.watch(currencyProvider);
    final String displayName = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!
        : user?.email?.split('@').first ?? 'Guest';
    final String email = user?.email ?? 'Not signed in';
    final String provider = _providerLabel(
      user?.providerData ?? const <UserInfo>[],
    );
    final String initials = _initials(displayName);

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool wide = constraints.maxWidth >= 760;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SettingsHeader(wide: wide),
                  const SizedBox(height: 24),
                  if (wide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: _ProfileCard(
                            displayName: displayName,
                            email: email,
                            provider: provider,
                            initials: initials,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 6,
                          child: _AppearanceCard(
                            mode: mode,
                            onChanged: (value) => ref
                                .read(themeModeProvider.notifier)
                                .setMode(value),
                          ),
                        ),
                      ],
                    )
                  else ...[
                    _ProfileCard(
                      displayName: displayName,
                      email: email,
                      provider: provider,
                      initials: initials,
                    ),
                    const SizedBox(height: 16),
                    _AppearanceCard(
                      mode: mode,
                      onChanged: (value) =>
                          ref.read(themeModeProvider.notifier).setMode(value),
                    ),
                  ],
                  const SizedBox(height: 16),
                  _CurrencyCard(
                    currency: currency,
                    onChanged: (value) =>
                        ref.read(currencyProvider.notifier).setCurrency(value),
                  ),
                  const SizedBox(height: 16),
                  GlassPanel(
                    padding: const EdgeInsets.all(22),
                    borderRadius: AppRadii.xl,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeading(
                          title: 'Session',
                          subtitle: 'End your session on this device.',
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 14),
                          ErrorBanner(message: _error!),
                        ],
                        const SizedBox(height: 18),
                        OutlinedButton.icon(
                          onPressed: _isSigningOut ? null : _signOut,
                          icon: _isSigningOut
                              ? const SizedBox.square(
                                  dimension: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.logout_rounded, size: 18),
                          label: Text(
                            _isSigningOut ? 'Signing out...' : 'Sign out',
                          ),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 48),
                            foregroundColor: Theme.of(context)
                                .colorScheme
                                .error,
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.error
                                  .withValues(alpha: 0.35),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'FINTRACK  ·  PRIVATE BY DESIGN',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.55),
                      letterSpacing: 1.8,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _providerLabel(List<UserInfo> providers) {
    if (providers.isEmpty) return 'Firebase';
    final String id = providers.first.providerId;
    if (id.contains('google')) return 'Google';
    if (id.contains('password')) return 'Email';
    return 'Firebase';
  }

  String _initials(String name) {
    final List<String> parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'F';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader({required this.wide});

  final bool wide;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SETTINGS  /  PERSONAL SPACE',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.primary,
            letterSpacing: 1.8,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Make it yours.',
          style:
              (wide
                      ? theme.textTheme.displaySmall
                      : theme.textTheme.headlineMedium)
                  ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Text(
          'Shape how Fintrack looks and how your account works.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.displayName,
    required this.email,
    required this.provider,
    required this.initials,
  });

  final String displayName;
  final String email;
  final String provider;
  final String initials;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return GlassPanel(
      padding: const EdgeInsets.all(22),
      borderRadius: AppRadii.xl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeading(
            title: 'Profile',
            subtitle: 'Your account, in one glance.',
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                  ),
                ),

                child: Center(
                  child: Text(
                    initials,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.2,
                          ),
                        ),
                      ),
                      child: Text(
                        '$provider account',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontSize: 9,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh.withValues(
                alpha: 0.35,
              ),
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your expenses are private to this account.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
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

class _AppearanceCard extends StatelessWidget {
  const _AppearanceCard({required this.mode, required this.onChanged});

  final ThemeMode mode;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(22),
      borderRadius: AppRadii.xl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeading(
            title: 'Appearance',
            subtitle: 'Choose your atmosphere.',
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final bool horizontal = constraints.maxWidth >= 430;
              final List<Widget> options = [
                _ThemeOption(
                  selected: mode == ThemeMode.system,
                  icon: Icons.brightness_auto_rounded,
                  title: 'System',
                  description: 'Follow your device',
                  onTap: () => onChanged(ThemeMode.system),
                ),
                _ThemeOption(
                  selected: mode == ThemeMode.light,
                  icon: Icons.light_mode_rounded,
                  title: 'Daylight',
                  description: 'Warm and bright',
                  onTap: () => onChanged(ThemeMode.light),
                ),
                _ThemeOption(
                  selected: mode == ThemeMode.dark,
                  icon: Icons.dark_mode_rounded,
                  title: 'Midnight',
                  description: 'Deep and focused',
                  onTap: () => onChanged(ThemeMode.dark),
                ),
              ];

              if (horizontal) {
                return Row(
                  children: [
                    for (int i = 0; i < options.length; i++) ...[
                      Expanded(child: options[i]),
                      if (i != options.length - 1) const SizedBox(width: 8),
                    ],
                  ],
                );
              }

              return Column(
                children: [
                  for (int i = 0; i < options.length; i++) ...[
                    options[i],
                    if (i != options.length - 1) const SizedBox(height: 8),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CurrencyCard extends StatelessWidget {
  const _CurrencyCard({required this.currency, required this.onChanged});

  final AppCurrency currency;
  final ValueChanged<AppCurrency> onChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return GlassPanel(
      padding: const EdgeInsets.all(22),
      borderRadius: AppRadii.xl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeading(
            title: 'Currency',
            subtitle: 'Choose how amounts appear across Fintrack.',
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final bool horizontal = constraints.maxWidth >= 520;
              final Widget picker = DropdownButtonFormField<AppCurrency>(
                key: ValueKey<String>(currency.code),
                initialValue: currency,
                isExpanded: true,
                menuMaxHeight: 320,
                decoration: const InputDecoration(
                  labelText: 'Display currency',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                items: [
                  for (final AppCurrency option in AppCurrencies.all)
                    DropdownMenuItem<AppCurrency>(
                      value: option,
                      child: Text(
                        option.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) onChanged(value);
                },
              );
              final Widget preview = Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.visibility_outlined,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Preview  ${AppFormatters.currency(1234.56, currency: currency)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              );

              if (horizontal) {
                return Row(
                  children: [
                    Expanded(flex: 3, child: picker),
                    const SizedBox(width: 14),
                    Expanded(flex: 2, child: preview),
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [picker, const SizedBox(height: 12), preview],
              );
            },
          ),
          const SizedBox(height: 10),
          Text(
            'This changes the symbol and number format only. Existing expense amounts are not converted.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.selected,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color accent = selected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;

    return PressScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary.withValues(alpha: 0.28)
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, size: 17, color: accent),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 9,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(
                Icons.check_circle_rounded,
                size: 16,
                color: theme.colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}
