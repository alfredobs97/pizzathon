import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizzathon/data/services/image_processing_service.dart';
import 'package:pizzathon/data/services/remote_config_service.dart';
import 'package:pizzathon/data/services/image_metadata_service.dart';
import 'package:pizzathon/data/services/pizza_validation_service.dart';

import 'package:pizzathon/ui/blocs/poc_images/poc_images_cubit.dart';
import 'package:pizzathon/ui/widgets/app_shell.dart';
import 'widgets/initial_view.dart';

class PocImagesPage extends StatelessWidget {
  const PocImagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (context) => PocImagesCubit(
        ImageProcessingService(),
        context.read<RemoteConfigService>(),
        ImageMetadataService(),
        PizzaValidationService(),
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
          actions: [
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => AppShell.openDrawer(),
            ),
          ],
        ),
        body: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: InitialView()),
        ),
      ),
    );
  }
}
