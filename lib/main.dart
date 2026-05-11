import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:pizzathon/data/services/cache_service.dart';
import 'package:pizzathon/data/services/firestore_service.dart';
import 'package:pizzathon/data/services/local_storage_service.dart';
import 'package:pizzathon/data/services/pizza_storage_service.dart';
import 'package:pizzathon/data/services/remote_config_service.dart';
import 'package:pizzathon/data/services/rtdb_service.dart';
import 'package:pizzathon/data/services/sentry_bloc_observer.dart';
import 'package:pizzathon/data/services/sentry_error_tracker_service.dart';
import 'package:pizzathon/domain/entities/tracked_error.dart';
import 'package:pizzathon/domain/services/error_tracker_service.dart';
import 'package:pizzathon/data/services/image_metadata_service.dart';
import 'package:pizzathon/data/services/image_processing_service.dart';
import 'package:pizzathon/data/services/pizza_validation_service.dart';
import 'package:pizzathon/data/services/upload_limit_service.dart';
import 'package:pizzathon/ui/app_router.dart';
import 'package:pizzathon/ui/blocs/upload_limit/upload_limit_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'firebase_options.dart';
import 'data/services/auth_service.dart';
import 'package:pizzathon/ui/blocs/enrollment_cubit.dart';
import 'package:pizzathon/ui/blocs/poc_images/poc_images_cubit.dart';
import 'ui/blocs/auth_cubit.dart';
import 'ui/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null);
  usePathUrlStrategy();

  final errorTracker = SentryErrorTrackerService();
  await errorTracker.init();

  Bloc.observer = SentryBlocObserver();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final prefs = await SharedPreferences.getInstance();

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
        RepositoryProvider(create: (context) => RtdbService()),
        RepositoryProvider(create: (context) => CacheService()),
        RepositoryProvider(create: (context) => PizzaStorageService()),
        RepositoryProvider(create: (context) => LocalStorageService()),
        RepositoryProvider(create: (context) => RemoteConfigService()..init()),
        RepositoryProvider<ErrorTrackerService>(create: (context) => errorTracker),
        RepositoryProvider(create: (context) => UploadLimitCacheService(prefs: prefs)),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthCubit(
              context.read<AuthService>(),
              context.read<ErrorTrackerService>(),
              context.read<CacheService>(),
            )..checkAuth(),
          ),
          BlocProvider(
            lazy: false,
            create: (context) => EnrollmentCubit(
              context.read<FirestoreService>(),
              context.read<AuthService>(),
              context.read<LocalStorageService>(),
              context.read<RemoteConfigService>(),
              context.read<ErrorTrackerService>(),
            )..checkUserEnrollment(),
          ),
          BlocProvider(
            create: (context) => UploadLimitCubit(
              context.read<UploadLimitCacheService>(),
              context.read<FirestoreService>(),
              context.read<ErrorTrackerService>(),
              context.read<AuthService>(),
              context.read<RemoteConfigService>(),
            ),
          ),          BlocProvider(
            create: (context) => PocImagesCubit(
              ImageProcessingService(),
              context.read<RemoteConfigService>(),
              ImageMetadataService(),
              PizzaValidationService(),
              context.read<ErrorTrackerService>(),
              context.read<AuthService>(),
              context.read<PizzaStorageService>(),
              context.read<FirestoreService>(),
              context.read<UploadLimitCacheService>(),
            ),
          ),
        ],
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
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.noScaling,
          ),
          child: child!,
        );
      },
    );
  }
}
