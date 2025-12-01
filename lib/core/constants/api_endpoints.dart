import 'package:flutter_dotenv/flutter_dotenv.dart';

/// API endpoints and configuration constants
class ApiEndpoints {
  ApiEndpoints._();

  // Supabase Configuration (loaded from .env file)
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  // Gemini AI Configuration (loaded from .env file)
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static const String geminiModel = 'gemini-2.0-flash';

  // Supabase Storage Buckets
  static const String pendingContentBucket = 'pending-content';
  static const String approvedContentBucket = 'approved-content';
  static const String userUploadsBucket = 'user-uploads';

  // Supabase Tables
  static const String branchesTable = 'branches';
  static const String semestersTable = 'semesters';
  static const String subjectsTable = 'subjects';
  static const String modulesTable = 'modules';
  static const String notesTable = 'notes';
  static const String questionPapersTable = 'question_papers';
  static const String usersTable = 'users';
  static const String aiConversationsTable = 'ai_conversations';
  static const String bookmarksTable = 'bookmarks';
  static const String downloadsTable = 'downloads';

  // API Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Content Status
  static const String statusPending = 'pending';
  static const String statusApproved = 'approved';
  static const String statusRejected = 'rejected';

  // File Size Limits
  static const int maxFileSizeMB = 50;
  static const int maxFileSizeBytes = maxFileSizeMB * 1024 * 1024;
}
