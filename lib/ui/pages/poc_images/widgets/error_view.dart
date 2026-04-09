import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizzathon/ui/blocs/poc_images/poc_images_cubit.dart';

class ErrorView extends StatelessWidget {
  final String message;
  const ErrorView({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 48),
        const SizedBox(height: 16),
        Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => context.read<PocImagesCubit>().pickAndCompressImages(),
          child: const Text("Reintentar"),
        ),
      ],
    );
  }
}