import 'package:flutter/material.dart';

class TopBanner extends StatelessWidget implements PreferredSizeWidget {
  const TopBanner({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: isMobile ? 0 : screenWidth * (42 / 1440)),
      color: Theme.of(context).colorScheme.secondary,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: Text(
        'Buscamos 100 MEJORES talentos en Pizza',
        textAlign: TextAlign.center,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
      ),
    );
  }
}
