import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizzathon/domain/models/pizza_model.dart';
import 'package:pizzathon/ui/app_router.dart';
import 'package:pizzathon/ui/blocs/auth_cubit.dart';
import 'package:pizzathon/ui/blocs/auth_state.dart';
import 'package:pizzathon/ui/blocs/admin_selected_pizzas/admin_selected_pizzas_cubit.dart';
import 'package:pizzathon/ui/blocs/admin_selected_pizzas/admin_selected_pizzas_state.dart';

class PizzaCard extends StatelessWidget {
  final PizzaModel pizza;

  const PizzaCard({super.key, required this.pizza});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String pizzaName = pizza.pizzaStyle?.displayName ?? 'Sin estilo';
    final String? imageUrl = pizza.imageUrls["front"];
    final bool isAdmin = AppRouter.isAdmin(context);

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
            color: theme.colorScheme.surfaceContainerHighest,
            image: imageUrl != null
                ? DecorationImage(image: CachedNetworkImageProvider(imageUrl), fit: BoxFit.cover)
                : null,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.1),
                  Colors.black.withValues(alpha: 0.4),
                  Colors.black.withValues(alpha: 0.1),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  pizzaName,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    shadows: const [
                      Shadow(color: Colors.black45, blurRadius: 6, offset: Offset(0, 2))
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (isAdmin)
          Positioned(
            top: 8,
            right: 8,
            child: BlocBuilder<AdminSelectedPizzasCubit, AdminSelectedPizzasState>(
              builder: (context, state) {
                final isSelected = context.read<AdminSelectedPizzasCubit>().isSelected(pizza.id);
                return Material(
                  color: Colors.black38,
                  shape: const CircleBorder(),
                  child: IconButton(
                    icon: Icon(
                      isSelected ? Icons.star : Icons.star_border,
                      color: isSelected ? Colors.amber : Colors.white,
                    ),
                    onPressed: () {
                      final authState = context.read<AuthCubit>().state;
                      if (authState is AuthAuthenticated) {
                        context.read<AdminSelectedPizzasCubit>().togglePizza(
                              authState.user.uid,
                              pizza,
                            );
                      }
                    },
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
