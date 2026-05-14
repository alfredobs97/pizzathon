import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PrizesModal extends StatelessWidget {
  const PrizesModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PrizesModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 32), // Spacer for centering title
                Text(
                  'PREMIOS',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: theme.colorScheme.onPrimary, size: 32),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _FirstPrizeCard(
                    title: 'HORNO\nALFA\nFORNI\nPORTABLE',
                    subtitle: 'TOP#1\nBEST\nPIZZA',
                    imageUrl: 'https://i.ibb.co/tpJLJNB5/Alfa-portable-1.png',
                    logoUrl: 'https://i.ibb.co/6RfjhFx9/alfa-forni-logo-negro-1.png',
                  ),
                  const SizedBox(height: 16),
                  const _SecondPrizeCard(
                    title1: 'PALA Y PALÍN\nGI-METAL AZZURRA',
                    subtitle1: 'TOP #1',
                    title2: 'PALA\nGI-METAL AZZURRA',
                    subtitle2: 'BEST PIZZA',
                    imageUrl: 'https://i.ibb.co/5ds5Wqd/palas.png',
                    logoUrl: 'https://i.ibb.co/fVFkzD05/Gi-Metal.png',
                  ),
                  const SizedBox(height: 16),
                  const _ThirdPrizeCard(
                    title: 'LOTE\nPRODUCTOS\nITALIANOS',
                    subtitle: 'TOP #1-#10\nBEST PIZZA',
                    imageUrl: 'https://i.ibb.co/Y4Y5B61s/premio-biribox.png',
                    logoUrl: 'https://i.ibb.co/V0HrVmnJ/biribox-3.png',
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FirstPrizeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final String logoUrl;

  const _FirstPrizeCard({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.logoUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 330,
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.onSecondaryContainer,
        borderRadius: BorderRadius.circular(32),
      ),
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Premio',
                  style: theme.textTheme.displayMedium?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 16),
                CachedNetworkImage(
                  imageUrl: logoUrl,
                  height: 50,
                  width: 90,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const SizedBox(
                    height: 50,
                    width: 90,
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.business),
                ),
                const SizedBox(height: 16),
                CachedNetworkImage(
                  imageUrl: imageUrl,
                  height: 174,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const SizedBox(
                    height: 174,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),

          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.displayMedium?.copyWith(
                        color: theme.colorScheme.secondary,
                        height: 1.0,
                        fontSize: 26,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      subtitle,
                      style: theme.textTheme.displayLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        height: 1.1,
                        fontSize: 32,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () => _launchUrl(
                    'https://detropen.es/barbacoas-hornos/hornos-pizza/horno-portable-gas-gris-alfa',
                  ),
                  child: Text(
                    'VER DETALLES\nDEL HORNO',
                    textAlign: TextAlign.left,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      height: 1.1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      /*  , */
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      debugPrint('No se pudo abrir $url');
    }
  }
}

class _SecondPrizeCard extends StatelessWidget {
  final String title1;
  final String subtitle1;
  final String title2;
  final String subtitle2;
  final String imageUrl;
  final String logoUrl;

  const _SecondPrizeCard({
    required this.title1,
    required this.subtitle1,
    required this.title2,
    required this.subtitle2,
    required this.imageUrl,
    required this.logoUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 155,
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.onSecondaryContainer,
        borderRadius: BorderRadius.circular(32),
      ),
      padding: const EdgeInsets.only(left: 24, right: 12, top: 18, bottom: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Premio',
                      style: theme.textTheme.displayMedium?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    CachedNetworkImage(
                      imageUrl: logoUrl,
                      height: 25,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const SizedBox(
                        height: 25,
                        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                      errorWidget: (context, url, error) => const Icon(Icons.business),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                CachedNetworkImage(
                  height: 112,
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const SizedBox(
                    height: 110,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title1,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle1,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    height: 1.1,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title2,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontSize: 14,
                  ),
                ),

                Text(
                  subtitle2,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    height: 1.1,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThirdPrizeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final String logoUrl;

  const _ThirdPrizeCard({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.logoUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.onSecondaryContainer,
        borderRadius: BorderRadius.circular(32),
      ),
      padding: const EdgeInsets.only(left: 24, right: 12, top: 18, bottom: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Premio',
                      style: theme.textTheme.displayMedium?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    CachedNetworkImage(
                      imageUrl: logoUrl,
                      height: 25,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const SizedBox(
                        height: 25,
                        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                      errorWidget: (context, url, error) => const Icon(Icons.business),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                CachedNetworkImage(
                  height: 80,
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) =>
                      const SizedBox(height: 80, child: Center(child: CircularProgressIndicator())),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
                const SizedBox(height: 14),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    height: 1.1,
                    fontSize: 20,
                  ),
                ), // Space for the link at bottom right
              ],
            ),
          ),
        ],
      ),
    );
  }
}
