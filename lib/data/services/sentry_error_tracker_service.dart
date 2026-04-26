import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:pizzathon/domain/entities/tracked_error.dart';
import 'package:pizzathon/domain/services/error_tracker_service.dart';

/// Implementation of [ErrorTrackerService] using Sentry.
class SentryErrorTrackerService implements ErrorTrackerService {
  static final SentryErrorTrackerService _instance = SentryErrorTrackerService._internal();

  factory SentryErrorTrackerService() => _instance;

  SentryErrorTrackerService._internal();

  bool _isInitialized = false;

  @override
  Future<void> init() async {
    if (_isInitialized) return;

    if (kDebugMode) {
      debugPrint('Sentry is disabled in debug mode.');
      return;
    }

    const dsn = String.fromEnvironment('SENTRY_DSN');

    if (dsn.isEmpty) {
      debugPrint('Sentry DSN is empty. Error tracking disabled.');
      return;
    }

    await SentryFlutter.init((options) {
      options.dsn = dsn;
      // Quota and privacy optimization settings
      options.tracesSampleRate = 0.01; // Performance monitoring sampled at 1%
      options.debug = kDebugMode;
      options.environment = const String.fromEnvironment(
        'ENVIRONMENT',
        defaultValue: kReleaseMode ? 'production' : 'development',
      );

      // Automatic PII blocking from Sentry
      options.sendDefaultPii = false;
    });

    await setAnonymousContext();
    _isInitialized = true;
  }

  @override
  Future<void> trackError(TrackedError trackedError) async {
    if (!_isInitialized) return;

    // Do not send if explicitly marked to ignore for quota
    if (trackedError.ignoreForQuota) return;

    await Sentry.captureException(
      trackedError.error,
      stackTrace: trackedError.stackTrace,
      withScope: (scope) {
        if (trackedError.isFatal) {
          scope.level = SentryLevel.fatal;
        }
        if (trackedError.extra != null) {
          scope.setContexts('extra_metadata', trackedError.extra!);
        }
      },
    );
  }

  @override
  Future<void> setAnonymousContext() async {
    if (!Sentry.isEnabled) return;

    // Generate an anonymous ID for session tracking without identifying the user
    final anonymousId = _generatedAnonymousId();

    await Sentry.configureScope((scope) {
      scope.setUser(SentryUser(id: anonymousId));
    });
  }

  @override
  Future<void> clearContext() async {
    await Sentry.configureScope((scope) {
      scope.setUser(null);
    });
  }

  String _generatedAnonymousId() {
    final random = Random();
    final values = List<int>.generate(16, (i) => random.nextInt(255));
    return values.map((e) => e.toRadixString(16).padLeft(2, '0')).join();
  }
}
