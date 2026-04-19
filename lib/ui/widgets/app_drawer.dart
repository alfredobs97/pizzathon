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
              _buildHeader(context, state),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _DrawerItem(
                      icon: Icons.home,
                      text: 'Inicio',
                      onTap: () => context.go(AppRouter.landingRoute),
                    ),
                    const SizedBox(height: 8),
                    if (!isAuthenticated)
                      _DrawerItem(
                        icon: Icons.login,
                        text: 'Entrar',
                        onTap: () {
                          context.read<AuthCubit>().login();
                        },
                      ),
                    if (isAuthenticated && isEnrolled) ...[
                      const SizedBox(height: 16),
                      _HighlightedDrawerItem(
                        icon: Icons.person,
                        text: 'Mi Perfil',
                        onTap: () => context.go(AppRouter.profileRoute),
                      ),
                      const SizedBox(height: 16),
                      _DrawerItem(
                        icon: Icons.people,
                        text: 'Participantes',
                        onTap: () => context.go(AppRouter.participantsRoute),
                      ),
                    ],
                    if (isAdmin) ...[
                      const Divider(color: Colors.white24, height: 40),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
                        child: Text(
                          'ADMINISTRACIÓN',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
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
                  padding: const EdgeInsets.all(24.0),
                  child: _DrawerItem(
                    icon: Icons.logout,
                    text: 'Cerrar Sesión',
                    onTap: () {
                      context.read<AuthCubit>().logout();
                      context.go(AppRouter.landingRoute);
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AuthState state) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      decoration: BoxDecoration(color: colorScheme.primary),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state is AuthAuthenticated) ...[
            CircleAvatar(
              radius: 35,
              backgroundColor: colorScheme.onPrimary.withValues(alpha: 0.2),
              backgroundImage: state.user.photoURL != null
                  ? NetworkImage(state.user.photoURL!)
                  : null,
              child: state.user.photoURL == null
                  ? Icon(Icons.person, color: colorScheme.onPrimary, size: 35)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              state.user.displayName ?? 'Usuario',
              style: theme.textTheme.displayMedium?.copyWith(color: Colors.white, fontSize: 18),
            ),
            Text(
              state.user.email ?? '',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
          ] else ...[
            Text(
              'PIZZATHON',
              style: theme.textTheme.displayLarge?.copyWith(
                color: Colors.white,
                fontSize: 28,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ],
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
      leading: Icon(icon, color: Colors.white60, size: 22),
      title: Text(
        text,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }
}

class _HighlightedDrawerItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _HighlightedDrawerItem({required this.icon, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white, size: 24),
        title: Text(
          text,
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
      ),
    );
  }
}
