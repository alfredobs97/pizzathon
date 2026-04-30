import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizzathon/ui/blocs/poc_images/poc_images_cubit.dart';
import 'package:pizzathon/ui/blocs/poc_images/poc_images_state.dart';

class PizzaConfirmationStep extends StatelessWidget {
  const PizzaConfirmationStep({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = context.watch<PocImagesCubit>().state;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "ESTA ES TU PIZZA",
                  style: theme.textTheme.displayLarge?.copyWith(
                    color: theme.colorScheme.secondary,
                    letterSpacing: -1,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "Repásala bien antes de enviarla al comite de expertos",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Galería de fotos
                _buildPhotoGallery(state),

                const SizedBox(height: 32),

                // Sección 1: La Masa
                _buildSection(
                  theme: theme,
                  title: "MASA Y FORMULACIÓN",
                  details: [
                    _buildDetailRow(theme, "ESTILO", state.pizzaStyle),
                    _buildDetailRow(theme, "HARINAS", state.flours),
                    _buildDetailRow(
                      theme,
                      "PREFERMENTO",
                      "${state.preferment} (${state.prefermentPercentage}%)",
                    ),
                    _buildDetailRow(theme, "HIDRATACIÓN", "${state.hydration}%"),
                    _buildDetailRow(theme, "PESO BOLA", "${state.doughBallWeight}gr"),
                  ],
                ),

                const SizedBox(height: 16),

                // Sección 2: La Cocción
                _buildSection(
                  theme: theme,
                  title: "COCCIÓN",
                  details: [
                    _buildDetailRow(theme, "HORNO", state.oven),
                    _buildDetailRow(theme, "TEMPERATURA", "${state.cookingTemperature}Cº"),
                  ],
                ),

                const SizedBox(height: 16),

                // Sección 3: Los Toppings
                _buildSection(
                  theme: theme,
                  title: "INGREDIENTES",
                  details: [
                    _buildDetailRow(theme, "BASE", state.baseIngredient),
                    _buildDetailRow(theme, "RESTO", state.otherIngredients),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),

        // Footer Buttons
        _buildFooter(context, state, theme),
      ],
    );
  }

  Widget _buildPhotoGallery(PocImagesState state) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.2,
      ),
      itemCount: PizzaPhotoStep.values.length,
      itemBuilder: (context, index) {
        final step = PizzaPhotoStep.values[index];
        final image = state.confirmedImages[step];

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (image != null)
                  Image.memory(image, fit: BoxFit.cover)
                else
                  Container(color: Colors.grey.shade200),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black87],
                      ),
                    ),
                    child: Text(
                      step.title.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSection({
    required ThemeData theme,
    required String title,
    required List<Widget> details,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondary.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.secondary.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
          child: Column(children: details),
        ),
      ],
    );
  }

  Widget _buildDetailRow(ThemeData theme, String label, String? value, {bool isLongText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.4),
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (!isLongText)
                Flexible(
                  child: Text(
                    value?.toUpperCase() ?? "-",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
            ],
          ),
          if (isLongText) ...[
            const SizedBox(height: 4),
            Text(
              value?.toUpperCase() ?? "-",
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.secondary,
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
          ],
          const SizedBox(height: 4),
          Divider(
            height: 1,
            color: theme.colorScheme.secondary.withValues(alpha: 0.05),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, PocImagesState state, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: state.isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FilledButton(
                  onPressed: () => context.read<PocImagesCubit>().submitPizza(),
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 4,
                    shadowColor: theme.colorScheme.primary.withValues(alpha: 0.4),
                  ),
                  child: Text(
                    "ENVIAR AL CAPO DE LA PIZZA",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () => context.read<PocImagesCubit>().redoChanges(),
                  icon: const Icon(Icons.refresh, size: 20),
                  label: const Text("REHACER CAMBIOS"),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.secondary.withValues(alpha: 0.5),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
