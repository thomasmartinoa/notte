import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/api_endpoints.dart';
import 'app.dart';

/// Main entry point of the application
void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  await dotenv.load(fileName: '.env');

  // Initialize Hive for local storage
  await Hive.initFlutter();
  await Hive.openBox('preferences');
  await Hive.openBox('downloads');
  await Hive.openBox('bookmarks');
  await Hive.openBox('cache');

  // Initialize Supabase
  await Supabase.initialize(
    url: ApiEndpoints.supabaseUrl,
    anonKey: ApiEndpoints.supabaseAnonKey,
  );

  // Run the app with Riverpod provider scope
  runApp(
    const ProviderScope(
      child: NotteApp(),
    ),
  );
}
