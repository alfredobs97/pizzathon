import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class TeamSection extends StatelessWidget {
  const TeamSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return Container(
      color: const Color(0xFFF8EEE3),
      constraints: BoxConstraints(minHeight: isMobile ? 0 : 180),
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'El equipo de Pizzathon está especializado en Pizza y Tecnología',
            textAlign: TextAlign.left,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.15,
              height: 26 / 24,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: 700,
            child: const Wrap(
              spacing: 50,
              runSpacing: 30,
              alignment: WrapAlignment.start,
              children: [
                _ProfileItem(
                  name: 'SALVATORE PIZZALOVER',
                  role: 'Divulgador y Formador\nde pizzeros caseros',
                  imageUrl: 'https://i.ibb.co/qL3Zhr1c/salva.png',
                ),
                _ProfileItem(
                  name: 'ALFREDO BAUTISTA',
                  role: 'Senior Frontend Developer\n& Google Developer Expert',
                  imageUrl: 'https://i.ibb.co/fY2wdFG9/alfredo.png',
                ),
                _ProfileItem(
                  name: 'JORGE BALDIZZONE',
                  role: 'Junior Developer \n& 42 Outer Core',
                  imageUrl: 'https://i.ibb.co/SXK5DzBr/jorge.png',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final String name;
  final String role;
  final String imageUrl;

  const _ProfileItem({required this.name, required this.role, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorWidget: (context, error, stackTrace) => Container(
              width: 60,
              height: 60,
              color: Colors.grey,
              child: const Icon(Icons.person, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w300,
                color: const Color(0xFF7E4F15),
                letterSpacing: 0.15,
                height: 18 / 10,
              ),
            ),
            Text(
              role,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF7E4F15),
                height: 12 / 10,
                letterSpacing: 0.15,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
