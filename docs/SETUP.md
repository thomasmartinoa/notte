# Setup Guide

Complete step-by-step guide to set up KTU notte from scratch.

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) ^3.10.0
- [Git](https://git-scm.com/downloads)
- [VS Code](https://code.visualstudio.com/) (recommended) with Flutter extension
- Google account (for Gemini API)
- GitHub account (for Supabase)

## Step 1: Clone the Repository

```bash
git clone https://github.com/thomasmartinoa/notte.git
cd notte
```

## Step 2: Install Flutter Dependencies

```bash
flutter pub get
```

## Step 3: Get Gemini API Key (Free)

1. Go to [Google AI Studio](https://aistudio.google.com/apikey)
2. Sign in with Google account
3. Click **"Create API Key"**
4. Copy the key (starts with `AIzaSy...`)

## Step 4: Create Supabase Project

### 4.1 Create Account & Project

1. Go to [Supabase](https://supabase.com/dashboard)
2. Sign up with GitHub
3. Click **"New Project"**
4. Fill in:
   - **Name:** `ktu-notte`
   - **Database Password:** (generate and save it!)
   - **Region:** Singapore or closest to you
5. Wait 2-3 minutes for provisioning

### 4.2 Get API Credentials

1. Go to **Settings → API**
2. Copy:
   - **Project URL** (e.g., `https://abc123.supabase.co`)
   - **anon public** key (for the app)
   - **service_role** key (for the scraper - keep secret!)

### 4.3 Run Database Schema

1. Go to **SQL Editor** in Supabase
2. Click **"New Query"**
3. Copy entire contents of `supabase/schema.sql`
4. Click **"Run"** (Ctrl+Enter)
5. Should see "Success. No rows returned"

### 4.4 Create Storage Buckets

1. Go to **Storage** in sidebar
2. Create 3 buckets:

| Bucket Name | Public Access |
|-------------|---------------|
| `pending-content` | OFF |
| `approved-content` | ON |
| `user-uploads` | OFF |

3. For `approved-content`:
   - Click bucket → **Policies**
   - **New Policy** → **Allow public access**

## Step 5: Configure Environment

1. Copy the example file:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` with your credentials:
   ```env
   SUPABASE_URL=https://your-project-id.supabase.co
   SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   GEMINI_API_KEY=AIzaSy...
   ```

## Step 6: Add Fonts (Optional)

### Option A: Download Poppins Font

1. Go to [Google Fonts - Poppins](https://fonts.google.com/specimen/Poppins)
2. Click **"Download family"**
3. Extract and copy to `assets/fonts/`:
   - `Poppins-Regular.ttf`
   - `Poppins-Medium.ttf`
   - `Poppins-SemiBold.ttf`
   - `Poppins-Bold.ttf`

### Option B: Use System Font

Remove the `fonts:` section from `pubspec.yaml` to use system defaults.

## Step 7: Create Asset Directories

```bash
mkdir -p assets/images
mkdir -p assets/icons
mkdir -p assets/fonts
```

## Step 8: Run the App

### On Android Emulator/Device
```bash
flutter run
```

### On Web
```bash
flutter run -d chrome
```

### On Windows
```bash
flutter run -d windows
```

## Step 9: Verify Setup

1. App should launch with onboarding screen
2. Select a branch (e.g., CSE)
3. Select a semester
4. You should see the home dashboard
5. Try the AI chat - it should respond

## Common Issues

### "Unable to load .env file"

Make sure `.env` exists in the project root and has valid content.

### "Supabase initialization failed"

- Check SUPABASE_URL is correct (no trailing slash)
- Check SUPABASE_ANON_KEY is the anon key, not service_role

### "Gemini API error"

- Verify GEMINI_API_KEY is correct
- Check you haven't exceeded the free tier quota

### Font loading errors

Either add the font files or remove the font configuration from pubspec.yaml.

### "Package not found"

Run `flutter pub get` to install dependencies.

## Next Steps

1. **Add Content:** See [SCRAPER_GUIDE.md](./SCRAPER_GUIDE.md) to configure the content scraper
2. **Customize:** Modify `lib/core/constants/ktu_data.dart` to add more subjects
3. **Deploy:** See [DEPLOYMENT.md](./DEPLOYMENT.md) for production deployment

## Environment Overview

| File | Purpose | Git Status |
|------|---------|------------|
| `.env` | Your secrets | ❌ Ignored |
| `.env.example` | Template | ✅ Committed |
| `pubspec.yaml` | Dependencies | ✅ Committed |
| `supabase/schema.sql` | DB schema | ✅ Committed |
