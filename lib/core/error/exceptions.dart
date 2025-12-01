/// Base exception class for custom exceptions
abstract class AppException implements Exception {
  final String message;
  final Object? error;
  final StackTrace? stackTrace;

  const AppException(this.message, [this.error, this.stackTrace]);

  @override
  String toString() => 'AppException: $message';
}

/// Server exceptions
class ServerException extends AppException {
  final int? statusCode;

  const ServerException(
    String message, {
    this.statusCode,
    Object? error,
    StackTrace? stackTrace,
  }) : super(message, error, stackTrace);
}

/// Network exceptions
class NetworkException extends AppException {
  const NetworkException([
    super.message = 'No internet connection',
    super.error,
    super.stackTrace,
  ]);
}

/// Cache exceptions
class CacheException extends AppException {
  const CacheException([
    super.message = 'Cache operation failed',
    super.error,
    super.stackTrace,
  ]);
}

/// Authentication exceptions
class AuthException extends AppException {
  const AuthException([
    super.message = 'Authentication failed',
    super.error,
    super.stackTrace,
  ]);
}

/// File exceptions
class FileException extends AppException {
  const FileException([
    super.message = 'File operation failed',
    super.error,
    super.stackTrace,
  ]);
}

/// Download exceptions
class DownloadException extends AppException {
  final double? progress;

  const DownloadException(
    String message, {
    this.progress,
    Object? error,
    StackTrace? stackTrace,
  }) : super(message, error, stackTrace);
}

/// AI exceptions
class AIException extends AppException {
  const AIException([
    super.message = 'AI service error',
    super.error,
    super.stackTrace,
  ]);
}
