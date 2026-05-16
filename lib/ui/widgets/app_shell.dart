import 'package:flutter/material.dart';
import 'package:pizzathon/ui/widgets/admin_selected_pizzas_fab.dart';
import 'package:pizzathon/ui/widgets/app_drawer.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  static final GlobalKey<ScaffoldState> scaffoldKey =
      GlobalKey<ScaffoldState>();

  const AppShell({super.key, required this.child});

  static void openDrawer() {
    scaffoldKey.currentState?.openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      endDrawer: const AppDrawer(),
      body: child,
      floatingActionButton: const AdminSelectedPizzasFab(),
    );
  }
}
