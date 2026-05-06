import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pizzathon/domain/models/pizza_model.dart';

class PizzaCard extends StatelessWidget {
  final PizzaModel pizza;

  const PizzaCard({super.key, required this.pizza});

  @override
  Widget build(BuildContext context) {
    final String pizzaName = pizza.pizzaStyle?.displayName ?? 'Sin estilo';
    final String pizzaDayTime = DateFormat("d 'de' MMMM · HH:mm'h'", 'es').format(pizza.createdAt);
    final String? imageUrl = pizza.imageUrls.values.firstOrNull;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
              Colors.black.withValues(alpha: 0.6),
              Colors.black.withValues(alpha: 0.2),
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                pizzaName.toUpperCase(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: Colors.white,
                  shadows: const [
                    Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  pizzaDayTime,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ),
              if (pizza.status != PizzaStatus.approved) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
                  child: Text(
                    pizza.status.displayName.toUpperCase(),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
