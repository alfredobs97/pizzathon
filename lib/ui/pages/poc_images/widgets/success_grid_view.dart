import 'package:flutter/material.dart';
import 'package:pizzathon/ui/blocs/poc_images/poc_images_state.dart';
import 'package:pizzathon/ui/blocs/poc_images/poc_images_cubit.dart'; // Necesario para el límite
import 'pizza_card.dart'; 
import 'add_pizza_card.dart';
import 'success_pizza_buttons.dart';

class SuccessGridView extends StatelessWidget {
  final PocImagesSuccess state;
  const SuccessGridView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final bool canAddMore = state.processedImages.length < PocImagesCubit.limitePizzas;

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
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 6900), 
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: GridView.builder(
              key: ValueKey<int>(state.processedImages.length),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 250, 
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: state.processedImages.length + (canAddMore ? 1 : 0),
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