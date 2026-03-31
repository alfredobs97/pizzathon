import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:pizzathon/data/services/firestore_service.dart';
import 'package:pizzathon/data/services/local_storage_service.dart';
import 'package:pizzathon/data/services/remote_config_service.dart';
import 'package:pizzathon/ui/app_router.dart';

import 'firebase_options.dart';
import 'data/services/auth_service.dart';
import 'ui/blocs/auth_cubit.dart';
import 'ui/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (!kIsWeb) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => AuthService()),
        RepositoryProvider(create: (context) => FirestoreService()),
        RepositoryProvider(create: (context) => LocalStorageService()),
        RepositoryProvider(create: (context) => RemoteConfigService()),
      ],
      child: BlocProvider(
        create: (context) => AuthCubit(context.read<AuthService>())..checkAuth(),
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
