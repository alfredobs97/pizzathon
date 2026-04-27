import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizzathon/ui/blocs/poc_images/poc_images_cubit.dart';
import 'package:pizzathon/ui/widgets/full_screen_image.dart';

class PizzaCard extends StatelessWidget {
  final dynamic item;
  final int index;
  final ThemeData theme;

  const PizzaCard({
    super.key,
    required this.item,
    required this.index,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final origKb = (item.original.lengthInBytes / 1024).toStringAsFixed(0);
    final compKb = (item.compressed.lengthInBytes / 1024).toStringAsFixed(0);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        color: theme.colorScheme.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // --- CLICK EN LA IMAGEN PARA PANTALLA COMPLETA ---
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => FullScreenImage(
                          imageBytes: item.compressed,
                          title: "Vista Previa", // Puedes quitar el title si prefieres que no salga texto
                        ),
                      );
                    },
                    child: Image.memory(item.compressed, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: -4,
                    right: -4,
                    child: IconButton(
                      icon: Icon(Icons.cancel, color: theme.colorScheme.error, size: 32),
                      onPressed: () => context.read<PocImagesCubit>().removeImage(index),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    "Original: $origKb KB",
                    style: theme.textTheme.labelMedium?.copyWith(color: Colors.grey.shade400),
                  ),
                  Text(
                    "Post Compresión: $compKb KB",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}