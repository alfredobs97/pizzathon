import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../app_router.dart';
import '../blocs/admin_selected_pizzas/admin_selected_pizzas_cubit.dart';
import '../blocs/admin_selected_pizzas/admin_selected_pizzas_state.dart';

class AdminSelectedPizzasFab extends StatefulWidget {
  const AdminSelectedPizzasFab({super.key});

  @override
  State<AdminSelectedPizzasFab> createState() => _AdminSelectedPizzasFabState();
}

class _AdminSelectedPizzasFabState extends State<AdminSelectedPizzasFab> {
  String? _lastAdminId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = context.watch<AuthCubit>().state;
    final isAdmin = AppRouter.isAdmin(context);

    if (!isAdmin || authState is! AuthAuthenticated) {
      _lastAdminId = null;
      return const SizedBox.shrink();
    }

    final adminId = authState.user.uid;
    if (_lastAdminId != adminId) {
      _lastAdminId = adminId;
      Future.microtask(() {
        if (context.mounted) {
          context.read<AdminSelectedPizzasCubit>().init(adminId);
        }
      });
    }

    return BlocBuilder<AdminSelectedPizzasCubit, AdminSelectedPizzasState>(
      builder: (context, state) {
        if (state.selectedPizzas.isEmpty || state.isLoading) return const SizedBox.shrink();

        return FloatingActionButton.extended(
          onPressed: () => context.push(AppRouter.adminSelectedPizzasRoute),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          icon: const Icon(Icons.star),
          label: Text('${state.selectedPizzas.length} seleccionadas'),
        );
      },
    );
  }
}
