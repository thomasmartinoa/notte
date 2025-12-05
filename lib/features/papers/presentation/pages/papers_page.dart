import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../config/providers.dart';

/// Question papers page
class PapersPage extends ConsumerStatefulWidget {
  const PapersPage({super.key});

  @override
  ConsumerState<PapersPage> createState() => _PapersPageState();
}

class _PapersPageState extends ConsumerState<PapersPage> {
  String? _selectedYear;
  String? _selectedExamType;

  @override
  Widget build(BuildContext context) {
    final papersAsync = ref.watch(questionPapersProvider);
    final prefs = ref.watch(userPreferencesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.questionPapers),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(questionPapersProvider),
          ),
        ],
      ),
      body: papersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading papers: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(questionPapersProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (papers) {
          if (papers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No question papers found',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Papers for Semester ${prefs.semester ?? '-'} will appear here',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                  ),
                ],
              ),
            );
          }

          // Get unique years and exam types for filters
          final years = papers.map((p) => p.year.toString()).toSet().toList()..sort((a, b) => b.compareTo(a));
          final examTypes = papers.map((p) => p.examType).toSet().toList()..sort();

          // Filter papers
          var filteredPapers = papers;
          if (_selectedYear != null) {
            filteredPapers = filteredPapers.where((p) => p.year.toString() == _selectedYear).toList();
          }
          if (_selectedExamType != null) {
            filteredPapers = filteredPapers.where((p) => p.examType == _selectedExamType).toList();
          }

          return Column(
            children: [
              // Filters
              if (years.length > 1 || examTypes.length > 1)
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      if (years.length > 1)
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedYear,
                            decoration: const InputDecoration(
                              labelText: 'Year',
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            hint: const Text('All Years'),
                            items: [
                              const DropdownMenuItem(value: null, child: Text('All Years')),
                              ...years.map((year) => DropdownMenuItem(
                                    value: year,
                                    child: Text(year),
                                  )),
                            ],
                            onChanged: (value) {
                              setState(() => _selectedYear = value);
                            },
                          ),
                        ),
                      if (years.length > 1 && examTypes.length > 1)
                        const SizedBox(width: 12),
                      if (examTypes.length > 1)
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedExamType,
                            decoration: const InputDecoration(
                              labelText: 'Exam Type',
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            hint: const Text('All Types'),
                            items: [
                              const DropdownMenuItem(value: null, child: Text('All Types')),
                              ...examTypes.map((type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  )),
                            ],
                            onChanged: (value) {
                              setState(() => _selectedExamType = value);
                            },
                          ),
                        ),
                    ],
                  ),
                ),

              // Info chip showing semester
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Chip(
                      avatar: const Icon(Icons.school, size: 18),
                      label: Text('Semester ${prefs.semester ?? '-'}'),
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${filteredPapers.length} papers',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Papers list
              Expanded(
                child: filteredPapers.isEmpty
                    ? Center(
                        child: Text(
                          'No papers match the selected filters',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredPapers.length,
                        itemBuilder: (context, index) {
                          final paper = filteredPapers[index];
                          return _PaperCard(paper: paper);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PaperCard extends StatelessWidget {
  final QuestionPaper paper;

  const _PaperCard({required this.paper});

  Future<void> _openPdf(BuildContext context) async {
    if (paper.pdfUrl == null || paper.pdfUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF not available')),
      );
      return;
    }

    final uri = Uri.parse(paper.pdfUrl!);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open PDF')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.description_rounded,
            color: AppColors.secondary,
          ),
        ),
        title: Text(
          paper.subjectName,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text('${paper.subjectCode} • ${paper.year} ${paper.examType}'),
        trailing: IconButton(
          icon: const Icon(Icons.open_in_new),
          onPressed: () => _openPdf(context),
          tooltip: 'Open PDF',
        ),
        onTap: () => _openPdf(context),
      ),
    );
  }
}
