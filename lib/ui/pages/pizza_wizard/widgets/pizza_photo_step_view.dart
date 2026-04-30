import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizzathon/ui/blocs/poc_images/poc_images_cubit.dart';

class PizzaPhotoStepView extends StatelessWidget {
  const PizzaPhotoStepView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = context.watch<PocImagesCubit>().state;
    final step = state.currentStep;

    final isCurrentStep = state.currentStep == step;
    final confirmedImage = state.confirmedImages[step];
    final hasConfirmed = confirmedImage != null;
    final hasPendingForThisStep = isCurrentStep && state.pendingImage != null;
    final isLoading = isCurrentStep && state.isLoading;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Text(
            "FOTO ${step.index + 1} de 4",
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.secondary,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            step.title,
            style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.secondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400, maxHeight: 400),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (hasPendingForThisStep)
                          Image.memory(state.pendingImage!, fit: BoxFit.cover)
                        else if (hasConfirmed)
                          Image.memory(confirmedImage, fit: BoxFit.cover)
                        else
                          ColorFiltered(
                            colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                            child: CachedNetworkImage(
                              imageUrl: step.exampleImageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(color: Colors.grey.shade300),
                              errorWidget: (context, url, error) =>
                                  Container(color: Colors.grey.shade300),
                            ),
                          ),
                        if (!hasConfirmed && !hasPendingForThisStep)
                          Container(color: Colors.black.withValues(alpha: 0.55)),
                        if (isLoading)
                          Container(
                            color: Colors.black.withValues(alpha: 0.4),
                            child: const Center(
                              child: CircularProgressIndicator(color: Colors.white),
                            ),
                          ),
                        if (!hasConfirmed && !hasPendingForThisStep && !isLoading)
                          Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.camera_alt, color: Colors.white, size: 48),
                                const SizedBox(height: 16),
                                SizedBox(
                                  height: 56,
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    onPressed: () =>
                                        context.read<PocImagesCubit>().pickSingleImage(),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      side: const BorderSide(color: Colors.white, width: 2),
                                    ),
                                    child: const Text("Escoger foto"),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (!hasConfirmed && !hasPendingForThisStep)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                step.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.7),
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 24),
          if (isCurrentStep && (hasPendingForThisStep || hasConfirmed) && !isLoading)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: TextButton(
                      onPressed: () => context.read<PocImagesCubit>().pickSingleImage(),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.secondary,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      ),
                      child: const Text("Cambiar"),
                    ),
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: FilledButton(
                      onPressed: () {
                        if (hasPendingForThisStep) {
                          context.read<PocImagesCubit>().confirmImage();
                        } else {
                          context.read<PocImagesCubit>().nextPhotoStep();
                        }
                      },
                      child: Text(hasPendingForThisStep ? "Confirmar" : "Siguiente"),
                    ),
                  ),
                ),
              ],
            )
          else
            const SizedBox(height: 48),
        ],
      ),
    );
  }
}
