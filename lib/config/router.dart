import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/home/presentation/pages/home_page.dart';
import '../features/onboarding/presentation/pages/onboarding_page.dart';
import '../features/onboarding/presentation/pages/branch_selection_page.dart';
import '../features/onboarding/presentation/pages/semester_selection_page.dart';
import '../features/notes/presentation/pages/notes_page.dart';
import '../features/notes/presentation/pages/note_viewer_page.dart';
import '../features/notes/presentation/pages/subject_notes_page.dart';
import '../features/papers/presentation/pages/papers_page.dart';
import '../features/ai_assistant/presentation/pages/ai_chat_page.dart';
import '../features/syllabus/presentation/pages/syllabus_page.dart';
import '../features/search/presentation/pages/search_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import '../shared/widgets/main_scaffold.dart';
import 'providers.dart';

/// Route names
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String branchSelection = '/branch-selection';
  static const String semesterSelection = '/semester-selection';
  static const String home = '/home';
  static const String notes = '/notes';
  static const String subjectNotes = '/notes/:subjectId';
  static const String noteViewer = '/note/:noteId';
  static const String papers = '/papers';
  static const String aiChat = '/ai-chat';
  static const String syllabus = '/syllabus';
  static const String search = '/search';
  static const String settings = '/settings';
}

/// Navigation shell key for bottom navigation
final _shellNavigatorKey = GlobalKey<NavigatorState>();
final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  final prefs = ref.watch(userPreferencesProvider);
  
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: prefs.hasCompletedOnboarding ? AppRoutes.home : AppRoutes.onboarding,
    debugLogDiagnostics: true,
    routes: [
      // Onboarding flow
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoutes.branchSelection,
        name: 'branchSelection',
        builder: (context, state) => const BranchSelectionPage(),
      ),
      GoRoute(
        path: AppRoutes.semesterSelection,
        name: 'semesterSelection',
        builder: (context, state) => const SemesterSelectionPage(),
      ),

      // Main app with bottom navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomePage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.notes,
            name: 'notes',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: NotesPage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.papers,
            name: 'papers',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PapersPage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.aiChat,
            name: 'aiChat',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AiChatPage(),
            ),
          ),
        ],
      ),

      // Full screen routes (outside shell)
      GoRoute(
        path: '/notes/:subjectId',
        name: 'subjectNotes',
        builder: (context, state) {
          final subjectId = state.pathParameters['subjectId']!;
          return SubjectNotesPage(subjectId: subjectId);
        },
      ),
      GoRoute(
        path: '/note/:noteId',
        name: 'noteViewer',
        builder: (context, state) {
          final noteId = state.pathParameters['noteId']!;
          return NoteViewerPage(noteId: noteId);
        },
      ),
      GoRoute(
        path: AppRoutes.syllabus,
        name: 'syllabus',
        builder: (context, state) => const SyllabusPage(),
      ),
      GoRoute(
        path: AppRoutes.search,
        name: 'search',
        builder: (context, state) => const SearchPage(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.error?.message ?? 'Unknown error',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
