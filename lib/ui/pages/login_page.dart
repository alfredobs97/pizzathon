import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_cubit.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bienvenido a Pizzathon')),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () => context.read<AuthCubit>().login(),
          icon: const Icon(Icons.login),
          label: const Text('Iniciar sesión con Google'),
        ),
      ),
    );
  }
}