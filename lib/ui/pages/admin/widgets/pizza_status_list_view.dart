import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../domain/models/pizza_model.dart';
import '../../../blocs/admin_pizzas/admin_pizzas_cubit.dart';
import '../../../blocs/admin_pizzas/admin_pizzas_state.dart';

class PizzaStatusListView extends StatefulWidget {
  final PizzaStatus status;

  const PizzaStatusListView({super.key, required this.status});

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
      context.read<AdminPizzasCubit>().fetchPizzas(widget.status, isLoadMore: true);
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
    return BlocBuilder<AdminPizzasCubit, AdminPizzasState>(
      buildWhen: (previous, current) =>
          previous.getForStatus(widget.status) != current.getForStatus(widget.status),
      builder: (context, state) {
        final listState = state.getForStatus(widget.status);

        if (listState.isLoading && listState.pizzas.isEmpty) {
          return const _LoadingView();
        }

        if (listState.errorMessage != null && listState.pizzas.isEmpty) {
          return _ErrorView(message: listState.errorMessage!);
        }

        if (listState.pizzas.isEmpty) {
          return const _EmptyView();
        }

        return _PizzaListView(
          pizzas: listState.pizzas,
          hasReachedMax: listState.hasReachedMax,
          isLoadingMore: listState.isLoading,
          scrollController: _scrollController,
          status: widget.status,
        );
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
        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.black),
      ),
    );
  }
}

class _PizzaListView extends StatelessWidget {
  final List<PizzaModel> pizzas;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final ScrollController scrollController;
  final PizzaStatus status;

  const _PizzaListView({
    required this.pizzas,
    required this.hasReachedMax,
    required this.isLoadingMore,
    required this.scrollController,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<AdminPizzasCubit>().fetchPizzas(status),
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
        await context.push('/capo/pizza', extra: pizza);
        // El admin refrescará manualmente cuando quiera ver los cambios
      },
      borderRadius: BorderRadius.circular(12),

        child: Container(
          decoration: BoxDecoration(
            color: pizza.status == PizzaStatus.approved ? theme.colorScheme.secondaryContainer : theme.colorScheme.primary,
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
