import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizzathon/ui/widgets/app_shell.dart';
import '../../../../data/services/firestore_service.dart';
import '../../blocs/user_list/users_list_cubit.dart';
import 'widgets/users_tab_view.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocProvider(
      create: (context) => UsersListCubit(context.read<FirestoreService>())..loadInitialUsers(),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: colorScheme.surface,
            elevation: 0,
            title: Text(
              'Panel de Administración',
              style: theme.textTheme.displayMedium?.copyWith(color: colorScheme.onSurface),
            ),
            iconTheme: IconThemeData(color: colorScheme.onSurface),
            actions: [
              IconButton(icon: const Icon(Icons.menu), onPressed: () => AppShell.openDrawer()),
            ],
            bottom: TabBar(
              indicatorColor: colorScheme.primary,
              indicatorWeight: 4,
              labelColor: colorScheme.primary,
              unselectedLabelColor: colorScheme.onSurface.withValues(alpha: 0.7),
              labelStyle: theme.textTheme.titleMedium,
              tabs: const [
                Tab(icon: Icon(Icons.people), text: 'Usuarios'),
                Tab(icon: Icon(Icons.local_pizza), text: 'Pizzas'),
              ],
            ),
          ),
          body: const TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: [
              UsersTabView(),
              Center(child: Text('Próximamente: Lista de Pizzas')),
            ],
          ),
        ),
      ),
    );
  }
}
