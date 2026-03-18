import 'package:flutter/material.dart';

class InfoSection extends StatelessWidget {
  const InfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    // --- BLOQUE DE TEXTOS (Alineado a la izquierda con matemáticas de Figma) ---
    Widget textBlock = SizedBox(
      width: isMobile ? double.infinity : 450,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estás entre los 100 mejores',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontWeight: FontWeight.w400,
              height: 26 / 24,
              letterSpacing: 0.15,
              color: const Color(0xFF7E4F15),
            ),
            textAlign: TextAlign.left,
          ),

          const SizedBox(height: 8),

          // TEXTO 2: DEMUESTRA TU TALENTO...
          Text(
            'DEMUESTRA TU TALENTO\nDESDE CASA HACIENDO PIZZA\nY CONSIGUE PREMIOS',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontWeight: FontWeight.w400,
              height: 30 / 24,
              letterSpacing: 0.15,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            textAlign: TextAlign.left,
          ),

          const SizedBox(height: 12),

          // TEXTO 3: Pizzathon te dará la oportunidad...
          Text(
            'Pizzathon te dará la oportunidad\ndurante una semana de demostrar\ntodo lo que puedes conseguir\nhaciendo pizza en casa.',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w400,
              height: 24 / 20,
              letterSpacing: 0.15,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );

    // --- BLOQUE DE IMAGEN ---
    Widget imageBlock = ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        'assets/images/manita_mazita.jpg',
        width: isMobile ? double.infinity : 320,
        height: isMobile ? 200 : 220,
        fit: BoxFit.cover,
      ),
    );

    // --- CONTENEDOR PRINCIPAL DE LA SECCIÓN ---
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.primary,
      constraints: BoxConstraints(minHeight: isMobile ? 0 : screenWidth * (326 / 1440)),
      padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 20),
      child: Center(
        child: isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [textBlock, const SizedBox(height: 25), imageBlock],
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [imageBlock, const SizedBox(width: 40), textBlock],
              ),
      ),
    );
  }
}
