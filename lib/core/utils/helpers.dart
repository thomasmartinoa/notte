/// Helper utilities for common operations
library;
import 'dart:async';
import 'package:flutter/foundation.dart';

/// Debouncer utility for search and other operations
class Debouncer {
  final Duration duration;
  Timer? _timer;

  Debouncer({this.duration = const Duration(milliseconds: 300)});

  void call(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}

/// Logger utility for debugging
class AppLogger {
  static void debug(String message, {String? tag}) {
    if (kDebugMode) {
      print('🔵 [${tag ?? 'DEBUG'}] $message');
    }
  }

  static void info(String message, {String? tag}) {
    if (kDebugMode) {
      print('🟢 [${tag ?? 'INFO'}] $message');
    }
  }

  static void warning(String message, {String? tag}) {
    if (kDebugMode) {
      print('🟡 [${tag ?? 'WARNING'}] $message');
    }
  }

  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      print('🔴 [${tag ?? 'ERROR'}] $message');
      if (error != null) print('   Error: $error');
      if (stackTrace != null) print('   StackTrace: $stackTrace');
    }
  }
}

/// Result wrapper for operations that can fail
sealed class Result<T> {
  const Result();

  factory Result.success(T data) = Success<T>;
  factory Result.failure(String message, [Object? error]) = Failure<T>;

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get dataOrNull => isSuccess ? (this as Success<T>).data : null;
  String? get errorOrNull => isFailure ? (this as Failure<T>).message : null;

  R when<R>({
    required R Function(T data) success,
    required R Function(String message, Object? error) failure,
  }) {
    if (this is Success<T>) {
      return success((this as Success<T>).data);
    } else {
      final f = this as Failure<T>;
      return failure(f.message, f.error);
    }
  }
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final String message;
  final Object? error;
  const Failure(this.message, [this.error]);
}

/// Validator utilities
class Validators {
  Validators._();

  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) return null;
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? minLength(String? value, int length) {
    if (value == null || value.length < length) {
      return 'Must be at least $length characters';
    }
    return null;
  }

  static String? maxLength(String? value, int length) {
    if (value != null && value.length > length) {
      return 'Must be at most $length characters';
    }
    return null;
  }
}
