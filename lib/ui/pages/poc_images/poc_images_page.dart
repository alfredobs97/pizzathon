import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizzathon/data/services/image_processing_service.dart';
import 'package:pizzathon/ui/blocs/poc_images/poc_images_cubit.dart';
import 'package:pizzathon/ui/blocs/poc_images/poc_images_state.dart';

import 'widgets/initial_view.dart';
import 'widgets/success_grid_view.dart';
import 'widgets/error_view.dart';

class PocImagesPage extends StatelessWidget {
  const PocImagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PocImagesCubit(ImageProcessingService()),
      child: Scaffold(
        appBar: AppBar(title: const Text('POC: Selección Múltiple (Admins)')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: BlocBuilder<PocImagesCubit, PocImagesState>(
              builder: (context, state) {
                return switch (state) {
                  PocImagesInitial() => const InitialView(),
                  PocImagesLoading() => const CircularProgressIndicator(),
                  PocImagesSuccess() => SuccessGridView(state: state),
                  PocImagesError() => ErrorView(message: state.message),
                };
              },
            ),
          ),
        ),
      ),
    );
  }
}