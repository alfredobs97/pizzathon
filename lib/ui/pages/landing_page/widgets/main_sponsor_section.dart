import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/link.dart';

class MainSponsorSection extends StatelessWidget {
  const MainSponsorSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Patrocinador principal',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 24,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          Link(
            uri: Uri.parse('https://www.alfaforni.com/es/'),
            target: LinkTarget.blank,
            builder: (context, followLink) {
              return InkWell(
                hoverColor: Colors.transparent,
                onTap: followLink,
                child: CachedNetworkImage(
                  imageUrl: 'https://i.ibb.co/6RfjhFx9/alfa-forni-logo-negro-1.png',
                  height: 116,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
