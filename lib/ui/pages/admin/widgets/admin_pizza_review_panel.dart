import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizzathon/domain/models/pizza_model.dart';
import 'package:pizzathon/ui/blocs/admin_pizza_review/admin_pizza_review_cubit.dart';
import 'package:pizzathon/ui/blocs/admin_pizza_review/admin_pizza_review_state.dart';

class AdminPizzaReviewPanel extends StatefulWidget {
  final PizzaModel pizza;
  final Function(int score, String comment) onApprove;
  final Function(String comment) onReject;

  const AdminPizzaReviewPanel({
    super.key,
    required this.pizza,
    required this.onApprove,
    required this.onReject,
  });

  @override
  State<AdminPizzaReviewPanel> createState() => _AdminPizzaReviewPanelState();
}

class _AdminPizzaReviewPanelState extends State<AdminPizzaReviewPanel> {
  int? _selectedScore;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedScore = widget.pizza.score;
    _commentController.text = widget.pizza.adminComment ?? '';
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isReviewed = widget.pizza.status != PizzaStatus.pending;

    return BlocConsumer<AdminPizzaReviewCubit, AdminPizzaReviewState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isReviewed ? 'Puntuación asignada' : 'Puntuación final',
                  style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.secondary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (isReviewed)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  border: Border.all(color: theme.colorScheme.primary),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${widget.pizza.score ?? 0} PUNTOS',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary),
                ),
              )
            else
              _buildScoreSelector(),
            if (!isReviewed) ...[
              const SizedBox(height: 24),
              _buildActionButton(context, 'APROBAR', theme.colorScheme.primary, () {
                if (_selectedScore == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor, selecciona una puntuación.')),
                  );
                  return;
                }
                widget.onApprove(_selectedScore!, _commentController.text);
              }),
            ],

            const SizedBox(height: 24),
            if (isReviewed)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Comentarios del administrador',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.pizza.adminComment?.isNotEmpty == true
                        ? widget.pizza.adminComment!
                        : 'Sin comentarios.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.secondary),
                  ),
                ],
              )
            else
              TextField(
                controller: _commentController,
                maxLines: 5,
                style: TextStyle(color: theme.colorScheme.secondary),
                decoration: InputDecoration(
                  labelText: 'Comentarios',
                  alignLabelWithHint: true,
                  labelStyle: TextStyle(color: theme.colorScheme.primary),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: theme.colorScheme.primary),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                  ),
                ),
              ),
            if (!isReviewed) ...[
              const SizedBox(height: 24),
              _buildActionButton(
                context,
                'RECHAZAR',
                theme.colorScheme.primary,
                () => widget.onReject(_commentController.text),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildScoreSelector() {
    final theme = Theme.of(context);
    final scores = [0, 10, 30, 100];
    return Column(
      children: scores.map((score) {
        final isSelected = _selectedScore == score;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: InkWell(
            onTap: () => setState(() => _selectedScore = score),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                border: Border.all(color: theme.colorScheme.primary),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$score PUNTOS',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isSelected ? Colors.white : theme.colorScheme.primary,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String text,
    Color color,
    VoidCallback onPressed,
  ) {
    final theme = Theme.of(context);
    return BlocBuilder<AdminPizzaReviewCubit, AdminPizzaReviewState>(
      builder: (context, state) {
        final isLoading = state.isSubmitting;
        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            ),
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(text, style: theme.textTheme.titleMedium?.copyWith(color: Colors.white)),
          ),
        );
      },
    );
  }
}
