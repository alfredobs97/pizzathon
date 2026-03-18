import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/services/firestore_service.dart';
import '../../blocs/user_list/users_list_cubit.dart';
import 'widgets/user_list_widget.dart';
import '../../blocs/auth_cubit.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF420B0B),
        centerTitle: true,
        title: const Text(
          'Buscamos 100 MEJORES talentos en Pizza',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => context.read<AuthCubit>().logout(),
          ),
        ],
      ),
      body: BlocProvider(
        create: (context) => UsersListCubit(context.read<FirestoreService>())..loadInitialUsers(),
        child: Column(
          children: [
            const Expanded(child: UserListWidget()),
            // Footer
            Container(
              width: double.infinity,
              color: const Color(0xFF420B0B),
              padding: const EdgeInsets.symmetric(vertical: 60),
              child: const Column(
                children: [
                  Text(
                    'Sigue las novedades de Pizzathon',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '@salva.pizzalover',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
