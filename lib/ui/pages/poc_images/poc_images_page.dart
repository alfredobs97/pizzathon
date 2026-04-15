import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizzathon/data/services/image_processing_service.dart';
import 'package:pizzathon/data/services/remote_config_service.dart';
import 'package:pizzathon/ui/blocs/poc_images/poc_images_cubit.dart';
import 'package:pizzathon/ui/blocs/poc_images/poc_images_state.dart';

import 'widgets/initial_view.dart';
import 'widgets/success_grid_view.dart';
import 'widgets/error_view.dart';

class PocImagesPage extends StatelessWidget {
  const PocImagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (context) => PocImagesCubit(
        ImageProcessingService(),
        RemoteConfigService(),
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor, 
          elevation: 0, 
          scrolledUnderElevation: 0, 
          centerTitle: true,
          iconTheme: IconThemeData(color: theme.colorScheme.primary), 
          title: Text(
            'Galería Pizzathon',
            style: theme.textTheme.displayMedium?.copyWith(
              fontSize: 22,
              color: theme.colorScheme.secondary, 
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: BlocBuilder<PocImagesCubit, PocImagesState>(
              builder: (context, state) {
                return switch (state) {
                  PocImagesInitial() => const InitialView(),
                  PocImagesLoading() => const CircularProgressIndicator(color: Color(0xFFE36414)), 
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