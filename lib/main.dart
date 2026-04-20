import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:pizzathon/data/services/firestore_service.dart';
import 'package:pizzathon/data/services/local_storage_service.dart';
import 'package:pizzathon/data/services/remote_config_service.dart';
import 'package:pizzathon/data/services/sentry_error_tracker_service.dart';
import 'package:pizzathon/domain/entities/tracked_error.dart';
import 'package:pizzathon/domain/services/error_tracker_service.dart';
import 'package:pizzathon/ui/app_router.dart';

import 'firebase_options.dart';
import 'data/services/auth_service.dart';
import 'ui/blocs/auth_cubit.dart';
import 'ui/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  final errorTracker = SentryErrorTrackerService();
  await errorTracker.init();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Global error capture
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    errorTracker.trackError(
      TrackedError(error: details.exception, stackTrace: details.stack, isFatal: true),
    );
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    errorTracker.trackError(TrackedError(error: error, stackTrace: stack, isFatal: true));
    return true;
  };

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => AuthService()),
        RepositoryProvider(create: (context) => FirestoreService()),
        RepositoryProvider(create: (context) => LocalStorageService()),
        RepositoryProvider(create: (context) => RemoteConfigService()..init()),
        RepositoryProvider<ErrorTrackerService>(create: (context) => errorTracker),
      ],
      child: BlocProvider(
        create: (context) =>
            AuthCubit(context.read<AuthService>(), context.read<ErrorTrackerService>())
              ..checkAuth(),
        child: const MainApp(),
      ),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Pizzathon',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      routerConfig: AppRouter().router,
    );
  }
}
