import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

import '../core/constants/api_endpoints.dart';
import '../services/storage_service.dart';
import '../services/download_service.dart';
import '../services/ai_service.dart';

/// Supabase client provider
final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Dio HTTP client provider
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: ApiEndpoints.connectionTimeout,
      receiveTimeout: ApiEndpoints.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  // Add logging interceptor in debug mode
  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
    logPrint: (obj) => print('📡 DIO: $obj'),
  ));

  return dio;
});

/// Connectivity provider
final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

/// Check if connected to internet
final isConnectedProvider = Provider<bool>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  return connectivity.whenOrNull(
        data: (results) => !results.contains(ConnectivityResult.none),
      ) ??
      true;
});

/// Hive box providers
final userPreferencesBoxProvider = Provider<Box>((ref) {
  return Hive.box('user_preferences');
});

final downloadedNotesBoxProvider = Provider<Box>((ref) {
  return Hive.box('downloaded_notes');
});

final bookmarksBoxProvider = Provider<Box>((ref) {
  return Hive.box('bookmarks');
});

final searchHistoryBoxProvider = Provider<Box>((ref) {
  return Hive.box('search_history');
});

/// Storage service provider
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService(
    preferencesBox: ref.watch(userPreferencesBoxProvider),
    downloadsBox: ref.watch(downloadedNotesBoxProvider),
    bookmarksBox: ref.watch(bookmarksBoxProvider),
  );
});

/// Download service provider
final downloadServiceProvider = Provider<DownloadService>((ref) {
  return DownloadService(
    dio: ref.watch(dioProvider),
    storageService: ref.watch(storageServiceProvider),
  );
});

/// Gemini AI model provider
final geminiModelProvider = Provider<GenerativeModel>((ref) {
  return GenerativeModel(
    model: ApiEndpoints.geminiModel,
    apiKey: ApiEndpoints.geminiApiKey,
    generationConfig: GenerationConfig(
      temperature: 0.7,
      topP: 0.9,
      maxOutputTokens: 2048,
    ),
  );
});

/// AI service provider
final aiServiceProvider = Provider<AIService>((ref) {
  return AIService(
    model: ref.watch(geminiModelProvider),
    storageService: ref.watch(storageServiceProvider),
  );
});

/// User preferences state
class UserPreferences {
  final String? branchId;
  final int? semester;
  final String? schemeId; // '2019' or '2024'
  final bool isDarkMode;
  final bool hasCompletedOnboarding;

  const UserPreferences({
    this.branchId,
    this.semester,
    this.schemeId,
    this.isDarkMode = false,
    this.hasCompletedOnboarding = false,
  });

  UserPreferences copyWith({
    String? branchId,
    int? semester,
    String? schemeId,
    bool? isDarkMode,
    bool? hasCompletedOnboarding,
  }) {
    return UserPreferences(
      branchId: branchId ?? this.branchId,
      semester: semester ?? this.semester,
      schemeId: schemeId ?? this.schemeId,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }
}

/// User preferences notifier
class UserPreferencesNotifier extends Notifier<UserPreferences> {
  @override
  UserPreferences build() {
    final box = ref.watch(userPreferencesBoxProvider);
    return UserPreferences(
      branchId: box.get('branch_id'),
      semester: box.get('semester'),
      schemeId: box.get('scheme_id'),
      isDarkMode: box.get('is_dark_mode', defaultValue: false),
      hasCompletedOnboarding: box.get('has_completed_onboarding', defaultValue: false),
    );
  }

  Future<void> setBranch(String branchId) async {
    final box = ref.read(userPreferencesBoxProvider);
    await box.put('branch_id', branchId);
    state = state.copyWith(branchId: branchId);
  }

  Future<void> setSemester(int semester) async {
    final box = ref.read(userPreferencesBoxProvider);
    await box.put('semester', semester);
    state = state.copyWith(semester: semester);
  }

  Future<void> setScheme(String schemeId) async {
    final box = ref.read(userPreferencesBoxProvider);
    await box.put('scheme_id', schemeId);
    state = state.copyWith(schemeId: schemeId);
  }

  Future<void> setDarkMode(bool isDarkMode) async {
    final box = ref.read(userPreferencesBoxProvider);
    await box.put('is_dark_mode', isDarkMode);
    state = state.copyWith(isDarkMode: isDarkMode);
  }

  Future<void> completeOnboarding() async {
    final box = ref.read(userPreferencesBoxProvider);
    await box.put('has_completed_onboarding', true);
    state = state.copyWith(hasCompletedOnboarding: true);
  }
}

/// User preferences provider
final userPreferencesProvider =
    NotifierProvider<UserPreferencesNotifier, UserPreferences>(
  UserPreferencesNotifier.new,
);

/// Theme mode provider
final themeModeProvider = Provider<ThemeMode>((ref) {
  final prefs = ref.watch(userPreferencesProvider);
  return prefs.isDarkMode ? ThemeMode.dark : ThemeMode.light;
});

/// Question paper model
class QuestionPaper {
  final String id;
  final String subjectCode;
  final String subjectName;
  final int semester;
  final String? branch;
  final int year;
  final String examType;
  final String? pdfUrl;
  final DateTime? createdAt;

  const QuestionPaper({
    required this.id,
    required this.subjectCode,
    required this.subjectName,
    required this.semester,
    this.branch,
    required this.year,
    required this.examType,
    this.pdfUrl,
    this.createdAt,
  });

  factory QuestionPaper.fromJson(Map<String, dynamic> json) {
    return QuestionPaper(
      id: json['id']?.toString() ?? '',
      subjectCode: json['subject_code'] ?? '',
      subjectName: json['subject_name'] ?? '',
      semester: json['semester'] ?? 1,
      branch: json['branch'],
      year: json['year'] ?? DateTime.now().year,
      examType: json['exam_type'] ?? 'Regular',
      pdfUrl: json['pdf_url'],
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at']) 
          : null,
    );
  }
}

/// Question papers provider - fetches from Supabase based on user preferences
final questionPapersProvider = FutureProvider.autoDispose<List<QuestionPaper>>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  final prefs = ref.watch(userPreferencesProvider);
  
  final semester = prefs.semester ?? 1;
  
  try {
    final response = await supabase
        .from(ApiEndpoints.questionPapersTable)
        .select()
        .eq('semester', semester)
        .order('year', ascending: false)
        .order('subject_name');
    
    return (response as List)
        .map((json) => QuestionPaper.fromJson(json))
        .toList();
  } catch (e) {
    print('Error fetching question papers: $e');
    return [];
  }
});
