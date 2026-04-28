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
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Resumen de tu Pizza",
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1,
                  ),
                  itemCount: PizzaPhotoStep.values.length,
                  itemBuilder: (context, index) {
                    final step = PizzaPhotoStep.values[index];
                    final image = state.confirmedImages[step];

                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (image != null)
                            Image.memory(image, fit: BoxFit.cover)
                          else
                            Container(color: Colors.grey.shade300),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 8,
                              ),
                              color: Colors.black54,
                              child: Text(
                                step.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                Card(
                  elevation: 0,
                  color: theme.colorScheme.secondary.withValues(alpha: 0.05),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSummaryItem(theme, "Estilo", state.pizzaStyle),
                        _buildSummaryItem(theme, "Harinas", state.flours),
                        Row(
                          children: [
                            Expanded(
                              child: _buildSummaryItem(
                                theme,
                                "Prefermento",
                                "${state.preferment} (${state.prefermentPercentage}%)",
                              ),
                            ),
                            Expanded(
                              child: _buildSummaryItem(
                                theme,
                                "Hidratación",
                                "${state.hydration}%",
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: _buildSummaryItem(
                                theme,
                                "Peso bola",
                                "${state.doughBallWeight}gr",
                              ),
                            ),
                            Expanded(
                              child: _buildSummaryItem(
                                theme,
                                "Horno",
                                state.oven,
                              ),
                            ),
                          ],
                        ),
                        _buildSummaryItem(
                          theme,
                          "Temperatura cocción",
                          "${state.cookingTemperature}Cº",
                        ),
                        const Divider(height: 32),
                        _buildSummaryItem(
                          theme,
                          "Ingrediente base",
                          state.baseIngredient,
                        ),
                        _buildSummaryItem(
                          theme,
                          "Resto de ingredientes",
                          state.otherIngredients,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: state.isSubmitting
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FilledButton(
                      onPressed: () =>
                          context.read<PocImagesCubit>().submitPizza(),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFE36414),
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Enviar al Comandante",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () =>
                          context.read<PocImagesCubit>().redoChanges(),
                      icon: const Icon(Icons.refresh),
                      label: const Text("Rehacer cambios"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.secondary,
                        minimumSize: const Size(double.infinity, 56),
                        side: BorderSide(
                          color: theme.colorScheme.secondary.withValues(
                            alpha: 0.3,
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(ThemeData theme, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          Text(
            value ?? "-",
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
