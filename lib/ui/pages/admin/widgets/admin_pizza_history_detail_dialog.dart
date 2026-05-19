import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pizzathon/domain/models/pizza_model.dart';

class AdminPizzaHistoryDetailDialog extends StatelessWidget {
  final PizzaModel pizza;

  const AdminPizzaHistoryDetailDialog({super.key, required this.pizza});

  static void show(BuildContext context, PizzaModel pizza) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        clipBehavior: Clip.antiAlias,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: AdminPizzaHistoryDetailDialog(pizza: pizza),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 800;

    return Container(
      color: theme.colorScheme.onSurface,
      width: isWide ? 900 : double.infinity,
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    children: [
                      Text(
                        pizza.pizzaStyle?.displayName ?? 'Pizza',
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                        ),
                      ),
                      Text(
                        DateFormat('EEEE d - HH:mm', 'es').format(pizza.createdAt),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.secondary.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Body
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: _buildImagesGrid()),
                        const SizedBox(width: 32),
                        Expanded(flex: 2, child: _buildDetails(theme)),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildImagesGrid(),
                        const SizedBox(height: 24),
                        _buildDetails(theme),
                      ],
                    ),
            ),
          ),

          // Footer
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Center(
              child: SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('Cerrar'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagesGrid() {
    final images = pizza.imagesInOrder;
    if (images.isEmpty) return const SizedBox.shrink();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: CachedNetworkImage(
            imageUrl: images[index],
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(color: Colors.grey.shade200),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        );
      },
    );
  }

  Widget _buildDetails(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (pizza.score != null) ...[
          Text(
            '${pizza.score} PUNTOS',
            style: theme.textTheme.displayMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w800,
              fontSize: 32,
            ),
          ),
          const SizedBox(height: 24),
        ],
        _buildDetailItem(theme, 'Estilo de pizza', pizza.pizzaStyle?.displayName),
        _buildDetailItem(theme, 'Harinas', pizza.flours),
        _buildDetailItem(theme, 'Prefermento', pizza.preferment),
        _buildDetailItem(theme, '% Prefermento', pizza.prefermentPercentage?.toString()),
        _buildDetailItem(
          theme,
          'Hidratación final',
          pizza.hydration != null ? '${pizza.hydration}%' : null,
        ),
        _buildDetailItem(
          theme,
          'Peso de bola',
          pizza.doughBallWeight != null ? '${pizza.doughBallWeight}g' : null,
        ),
        _buildDetailItem(theme, 'Horno', pizza.oven),
        _buildDetailItem(theme, 'Temperaturas de cocción', pizza.cookingTemperature?.toString()),
        _buildDetailItem(theme, 'Ingrediente base', pizza.baseIngredient),
        _buildDetailItem(theme, 'Ingredientes', pizza.otherIngredients),
      ],
    );
  }

  Widget _buildDetailItem(ThemeData theme, String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.secondary.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.secondary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
