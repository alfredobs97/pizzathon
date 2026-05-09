import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pizzathon/data/services/firestore_service.dart';
import 'package:pizzathon/ui/app_router.dart';
import 'package:pizzathon/ui/blocs/auth_cubit.dart';
import 'package:pizzathon/ui/blocs/auth_state.dart';
import 'package:pizzathon/ui/blocs/upload_limit/upload_limit_cubit.dart';
import 'package:pizzathon/ui/blocs/upload_limit/upload_limit_state.dart';
import 'package:pizzathon/ui/blocs/user_pizzas/user_pizzas_cubit.dart';
import 'package:pizzathon/ui/pages/profile/widgets/profile_header.dart';
import 'package:pizzathon/ui/pages/profile/widgets/sponsor_banner.dart';
import 'package:pizzathon/ui/pages/profile/widgets/user_pizzas_list.dart';
import 'package:pizzathon/ui/widgets/top_banner.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthAuthenticated) {
        context.read<UploadLimitCubit>().checkLimit(authState.user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go(AppRouter.landingRoute);
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
                final theme = Theme.of(context);

                return BlocProvider<UserPizzasCubit>(
                  create: (context) => UserPizzasCubit(
                    firestoreService: context.read<FirestoreService>(),
                    userId: user.uid,
                  )..fetchInitialPizzas(),
                  child: BlocProvider.value(
                    value: context.read<UploadLimitCubit>(),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            color: theme.colorScheme.onSurface,
                            child: Column(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20.0),
                                  child: SponsorBanner(),
                                ),
                                ProfileHeader(user: user),
                                const SizedBox(height: 16),
                                BlocBuilder<UploadLimitCubit, UploadLimitState>(
                                  builder: (context, limitState) {
                                    final bool isReached = limitState is UploadLimitReached;
                                    final bool isChecking = limitState is UploadLimitChecking;
                                    final bool isError = limitState is UploadLimitError;

                                    return Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                          child: ConstrainedBox(
                                            constraints: const BoxConstraints(maxWidth: 500),
                                            child: SizedBox(
                                              width: 320,
                                              height: 56,
                                              child: ElevatedButton(
                                                onPressed: (isReached || isChecking || isError)
                                                    ? null
                                                    : () async {
                                                        await context.push(AppRouter.newPizzaRoute);
                                                        if (context.mounted) {
                                                          context
                                                              .read<UploadLimitCubit>()
                                                              .checkLimit(user.uid);
                                                        }
                                                      },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: theme.colorScheme.primary,
                                                  foregroundColor: theme.colorScheme.onPrimary,
                                                  disabledBackgroundColor: Colors.grey.shade300,
                                                  disabledForegroundColor: Colors.grey.shade600,
                                                  textStyle: theme.textTheme.bodyLarge,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(30),
                                                  ),
                                                ),
                                                child: isChecking
                                                    ? const SizedBox(
                                                        height: 20,
                                                        width: 20,
                                                        child: CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          color: Colors.white,
                                                        ),
                                                      )
                                                    : Text(isReached ? 'Listo por hoy' : 'Nueva Pizza'),
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (isReached)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 12.0),
                                            child: Text(
                                              'Has alcanzado el límite de 3 pizzas por hoy.',
                                              style: theme.textTheme.bodySmall?.copyWith(
                                                color: theme.colorScheme.error,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        if (isError)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 12.0),
                                            child: Text(
                                              limitState.message,
                                              style: theme.textTheme.bodySmall?.copyWith(
                                                color: theme.colorScheme.error,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                      ],
                                    );
                                  },
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
