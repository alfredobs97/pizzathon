import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SponsorSection extends StatelessWidget {
  const SponsorSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return Container(
      width: double.infinity,
      color: const Color(0xFFF1DAC1),
      constraints: BoxConstraints(minHeight: isMobile ? 0 : screenWidth * (210 / 1440)),
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 40 : 20, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // --- TEXTO 1: TÍTULO ---
          Text(
            '¿Quieres patrocinar Pizzathon?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              height: 26 / 24,
              letterSpacing: 0.15,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),

          const SizedBox(height: 10),

          // --- TEXTO 2: SUBTÍTULO (Lo he recuperado) ---
          Text(
            'Un evento único donde mostrar tu producto a pizzeros caseros en español',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 20 / 16,
              letterSpacing: 0.15,
              color: const Color(0xFF7E4F15),
            ),
          ),

          const SizedBox(height: 30),

          // --- TEXTO 3: BOTÓN ---
          SizedBox(
            height: 56,
            width: 200,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: () => _launchEmail(),
              child: Text(
                'Me interesa',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 24 / 16,
                  letterSpacing: 0.15,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'salvapizzalover@gmail.com',
      query: _encodeQueryParameters(<String, String>{
        'subject': 'Interés en Patrocinar Pizzathon 🍕',
        'body':
            'Hola Salva,\n\nMe gustaría obtener más información sobre las opciones de patrocinio para la Pizzathon.\n\n¡Un saludo!',
      }),
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    }
  }

  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
}
