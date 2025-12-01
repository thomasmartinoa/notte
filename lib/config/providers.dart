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
  final bool isDarkMode;
  final bool hasCompletedOnboarding;

  const UserPreferences({
    this.branchId,
    this.semester,
    this.isDarkMode = false,
    this.hasCompletedOnboarding = false,
  });

  UserPreferences copyWith({
    String? branchId,
    int? semester,
    bool? isDarkMode,
    bool? hasCompletedOnboarding,
  }) {
    return UserPreferences(
      branchId: branchId ?? this.branchId,
      semester: semester ?? this.semester,
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
