import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class SponsorBanner extends StatelessWidget {
  const SponsorBanner({super.key});

  @override
  Widget build(BuildContext context) {
    const sponsorImageUrl = 'https://i.ibb.co/6RfjhFx9/alfa-forni-logo-negro-1.png';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
            height: 55,
            child: CachedNetworkImage(
              imageUrl: sponsorImageUrl,
              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => const Icon(Icons.business),
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Patrocinador principal',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: const Color(0xFF2D1414), fontSize: 16),
          ),
        ],
      ),
    );
  }
}
