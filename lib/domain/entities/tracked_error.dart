import 'package:equatable/equatable.dart';

/// An encapsulated error to be tracked by the monitoring system.
class TrackedError extends Equatable {
  final Object error;
  final StackTrace? stackTrace;
  final bool isFatal;
  
  /// If true, the system can decide not to send this error if it is considered
  /// an "expected" or low-priority error to save quota.
  final bool ignoreForQuota;
  
  /// Optional additional metadata for the error.
  final Map<String, dynamic>? extra;

  const TrackedError({
    required this.error,
    this.stackTrace,
    this.isFatal = false,
    this.ignoreForQuota = false,
    this.extra,
  });

  @override
  List<Object?> get props => [error, stackTrace, isFatal, ignoreForQuota, extra];
}
