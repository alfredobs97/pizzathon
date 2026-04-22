import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizzathon/ui/blocs/poc_images/poc_images_cubit.dart';
import 'package:pizzathon/ui/blocs/poc_images/poc_images_state.dart';

class PizzaPhotoStepView extends StatelessWidget {
  final PizzaPhotoStep step;
  final PocImagesState state;
  final ThemeData theme;

  const PizzaPhotoStepView({
    super.key,
    required this.step,
    required this.state,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrentStep = state.currentStep == step;
    final confirmedImage = state.confirmedImages[step];
    final hasConfirmed = confirmedImage != null;
    final hasPendingForThisStep = isCurrentStep && state.pendingImage != null;
    final isLoading = isCurrentStep && state.isLoading;
    final stepDescription = step.title.split(': ').last;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Text(
            stepDescription,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.secondary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (hasConfirmed)
                      Image.memory(confirmedImage, fit: BoxFit.cover)
                    else if (hasPendingForThisStep)
                      Image.memory(state.pendingImage!, fit: BoxFit.cover)
                    else
                      ColorFiltered(
                        colorFilter: const ColorFilter.mode(
                          Colors.grey,
                          BlendMode.saturation,
                        ),
                        child: CachedNetworkImage(
                          imageUrl: step.exampleImageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              Container(color: Colors.grey.shade300),
                          errorWidget: (context, url, error) =>
                              Container(color: Colors.grey.shade300),
                        ),
                      ),
                      
                    if (!hasConfirmed && !hasPendingForThisStep)
                      Container(color: Colors.black.withAlpha(140)),
                      
                    if (isLoading)
                      Container(
                        color: Colors.black.withAlpha(100),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                      ),

                    if (!hasConfirmed && !hasPendingForThisStep && !isLoading)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.camera_alt, color: Colors.white, size: 48),
                          const SizedBox(height: 16),
                          OutlinedButton(
                            onPressed: () => context
                                .read<PocImagesCubit>()
                                .pickSingleImage(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(
                                color: Colors.white,
                                width: 2,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: const Text("Tomar foto o galería"),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          if (isCurrentStep && hasPendingForThisStep && !isLoading)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: () =>
                      context.read<PocImagesCubit>().pickSingleImage(),
                  icon: const Icon(Icons.refresh),
                  label: const Text("Cambiar"),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () =>
                      context.read<PocImagesCubit>().confirmImage(),
                  icon: const Icon(Icons.check),
                  label: const Text("Confirmar"),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFE36414),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
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
