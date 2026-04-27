import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/link.dart';

class MainSponsorSection extends StatelessWidget {
  const MainSponsorSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 365,
      color: Theme.of(context).colorScheme.onSecondaryContainer,
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
                  height: 130,
                ),
              );
            },
          ),
          const SizedBox(height: 30),
          Text(
            'Patrocinadores',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 24,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Link(
                uri: Uri.parse('https://gimetal.it/'),
                target: LinkTarget.blank,
                builder: (context, followLink) {
                  return InkWell(
                    hoverColor: Colors.transparent,
                    onTap: followLink,
                    child: CachedNetworkImage(
                      imageUrl: 'https://i.ibb.co/fVFkzD05/Gi-Metal.png',
                      height: 65,
                    ),
                  );
                },
              ),
              const SizedBox(width: 40),
              Link(
                uri: Uri.parse('https://biribox.com/'),
                target: LinkTarget.blank,
                builder: (context, followLink) {
                  return InkWell(
                    hoverColor: Colors.transparent,
                    onTap: followLink,
                    child: CachedNetworkImage(
                      imageUrl: 'https://i.ibb.co/V0HrVmnJ/biribox-3.png',
                      height: 65,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
