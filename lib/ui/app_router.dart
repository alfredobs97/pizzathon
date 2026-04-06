import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pizzathon/domain/models/user_extension.dart';
import 'package:pizzathon/ui/blocs/auth_cubit.dart';
import 'package:pizzathon/ui/blocs/auth_state.dart';
import 'package:pizzathon/ui/pages/home/home_page.dart';
import 'package:pizzathon/ui/pages/landing_page/landing_page.dart';

class AppRouter {
  static const String landingRoute = '/';
  static const String participantsRoute = '/participantes';
  static const String adminRoute = '/capo';

  final _router = GoRouter(
    initialLocation: landingRoute,
    routes: [
      GoRoute(path: landingRoute, builder: (context, state) => LandingPage()),
      GoRoute(path: participantsRoute, builder: (context, state) => HomePage()),
      GoRoute(
        path: '/__/auth/handler', // Captura la ruta conflictiva
        builder: (context, state) {
          // Devuelve una pantalla en blanco o de carga.
          // Firebase cerrará este popup automáticamente en un segundo.
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        },
      ),
      GoRoute(
        path: adminRoute,
        builder: (context, state) => Scaffold(
          body: Center(
            child: Image.network(
              'https://www.shutterstock.com/shutterstock/photos/1470841721/display_1500/stock-photo-the-circle-game-meme-fingers-making-the-ok-symbol-meme-internet-popular-prank-game-if-you-look-1470841721.jpg',
            ),
          ),
        ),
      ),
    ],
    redirect: (context, state) {
      if (state.matchedLocation == adminRoute && !isAdmin(context)) {
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
