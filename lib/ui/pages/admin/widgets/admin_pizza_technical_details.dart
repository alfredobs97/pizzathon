import 'package:flutter/material.dart';
import 'package:pizzathon/domain/models/pizza_model.dart';

class AdminPizzaTechnicalDetails extends StatelessWidget {
  final PizzaModel pizza;

  const AdminPizzaTechnicalDetails({super.key, required this.pizza});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _detailItem(context, 'Estilo de pizza', pizza.pizzaStyle?.displayName),
        _detailItem(context, 'Harinas', pizza.flours),
        _detailItem(context, 'Prefermento', pizza.preferment),
        _detailItem(
          context,
          '% Prefermento',
          pizza.prefermentPercentage?.toString(),
        ),
        _detailItem(context, 'Hidratacion final', pizza.hydration?.toString()),
        _detailItem(context, 'Peso de bola', pizza.doughBallWeight?.toString()),
        _detailItem(context, 'Horno', pizza.oven),
        _detailItem(
          context,
          'Temperaturas de coccion',
          pizza.cookingTemperature?.toString(),
        ),
        _detailItem(context, 'Ingrediente base', pizza.baseIngredient),
        _detailItem(context, 'Ingredientes', pizza.otherIngredients),
      ],
    );
  }

  Widget _detailItem(BuildContext context, String label, String? value) {
    final theme = Theme.of(context);
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.secondary.withValues(alpha: 0.6),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.displayMedium?.copyWith(
              color: theme.colorScheme.secondary,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
