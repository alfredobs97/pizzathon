import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pizzathon/ui/app_router.dart';
import 'package:pizzathon/ui/blocs/poc_images/poc_images_cubit.dart';
import 'package:pizzathon/ui/blocs/poc_images/poc_images_state.dart';
import 'package:pizzathon/domain/models/pizza_photo_step.dart';

class PizzaSuccessPage extends StatelessWidget {
  const PizzaSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = context.watch<PocImagesCubit>().state;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ENVÍO COMPLETADO'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              context.read<PocImagesCubit>().resetWizard();
              context.go(AppRouter.landingRoute);
            },
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
            const SizedBox(height: 16),
            Text(
              '¡PIZZA ENVIADA AL CAPO!',
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Aquí tienes los detalles técnicos del envío para validación.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildTechSection(theme, state),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: () {
                context.read<PocImagesCubit>().resetWizard();
                context.go(AppRouter.landingRoute);
              },
              child: const Text('VOLVER AL INICIO'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechSection(ThemeData theme, PocImagesState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'METADATOS DE IMÁGENES',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 16),
        ...PizzaPhotoStep.values.map((step) => _buildStepDetail(theme, step, state)),
      ],
    );
  }

  Widget _buildStepDetail(ThemeData theme, PizzaPhotoStep step, PocImagesState state) {
    final originalSize = state.originalSizes[step] ?? 0;
    final compressedSize = state.compressedSizes[step] ?? 0;
    final url = state.imageUrls[step] ?? 'No disponible';
    final reduction = originalSize > 0 
        ? ((originalSize - compressedSize) / originalSize * 100).toStringAsFixed(1)
        : '0';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              step.title.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
            ),
            const Divider(),
            _buildInfoRow('Peso Original', '${(originalSize / 1024).toStringAsFixed(2)} KB'),
            _buildInfoRow('Peso Comprimido', '${(compressedSize / 1024).toStringAsFixed(2)} KB'),
            _buildInfoRow('Reducción', '$reduction%'),
            const SizedBox(height: 8),
            const Text('URL de Storage:', style: TextStyle(fontSize: 10, color: Colors.grey)),
            Row(
              children: [
                Expanded(
                  child: Text(
                    url,
                    style: const TextStyle(fontSize: 10, color: Colors.blue),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 16),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: url));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
