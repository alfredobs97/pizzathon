import 'package:flutter/material.dart';
import 'package:pizzathon/ui/widgets/top_banner.dart';
import 'widgets/admin_pizzas_tab_view.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: CountdownTopBanner(),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: AdminPizzasTabView(),
        ),
      ),
    );
  }
}
