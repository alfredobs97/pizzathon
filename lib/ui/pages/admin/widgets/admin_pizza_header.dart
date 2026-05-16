import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizzathon/domain/models/pizza_model.dart';
import 'package:pizzathon/ui/blocs/admin_pizza_review/admin_pizza_review_cubit.dart';
import 'package:pizzathon/ui/blocs/admin_pizza_review/admin_pizza_review_state.dart';

class AdminPizzaHeader extends StatelessWidget {
  final PizzaModel pizza;
  final String formattedDate;

  const AdminPizzaHeader({super.key, required this.pizza, required this.formattedDate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            spacing: 16,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BlocBuilder<AdminPizzaReviewCubit, AdminPizzaReviewState>(
                    buildWhen: (previous, current) => previous.styleCount != current.styleCount,
                    builder: (context, state) {
                      return RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: pizza.pizzaStyle?.displayName ?? 'Sin estilo',
                              style: theme.textTheme.displayLarge?.copyWith(
                                color: theme.colorScheme.secondary,
                              ),
                            ),
                            if (pizza.pizzaStyle != null)
                              TextSpan(
                                text: ' (${state.styleCount} de este estilo)',
                                style: theme.textTheme.displayLarge?.copyWith(
                                  color: theme.colorScheme.secondary.withValues(alpha: 0.5),
                                ),
                              ),
                            TextSpan(
                              text: ' • $formattedDate',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.secondary.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, size: 32),
          onPressed: () => Navigator.of(context).pop(),
          color: theme.colorScheme.secondary,
        ),
      ],
    );
  }
}
