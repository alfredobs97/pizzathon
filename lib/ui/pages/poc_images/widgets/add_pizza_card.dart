import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizzathon/ui/blocs/poc_images/poc_images_cubit.dart';

class AddPizzaCard extends StatelessWidget {
  final ThemeData theme;

  const AddPizzaCard({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: theme.scaffoldBackgroundColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.secondary.withAlpha(128), width: 2),
      ),
      child: InkWell(
        onTap: () => context.read<PocImagesCubit>().pickAndCompressImages(),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_pizza, size: 40, color: theme.colorScheme.secondary),
            const SizedBox(height: 8),
            Text(
              "Añadir",
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.secondary),
            ),
          ],
        ),
      ),
    );
  }
}