import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

/// PDF viewer page for notes
class NoteViewerPage extends ConsumerWidget {
  final String noteId;

  const NoteViewerPage({super.key, required this.noteId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Fetch note details and file path from storage
    final isDownloaded = false; // Placeholder

    return Scaffold(
      appBar: AppBar(
        title: Text('Note: $noteId'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {
              // TODO: Toggle bookmark
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Share note
            },
          ),
        ],
      ),
      body: isDownloaded
          ? const Center(
              child: Text('PDF Viewer will be shown here'),
              // SfPdfViewer.file(File(localPath))
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.picture_as_pdf,
                    size: 80,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Note not downloaded',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text('Download the note to view it offline'),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Download note
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Download Now'),
                  ),
                ],
              ),
            ),
    );
  }
}
