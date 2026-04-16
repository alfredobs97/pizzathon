import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pizzathon/ui/app_router.dart';
import 'package:pizzathon/ui/blocs/auth_cubit.dart';
import 'package:pizzathon/ui/blocs/auth_state.dart';
import 'package:pizzathon/ui/widgets/top_banner.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go(AppRouter.landingRoute);
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            const TopBanner(),
            Expanded(
              child: BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  if (state is! AuthAuthenticated) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final user = state.user;
                  final nameParts = (user.displayName ?? "Usuario Anónimo").split(" ");
                  final firstName = nameParts.isNotEmpty ? nameParts.first : "";
                  final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(" ") : "";

                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
                      child: Center(
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 500),
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.onSecondary,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(20),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'MI PERFIL',
                                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                              const SizedBox(height: 32),
                              CircleAvatar(
                                radius: 60,
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary.withAlpha(30),
                                backgroundImage: user.photoURL != null
                                    ? NetworkImage(user.photoURL!)
                                    : null,
                                child: user.photoURL == null
                                    ? Icon(
                                        Icons.person,
                                        size: 60,
                                        color: Theme.of(context).colorScheme.primary,
                                      )
                                    : null,
                              ),
                              const SizedBox(height: 24),
                              _ProfileField(label: 'NOMBRE', value: firstName),
                              const SizedBox(height: 16),
                              _ProfileField(label: 'APELLIDOS', value: lastName),
                              const SizedBox(height: 16),
                              _ProfileField(label: 'EMAIL', value: user.email ?? '-'),
                              const SizedBox(height: 40),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () => context.read<AuthCubit>().logout(),
                                  icon: const Icon(Icons.logout),
                                  label: const Text('CERRAR SESIÓN'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).colorScheme.secondary,
                                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    textStyle: Theme.of(context).textTheme.titleMedium,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.secondary.withAlpha(150),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(50),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).colorScheme.secondary.withAlpha(30)),
          ),
          child: Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.secondary),
          ),
        ),
      ],
    );
  }
}
