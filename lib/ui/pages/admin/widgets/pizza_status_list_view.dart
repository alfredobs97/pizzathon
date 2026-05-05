import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../domain/models/pizza_model.dart';
import '../../../blocs/admin_pizzas/admin_pizzas_cubit.dart';
import '../../../blocs/admin_pizzas/admin_pizzas_state.dart';

class PizzaStatusListView extends StatefulWidget {
  const PizzaStatusListView({super.key});

  @override
  State<PizzaStatusListView> createState() => _PizzaStatusListViewState();
}

class _PizzaStatusListViewState extends State<PizzaStatusListView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<AdminPizzasListCubit>().loadMorePizzas();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminPizzasListCubit, AdminPizzasListState>(
      builder: (context, state) => switch (state) {
        AdminPizzasListLoading() => const _LoadingView(),
        AdminPizzasListError(:final message) => _ErrorView(message: message),
        AdminPizzasListLoaded(:final pizzas, :final hasReachedMax) =>
          pizzas.isEmpty
              ? const _EmptyView()
              : _PizzaListView(
                  pizzas: pizzas,
                  hasReachedMax: hasReachedMax,
                  scrollController: _scrollController,
                ),
      },
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(message));
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No hay pizzas en esta categoría.',
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(color: Colors.black),
      ),
    );
  }
}

class _PizzaListView extends StatelessWidget {
  final List<PizzaModel> pizzas;
  final bool hasReachedMax;
  final ScrollController scrollController;

  const _PizzaListView({
    required this.pizzas,
    required this.hasReachedMax,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<AdminPizzasListCubit>().loadInitialPizzas(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        controller: scrollController,
        itemCount: hasReachedMax ? pizzas.length : pizzas.length + 1,
        itemBuilder: (context, index) {
          if (index >= pizzas.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          return _PizzaListItem(pizza: pizzas[index]);
        },
      ),
    );
  }
}

class _PizzaListItem extends StatelessWidget {
  final PizzaModel pizza;
  const _PizzaListItem({required this.pizza});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = DateFormat('EEEE d - HH:mm', 'es').format(pizza.createdAt);
    final formattedDate = dateStr[0].toUpperCase() + dateStr.substring(1);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: InkWell(
        onTap: () async {
          final result = await context.push('/capo/pizza', extra: pizza);
          // Si se aprueba/rechaza con éxito, recargamos la lista
          if (result == true && context.mounted) {
            context.read<AdminPizzasListCubit>().loadInitialPizzas();
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  pizza.pizzaStyle?.displayName ?? 'Pizza Desconocida',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                formattedDate,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
