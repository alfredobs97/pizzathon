import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pizzathon/ui/app_router.dart';
import 'package:pizzathon/ui/blocs/poc_images/poc_images_cubit.dart';

class InitialView extends StatelessWidget {
  const InitialView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.local_pizza_outlined,
          size: 80,
          color: Theme.of(context).colorScheme.primary.withAlpha(128),
        ),
        const SizedBox(height: 24),
        Text(
          "¿Listo para subir tus Pizzas?",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 32),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            elevation: 4,
          ),
          icon: const Icon(Icons.local_pizza, size: 20),
          label: Text(
            "Nueva pizza",
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontSize: 18),
          ),
          onPressed: () {
            context.read<PocImagesCubit>().resetWizard();

            context.push(
              '${AppRouter.pocImagesRoute}/wizard',
              extra: context.read<PocImagesCubit>(),
            );
          },
        ),
      ],
    );
  }
}
