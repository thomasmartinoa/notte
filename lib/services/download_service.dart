import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'storage_service.dart';

/// Download status enum
enum DownloadStatus {
  idle,
  downloading,
  paused,
  completed,
  failed,
}

/// Download task model
class DownloadTask {
  final String noteId;
  final String url;
  final String title;
  final String? localPath;
  final double progress;
  final DownloadStatus status;
  final String? error;
  final CancelToken? cancelToken;

  const DownloadTask({
    required this.noteId,
    required this.url,
    required this.title,
    this.localPath,
    this.progress = 0,
    this.status = DownloadStatus.idle,
    this.error,
    this.cancelToken,
  });

  DownloadTask copyWith({
    String? noteId,
    String? url,
    String? title,
    String? localPath,
    double? progress,
    DownloadStatus? status,
    String? error,
    CancelToken? cancelToken,
  }) {
    return DownloadTask(
      noteId: noteId ?? this.noteId,
      url: url ?? this.url,
      title: title ?? this.title,
      localPath: localPath ?? this.localPath,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      error: error ?? this.error,
      cancelToken: cancelToken ?? this.cancelToken,
    );
  }
}

/// Service for downloading files
class DownloadService {
  final Dio dio;
  final StorageService storageService;
  
  // Active downloads tracking
  final Map<String, DownloadTask> _activeDownloads = {};

  DownloadService({
    required this.dio,
    required this.storageService,
  });

  /// Get active download for a note
  DownloadTask? getActiveDownload(String noteId) {
    return _activeDownloads[noteId];
  }

  /// Check if download is in progress
  bool isDownloading(String noteId) {
    return _activeDownloads[noteId]?.status == DownloadStatus.downloading;
  }

  /// Download a note PDF
  Future<DownloadTask> downloadNote({
    required String noteId,
    required String url,
    required String title,
    void Function(double progress)? onProgress,
    void Function(DownloadTask task)? onComplete,
    void Function(String error)? onError,
  }) async {
    // Check if already downloading
    if (isDownloading(noteId)) {
      return _activeDownloads[noteId]!;
    }

    // Check if already downloaded
    if (storageService.isNoteDownloaded(noteId)) {
      final localPath = storageService.getDownloadedNotePath(noteId);
      return DownloadTask(
        noteId: noteId,
        url: url,
        title: title,
        localPath: localPath,
        progress: 1.0,
        status: DownloadStatus.completed,
      );
    }

    // Create cancel token
    final cancelToken = CancelToken();

    // Initialize download task
    var task = DownloadTask(
      noteId: noteId,
      url: url,
      title: title,
      status: DownloadStatus.downloading,
      cancelToken: cancelToken,
    );
    _activeDownloads[noteId] = task;

    try {
      // Get download path
      final downloadsPath = await StorageService.getDownloadsPath();
      final fileName = _sanitizeFileName('$title.pdf');
      final localPath = path.join(downloadsPath, fileName);

      // Download file
      await dio.download(
        url,
        localPath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final progress = received / total;
            task = task.copyWith(progress: progress);
            _activeDownloads[noteId] = task;
            onProgress?.call(progress);
          }
        },
      );

      // Get file size
      final file = File(localPath);
      final fileSize = await file.length();

      // Save to storage
      await storageService.saveDownload(
        noteId: noteId,
        title: title,
        localPath: localPath,
        fileSize: fileSize,
        downloadedAt: DateTime.now(),
      );

      // Update task
      task = task.copyWith(
        localPath: localPath,
        progress: 1.0,
        status: DownloadStatus.completed,
      );
      _activeDownloads[noteId] = task;
      onComplete?.call(task);

      return task;
    } on DioException catch (e) {
      String errorMessage;
      if (e.type == DioExceptionType.cancel) {
        errorMessage = 'Download cancelled';
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Download timed out';
      } else {
        errorMessage = e.message ?? 'Download failed';
      }

      task = task.copyWith(
        status: DownloadStatus.failed,
        error: errorMessage,
      );
      _activeDownloads[noteId] = task;
      onError?.call(errorMessage);

      return task;
    } catch (e) {
      final errorMessage = 'Download failed: ${e.toString()}';
      task = task.copyWith(
        status: DownloadStatus.failed,
        error: errorMessage,
      );
      _activeDownloads[noteId] = task;
      onError?.call(errorMessage);

      return task;
    }
  }

  /// Cancel a download
  void cancelDownload(String noteId) {
    final task = _activeDownloads[noteId];
    if (task != null && task.cancelToken != null) {
      task.cancelToken!.cancel('User cancelled');
      _activeDownloads[noteId] = task.copyWith(
        status: DownloadStatus.failed,
        error: 'Download cancelled',
      );
    }
  }

  /// Delete a downloaded note
  Future<void> deleteDownload(String noteId) async {
    cancelDownload(noteId);
    await storageService.removeDownload(noteId);
    _activeDownloads.remove(noteId);
  }

  /// Get all active downloads
  List<DownloadTask> get activeDownloads {
    return _activeDownloads.values
        .where((t) => t.status == DownloadStatus.downloading)
        .toList();
  }

  /// Sanitize filename
  String _sanitizeFileName(String fileName) {
    return fileName
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase();
  }
}
