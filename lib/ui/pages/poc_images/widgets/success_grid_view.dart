import 'package:flutter/material.dart';
import 'package:pizzathon/ui/blocs/poc_images/poc_images_state.dart';
import 'pizza_card.dart'; // Asegúrate de que el import coincida con tu nombre de archivo
import 'add_pizza_card.dart';
import 'success_pizza_buttons.dart';

class SuccessGridView extends StatelessWidget {
  final PocImagesSuccess state;
  const SuccessGridView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          "Pizzas listas: ${state.processedImages.length}",
          style: theme.textTheme.displayMedium?.copyWith(
            color: theme.colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.builder(
            // CAMBIO CLAVE: Usamos MaxCrossAxisExtent para que sea responsive
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 250, // Ninguna carta medirá más de 250px
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: state.processedImages.length + 1,
            itemBuilder: (context, index) {
              if (index == state.processedImages.length) {
                return AddPizzaCard(theme: theme);
              }
              return PizzaCard(
                item: state.processedImages[index],
                index: index,
                theme: theme,
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        SuccessPizzaButtons(
          imageCount: state.processedImages.length,
          theme: theme,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}