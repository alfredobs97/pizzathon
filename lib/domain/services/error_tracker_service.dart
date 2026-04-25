import 'package:pizzathon/domain/entities/tracked_error.dart';

/// Interface for the error tracking service.
///
/// This service is responsible for centralizing the reporting of failures to external platforms
/// and managing which errors should be reported to optimize the quota.
abstract interface class ErrorTrackerService {
  /// Initializes the tracking service.
  Future<void> init();

  /// Captures and reports a manual or caught error.
  ///
  /// [error] contains information about the failure, the stacktrace, and importance flags.
  Future<void> trackError(TrackedError error);

  /// Sets user information anonymously for tracking.
  ///
  /// Personal data (PII) should not be sent to comply with privacy
  /// without the need for explicit consent.
  Future<void> setAnonymousContext();

  /// Clears the current tracker session or context.
  Future<void> clearContext();
}
