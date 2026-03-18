import 'package:flutter/material.dart';

class TeamSection extends StatelessWidget {
  const TeamSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return Container(
      width: double.infinity,
      color: const Color(0xFFF8EEE3),
      constraints: BoxConstraints(minHeight: isMobile ? 0 : screenWidth * (190 / 1440)),
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 40 : 20, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'El equipo de Pizzathon está especializado en Pizza y Tecnología',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.15,
              height: 26 / 24,
            ),
          ),
          const SizedBox(height: 40),
          const Wrap(
            spacing: 40,
            runSpacing: 30,
            alignment: WrapAlignment.center,
            children: [
              _ProfileItem(
                name: 'SALVATORE PIZZALOVER',
                role: 'Divulgador y Formador\nde pizzeros caseros',
                imagePath: 'assets/images/Salvatore.jpg',
              ),
              _ProfileItem(
                name: 'ALFREDO BAUTISTA',
                role: 'Senior Frontend Developer\n& Google Developer Expert',
                imagePath: 'assets/images/Alfredo.jpg',
              ),
              _ProfileItem(
                name: 'JORGE BALDIZZONE',
                role: 'Hacker',
                imagePath: 'assets/images/Jorge.jpg',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final String name;
  final String role;
  final String imagePath;

  const _ProfileItem({required this.name, required this.role, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            imagePath,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 60,
              height: 60,
              color: Colors.grey,
              child: const Icon(Icons.person, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            Text(
              role,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.black54, height: 1.2),
            ),
          ],
        ),
      ],
    );
  }
}
