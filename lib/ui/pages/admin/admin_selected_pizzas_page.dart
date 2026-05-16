import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_router.dart';
import '../../blocs/auth_cubit.dart';
import '../../blocs/auth_state.dart';
import '../../blocs/admin_selected_pizzas/admin_selected_pizzas_cubit.dart';
import '../../blocs/admin_selected_pizzas/admin_selected_pizzas_state.dart';
import '../profile/widgets/pizza_card.dart';

class AdminSelectedPizzasPage extends StatelessWidget {
  const AdminSelectedPizzasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.onSurface,
      appBar: AppBar(
        title: Text(
          'BEST PIZZA',
          style: GoogleFonts.climateCrisis(
            fontSize: 18,
            color: theme.colorScheme.primary,
          ),
        ),
        backgroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<AdminSelectedPizzasCubit, AdminSelectedPizzasState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.selectedPizzas.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star_border, size: 80, color: theme.colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    'No hay pizzas seleccionadas',
                    style: theme.textTheme.titleLarge?.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400,
              mainAxisSpacing: 24,
              crossAxisSpacing: 24,
              childAspectRatio: 1.0,
            ),
            itemCount: state.selectedPizzas.length,
            itemBuilder: (context, index) {
              final pizza = state.selectedPizzas[index];
              return InkWell(
                onTap: () => context.push(AppRouter.adminPizzaDetailRoute, extra: pizza),
                child: PizzaCard(pizza: pizza),
              );
            },
          );
        },
      ),
    );
  }
}
