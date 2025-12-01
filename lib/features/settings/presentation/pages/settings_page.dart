import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../config/providers.dart';

/// Settings page
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(userPreferencesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settings),
      ),
      body: ListView(
        children: [
          // Appearance section
          _SectionHeader(title: 'Appearance'),
          SwitchListTile(
            title: const Text(AppStrings.darkMode),
            subtitle: const Text('Use dark theme'),
            value: prefs.isDarkMode,
            onChanged: (value) {
              ref.read(userPreferencesProvider.notifier).setDarkMode(value);
            },
          ),

          const Divider(),

          // Account section
          _SectionHeader(title: 'Account'),
          ListTile(
            leading: const Icon(Icons.school),
            title: const Text('Branch & Semester'),
            subtitle: Text(
              '${prefs.branchId?.toUpperCase() ?? 'Not set'} • Semester ${prefs.semester ?? '-'}',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to branch/semester selection
            },
          ),

          const Divider(),

          // Storage section
          _SectionHeader(title: 'Storage'),
          ListTile(
            leading: const Icon(Icons.storage),
            title: const Text(AppStrings.clearCache),
            subtitle: const Text('Free up storage space'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showClearCacheDialog(context, ref);
            },
          ),

          const Divider(),

          // About section
          _SectionHeader(title: 'About'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text(AppStrings.aboutApp),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showAboutDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text(AppStrings.privacyPolicy),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Open privacy policy
            },
          ),
          ListTile(
            leading: const Icon(Icons.star_outline),
            title: const Text(AppStrings.rateApp),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Open Play Store
            },
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.clearCache),
        content: const Text(AppStrings.confirmClearCache),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(storageServiceProvider).clearAllCache();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text(AppStrings.successClearCache)),
                );
              }
            },
            child: const Text(AppStrings.confirm),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppStrings.appName,
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2024 KTU Scholar',
      children: [
        const SizedBox(height: 16),
        const Text(AppStrings.appDescription),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
