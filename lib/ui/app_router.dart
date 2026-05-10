import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pizzathon/data/services/cache_service.dart';
import 'package:pizzathon/data/services/firestore_service.dart';
import 'package:pizzathon/domain/models/pizza_model.dart';
import 'package:pizzathon/domain/models/user_extension.dart';
import 'package:pizzathon/ui/blocs/admin_pizza_review/admin_pizza_review_cubit.dart';
import 'package:pizzathon/ui/blocs/auth_cubit.dart';
import 'package:pizzathon/ui/blocs/auth_state.dart';
import 'package:pizzathon/ui/blocs/enrollment_cubit.dart';
import 'package:pizzathon/ui/blocs/enrollment_state.dart';
import 'package:pizzathon/ui/blocs/poc_images/poc_images_cubit.dart';
import 'package:pizzathon/ui/blocs/profile/profile_cubit.dart';
import 'package:pizzathon/ui/blocs/user_pizzas/user_pizzas_cubit.dart';
import 'package:pizzathon/ui/pages/admin/admin_page.dart';
import 'package:pizzathon/ui/pages/admin/admin_pizza_detail_page.dart';
import 'package:pizzathon/ui/pages/home/home_page.dart';
import 'package:pizzathon/ui/pages/landing_page/landing_page.dart';
import 'package:pizzathon/ui/pages/not_found_page.dart';
import 'package:pizzathon/ui/pages/pizza_wizard/widgets/pizza_wizard_dialogs.dart';
import 'package:pizzathon/ui/pages/pizza_wizard/pizza_wizard_page.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:pizzathon/ui/pages/profile/profile_page.dart';
import 'package:pizzathon/ui/widgets/app_shell.dart';
import 'package:pizzathon/ui/blocs/upload_limit/upload_limit_cubit.dart';
import 'package:pizzathon/ui/blocs/upload_limit/upload_limit_state.dart';

class AppRouter {
  static const String landingRoute = '/';
  static const String participantsRoute = '/participantes';
  static const String adminRoute = '/capo';
  static const String adminPizzaDetailRoute = '/capo/pizza';
  static const String newPizzaRoute = '/nueva-pizza';
  static const String profileRoute = '/perfil';
  static const String publicProfileRoute = '/p/:userSlug';
  static const String nonFoundPage = '/not-found';

  final _router = GoRouter(
    initialLocation: landingRoute,
    errorBuilder: (context, state) => const NotFoundPage(),
    observers: [SentryNavigatorObserver()],
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: nonFoundPage,
            pageBuilder: (context, state) => _fadeTransition(state, const NotFoundPage()),
          ),
          GoRoute(
            path: landingRoute,
            pageBuilder: (context, state) => _fadeTransition(state, const LandingPage()),
          ),
          GoRoute(
            path: participantsRoute,
            pageBuilder: (context, state) => _fadeTransition(state, const HomePage()),
          ),
          GoRoute(
            path: newPizzaRoute,
            onExit: (context, state) async {
              final isFinished = context.read<PocImagesCubit>().state.isFinished;
              final isLimitExceeded = context.read<UploadLimitCubit>().state is UploadLimitReached;

              if (isFinished || isLimitExceeded) {
                return true;
              }

              final result = await showExitConfirmationDialog(context);
              return result;
            },
            pageBuilder: (context, state) => _fadeTransition(state, const PizzaWizardPage()),
          ),
          GoRoute(
            path: profileRoute,
            pageBuilder: (context, state) {
              final authState = context.read<AuthCubit>().state;
              final String userId = authState is AuthAuthenticated ? authState.user.uid : '';

              return _fadeTransition(
                state,
                MultiBlocProvider(
                  providers: [
                    BlocProvider<UserPizzasCubit>(
                      create: (context) => UserPizzasCubit(
                        firestoreService: context.read<FirestoreService>(),
                        cacheService: context.read<CacheService>(),
                      ),
                    ),
                    BlocProvider<ProfileCubit>(
                      create: (context) => ProfileCubit(
                        firestoreService: context.read<FirestoreService>(),
                        cacheService: context.read<CacheService>(),
                      )..loadProfile(userId),
                    ),
                  ],
                  child: const ProfilePage(),
                ),
              );
            },
          ),
          GoRoute(
            path: publicProfileRoute,
            pageBuilder: (context, state) {
              final userSlug = state.pathParameters['userSlug']!;
              // El slug puede ser "shortId-nombre" o solo "uid"
              final identifier = userSlug.split('-').first;

              return _fadeTransition(
                state,
                MultiBlocProvider(
                  providers: [
                    BlocProvider<UserPizzasCubit>(
                      create: (context) => UserPizzasCubit(
                        firestoreService: context.read<FirestoreService>(),
                        cacheService: context.read<CacheService>(),
                      ),
                    ),
                    BlocProvider<ProfileCubit>(
                      create: (context) => ProfileCubit(
                        firestoreService: context.read<FirestoreService>(),
                        cacheService: context.read<CacheService>(),
                      )..loadPublicProfile(identifier),
                    ),
                  ],
                  child: ProfilePage(publicIdentifier: identifier),
                ),
              );
            },
          ),
          GoRoute(
            path: adminRoute,
            pageBuilder: (context, state) => _fadeTransition(state, const AdminPage()),
            routes: [
              GoRoute(
                path: 'pizza',
                pageBuilder: (context, state) {
                  final pizza = state.extra as PizzaModel;
                  return _fadeTransition(
                    state,
                    BlocProvider(
                      create: (context) {
                        final cubit = AdminPizzaReviewCubit(context.read<FirestoreService>());
                        if (pizza.pizzaStyle != null) {
                          cubit.loadStyleCount(pizza.pizzaStyle!);
                        }
                        return cubit;
                      },
                      child: AdminPizzaDetailPage(pizza: pizza),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/__/auth/handler',
        builder: (context, state) =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
    ],
    redirect: (context, state) {
      // public routes
      if (state.matchedLocation.startsWith('/p/')) {
        return null;
      }

      // private routes
      if ((state.matchedLocation == adminRoute) && !isAdmin(context)) {
        return landingRoute;
      }
      if (state.matchedLocation == participantsRoute && !isAuth(context)) {
        return landingRoute;
      }

      if (state.matchedLocation == profileRoute && (!isAuth(context) || !isEnrolled(context))) {
        return landingRoute;
      }
      return null;
    },
  );

  GoRouter get router => _router;

  static CustomTransitionPage _fadeTransition(GoRouterState state, Widget child) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  static bool isAuth(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    return authState is AuthAuthenticated;
  }

  static bool isEnrolled(BuildContext context) {
    final enrollmentState = context.read<EnrollmentCubit>().state;
    return enrollmentState is EnrollmentStatusChecked && enrollmentState.isEnrolled;
  }

  static bool isAdmin(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    return authState is AuthAuthenticated && authState.user.isAdmin;
  }
}
