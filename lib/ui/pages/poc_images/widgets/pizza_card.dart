import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizzathon/ui/blocs/poc_images/poc_images_cubit.dart';

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
                  Image.memory(item.compressed, fit: BoxFit.cover),
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
                    "Ahorro: $compKb KB",
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