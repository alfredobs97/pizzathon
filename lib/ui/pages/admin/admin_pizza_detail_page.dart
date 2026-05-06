import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pizzathon/domain/models/pizza_model.dart';
import 'package:pizzathon/ui/blocs/admin_pizza_review/admin_pizza_review_cubit.dart';
import 'package:pizzathon/ui/blocs/admin_pizza_review/admin_pizza_review_state.dart';
import 'package:pizzathon/ui/pages/admin/widgets/admin_pizza_dialogs.dart';
import 'package:pizzathon/ui/pages/admin/widgets/admin_pizza_header.dart';
import 'package:pizzathon/ui/pages/admin/widgets/admin_pizza_history_section.dart';
import 'package:pizzathon/ui/pages/admin/widgets/admin_pizza_images_grid.dart';
import 'package:pizzathon/ui/pages/admin/widgets/admin_pizza_review_panel.dart';
import 'package:pizzathon/ui/pages/admin/widgets/admin_pizza_technical_details.dart';

class AdminPizzaDetailPage extends StatelessWidget {
  final PizzaModel pizza;

  const AdminPizzaDetailPage({super.key, required this.pizza});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEEE d - HH:mm', 'es').format(pizza.createdAt);
    final formattedDate = dateStr[0].toUpperCase() + dateStr.substring(1);

    return BlocListener<AdminPizzaReviewCubit, AdminPizzaReviewState>(
      listener: (context, state) {
        if (state.isSuccess) {
          AdminPizzaDialogs.showSuccess(context);
        }
        if (state.isError && state.errorMessage != null) {
          AdminPizzaDialogs.showError(context, state.errorMessage!);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AdminPizzaHeader(pizza: pizza, formattedDate: formattedDate),
                const SizedBox(height: 32),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AdminPizzaImagesGrid(imageUrls: pizza.imageUrls),
                          const SizedBox(height: 32),
                          AdminPizzaTechnicalDetails(pizza: pizza),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: AdminPizzaHistorySection(
                        userId: pizza.userId,
                        currentPizzaDate: pizza.createdAt,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: AdminPizzaReviewPanel(
                        pizza: pizza,
                        onApprove: (score, comment) {
                          context.read<AdminPizzaReviewCubit>().submitReview(
                            pizzaId: pizza.id,
                            userId: pizza.userId,
                            status: PizzaStatus.approved,
                            score: score,
                            comment: comment,
                          );
                        },
                        onReject: (comment) {
                          context.read<AdminPizzaReviewCubit>().submitReview(
                            pizzaId: pizza.id,
                            userId: pizza.userId,
                            status: PizzaStatus.rejected,
                            score: 0,
                            comment: comment,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
