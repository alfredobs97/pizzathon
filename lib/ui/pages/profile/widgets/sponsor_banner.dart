import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SponsorBanner extends StatelessWidget {
  const SponsorBanner({super.key});

  @override
  Widget build(BuildContext context) {
    // URL to be provided by user. Using a placeholder for now.
    const sponsorImageUrl =
        'https://i.ibb.co/3ykCWhmJ/alfa-forni-logo.png'; // Placeholder or actual URL if known

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 40,
          decoration: BoxDecoration(border: Border.all(color: Colors.black12)),
          child: CachedNetworkImage(
            imageUrl: sponsorImageUrl,
            placeholder: (context, url) =>
                const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => const Icon(Icons.business),
            fit: BoxFit.contain,
          ),
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
