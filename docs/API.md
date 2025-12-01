# API Documentation

This document describes the APIs and data models used in KTU notte.

## Supabase Tables

### branches

Stores KTU engineering branches.

| Column | Type | Description |
|--------|------|-------------|
| `id` | TEXT (PK) | Branch identifier (e.g., 'cse', 'ece') |
| `name` | TEXT | Full name |
| `short_name` | TEXT | Abbreviation (e.g., 'CSE') |
| `icon` | TEXT | Material icon name |
| `created_at` | TIMESTAMPTZ | Creation timestamp |
| `updated_at` | TIMESTAMPTZ | Last update timestamp |

**Example:**
```json
{
  "id": "cse",
  "name": "Computer Science and Engineering",
  "short_name": "CSE",
  "icon": "computer"
}
```

### subjects

Stores subject information.

| Column | Type | Description |
|--------|------|-------------|
| `id` | TEXT (PK) | Subject identifier |
| `code` | TEXT | Subject code (e.g., 'CST201') |
| `name` | TEXT | Subject name |
| `branch_id` | TEXT (FK) | Reference to branches.id |
| `semester` | INTEGER | Semester number (1-8) |
| `credits` | INTEGER | Credit hours |
| `modules` | INTEGER | Number of modules |
| `is_common` | BOOLEAN | Common across branches |

**Example:**
```json
{
  "id": "cst201",
  "code": "CST201",
  "name": "Data Structures",
  "branch_id": "cse",
  "semester": 3,
  "credits": 4,
  "modules": 5
}
```

### notes

Stores study materials.

| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID (PK) | Unique identifier |
| `title` | TEXT | Note title |
| `description` | TEXT | Description |
| `subject_id` | TEXT (FK) | Reference to subjects.id |
| `module_number` | INTEGER | Module number (1-6) |
| `file_url` | TEXT | URL to PDF file |
| `file_size_bytes` | BIGINT | File size |
| `file_type` | TEXT | File type (default: 'pdf') |
| `page_count` | INTEGER | Number of pages |
| `source_url` | TEXT | Original source URL |
| `source_name` | TEXT | Source website name |
| `is_verified` | BOOLEAN | Admin verified |
| `is_published` | BOOLEAN | Visible to users |
| `download_count` | INTEGER | Download counter |

### question_papers

Stores previous year question papers.

| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID (PK) | Unique identifier |
| `subject_id` | TEXT (FK) | Reference to subjects.id |
| `year` | INTEGER | Exam year |
| `exam_type` | TEXT | 'regular', 'supplementary', 'internal', 'series' |
| `month` | TEXT | Exam month |
| `file_url` | TEXT | URL to PDF file |
| `file_size_bytes` | BIGINT | File size |
| `source_url` | TEXT | Original source |
| `is_verified` | BOOLEAN | Admin verified |
| `is_published` | BOOLEAN | Visible to users |
| `download_count` | INTEGER | Download counter |

### review_queue

Content moderation queue.

| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID (PK) | Queue item ID |
| `content_type` | TEXT | 'note' or 'paper' |
| `content_id` | UUID | Reference to content |
| `status` | TEXT | 'pending', 'approved', 'rejected' |
| `reviewer_notes` | TEXT | Admin notes |
| `created_at` | TIMESTAMPTZ | Added to queue |
| `reviewed_at` | TIMESTAMPTZ | Review timestamp |

---

## Supabase Functions

### increment_download_count

Increments the download counter for notes or papers.

```sql
SELECT increment_download_count('notes', 'uuid-here');
```

### approve_content

Approves content from review queue and publishes it.

```sql
SELECT approve_content('queue-uuid-here');
```

---

## Gemini AI API

### Model Configuration

- **Model:** `gemini-2.0-flash`
- **Temperature:** 0.7
- **Max Tokens:** 2048
- **Top P:** 0.9

### System Prompt

The AI assistant uses a context-aware system prompt:

```
You are a helpful KTU study assistant. The student is studying 
{branch_name} in Semester {semester}.

Help with:
- Explaining concepts from their syllabus
- Solving problems step by step
- Exam preparation tips
- Clarifying doubts

Keep responses focused on KTU curriculum. Be concise but thorough.
```

### Chat Request

```dart
final response = await model.generateContent([
  Content.text(systemPrompt),
  Content.text(userMessage),
]);
```

### Streaming Response

```dart
final stream = model.generateContentStream([
  Content.text(systemPrompt),
  Content.text(userMessage),
]);

await for (final chunk in stream) {
  yield chunk.text ?? '';
}
```

---

## Local Storage (Hive)

### Box: preferences

User preferences storage.

| Key | Type | Description |
|-----|------|-------------|
| `branch_id` | String | Selected branch |
| `semester` | int | Selected semester |
| `is_dark_mode` | bool | Theme preference |
| `onboarding_complete` | bool | First run flag |

### Box: downloads

Downloaded files metadata.

| Key | Type | Description |
|-----|------|-------------|
| `{note_id}` | Map | Note metadata + local path |

**Value structure:**
```json
{
  "id": "uuid",
  "title": "Data Structures Module 1",
  "localPath": "/storage/.../file.pdf",
  "downloadedAt": "2024-01-01T00:00:00Z",
  "fileSize": 1234567
}
```

### Box: bookmarks

User bookmarks.

| Key | Type | Description |
|-----|------|-------------|
| `notes` | List<String> | List of bookmarked note IDs |
| `papers` | List<String> | List of bookmarked paper IDs |

---

## API Endpoints Constants

Located in `lib/core/constants/api_endpoints.dart`:

```dart
class ApiEndpoints {
  // Loaded from .env
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  
  // Constants
  static const String geminiModel = 'gemini-2.0-flash';
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const int defaultPageSize = 20;
  static const int maxFileSizeMB = 50;
}
```

---

## Error Handling

### Failure Types

```dart
abstract class AppFailure {
  final String message;
  final String? code;
}

class NetworkFailure extends AppFailure {}
class ServerFailure extends AppFailure {}
class CacheFailure extends AppFailure {}
class AuthFailure extends AppFailure {}
```

### Exception Types

```dart
abstract class AppException implements Exception {
  final String message;
  final String? code;
}

class NetworkException extends AppException {}
class ServerException extends AppException {}
class CacheException extends AppException {}
class AuthException extends AppException {}
```

---

## Data Models

### ChatMessage

```dart
class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final bool isError;
}
```

### DownloadTask

```dart
class DownloadTask {
  final String id;
  final String url;
  final String fileName;
  final String localPath;
  final DownloadStatus status;
  final double progress;
  final int? totalBytes;
  final int? downloadedBytes;
  final String? error;
}

enum DownloadStatus {
  idle,
  downloading,
  paused,
  completed,
  failed,
}
```

### UserPreferences

```dart
class UserPreferences {
  final String? branchId;
  final int? semester;
  final bool isDarkMode;
}
```
