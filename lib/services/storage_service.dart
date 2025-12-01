import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

/// Service for local storage operations using Hive
class StorageService {
  final Box preferencesBox;
  final Box downloadsBox;
  final Box bookmarksBox;

  StorageService({
    required this.preferencesBox,
    required this.downloadsBox,
    required this.bookmarksBox,
  });

  // ============ USER PREFERENCES ============

  /// Get user's selected branch ID
  String? get branchId => preferencesBox.get('branch_id');

  /// Set user's selected branch ID
  Future<void> setBranchId(String branchId) async {
    await preferencesBox.put('branch_id', branchId);
  }

  /// Get user's selected semester
  int? get semester => preferencesBox.get('semester');

  /// Set user's selected semester
  Future<void> setSemester(int semester) async {
    await preferencesBox.put('semester', semester);
  }

  /// Check if onboarding is completed
  bool get hasCompletedOnboarding =>
      preferencesBox.get('has_completed_onboarding', defaultValue: false);

  /// Mark onboarding as completed
  Future<void> completeOnboarding() async {
    await preferencesBox.put('has_completed_onboarding', true);
  }

  /// Get dark mode preference
  bool get isDarkMode =>
      preferencesBox.get('is_dark_mode', defaultValue: false);

  /// Set dark mode preference
  Future<void> setDarkMode(bool isDarkMode) async {
    await preferencesBox.put('is_dark_mode', isDarkMode);
  }

  // ============ DOWNLOADS ============

  /// Get all downloaded notes metadata
  List<Map<String, dynamic>> get downloadedNotes {
    final keys = downloadsBox.keys.toList();
    return keys.map((key) => Map<String, dynamic>.from(downloadsBox.get(key))).toList();
  }

  /// Check if a note is downloaded
  bool isNoteDownloaded(String noteId) {
    return downloadsBox.containsKey(noteId);
  }

  /// Get downloaded note path
  String? getDownloadedNotePath(String noteId) {
    final data = downloadsBox.get(noteId);
    return data?['local_path'];
  }

  /// Save download metadata
  Future<void> saveDownload({
    required String noteId,
    required String title,
    required String localPath,
    required int fileSize,
    required DateTime downloadedAt,
  }) async {
    await downloadsBox.put(noteId, {
      'note_id': noteId,
      'title': title,
      'local_path': localPath,
      'file_size': fileSize,
      'downloaded_at': downloadedAt.toIso8601String(),
    });
  }

  /// Remove download metadata and file
  Future<void> removeDownload(String noteId) async {
    final data = downloadsBox.get(noteId);
    if (data != null) {
      final localPath = data['local_path'] as String?;
      if (localPath != null) {
        final file = File(localPath);
        if (await file.exists()) {
          await file.delete();
        }
      }
    }
    await downloadsBox.delete(noteId);
  }

  /// Get total downloaded size in bytes
  int get totalDownloadedSize {
    int total = 0;
    for (var key in downloadsBox.keys) {
      final data = downloadsBox.get(key);
      if (data != null) {
        total += (data['file_size'] as int?) ?? 0;
      }
    }
    return total;
  }

  // ============ BOOKMARKS ============

  /// Get all bookmarked items
  List<String> get bookmarkedIds {
    return bookmarksBox.keys.cast<String>().toList();
  }

  /// Check if item is bookmarked
  bool isBookmarked(String id) {
    return bookmarksBox.containsKey(id);
  }

  /// Add bookmark
  Future<void> addBookmark(String id, {String? type, String? title}) async {
    await bookmarksBox.put(id, {
      'id': id,
      'type': type ?? 'note',
      'title': title,
      'bookmarked_at': DateTime.now().toIso8601String(),
    });
  }

  /// Remove bookmark
  Future<void> removeBookmark(String id) async {
    await bookmarksBox.delete(id);
  }

  /// Toggle bookmark
  Future<bool> toggleBookmark(String id, {String? type, String? title}) async {
    if (isBookmarked(id)) {
      await removeBookmark(id);
      return false;
    } else {
      await addBookmark(id, type: type, title: title);
      return true;
    }
  }

  // ============ CACHE MANAGEMENT ============

  /// Clear all downloads
  Future<void> clearDownloads() async {
    // Delete all downloaded files
    for (var key in downloadsBox.keys) {
      final data = downloadsBox.get(key);
      if (data != null) {
        final localPath = data['local_path'] as String?;
        if (localPath != null) {
          final file = File(localPath);
          if (await file.exists()) {
            await file.delete();
          }
        }
      }
    }
    await downloadsBox.clear();
  }

  /// Clear all bookmarks
  Future<void> clearBookmarks() async {
    await bookmarksBox.clear();
  }

  /// Clear all cached data
  Future<void> clearAllCache() async {
    await clearDownloads();
    await clearBookmarks();
    
    // Clear app cache directory
    final cacheDir = await getTemporaryDirectory();
    if (await cacheDir.exists()) {
      await cacheDir.delete(recursive: true);
      await cacheDir.create();
    }
  }

  /// Get downloads directory path
  static Future<String> getDownloadsPath() async {
    final appDir = await getApplicationDocumentsDirectory();
    final downloadsDir = Directory('${appDir.path}/downloads');
    if (!await downloadsDir.exists()) {
      await downloadsDir.create(recursive: true);
    }
    return downloadsDir.path;
  }
}
