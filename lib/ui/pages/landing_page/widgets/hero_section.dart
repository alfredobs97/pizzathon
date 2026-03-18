import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    double calculatedHeight = screenWidth * (522 / 1440);
    final double heroHeight = isMobile ? 400 : calculatedHeight.clamp(0.0, 522.0);

    return Container(
      width: double.infinity,
      height: heroHeight,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background_pizza.jpg'),
          fit: BoxFit.cover,
          alignment: Alignment.center,
          colorFilter: ColorFilter.mode(Colors.black38, BlendMode.darken),
        ),
      ),
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
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.8),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    '¡Abriremos las inscripciones muy pronto!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  behavior: SnackBarBehavior.floating,
                  width: isMobile ? null : 400,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            child: const Text('Próximamente', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}