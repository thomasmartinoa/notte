import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/ktu_data.dart';
import '../../../../config/providers.dart';

/// Notes browsing page
class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(userPreferencesProvider);
    final subjects = KtuData.getSubjects(
      prefs.branchId ?? 'cse',
      prefs.semester ?? 1,
      schemeId: prefs.schemeId,
    );

    // Get scheme name for display
    String schemeName = '';
    if (prefs.schemeId != null) {
      final scheme = KtuData.getScheme(prefs.schemeId!);
      schemeName = scheme?.name ?? '';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.notes),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_done_rounded),
            onPressed: () {
              // Show downloaded notes
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Scheme & Semester info chip
          if (schemeName.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  Chip(
                    avatar: const Icon(Icons.calendar_today, size: 16),
                    label: Text(schemeName),
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    avatar: const Icon(Icons.school, size: 16),
                    label: Text('Semester ${prefs.semester ?? '-'}'),
                    backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
          
          // Subjects list
          Expanded(
            child: subjects.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.menu_book_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        const Text('No subjects found'),
                        const SizedBox(height: 8),
                        Text(
                          'Subjects for this combination will appear here',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: subjects.length,
                    itemBuilder: (context, index) {
                      final subject = subjects[index];
                      return _SubjectNoteCard(subject: subject);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SubjectNoteCard extends StatelessWidget {
  final Subject subject;

  const _SubjectNoteCard({required this.subject});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push('/notes/${subject.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.code,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subject.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${subject.modules} Modules',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
