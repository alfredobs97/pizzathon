import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// [BlocObserver] that records BLoC transitions and errors as breadcrumbs in Sentry.
class SentryBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    Sentry.addBreadcrumb(
      Breadcrumb(
        type: 'debug',
        category: 'bloc.event',
        message: 'Event in ${bloc.runtimeType}',
        data: {
          'event': event.toString(),
        },
      ),
    );
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    Sentry.captureException(
      error,
      stackTrace: stackTrace,
      withScope: (scope) {
        scope.setTag('bloc', bloc.runtimeType.toString());
        scope.setContexts('bloc', {
          'state': bloc.state.toString(),
        });
      },
    );
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    Sentry.addBreadcrumb(
      Breadcrumb(
        type: 'debug',
        category: 'bloc.change',
        message: 'Change in ${bloc.runtimeType}',
        data: {
          'currentState': change.currentState.toString(),
          'nextState': change.nextState.toString(),
        },
      ),
    );
  }

  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    Sentry.addBreadcrumb(
      Breadcrumb(
        type: 'debug',
        category: 'bloc.lifecycle',
        message: 'Created ${bloc.runtimeType}',
      ),
    );
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    Sentry.addBreadcrumb(
      Breadcrumb(
        type: 'debug',
        category: 'bloc.lifecycle',
        message: 'Closed ${bloc.runtimeType}',
      ),
    );
  }
}
