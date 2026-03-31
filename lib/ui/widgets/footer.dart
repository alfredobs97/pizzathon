import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/link.dart';
import 'package:url_launcher/url_launcher.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  Future<void> _launchInstagram() async {
    final Uri url = Uri.parse('https://www.instagram.com/salva.pizzalover/');
    if (!await launchUrl(url)) {
      debugPrint('No se pudo abrir $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return Container(
      height: 160,
      width: double.infinity,
      color: Theme.of(context).colorScheme.secondary,
      constraints: BoxConstraints(minHeight: isMobile ? 0 : screenWidth * (162 / 1440)),
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 40 : 20, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Sigue las novedades de Pizzathon',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontSize: 14,
              height: 20 / 14,
              letterSpacing: 0.15,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          const SizedBox(height: 20),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: _launchInstagram,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: CachedNetworkImageProvider('https://i.ibb.co/qL3Zhr1c/salva.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '@salva.pizzalover',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Text(
                          'Ver en Instagram',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(width: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Seguir',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Link(
            uri: Uri.parse('https://pizzathon.es/privacy.html'),
            target: LinkTarget.blank,
            builder: (BuildContext context, FollowLink? followLink) {
              return TextButton(
                onPressed: followLink,
                child: Text('Política de Privacidad', style: Theme.of(context).textTheme.bodySmall),
              );
            },
          ),
        ],
      ),
    );
  }
}
