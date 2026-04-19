import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      // Sponsor Banner
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: _SponsorBanner(),
                      ),

                      // Profile Card
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Center(
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 500),
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '#7',
                                            style: GoogleFonts.climateCrisis(
                                              fontSize: 40,
                                              wordSpacing: 1,
                                              fontWeight: FontWeight.w400,
                                              color: Theme.of(context).colorScheme.primary,
                                              height: 1.0,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            '24 Puntos',
                                            style: Theme.of(context).textTheme.displayLarge
                                                ?.copyWith(
                                                  color: Theme.of(context).colorScheme.secondary,
                                                  fontWeight: FontWeight.w400,
                                                  letterSpacing: 0.15,
                                                  height: 30 / 24,
                                                ),
                                          ),
                                          Text(
                                            '5 Pizzas',
                                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                              color: Theme.of(context).colorScheme.secondary,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Avatar
                                    CircleAvatar(
                                      radius: 60,
                                      backgroundColor: Theme.of(
                                        context,
                                      ).colorScheme.onPrimaryContainer,
                                      backgroundImage: user.photoURL != null
                                          ? CachedNetworkImageProvider(user.photoURL!)
                                          : null,
                                      child: user.photoURL == null
                                          ? const Icon(Icons.person, size: 60)
                                          : null,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                // User Name
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    user.displayName?.toUpperCase() ?? '',
                                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 500),
                          child: SizedBox(
                            width: double.infinity,
                            height: 64,
                            child: ElevatedButton(
                              onPressed: () => _showNewPizzaModal(context),
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

                      TextButton.icon(
                        onPressed: () => context.read<AuthCubit>().logout(),
                        icon: const Icon(Icons.logout),
                        label: const Text('Cerrar Sesión'),
                        style: TextButton.styleFrom(foregroundColor: Colors.grey),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showNewPizzaModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('NUEVA PIZZA', style: GoogleFonts.archivoBlack(fontSize: 24)),
              const SizedBox(height: 24),
              const Text('Aquí irá el formulario para subir una nueva pizza.'),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CERRAR'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SponsorBanner extends StatelessWidget {
  const _SponsorBanner();

  @override
  Widget build(BuildContext context) {
    // URL to be provided by user. Using a placeholder for now.
    const sponsorImageUrl =
        'https://i.ibb.co/3ykCWhmJ/alfa-forni-logo.png'; // Placeholder or actual URL if known

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 40,
          decoration: BoxDecoration(border: Border.all(color: Colors.black12)),
          child: CachedNetworkImage(
            imageUrl: sponsorImageUrl,
            placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => const Icon(Icons.business),
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Pone la llama a Pizzathon',
          style: GoogleFonts.archivo(
            fontSize: 16,
            color: const Color(0xFF4A1C17),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
