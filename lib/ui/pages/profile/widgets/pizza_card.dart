import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pizzathon/domain/models/pizza_model.dart';

class PizzaCard extends StatelessWidget {
  final PizzaModel pizza;

  const PizzaCard({super.key, required this.pizza});

  @override
  Widget build(BuildContext context) {
    final String pizzaName = pizza.metadata?['name'] ?? 'Teglia Romana';
    final String pizzaDayTime = pizza.metadata?['day'] ?? 'Dia 1 · 17:42h';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
        image: DecorationImage(
          image: CachedNetworkImageProvider(pizza.imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          // Gradient overlay to make text readable regardless of the background image
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.1),
              Colors.black.withValues(alpha: 0.5),
              Colors.black.withValues(alpha: 0.1),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                pizzaName,
                textAlign: TextAlign.center,
                style: GoogleFonts.archivoBlack(
                  fontSize: 28,
                  height: 1.0,
                  color: Colors.white,
                  shadows: const [
                    Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2)),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                pizzaDayTime,
                textAlign: TextAlign.center,
                style: GoogleFonts.archivo(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withValues(alpha: 0.9),
                  shadows: const [
                    Shadow(color: Colors.black45, blurRadius: 2, offset: Offset(0, 1)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
