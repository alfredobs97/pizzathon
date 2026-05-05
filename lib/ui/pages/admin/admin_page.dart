import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizzathon/data/services/firestore_service.dart';
import 'package:pizzathon/ui/blocs/admin_pizzas/admin_pizzas_cubit.dart';
import 'package:pizzathon/ui/widgets/top_banner.dart';
import 'widgets/admin_pizzas_tab_view.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (context) => AdminPizzasCubit(context.read<FirestoreService>())..refreshAll(),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: CountdownTopBanner(
            actions: [
              Builder(
                builder: (context) {
                  return IconButton(
                    icon: const Icon(Icons.refresh_rounded),
                    tooltip: 'Refrescar todo',
                    onPressed: () => context.read<AdminPizzasCubit>().refreshAll(),
                  );
                },
              ),
            ],
          ),
          body: const Padding(
            padding: EdgeInsets.all(16.0),
            child: AdminPizzasTabView(),
          ),
        ),
      ),
    );
  }
}
