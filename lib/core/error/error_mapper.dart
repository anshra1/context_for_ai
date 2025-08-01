import 'package:context_for_ai/core/error/exception.dart';
import 'package:context_for_ai/core/error/failure.dart';

class ErrorMapper {
  static Failure mapErrorToFailure(dynamic error) {
    // Since exceptions already have proper messages and codes,
    // we just need to map them directly

    if (error is ServerException) {
      return ServerFailure(
        message: error.userMessage,
        isRecoverable: error.isRecoverable,
        title: error.title,
        priority: error.priority,
      );
    }

    if (error is ServerException) {
      return ServerFailure(
        message: error.userMessage,
        isRecoverable: error.isRecoverable,
        title: error.title, // Added title
        priority: error.priority, // Added priority
      );
    }

    // Validation Exceptions
    if (error is ValidationException) {
      return ValidationFailure(
        message: error.userMessage, // Changed to error.userMessage
        isRecoverable: error.isRecoverable,
        title: error.title, // Added title
        priority: error.priority, // Added priority
      );
    }

    // Network Exceptions
    if (error is NetworkException) {
      return NetworkFailure(
        message: error.userMessage, // Changed to error.userMessage
        isRecoverable: error.isRecoverable,
        title: error.title, // Added title
        priority: error.priority, // Added priority
      );
    }

    // Cache Exceptions
    if (error is CacheException) {
      return CacheFailure(
        message: error.userMessage, // Changed to error.userMessage
        isRecoverable: error.isRecoverable,
        title: error.title, // Added title
        priority: error.priority, // Added priority
      );
    }

    if (error is StorageException) {
      return StorageFailure(
        message: error.userMessage, // Changed to error.userMessage
        isRecoverable: error.isRecoverable,
        title: error.title, // Added title
        priority: error.priority, // Added priority
      );
    }

    // Unknown/Unexpected Errors
    return const UnknownFailure(
      message: 'Unknown Error',
      title: 'Unknown Error', // Added title
    );
  }
}
