// Package imports:

import 'package:context_for_ai/core/error/error_priority_enum.dart';
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure({
    required this.message,
    required this.title, // Title is now required
    this.priority = ErrorPriority.low,
    this.isRecoverable = false,
  });

  final String message;
  final String title; // Title instance variable is now non-nullable
  final ErrorPriority priority;
  final bool isRecoverable;

  @override
  List<Object?> get props => [message, title]; // Updated to include title
}

class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    required super.title, // Title is now required
    required super.isRecoverable,
    super.priority,
  });
}

class StoreageFailure extends Failure {
  const StoreageFailure({
    required super.message,
    required super.title, // Title is now required
    super.isRecoverable,
    super.priority,
  });
}

class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    required super.title, // Title is now required
    super.isRecoverable,
    super.priority,
  });
}

class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    required super.title, // Title is now required
    super.isRecoverable,
    super.priority,
  });
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    required super.title, // Title is now required
    super.isRecoverable,
    super.priority,
  });
}

class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    required super.title, // Title is now required
    super.isRecoverable,
    super.priority,
  });

  @override
  List<Object?> get props => [...super.props];
}

class TimeoutFailure extends Failure {
  const TimeoutFailure({
    required super.message,
    required super.title, // Title is now required
    super.isRecoverable,
    super.priority,
  });

  @override
  List<Object?> get props => [...super.props];
}

class UnknownFailure extends Failure {
  const UnknownFailure({
    required super.message,
    required super.title, // Title is now required
    super.isRecoverable,
    super.priority = ErrorPriority.low,
  });
}

class PermissionDeniedFailure extends Failure {
  const PermissionDeniedFailure({
    required super.message,
    required super.title, // Title is now required
    required super.isRecoverable,
    required super.priority,
  });
}

class PlatformFailure extends Failure {
  const PlatformFailure({
    required super.message,
    required super.title, // Title is now required
    required super.isRecoverable,
    required super.priority,
  });
}

class InitializationFailure extends Failure {
  const InitializationFailure({
    required super.message,
    required super.title, // Title is now required
    required super.isRecoverable,
    required super.priority,
  });
}
