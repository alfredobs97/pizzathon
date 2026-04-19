import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pizzathon/domain/models/user_extension.dart';
import 'package:pizzathon/ui/app_router.dart';
import 'package:pizzathon/ui/blocs/auth_cubit.dart';
import 'package:pizzathon/ui/blocs/auth_state.dart';
import 'package:pizzathon/ui/blocs/enrollment_cubit.dart';
import 'package:pizzathon/ui/blocs/enrollment_state.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Drawer(
      backgroundColor: colorScheme.surface,
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final isAuthenticated = state is AuthAuthenticated;
          final enrollmentState = context.watch<EnrollmentCubit>().state;
          final isEnrolled =
              enrollmentState is EnrollmentStatusChecked && enrollmentState.isEnrolled;
          final isAdmin = isAuthenticated && state.user.isAdmin;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _DrawerItem(
                      icon: Icons.home,
                      text: 'Inicio',
                      onTap: () => context.go(AppRouter.landingRoute),
                    ),
                    if (!isAuthenticated)
                      _DrawerItem(
                        icon: Icons.login,
                        text: 'Entrar',
                        onTap: () {
                          Navigator.pop(context);
                          context.read<AuthCubit>().login();
                        },
                      ),
                    if (isAuthenticated && isEnrolled) ...[
                      _DrawerItem(
                        icon: Icons.person,
                        text: 'Mi Perfil',
                        onTap: () => context.go(AppRouter.profileRoute),
                      ),
                      _DrawerItem(
                        icon: Icons.people,
                        text: 'Participantes',
                        onTap: () => context.go(AppRouter.participantsRoute),
                      ),
                    ],
                    if (isAdmin) ...[
                      const Divider(color: Colors.white24, height: 32),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                        child: Text(
                          'ADMINISTRACIÓN',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _DrawerItem(
                        icon: Icons.admin_panel_settings,
                        text: 'Admin Console',
                        onTap: () => context.go(AppRouter.adminRoute),
                      ),
                      _DrawerItem(
                        icon: Icons.image,
                        text: 'POC Imágenes',
                        onTap: () => context.go(AppRouter.pocImagesRoute),
                      ),
                    ],
                  ],
                ),
              ),
              if (isAuthenticated)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _DrawerItem(
                    icon: Icons.logout,
                    text: 'Cerrar Sesión',
                    onTap: () {
                      Navigator.pop(context);
                      context.read<AuthCubit>().logout();
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _DrawerItem({required this.icon, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(text, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white)),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }
}
