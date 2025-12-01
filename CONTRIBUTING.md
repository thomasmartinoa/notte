# Contributing to KTU notte

Thank you for your interest in contributing to KTU notte! This document provides guidelines and instructions for contributors.

## 📋 Prerequisites

- Flutter SDK ^3.10.0
- Dart SDK ^3.0.0
- Git
- A code editor (VS Code recommended)
- Supabase account (for backend)
- Google AI Studio account (for Gemini API)

## 🚀 Getting Started

### 1. Fork and Clone

```bash
git clone https://github.com/YOUR_USERNAME/notte.git
cd notte
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Setup Environment

Copy the example environment file and add your credentials:

```bash
cp .env.example .env
```

Edit `.env` with your API keys:
```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
GEMINI_API_KEY=your_gemini_api_key
```

### 4. Run the App

```bash
flutter run
```

## 📁 Project Structure

```
lib/
├── main.dart          # App entry point
├── app.dart           # Root widget
├── config/            # Configuration (router, providers)
├── core/              # Core utilities (constants, theme, utils)
├── services/          # Business logic services
├── shared/            # Shared widgets
└── features/          # Feature modules
```

## 🎨 Code Style

### Dart/Flutter

- Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use `flutter_lints` (already configured)
- Run `dart format .` before committing

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Files | snake_case | `user_service.dart` |
| Classes | PascalCase | `UserService` |
| Variables | camelCase | `userName` |
| Constants | camelCase | `maxRetries` |
| Providers | camelCase + Provider | `userServiceProvider` |

### Widget Guidelines

1. **Use ConsumerWidget** for widgets that need Riverpod
2. **Keep widgets small** - extract to separate files if >100 lines
3. **Use const constructors** where possible
4. **Document public APIs** with `///` comments

## 🔧 Adding a New Feature

### 1. Create Feature Folder

```
lib/features/
└── my_feature/
    └── presentation/
        └── pages/
            └── my_feature_page.dart
```

### 2. Add Route

In `lib/config/router.dart`:

```dart
GoRoute(
  path: '/my-feature',
  name: 'myFeature',
  builder: (context, state) => const MyFeaturePage(),
),
```

### 3. Add Provider (if needed)

In `lib/config/providers.dart`:

```dart
final myFeatureProvider = Provider<MyFeatureService>((ref) {
  return MyFeatureService();
});
```

## 🧪 Testing

### Run Tests

```bash
flutter test
```

### Write Tests

- Place tests in `test/` directory
- Mirror the `lib/` structure
- Name test files with `_test.dart` suffix

## 📝 Commit Guidelines

### Commit Message Format

```
type(scope): description

[optional body]
```

### Types

| Type | Description |
|------|-------------|
| feat | New feature |
| fix | Bug fix |
| docs | Documentation |
| style | Formatting |
| refactor | Code restructuring |
| test | Adding tests |
| chore | Maintenance |

### Examples

```
feat(notes): add download progress indicator
fix(ai): handle empty response from Gemini
docs(readme): update setup instructions
```

## 🔀 Pull Request Process

1. **Create a branch** from `main`
   ```bash
   git checkout -b feat/my-feature
   ```

2. **Make your changes** and commit

3. **Push to your fork**
   ```bash
   git push origin feat/my-feature
   ```

4. **Open a Pull Request** against `main`

5. **PR Checklist:**
   - [ ] Code follows style guidelines
   - [ ] Tests pass (`flutter test`)
   - [ ] No lint errors (`flutter analyze`)
   - [ ] Documentation updated if needed
   - [ ] Commit messages follow guidelines

## 🐛 Bug Reports

When reporting bugs, include:

1. **Description** - What happened?
2. **Steps to reproduce** - How can we reproduce it?
3. **Expected behavior** - What should happen?
4. **Screenshots** - If applicable
5. **Environment** - Flutter version, device, OS

## 💡 Feature Requests

When requesting features:

1. **Problem** - What problem does it solve?
2. **Solution** - How should it work?
3. **Alternatives** - Other approaches considered?
4. **Additional context** - Mockups, examples, etc.

## 📞 Contact

- **Issues:** GitHub Issues
- **Discussions:** GitHub Discussions

## 📄 License

By contributing, you agree that your contributions will be licensed under the MIT License.
