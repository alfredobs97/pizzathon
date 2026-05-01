import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pizzathon/ui/blocs/auth_cubit.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    double calculatedHeight = screenWidth * (522 / 1440);
    final double heroHeight = isMobile
        ? 400
        : calculatedHeight.clamp(0.0, 522.0);

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
                child: const Center(
                  child: Icon(Icons.error, color: Colors.white, size: 40),
                ),
              ),
            ),
          ),

          // Contenido del Hero
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Primera edición - 11 / 17 Mayo 2026',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                // --- TÍTULO AUTO-AJUSTABLE ---
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

                const SizedBox(height: 30),
                SizedBox(
                  height: 56,
                  width: 240,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.8),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      context.read<AuthCubit>().login();
                    },
                    child: const Text(
                      'Entrar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
