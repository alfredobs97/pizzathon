import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pizzathon/ui/blocs/auth_cubit.dart';
import 'package:pizzathon/ui/blocs/auth_state.dart';
import 'package:pizzathon/ui/pages/home/home_page.dart';
import 'package:pizzathon/ui/pages/landing_page/landing_page.dart';

class AppRouter {
  static const String landingRoute = '/';
  static const String participantsRoute = '/participantes';

  final _router = GoRouter(
    initialLocation: landingRoute,
    routes: [
      GoRoute(path: landingRoute, builder: (context, state) => LandingPage()),
      GoRoute(path: participantsRoute, builder: (context, state) => HomePage()),
    ],
    redirect: (context, state) {
      final authState = context.read<AuthCubit>().state;

      if (state.matchedLocation == participantsRoute && authState is! AuthAuthenticated) {
        return landingRoute;
      }

      return null;
    },
  );

  GoRouter get router => _router;
}
