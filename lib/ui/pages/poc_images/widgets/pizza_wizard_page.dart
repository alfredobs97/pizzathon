import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizzathon/ui/blocs/poc_images/poc_images_cubit.dart';
import 'package:pizzathon/ui/blocs/poc_images/poc_images_state.dart';
import 'pizza_confirmation_step.dart';
import 'pizza_details_form.dart';
import 'pizza_photo_step_view.dart';
import 'pizza_wizard_dialogs.dart';

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
    final initialState = context.read<PocImagesCubit>().state;
    _pageController = PageController(initialPage: initialState.mainStep.index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<PocImagesCubit, PocImagesState>(
      listenWhen: (previous, current) =>
          previous.mainStep != current.mainStep ||
          previous.isFinished != current.isFinished ||
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        if (state.errorMessage != null) {
          showErrorDialog(context, state.errorMessage!, theme);
        }

        if (state.isFinished) {
          Navigator.of(context).pop();
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
            leading: IconButton(
              icon: Icon(
                Icons.close,
                color: theme.colorScheme.secondary,
                size: 30,
              ),
              onPressed: () => showExitConfirmationDialog(context, theme),
            ),
            title: _buildStepper(context, state, theme),
            centerTitle: true,
          ),
          body: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              // PASO 1: FOTOS
              PizzaPhotoStepView(
                step: state.currentStep,
                state: state,
              ),
              // PASO 2: FORMULARIO
              _buildDetailsStep(context, state, theme),
              // PASO 3: CONFIRMACIÓN
              PizzaConfirmationStep(state: state, theme: theme),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStepper(
    BuildContext context,
    PocImagesState state,
    ThemeData theme,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(WizardStep.values.length, (index) {
        final isCompleted = state.mainStep.index > index;
        final isCurrent = state.mainStep.index == index;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isCompleted
                ? theme.colorScheme.primary
                : isCurrent
                    ? theme.colorScheme.primary.withValues(alpha: 0.15)
                    : theme.colorScheme.secondary.withValues(alpha: 0.08),
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
                color: isCompleted
                    ? theme.colorScheme.onPrimary
                    : isCurrent
                        ? theme.colorScheme.primary
                        : theme.colorScheme.secondary.withValues(alpha: 0.5),
                fontWeight: FontWeight.bold,
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Text(
            "Detalles de la Pizza",
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.secondary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          PizzaDetailsForm(
            onSubmit: (title, description) {
              context.read<PocImagesCubit>().savePizzaDetails(
                title,
                description,
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
