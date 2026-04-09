import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizzathon/ui/blocs/poc_images/poc_images_cubit.dart';

class SuccessPizzaButtons extends StatelessWidget {
  final int imageCount;
  final ThemeData theme;

  const SuccessPizzaButtons({
    super.key,
    required this.imageCount,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () =>
                  context.read<PocImagesCubit>().pickAndCompressImages(),
              icon: const Icon(Icons.add_photo_alternate, size: 18),
              label: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text("Más pizzas"),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                foregroundColor: theme.colorScheme.primary,
                side: BorderSide(color: theme.colorScheme.primary, width: 2),
                textStyle: theme.textTheme.bodyLarge,
              ),
            ),
          ),
          const SizedBox(width: 8),

          Expanded(
            child: FilledButton.icon(
              onPressed: () => _mostrarDialogoConfirmacion(context),
              icon: const Icon(Icons.cloud_upload, size: 18),
              label: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text("Enviar a Salvatore"),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.secondary,
                foregroundColor: theme.colorScheme.onSecondary,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                textStyle: theme.textTheme.bodyLarge,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoConfirmacion(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            'Confirmar envío',
            style: theme.textTheme.displayMedium?.copyWith(
              fontSize: 20,
              color: theme.colorScheme.secondary,
            ),
          ),
          content: Text(
            '¿Estás seguro de que quieres subir estas $imageCount pizzas?',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.secondary, 
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancelar',
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('¡Pizzas enviadas al servidor!'),
                    backgroundColor: theme.colorScheme.primary,
                  ),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
              ),
              child: Text('Sí, subir', style: theme.textTheme.bodyLarge),
            ),
          ],
        );
      },
    );
  }
}
