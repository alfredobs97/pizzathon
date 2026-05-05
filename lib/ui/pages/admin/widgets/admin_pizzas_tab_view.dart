import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/services/firestore_service.dart';
import '../../../../domain/models/pizza_model.dart';
import '../../../blocs/admin_pizzas/admin_pizzas_cubit.dart';
import 'pizza_status_list_view.dart';

class AdminPizzasTabView extends StatelessWidget {
  const AdminPizzasTabView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: TabBar.secondary(
              isScrollable: false,
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              labelPadding: const EdgeInsets.symmetric(horizontal: 16.0),
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: colorScheme.onSecondaryContainer,
              ),
              labelColor: colorScheme.secondary,
              unselectedLabelColor: colorScheme.secondary,
              labelStyle: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: theme.textTheme.bodyLarge,
              tabs: const [
                Tab(text: 'Nuevas'),
                Tab(text: 'Aprobadas'),
                Tab(text: 'Rechazadas'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildStatusList(context, PizzaStatus.pending),
                _buildStatusList(context, PizzaStatus.approved),
                _buildStatusList(context, PizzaStatus.rejected),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusList(BuildContext context, PizzaStatus status) {
    return _KeepAliveWrapper(
      child: BlocProvider(
        create: (context) =>
            AdminPizzasListCubit(context.read<FirestoreService>(), status)
              ..loadInitialPizzas(),
        child: const PizzaStatusListView(),
      ),
    );
  }
}

class _KeepAliveWrapper extends StatefulWidget {
  final Widget child;
  const _KeepAliveWrapper({required this.child});

  @override
  State<_KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<_KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
