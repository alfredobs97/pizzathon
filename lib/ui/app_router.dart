import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pizzathon/domain/models/user_extension.dart';
import 'package:pizzathon/ui/blocs/auth_cubit.dart';
import 'package:pizzathon/ui/blocs/auth_state.dart';
import 'package:pizzathon/ui/pages/admin/admin_page.dart';
import 'package:pizzathon/ui/pages/home/home_page.dart';
import 'package:pizzathon/ui/pages/landing_page/landing_page.dart';
import 'package:pizzathon/ui/pages/not_found_page.dart';
import 'package:pizzathon/ui/pages/poc_images/poc_images_page.dart';

class AppRouter {
  static const String landingRoute = '/';
  static const String participantsRoute = '/participantes';
  static const String adminRoute = '/capo';
  static const String pocImagesRoute = '/poc-imagenes';

  final _router = GoRouter(
    initialLocation: landingRoute,
    errorBuilder: (context, state) => const NotFoundPage(),
    routes: [
      GoRoute(path: landingRoute, builder: (context, state) => LandingPage()),
      GoRoute(path: participantsRoute, builder: (context, state) => HomePage()),
      GoRoute(path: pocImagesRoute, builder: (context, state) => const PocImagesPage()),
      GoRoute(
        path: '/__/auth/handler', 
        builder: (context, state) {
          // Devuelve una pantalla en blanco o de carga.
          // Firebase cerrará este popup automáticamente en un segundo.
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        },
      ),
      GoRoute(
        path: adminRoute,
        builder: (context, state) => const AdminPage(),
      ),
    ],
    redirect: (context, state) {
      if ((state.matchedLocation == adminRoute || state.matchedLocation == pocImagesRoute) && !isAdmin(context)) {
        return landingRoute;
      }
      if (state.matchedLocation == participantsRoute && !isAuth(context)) {
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

  static bool isAdmin(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    return authState is AuthAuthenticated && authState.user.isAdmin;
  }
}
