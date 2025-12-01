import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

/// PDF viewer page for notes
class NoteViewerPage extends ConsumerStatefulWidget {
  final String noteId;

  const NoteViewerPage({super.key, required this.noteId});

  @override
  ConsumerState<NoteViewerPage> createState() => _NoteViewerPageState();
}

class _NoteViewerPageState extends ConsumerState<NoteViewerPage> {
  bool _isDownloaded = false;

  @override
  void initState() {
    super.initState();
    // TODO: Check if note is downloaded
    _checkDownloadStatus();
  }

  Future<void> _checkDownloadStatus() async {
    // TODO: Implement download status check
    setState(() {
      _isDownloaded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Note: ${widget.noteId}'),
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
      body: _isDownloaded
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
