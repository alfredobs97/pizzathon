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
    final int limite = PocImagesCubit.limitePizzas;
    final bool canAddMore = imageCount < limite;
    final bool canSubmit = imageCount == limite;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: canAddMore
                  ? () => context.read<PocImagesCubit>().pickAndCompressImages()
                  : null,
              icon: Icon(
                canAddMore ? Icons.add_circle_outline : Icons.check_circle_outline, 
                size: 18,
                color: canAddMore ? theme.colorScheme.primary : Colors.grey.shade600, // Aquí
              ), 
              label: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  canAddMore 
                      ? "$imageCount/$limite Añadir pizzas" 
                      : "$imageCount/$limite Límite alcanzado",
                  style: TextStyle(
                    color: canAddMore ? theme.colorScheme.primary : Colors.grey.shade600, 
                  ),
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                foregroundColor: theme.colorScheme.primary,
                side: BorderSide(
                  color: canAddMore ? theme.colorScheme.primary : Colors.grey.shade400, 
                  width: 2
                ),
                textStyle: theme.textTheme.bodyLarge,
              ),
            ),
          ),
          const SizedBox(width: 8),

          Expanded(
            child: FilledButton.icon(
              onPressed: canSubmit 
                  ? () => _mostrarDialogoConfirmacion(context) 
                  : null,
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