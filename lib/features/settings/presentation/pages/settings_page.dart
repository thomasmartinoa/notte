import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/ktu_data.dart';
import '../../../../config/providers.dart';

/// Settings page
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(userPreferencesProvider);

    // Find branch name from ID
    String branchName = 'Not set';
    if (prefs.branchId != null) {
      final branch = KtuData.branches.where((b) => b.id == prefs.branchId).firstOrNull;
      branchName = branch?.shortName ?? prefs.branchId!.toUpperCase();
    }

    // Find scheme name from ID
    String schemeName = 'Not set';
    if (prefs.schemeId != null) {
      final scheme = KtuData.schemes.where((s) => s.id == prefs.schemeId).firstOrNull;
      schemeName = scheme?.name ?? '${prefs.schemeId} Scheme';
    }

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

          // Academic section
          _SectionHeader(title: 'Academic'),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('KTU Scheme'),
            subtitle: Text(schemeName),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showSchemeSheet(context, ref);
            },
          ),
          ListTile(
            leading: const Icon(Icons.school),
            title: const Text('Branch & Semester'),
            subtitle: Text(
              '$branchName • Semester ${prefs.semester ?? '-'}',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showBranchSemesterSheet(context, ref);
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

  void _showSchemeSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _SchemeSheet(ref: ref),
    );
  }

  void _showBranchSemesterSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _BranchSemesterSheet(ref: ref),
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

/// Bottom sheet for changing branch and semester
class _BranchSemesterSheet extends ConsumerStatefulWidget {
  final WidgetRef ref;

  const _BranchSemesterSheet({required this.ref});

  @override
  ConsumerState<_BranchSemesterSheet> createState() => _BranchSemesterSheetState();
}

class _BranchSemesterSheetState extends ConsumerState<_BranchSemesterSheet> {
  String? _selectedBranch;
  int? _selectedSemester;

  @override
  void initState() {
    super.initState();
    final prefs = widget.ref.read(userPreferencesProvider);
    _selectedBranch = prefs.branchId;
    _selectedSemester = prefs.semester;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Change Branch & Semester',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const Divider(),

            // Content
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Branch section
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Select Branch',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: KtuData.branches.map((branch) {
                        final isSelected = _selectedBranch == branch.id;
                        return ChoiceChip(
                          label: Text(branch.shortName),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedBranch = selected ? branch.id : null;
                            });
                          },
                          selectedColor: AppColors.primary.withValues(alpha: 0.2),
                          labelStyle: TextStyle(
                            color: isSelected 
                                ? AppColors.primary 
                                : Theme.of(context).colorScheme.onSurface,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // Semester section
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Select Semester',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: KtuData.semesters.map((semester) {
                        final isSelected = _selectedSemester == semester.number;
                        return ChoiceChip(
                          label: Text('S${semester.number}'),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedSemester = selected ? semester.number : null;
                            });
                          },
                          selectedColor: AppColors.primary.withValues(alpha: 0.2),
                          labelStyle: TextStyle(
                            color: isSelected 
                                ? AppColors.primary 
                                : Theme.of(context).colorScheme.onSurface,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Save button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _selectedBranch != null && _selectedSemester != null
                      ? () async {
                          final notifier = widget.ref.read(userPreferencesProvider.notifier);
                          await notifier.setBranch(_selectedBranch!);
                          await notifier.setSemester(_selectedSemester!);
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Preferences updated successfully'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
                      : null,
                  child: const Text('Save Changes'),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Bottom sheet for changing scheme
class _SchemeSheet extends ConsumerStatefulWidget {
  final WidgetRef ref;

  const _SchemeSheet({required this.ref});

  @override
  ConsumerState<_SchemeSheet> createState() => _SchemeSheetState();
}

class _SchemeSheetState extends ConsumerState<_SchemeSheet> {
  String? _selectedScheme;

  @override
  void initState() {
    super.initState();
    final prefs = widget.ref.read(userPreferencesProvider);
    _selectedScheme = prefs.schemeId;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Title
          Text(
            'Select KTU Scheme',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose based on your admission year',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
          ),
          const SizedBox(height: 20),

          // Scheme options
          ...KtuData.schemes.map((scheme) {
            final isSelected = _selectedScheme == scheme.id;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  width: 2,
                ),
              ),
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : Theme.of(context).colorScheme.surface,
              child: ListTile(
                onTap: () {
                  setState(() => _selectedScheme = scheme.id);
                },
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      scheme.id,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                title: Row(
                  children: [
                    Text(
                      scheme.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppColors.primary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    if (scheme.isCurrent) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Latest',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                subtitle: Text(scheme.description),
                trailing: isSelected
                    ? Icon(Icons.check_circle, color: AppColors.primary)
                    : null,
              ),
            );
          }),

          const SizedBox(height: 8),

          // Save button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _selectedScheme != null
                  ? () async {
                      await widget.ref
                          .read(userPreferencesProvider.notifier)
                          .setScheme(_selectedScheme!);
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Scheme updated successfully'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  : null,
              child: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}
