import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/ktu_data.dart';
import '../../../../config/router.dart';
import '../../../../config/providers.dart';

/// Branch selection page
class BranchSelectionPage extends ConsumerWidget {
  const BranchSelectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedBranch = ref.watch(userPreferencesProvider).branchId;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.selectBranch),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Choose your engineering branch to get personalized content',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
              ),
            ),

            // Branch grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: KtuData.branches.length,
                itemBuilder: (context, index) {
                  final branch = KtuData.branches[index];
                  final isSelected = selectedBranch == branch.id;

                  return _BranchCard(
                    branch: branch,
                    isSelected: isSelected,
                    onTap: () async {
                      await ref
                          .read(userPreferencesProvider.notifier)
                          .setBranch(branch.id);
                    },
                  );
                },
              ),
            ),

            // Continue button
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: selectedBranch != null
                      ? () => context.go(AppRoutes.semesterSelection)
                      : null,
                  child: const Text(AppStrings.continueText),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BranchCard extends StatelessWidget {
  final Branch branch;
  final bool isSelected;
  final VoidCallback onTap;

  const _BranchCard({
    required this.branch,
    required this.isSelected,
    required this.onTap,
  });

  IconData _getIcon() {
    switch (branch.icon) {
      case 'computer':
        return Icons.computer_rounded;
      case 'memory':
        return Icons.memory_rounded;
      case 'bolt':
        return Icons.bolt_rounded;
      case 'settings':
        return Icons.settings_rounded;
      case 'domain':
        return Icons.domain_rounded;
      case 'code':
        return Icons.code_rounded;
      case 'business':
        return Icons.business_center_rounded;
      case 'psychology':
        return Icons.psychology_rounded;
      case 'smart_toy':
        return Icons.smart_toy_rounded;
      case 'security':
        return Icons.security_rounded;
      case 'flight':
        return Icons.flight_rounded;
      case 'directions_car':
        return Icons.directions_car_rounded;
      case 'biotech':
        return Icons.biotech_rounded;
      case 'science':
        return Icons.science_rounded;
      default:
        return Icons.engineering_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? AppColors.primary.withValues(alpha: 0.1)
          : Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.dividerLight,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getIcon(),
                size: 32,
                color: isSelected
                    ? AppColors.primary
                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 8),
              Text(
                branch.shortName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.primary : null,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                branch.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
