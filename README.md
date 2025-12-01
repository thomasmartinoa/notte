# 📚 KTU notte

A comprehensive study companion app for APJ Abdul Kalam Technological University (KTU) students. Access notes, question papers, and AI-powered study assistance - all in one place.

## ✨ Features

- **📖 Notes Repository** - Browse notes organized by branch, semester, and subject
- **📝 Question Papers** - Access previous year question papers with filters
- **🤖 AI Study Assistant** - Gemini-powered chat for concept explanations
- **📥 Offline Access** - Download notes for offline studying
- **🔍 Smart Search** - Find notes and papers quickly
- **📋 Syllabus View** - Complete syllabus with module breakdown
- **🌙 Dark Mode** - Eye-friendly dark theme support

## 🏗️ Architecture

```
lib/
├── app.dart              # App widget
├── main.dart             # Entry point
├── config/               # App configuration
│   ├── router.dart       # GoRouter setup
│   └── providers.dart    # Riverpod providers
├── core/                 # Core utilities
│   ├── constants/        # App constants (colors, strings, KTU data)
│   ├── theme/            # Light/dark themes
│   ├── utils/            # Helpers, extensions
│   └── error/            # Error handling
├── services/             # Business logic services
│   ├── storage_service.dart
│   ├── download_service.dart
│   └── ai_service.dart
├── shared/               # Shared widgets
│   └── widgets/
└── features/             # Feature modules
    ├── onboarding/
    ├── home/
    ├── notes/
    ├── papers/
    ├── ai_assistant/
    ├── syllabus/
    ├── search/
    └── settings/
```

## 🛠️ Tech Stack

- **Framework**: Flutter 3.x
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **Backend**: Supabase
- **AI**: Google Gemini
- **Local Storage**: Hive
- **PDF Viewer**: Syncfusion

## 🚀 Getting Started

### Prerequisites

- Flutter SDK ^3.10.0
- Dart SDK ^3.0.0
- Supabase account
- Google AI Studio API key (for Gemini)

### Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/notte.git
   cd notte
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure API keys in `lib/core/constants/api_endpoints.dart`:
   ```dart
   static const String supabaseUrl = 'YOUR_SUPABASE_URL';
   static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
   static const String geminiApiKey = 'YOUR_GEMINI_API_KEY';
   ```

4. Set up Supabase:
   - Create a new Supabase project
   - Run `supabase/schema.sql` in the SQL Editor
   - Enable Storage and create a `pdfs` bucket

5. Run the app:
   ```bash
   flutter run
   ```

## 📊 Database Schema

The app uses Supabase with the following tables:
- `branches` - All 24 KTU engineering branches
- `subjects` - Subject catalog with semester mapping
- `notes` - Study materials with module organization
- `question_papers` - Previous year papers
- `syllabus` - Module-wise syllabus content
- `scraping_logs` - Content scraping audit trail
- `review_queue` - Manual review workflow

## 🔄 Content Pipeline

Content is scraped daily via GitHub Actions:

1. **Scraper runs** at 2 AM UTC (7:30 AM IST)
2. **New content** is added to the review queue
3. **Manual review** approves/rejects content
4. **Published content** becomes visible to users

## 📱 Screenshots

*Coming soon*

## 🤝 Contributing

Contributions are welcome! Please read our contributing guidelines.

## 📄 License

This project is licensed under the MIT License.

## 🙏 Acknowledgments

- KTU for the curriculum structure
- All content contributors
- Open source community
