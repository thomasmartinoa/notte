import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';

/// Subject notes page - shows modules and notes for a subject
class SubjectNotesPage extends ConsumerWidget {
  final String subjectId;

  const SubjectNotesPage({super.key, required this.subjectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Fetch notes from Supabase
    final modules = List.generate(5, (i) => 'Module ${i + 1}');

    return Scaffold(
      appBar: AppBar(
        title: Text(subjectId.toUpperCase()),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: modules.length,
        itemBuilder: (context, index) {
          return _ModuleCard(
            moduleNumber: index + 1,
            moduleName: modules[index],
            notesCount: 3, // Placeholder
          );
        },
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final int moduleNumber;
  final String moduleName;
  final int notesCount;

  const _ModuleCard({
    required this.moduleNumber,
    required this.moduleName,
    required this.notesCount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              'M$moduleNumber',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ),
        title: Text(
          moduleName,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        subtitle: Text(
          '$notesCount notes available',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        children: [
          // Placeholder notes list
          ...List.generate(notesCount, (i) {
            return ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: Text('Note ${i + 1}'),
              subtitle: const Text('2.5 MB • PDF'),
              trailing: IconButton(
                icon: const Icon(Icons.download_outlined),
                onPressed: () {
                  // TODO: Implement download
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
