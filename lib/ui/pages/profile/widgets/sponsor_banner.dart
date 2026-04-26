import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SponsorBanner extends StatelessWidget {
  const SponsorBanner({super.key});

  @override
  Widget build(BuildContext context) {
    const sponsorImageUrl = 'https://i.ibb.co/6RfjhFx9/alfa-forni-logo-negro-1.png';

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CachedNetworkImage(
          imageUrl: sponsorImageUrl,
          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) => const Icon(Icons.business),
          height: 80,
        ),
        const SizedBox(width: 12),
        Text(
          'Pone la llama a Pizzathon',
          style: GoogleFonts.archivo(
            fontSize: 16,
            color: const Color(0xFF4A1C17),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
