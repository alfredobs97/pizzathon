import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pizzathon/ui/app_router.dart';
import 'package:pizzathon/ui/blocs/auth_cubit.dart';
import 'package:pizzathon/ui/blocs/auth_state.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    double calculatedHeight = screenWidth * (522 / 1440);
    final double heroHeight = isMobile ? 500 : calculatedHeight.clamp(500.0, 700.0);

    return SizedBox(
      width: double.infinity,
      height: heroHeight,
      child: Stack(
        children: [
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: 'https://i.ibb.co/Zp8bj1WH/background-pizza.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              color: Colors.black38,
              colorBlendMode: BlendMode.darken,
              placeholder: (context, url) =>
                  Container(color: Theme.of(context).colorScheme.primary),
              errorWidget: (context, url, error) => Container(
                color: Colors.black26,
                child: const Center(child: Icon(Icons.error, color: Colors.white, size: 40)),
              ),
            ),
          ),

          // Contenido del Hero
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Primera edición · 11 / 18 Mayo 2026',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontSize: isMobile ? 18 : 24,
                  ),
                ),
                const SizedBox(height: 10),

                // --- TÍTULO ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: isMobile ? screenWidth * 0.9 : 800,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'PIZZATHON',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.climateCrisis(
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          fontSize: 120,
                          letterSpacing: -0.5,
                          height: 0.9,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // --- BOTONES ---
                _HeroButton(
                  text: 'Soy Participante',
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: () {
                    final authState = context.read<AuthCubit>().state;
                    if (authState is AuthAuthenticated) {
                      context.go(AppRouter.profileRoute);
                    } else {
                      context.read<AuthCubit>().login();
                    }
                  },
                ),
                const SizedBox(height: 16),
                _HeroButton(
                  text: 'VER RANKING',
                  color: Theme.of(context).colorScheme.secondary,
                  onPressed: () {
                    context.go(AppRouter.scoreboardRoute);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onPressed;

  const _HeroButton({required this.text, required this.color, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      width: 280,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ),
    );
  }
}
