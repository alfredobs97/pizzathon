import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pizzathon/domain/models/user_extension.dart';
import 'package:pizzathon/ui/blocs/auth_cubit.dart';
import 'package:pizzathon/ui/blocs/auth_state.dart';
import 'package:pizzathon/ui/blocs/enrollment_cubit.dart';
import 'package:pizzathon/ui/blocs/enrollment_state.dart';
import 'package:pizzathon/ui/pages/admin/admin_page.dart';
import 'package:pizzathon/ui/pages/home/home_page.dart';
import 'package:pizzathon/ui/pages/landing_page/landing_page.dart';
import 'package:pizzathon/ui/pages/not_found_page.dart';
import 'package:pizzathon/ui/pages/pizza_wizard/widgets/pizza_wizard_dialogs.dart';
import 'package:pizzathon/ui/pages/pizza_wizard/pizza_wizard_page.dart';
import 'package:pizzathon/ui/pages/profile/profile_page.dart';
import 'package:pizzathon/ui/widgets/app_shell.dart';

class AppRouter {
  static const String landingRoute = '/';
  static const String participantsRoute = '/participantes';
  static const String adminRoute = '/capo';
  static const String pocImagesRoute = '/poc-imagenes';
  static const String profileRoute = '/perfil';

  final _router = GoRouter(
    initialLocation: landingRoute,
    errorBuilder: (context, state) => const NotFoundPage(),
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: landingRoute,
            pageBuilder: (context, state) => _fadeTransition(state, const LandingPage()),
          ),
          GoRoute(
            path: participantsRoute,
            pageBuilder: (context, state) => _fadeTransition(state, const HomePage()),
          ),
          GoRoute(
            path: pocImagesRoute,
            onExit: (context, state) async {
              final result = await showExitConfirmationDialog(context);
              return result;
            },
            pageBuilder: (context, state) => _fadeTransition(state, const PizzaWizardPage()),
          ),
          GoRoute(
            path: profileRoute,
            pageBuilder: (context, state) => _fadeTransition(state, const ProfilePage()),
          ),
          GoRoute(
            path: adminRoute,
            pageBuilder: (context, state) => _fadeTransition(state, const AdminPage()),
          ),
        ],
      ),
      GoRoute(
        path: '/__/auth/handler',
        builder: (context, state) =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
    ],
    /* redirect: (context, state) {
      if ((state.matchedLocation == adminRoute || state.matchedLocation == pocImagesRoute) &&
          !isAdmin(context)) {
        return landingRoute;
      }
      if (state.matchedLocation == participantsRoute && !isAuth(context)) {
        return landingRoute;
      }

      if (state.matchedLocation == profileRoute && (!isAuth(context) || !isEnrolled(context))) {
        return landingRoute;
      }
      return null;
    }, */
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
