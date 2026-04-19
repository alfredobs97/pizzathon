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
import 'package:pizzathon/ui/pages/poc_images/poc_images_page.dart';
import 'package:pizzathon/ui/pages/profile_page.dart';
import 'package:pizzathon/ui/widgets/app_shell.dart';

class AppRouter {
  static const String landingRoute = '/';
  static const String participantsRoute = '/participantes';
  static const String adminRoute = '/capo';
  static const String pocImagesRoute = '/poc-imagenes';
  static const String profileRoute = '/perfil';

  final _router = GoRouter(
    initialLocation: landingRoute,
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(path: landingRoute, builder: (context, state) => const LandingPage()),
          GoRoute(path: participantsRoute, builder: (context, state) => const HomePage()),
          GoRoute(path: pocImagesRoute, builder: (context, state) => const PocImagesPage()),
          GoRoute(path: profileRoute, builder: (context, state) => const ProfilePage()),
          GoRoute(path: adminRoute, builder: (context, state) => const AdminPage()),
        ],
      ),
      GoRoute(
        path: '/__/auth/handler',
        builder: (context, state) =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
    ],
    redirect: (context, state) {
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
    },
  );

  GoRouter get router => _router;

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
