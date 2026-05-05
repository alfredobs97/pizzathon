import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pizzathon/domain/models/pizza_model.dart';
import 'package:pizzathon/ui/blocs/admin_pizza_review/admin_pizza_review_cubit.dart';
import 'package:pizzathon/ui/blocs/admin_pizza_review/admin_pizza_review_state.dart';

class AdminPizzaHistorySection extends StatefulWidget {
  final String userId;

  const AdminPizzaHistorySection({super.key, required this.userId});

  @override
  State<AdminPizzaHistorySection> createState() =>
      _AdminPizzaHistorySectionState();
}

class _AdminPizzaHistorySectionState extends State<AdminPizzaHistorySection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
            if (_isExpanded) {
              final state = context.read<AdminPizzaReviewCubit>().state;
              if (state.previousPizzas.isEmpty) {
                context.read<AdminPizzaReviewCubit>().loadUserHistory(
                  widget.userId,
                );
              }
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Listado Publicadas',
                    style: theme.textTheme.displayMedium?.copyWith(
                      color: theme.colorScheme.secondary,
                      fontSize: 24,
                    ),
                  ),
                ),
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: theme.colorScheme.secondary,
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded) ...[
          const SizedBox(height: 16),
          BlocBuilder<AdminPizzaReviewCubit, AdminPizzaReviewState>(
            builder: (context, state) {
              if (state.isLoadingHistory) {
                return const Center(child: CircularProgressIndicator());
              }
              final previousPizzas = state.previousPizzas;
              if (previousPizzas.isEmpty) {
                return Center(
                  child: Text(
                    'No hay pizzas anteriores.',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: previousPizzas.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final pizza = previousPizzas[index];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1DAC1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              pizza.pizzaStyle?.displayName ?? 'Pizza',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.secondary,
                              ),
                            ),
                            Text(
                              DateFormat(
                                'EEEE d - HH:mm',
                                'es',
                              ).format(pizza.createdAt),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.secondary.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (pizza.otherIngredients != null)
                          Text(
                            pizza.otherIngredients!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ],
    );
  }
}
