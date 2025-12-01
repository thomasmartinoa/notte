import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/ktu_data.dart';
import '../../../../config/router.dart';
import '../../../../config/providers.dart';

/// Semester selection page
class SemesterSelectionPage extends ConsumerWidget {
  const SemesterSelectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSemester = ref.watch(userPreferencesProvider).semester;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.selectSemester),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Select your current semester to see relevant subjects',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
              ),
            ),

            // Semester grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: KtuData.semesters.length,
                itemBuilder: (context, index) {
                  final semester = KtuData.semesters[index];
                  final isSelected = selectedSemester == semester.number;

                  return _SemesterCard(
                    semester: semester,
                    isSelected: isSelected,
                    onTap: () async {
                      await ref
                          .read(userPreferencesProvider.notifier)
                          .setSemester(semester.number);
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
                  onPressed: selectedSemester != null
                      ? () async {
                          await ref
                              .read(userPreferencesProvider.notifier)
                              .completeOnboarding();
                          if (context.mounted) {
                            context.go(AppRoutes.home);
                          }
                        }
                      : null,
                  child: const Text(AppStrings.getStarted),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SemesterCard extends StatelessWidget {
  final Semester semester;
  final bool isSelected;
  final VoidCallback onTap;

  const _SemesterCard({
    required this.semester,
    required this.isSelected,
    required this.onTap,
  });

  String _getOrdinal(int number) {
    if (number >= 11 && number <= 13) return '${number}th';
    switch (number % 10) {
      case 1:
        return '${number}st';
      case 2:
        return '${number}nd';
      case 3:
        return '${number}rd';
      default:
        return '${number}th';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? AppColors.primary.withValues(alpha: 0.1)
          : Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.dividerLight,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'S${semester.number}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppColors.primary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_getOrdinal(semester.number)} Semester',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
