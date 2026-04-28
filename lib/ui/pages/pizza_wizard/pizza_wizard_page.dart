import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pizzathon/data/services/image_metadata_service.dart';
import 'package:pizzathon/data/services/image_processing_service.dart';
import 'package:pizzathon/data/services/pizza_validation_service.dart';
import 'package:pizzathon/data/services/remote_config_service.dart';
import 'package:pizzathon/domain/services/error_tracker_service.dart';
import 'package:pizzathon/ui/blocs/poc_images/poc_images_cubit.dart';
import 'package:pizzathon/ui/blocs/poc_images/poc_images_state.dart';
import 'package:pizzathon/ui/pages/pizza_wizard/widgets/pizza_photo_step_view.dart';
import 'widgets/pizza_confirmation_step.dart';
import 'widgets/pizza_details_form.dart';
import 'widgets/pizza_ingredients_step.dart';
import 'widgets/pizza_wizard_dialogs.dart';

class PizzaWizardPage extends StatefulWidget {
  const PizzaWizardPage({super.key});

  @override
  State<PizzaWizardPage> createState() => _PizzaWizardPageState();
}

class _PizzaWizardPageState extends State<PizzaWizardPage> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (context) => PocImagesCubit(
        ImageProcessingService(),
        context.read<RemoteConfigService>(),
        ImageMetadataService(),
        PizzaValidationService(),
        context.read<ErrorTrackerService>(),
      ),
      child: Builder(
        builder: (context) => BlocConsumer<PocImagesCubit, PocImagesState>(
          listenWhen: (previous, current) =>
              previous.mainStep != current.mainStep ||
              previous.isFinished != current.isFinished ||
              previous.errorMessage != current.errorMessage,
          listener: (context, state) {
            if (state.errorMessage != null) {
              showErrorDialog(context, state.errorMessage!, theme);
            }

            if (state.isFinished) {
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('¡Participación enviada con éxito!'),
                  backgroundColor: theme.colorScheme.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            } else {
              // Animate to the new step if it changed
              if (_pageController.hasClients &&
                  _pageController.page?.round() != state.mainStep.index) {
                _pageController.animateToPage(
                  state.mainStep.index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            }
          },
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: theme.scaffoldBackgroundColor,
                elevation: 0,
                title: _buildStepper(context, state, theme),
                centerTitle: true,
                leading: IconButton(
                  icon: Icon(Icons.close, color: theme.colorScheme.secondary),
                  onPressed: () async {
                    final shouldExit = await showExitConfirmationDialog(context);
                    if (shouldExit && context.mounted) {
                      context.pop();
                    }
                  },
                ),
              ),
              body: Center(
                child: SizedBox(
                  width: 480,
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      const PizzaPhotoStepView(),
                      _buildDetailsStep(context, state, theme),
                      const PizzaIngredientsStep(),
                      const PizzaConfirmationStep(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStepper(
    BuildContext context,
    PocImagesState state,
    ThemeData theme,
  ) {
    if (state.mainStep == WizardStep.confirmacion) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        final isCurrent = state.mainStep.index == index;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isCurrent
                ? theme.colorScheme.onSecondaryContainer
                : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: isCurrent ? theme.colorScheme.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: TextStyle(
                color: isCurrent
                    ? theme.colorScheme.primary
                    : theme.colorScheme.primary.withValues(alpha: 0.5),
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDetailsStep(
    BuildContext context,
    PocImagesState state,
    ThemeData theme,
  ) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(24.0),
      child: Column(children: [PizzaDetailsForm(), SizedBox(height: 16)]),
    );
  }
}
