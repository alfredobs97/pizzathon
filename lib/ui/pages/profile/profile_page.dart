import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pizzathon/data/services/firestore_service.dart';
import 'package:pizzathon/ui/app_router.dart';
import 'package:pizzathon/ui/blocs/auth_cubit.dart';
import 'package:pizzathon/ui/blocs/auth_state.dart';
import 'package:pizzathon/ui/blocs/user_pizzas/user_pizzas_cubit.dart';
import 'package:pizzathon/ui/pages/profile/widgets/profile_header.dart';
import 'package:pizzathon/ui/pages/profile/widgets/sponsor_banner.dart';
import 'package:pizzathon/ui/pages/profile/widgets/user_pizzas_list.dart';
import 'package:pizzathon/ui/widgets/top_banner.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          //context.go(AppRouter.landingRoute);
        }
      },
      child: Column(
        children: [
          const CountdownTopBanner(),
          Expanded(
            child: BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                if (state is! AuthAuthenticated) {
                  return const Center(child: CircularProgressIndicator());
                }

                final user = state.user;

                return BlocProvider<UserPizzasCubit>(
                  create: (context) => UserPizzasCubit(
                    firestoreService: context.read<FirestoreService>(),
                    userId: user.uid,
                  )..fetchInitialPizzas(),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          color: Theme.of(context).colorScheme.onSurface,
                          child: Column(
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20.0),
                                child: SponsorBanner(),
                              ),
                              ProfileHeader(user: user),
                              const SizedBox(height: 16),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 500),
                                  child: SizedBox(
                                    width: 320,
                                    height: 56,
                                    child: ElevatedButton(
                                      onPressed: () => context.push(AppRouter.newPizzaRoute),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context).colorScheme.primary,
                                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                      ),
                                      child: Text(
                                        'Nueva Pizza',
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          color: Theme.of(context).colorScheme.onPrimary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                        UserPizzasList(user: user),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
