# KTU notte - AI Context Document

> This document provides complete context for AI assistants (Claude, Copilot, etc.) to understand and work with this codebase.

## 📋 Project Overview

**Name:** KTU notte (formerly KTU Scholar)  
**Purpose:** A comprehensive study companion app for APJ Abdul Kalam Technological University (KTU) students  
**Target Users:** 100,000+ engineering students across Kerala, India  
**Platform:** Flutter (iOS, Android, Web, Desktop)

### Core Features
1. **Notes Repository** - Browse/download study notes by branch, semester, subject, module
2. **Question Papers** - Access previous year papers with year/exam type filters
3. **AI Study Assistant** - Gemini-powered chat for concept explanations
4. **Offline Access** - Download notes for offline studying via Hive
5. **Smart Search** - Full-text search across all content
6. **Syllabus View** - Module-wise syllabus breakdown

---

## 🏗️ Architecture

### Tech Stack
| Layer | Technology |
|-------|------------|
| Framework | Flutter 3.x (Dart) |
| State Management | Riverpod |
| Navigation | GoRouter |
| Backend | Supabase (PostgreSQL + Auth + Storage) |
| AI | Google Gemini (gemini-2.0-flash) |
| Local Storage | Hive |
| HTTP Client | Dio |
| PDF Viewer | Syncfusion Flutter PDFViewer |

### Project Structure
```
lib/
├── main.dart                 # Entry point - initializes Hive, Supabase, dotenv
├── app.dart                  # Root MaterialApp with theme and router
│
├── config/
│   ├── router.dart           # GoRouter configuration with all routes
│   └── providers.dart        # Riverpod providers (DI container)
│
├── core/
│   ├── constants/
│   │   ├── api_endpoints.dart   # Supabase/Gemini config (loads from .env)
│   │   ├── app_colors.dart      # Color palette
│   │   ├── app_strings.dart     # UI strings
│   │   └── ktu_data.dart        # KTU branches, semesters, subjects data
│   ├── theme/
│   │   └── app_theme.dart       # Light/dark ThemeData
│   ├── error/
│   │   ├── failures.dart        # Failure classes for error handling
│   │   └── exceptions.dart      # Exception classes
│   └── utils/
│       ├── extensions.dart      # Dart extensions
│       └── helpers.dart         # Utility functions
│
├── services/
│   ├── storage_service.dart     # Hive-based local storage
│   ├── download_service.dart    # Dio-based PDF download manager
│   └── ai_service.dart          # Gemini chat integration
│
├── shared/
│   └── widgets/
│       ├── main_scaffold.dart   # Bottom navigation shell
│       └── common_widgets.dart  # Reusable UI components
│
└── features/
    ├── onboarding/              # Welcome, branch/semester selection
    ├── home/                    # Dashboard with quick access
    ├── notes/                   # Notes browsing and viewing
    ├── papers/                  # Question papers with filters
    ├── ai_assistant/            # AI chat interface
    ├── syllabus/                # Syllabus viewer
    ├── search/                  # Global search
    └── settings/                # App settings
```

---

## 🔧 Configuration

