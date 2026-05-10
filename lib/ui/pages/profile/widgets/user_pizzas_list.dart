import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pizzathon/domain/models/user_model.dart';
import 'package:pizzathon/ui/blocs/user_pizzas/user_pizzas_cubit.dart';
import 'package:pizzathon/ui/blocs/user_pizzas/user_pizzas_state.dart';
import 'package:pizzathon/ui/pages/profile/widgets/pizza_card.dart';

class UserPizzasList extends StatelessWidget {
  final UserModel user;

  const UserPizzasList({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollNotification(scrollInfo)) {
          context.read<UserPizzasCubit>().fetchMorePizzas(user.uid);
        }
        return false;
      },
      child: BlocBuilder<UserPizzasCubit, UserPizzasState>(
        builder: (context, state) {
          if (state is UserPizzasLoading) {
            return const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (state is UserPizzasError) {
            return SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    'Error: ${state.message}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            );
          }

          if (state is UserPizzasLoaded) {
            if (state.pizzas.isEmpty) {
              return SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.local_pizza,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No has subido ninguna pizza aún.',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              sliver: SliverMainAxisGroup(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        'Pizzas de ${user.displayName}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.archivo(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  SliverGrid(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 400,
                      mainAxisSpacing: 24,
                      crossAxisSpacing: 24,
                      childAspectRatio: 1.0,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final pizza = state.pizzas[index];
                        return PizzaCard(pizza: pizza);
                      },
                      childCount: state.pizzas.length,
                    ),
                  ),
                  if (!state.hasReachedMax)
                    const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }

          return const SliverToBoxAdapter(child: SizedBox.shrink());
        },
      ),
    );
  }

  bool scrollNotification(ScrollNotification scrollInfo) {
    return scrollInfo.metrics.pixels >= (scrollInfo.metrics.maxScrollExtent - 200);
  }
}
