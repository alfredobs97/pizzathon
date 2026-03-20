import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/link.dart';
import 'package:url_launcher/url_launcher.dart';

class SponsorSection extends StatelessWidget {
  const SponsorSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    final String subject = Uri.encodeComponent('Interés en Patrocinar Pizzathon 🍕');
    final String body = Uri.encodeComponent(
      'Hola Salva,\n\nMe gustaría obtener más información sobre las opciones de patrocinio para la Pizzathon.\n\n¡Un saludo!',
    );
    final Uri emailLaunchUri = Uri.parse(
      'mailto:salvapizzalover@gmail.com?subject=$subject&body=$body',
    );

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
            child: kIsWeb
                ? Link(
                    uri: emailLaunchUri,
                    target: LinkTarget.blank,
                    builder: (context, followLink) => _buildButton(context, followLink),
                  )
                : _buildButton(context, () => _launchEmail(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context, VoidCallback? onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      onPressed: onPressed,
      child: Text(
        'Me interesa',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          height: 24 / 16,
          letterSpacing: 0.15,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }

  Future<void> _launchEmail(BuildContext context) async {
    const String recipient = 'salvapizzalover@gmail.com';
    final String subject = Uri.encodeComponent('Interés en Patrocinar Pizzathon 🍕');
    final String body = Uri.encodeComponent(
      'Hola Salva,\n\nMe gustaría obtener más información sobre las opciones de patrocinio para la Pizzathon.\n\n¡Un saludo!',
    );
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: recipient,
      queryParameters: {'to': recipient, 'cc': recipient, 'subject': subject, 'body': body},
    );

    await canLaunchUrl(emailLaunchUri)
        ? launchUrl(emailLaunchUri, webOnlyWindowName: '_self')
        // ignore: use_build_context_synchronously
        : _fallbackCopyEmail(context);
  }

  Future<void> _fallbackCopyEmail(BuildContext context) async {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('¿Quieres copiar nuestro correo electrónico?'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Copiar',
          onPressed: () async {
            await Clipboard.setData(const ClipboardData(text: 'salvapizzalover@gmail.com'));
          },
        ),
      ),
    );
  }
}