### Environment Variables (.env)
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIs...
GEMINI_API_KEY=AIzaSy...
```

### Key Files
- `.env` - Secrets (gitignored)
- `.env.example` - Template for .env
- `pubspec.yaml` - Flutter dependencies
- `supabase/schema.sql` - Database schema

---

## 🗃️ Database Schema (Supabase)

### Tables
| Table | Purpose |
|-------|---------|
| `branches` | 24 KTU engineering branches (CSE, ECE, ME, etc.) |
| `subjects` | Subject catalog with branch/semester mapping |
| `notes` | Study materials with module organization |
| `question_papers` | Previous year papers |
| `syllabus` | Module-wise syllabus content |
| `scraping_logs` | Content scraping audit trail |
| `review_queue` | Manual review workflow for scraped content |

### Key Relationships
- `subjects.branch_id` → `branches.id`
- `notes.subject_id` → `subjects.id`
- `question_papers.subject_id` → `subjects.id`

### Content Workflow
1. Scraper adds content → `is_published = false`
2. Auto-added to `review_queue`
3. Admin reviews → calls `approve_content(queue_id)`
4. Content becomes visible → `is_published = true`

---

## 🔄 Content Pipeline

### Scraper (Python)
- **Location:** `scripts/scraper.py`
- **Schedule:** Daily via GitHub Actions (2 AM UTC)
- **Flow:** Scrape → Upload to Supabase Storage → Insert to DB → Add to review queue

### To Configure Scraper
1. Add source URLs to `BASE_URLS` list in `KTUStudyMaterialsScraper` class
2. Implement site-specific selectors in `scrape_site()` method
3. Set GitHub Secrets: `SUPABASE_URL`, `SUPABASE_SERVICE_KEY`

---

## 🧭 Navigation Flow

```
Onboarding → Branch Selection → Semester Selection → Home
                                                      ↓
                              ┌─────────────────────────────────────┐
                              │         Bottom Navigation           │
                              │  Home | Notes | Papers | AI Chat    │
                              └─────────────────────────────────────┘
                                   ↓        ↓        ↓        ↓
                                Search   Subject  Filters  Chat UI
                                Syllabus  Notes    Year    Streaming
                                Settings  Viewer   Type    Responses
```

---

## 📦 State Management

### Riverpod Providers (config/providers.dart)

| Provider | Type | Purpose |
|----------|------|---------|
| `supabaseProvider` | Provider | Supabase client |
| `dioProvider` | Provider | HTTP client |
| `storageServiceProvider` | Provider | Local storage ops |
| `downloadServiceProvider` | Provider | PDF downloads |
| `aiServiceProvider` | Provider | Gemini AI |
| `userPreferencesProvider` | StateNotifier | Branch, semester, theme |
| `routerProvider` | Provider | GoRouter instance |

### User Preferences State
```dart
class UserPreferences {
  String? branchId;
  int? semester;
  bool isDarkMode;
}
```

---

## 🔐 Security

### API Keys
- Stored in `.env` file (gitignored)
- Loaded via `flutter_dotenv` package
- Accessed via `ApiEndpoints` class getters

### Row Level Security (RLS)
- All tables have RLS enabled
- Public read for `is_published = true` content
- Write access requires service_role key (scraper only)

---

## 🧪 Key Code Patterns

### Feature Structure
```
features/
└── feature_name/
    └── presentation/
        └── pages/
            └── feature_page.dart
```

### Widget Pattern (ConsumerWidget)
```dart
class MyPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(userPreferencesProvider);
    // ...
  }
}
```

### Service Pattern
```dart
class MyService {
  final Dio dio;
  final StorageService storage;
  
  MyService({required this.dio, required this.storage});
  
  Future<Result> doSomething() async { ... }
}
```

---

## 🐛 Common Issues

### "Package not found" errors
→ Run `flutter pub get`

### Supabase connection errors
→ Check `.env` file has correct URL and keys

### Gemini API errors
→ Verify API key at https://aistudio.google.com/apikey

### Font errors
→ Either add Poppins fonts to `assets/fonts/` or remove font config from pubspec.yaml

---

## 📝 TODO / Future Work

1. **Authentication** - Add user login for bookmarks sync
2. **Push Notifications** - New content alerts
3. **Notes Upload** - Let students contribute notes
4. **Offline Sync** - Background content sync
5. **Analytics** - Track popular content
6. **More Branches** - Add more subject data beyond CSE

---

## 🔗 External Resources

- [Supabase Dashboard](https://supabase.com/dashboard)
- [Google AI Studio](https://aistudio.google.com/)
- [Flutter Docs](https://docs.flutter.dev/)
- [Riverpod Docs](https://riverpod.dev/)
- [GoRouter Docs](https://pub.dev/packages/go_router)
