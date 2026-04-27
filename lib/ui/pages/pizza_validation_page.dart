import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pizzathon/domain/entities/pizza_image_metadata.dart';
import 'package:pizzathon/domain/services/error_tracker_service.dart';
import '../blocs/pizza_validation_cubit.dart';
import '../blocs/pizza_validation_state.dart';

class PizzaValidationPage extends StatelessWidget {
  const PizzaValidationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          PizzaValidationCubit(errorTrackerService: context.read<ErrorTrackerService>()),
      child: const PizzaValidationView(),
    );
  }
}

class PizzaValidationView extends StatelessWidget {
  const PizzaValidationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('POC - Añadir pizza'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: BlocBuilder<PizzaValidationCubit, PizzaValidationState>(
              builder: (context, state) {
                switch (state.status) {
                  case PizzaValidationStatus.initial:
                    return _buildInitialState(context);
                  case PizzaValidationStatus.loading:
                    return _buildLoadingState();
                  case PizzaValidationStatus.success:
                    return _buildSuccessState(context, state);
                  case PizzaValidationStatus.rejected:
                    return _buildRejectedState(context, state);
                  case PizzaValidationStatus.disqualified:
                    return _buildDisqualifiedState(context, state);
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInitialState(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => context.read<PizzaValidationCubit>().pickAndValidateImage(),
      icon: const Icon(Icons.add),
      label: const Text('Añadir pizza'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple.shade50,
        foregroundColor: Colors.deepPurple,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text('Analizando pizza', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _buildSuccessState(BuildContext context, PizzaValidationState state) {
    final dateFormat = DateFormat("dd MMM yyyy / HH:mm 'h'");
    final metadata = state.metadata;
    final dateText = metadata is DetailedImageMetadata && metadata.creationDate != null
        ? dateFormat.format(metadata.creationDate!)
        : 'Desconocida';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: kIsWeb
              ? Image.network(state.imageFile!.path, width: 250, height: 250, fit: BoxFit.cover)
              : Image.file(File(state.imageFile!.path), width: 250, height: 250, fit: BoxFit.cover),
        ),
        const SizedBox(height: 16),
        const Text(
          'Foto válida para subir',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          'Imagen creada el $dateText',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 24),
        Center(
          child: ElevatedButton(
            onPressed: () => context.read<PizzaValidationCubit>().reset(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C6381),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Aceptar'),
          ),
        ),
      ],
    );
  }

  Widget _buildRejectedState(BuildContext context, PizzaValidationState state) {
    return _buildResultState(
      context,
      state,
      title: 'No puedes participar con esta foto',
      color: Colors.red,
      icon: Icons.priority_high,
    );
  }

  Widget _buildDisqualifiedState(BuildContext context, PizzaValidationState state) {
    return _buildResultState(
      context,
      state,
      title: '¡Estás descalificado!',
      color: Colors.red.shade900,
      icon: Icons.block,
      isDisqualified: true,
    );
  }

  Widget _buildResultState(
    BuildContext context,
    PizzaValidationState state, {
    required String title,
    required Color color,
    required IconData icon,
    bool isDisqualified = false,
  }) {
    return FractionallySizedBox(
      widthFactor: 0.6,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(color.withValues(alpha: 0.6), BlendMode.srcOver),
                  child: kIsWeb
                      ? Image.network(
                          state.imageFile!.path,
                          width: 250,
                          height: 250,
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          File(state.imageFile!.path),
                          width: 250,
                          height: 250,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 32),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          if (state.status == PizzaValidationStatus.rejected) ...[
            const SizedBox(height: 4),
            Text(
              state.errorMessage ?? 'No cumple con los requisitos',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
          const SizedBox(height: 24),
          if (isDisqualified) ...[
            const Text(
              'Hemos detectado que has intentado usar IA para participar. Las trampas no están permitidas y no podrás volver a participar en el concurso.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
          ],

          Center(
            child: ElevatedButton(
              onPressed: () => context.read<PizzaValidationCubit>().reset(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C6381),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Aceptar'),
            ),
          ),
        ],
      ),
    );
  }
}
