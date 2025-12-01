import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

/// Question papers page
class PapersPage extends ConsumerStatefulWidget {
  const PapersPage({super.key});

  @override
  ConsumerState<PapersPage> createState() => _PapersPageState();
}

class _PapersPageState extends ConsumerState<PapersPage> {
  String _selectedYear = '2024';
  String _selectedExamType = 'Regular';

  final List<String> _years = ['2024', '2023', '2022', '2021', '2020'];
  final List<String> _examTypes = ['Regular', 'Supplementary'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.questionPapers),
      ),
      body: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedYear,
                    decoration: const InputDecoration(
                      labelText: 'Year',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    items: _years.map((year) {
                      return DropdownMenuItem(
                        value: year,
                        child: Text(year),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedYear = value);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedExamType,
                    decoration: const InputDecoration(
                      labelText: 'Exam Type',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    items: _examTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedExamType = value);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          // Papers list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 6, // Placeholder
              itemBuilder: (context, index) {
                return _PaperCard(
                  subjectCode: 'CST${200 + index}',
                  subjectName: 'Subject ${index + 1}',
                  year: _selectedYear,
                  examType: _selectedExamType,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PaperCard extends StatelessWidget {
  final String subjectCode;
  final String subjectName;
  final String year;
  final String examType;

  const _PaperCard({
    required this.subjectCode,
    required this.subjectName,
    required this.year,
    required this.examType,
  });

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
          subjectName,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        subtitle: Text('$subjectCode • $year $examType'),
        trailing: IconButton(
          icon: const Icon(Icons.download_outlined),
          onPressed: () {
            // TODO: Download paper
          },
        ),
      ),
    );
  }
}
