import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizzathon/ui/blocs/poc_images/poc_images_cubit.dart';
import 'package:pizzathon/ui/blocs/poc_images/poc_images_state.dart';
import 'pizza_details_form.dart';

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
    final initialStep = context.read<PocImagesCubit>().state.currentStep.index;
    _pageController = PageController(initialPage: initialStep);
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
          previous.currentStep != current.currentStep ||
          previous.isFinished != current.isFinished ||
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        if (state.errorMessage != null) {
          _showErrorDialog(context, state.errorMessage!, theme);
        }

        if (state.isFinished) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('¡Participación enviada con éxito!'),
              backgroundColor: theme.colorScheme.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        } else {
          // Animate to the new step if it changed
          if (_pageController.hasClients && _pageController.page?.round() != state.currentStep.index) {
            _pageController.animateToPage(
              state.currentStep.index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        }
      },
      builder: (context, state) {
        final totalSteps = PizzaPhotoStep.values.length;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.close, color: theme.colorScheme.secondary, size: 28),
              onPressed: () => _showExitConfirmationDialog(context, theme),
            ),
            title: _buildStepper(state, theme),
            centerTitle: true,
          ),
          body: PageView.builder(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: totalSteps,
            itemBuilder: (context, index) {
              final step = PizzaPhotoStep.values[index];
              if (step == PizzaPhotoStep.detalles) {
                return _buildDetailsStep(context, state, theme);
              }
              return _buildPhotoStep(context, step, state, theme);
            },
          ),
        );
      },
    );
  }

  Widget _buildStepper(PocImagesState state, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(PizzaPhotoStep.values.length, (index) {
        final step = PizzaPhotoStep.values[index];
        final isCompleted = index < state.currentStep.index;
        final isActive = index == state.currentStep.index;

        IconData iconData;
        switch (step) {
          case PizzaPhotoStep.bocaHorno:
            iconData = Icons.local_fire_department_rounded;
            break;
          case PizzaPhotoStep.vistaArriba:
            iconData = Icons.camera_alt_rounded;
            break;
          case PizzaPhotoStep.corte:
            iconData = Icons.local_pizza_rounded;
            break;
          case PizzaPhotoStep.abajo:
            iconData = Icons.flip_camera_android_rounded;
            break;
          case PizzaPhotoStep.detalles:
            iconData = Icons.edit_note_rounded;
            break;
        }

        final color = isActive || isCompleted
            ? theme.colorScheme.primary
            : theme.colorScheme.secondary.withAlpha(80);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isActive ? theme.colorScheme.primary.withAlpha(30) : Colors.transparent,
            shape: BoxShape.circle,
            border: isActive ? Border.all(color: theme.colorScheme.primary, width: 2) : null,
          ),
          child: Icon(
            iconData,
            color: color,
            size: isActive ? 22 : 18,
          ),
        );
      }),
    );
  }

  Widget _buildPhotoStep(BuildContext context, PizzaPhotoStep step, PocImagesState state, ThemeData theme) {
    final isCurrentStep = state.currentStep == step;
    final confirmedImage = state.confirmedImages[step];
    final hasConfirmed = confirmedImage != null;
    final hasPendingForThisStep = isCurrentStep && state.pendingImage != null;
    final isLoading = isCurrentStep && state.isLoading;
    final stepDescription = step.title.split(': ').last;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Text(
            stepDescription,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.secondary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (hasConfirmed)
                      Image.memory(confirmedImage, fit: BoxFit.cover)
                    else if (hasPendingForThisStep)
                      Image.memory(state.pendingImage!, fit: BoxFit.cover)
                    else
                      ColorFiltered(
                        colorFilter: const ColorFilter.mode(
                          Colors.grey,
                          BlendMode.saturation,
                        ),
                        child: CachedNetworkImage(
                          imageUrl: step.exampleImageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              Container(color: Colors.grey.shade300),
                          errorWidget: (context, url, error) =>
                              Container(color: Colors.grey.shade300),
                        ),
                      ),
                      
                    if (!hasConfirmed && !hasPendingForThisStep)
                      Container(color: Colors.black.withAlpha(140)),
                      
                    if (isLoading)
                      Container(
                        color: Colors.black.withAlpha(100),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                      ),

                    if (!hasConfirmed && !hasPendingForThisStep && !isLoading)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.camera_alt, color: Colors.white, size: 48),
                          const SizedBox(height: 16),
                          OutlinedButton(
                            onPressed: () => context
                                .read<PocImagesCubit>()
                                .pickSingleImage(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(
                                color: Colors.white,
                                width: 2,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: const Text("Tomar foto o galería"),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          if (isCurrentStep && hasPendingForThisStep && !isLoading)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: () =>
                      context.read<PocImagesCubit>().pickSingleImage(),
                  icon: const Icon(Icons.refresh),
                  label: const Text("Cambiar"),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () =>
                      context.read<PocImagesCubit>().confirmImage(),
                  icon: const Icon(Icons.check),
                  label: const Text("Confirmar"),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFE36414),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            )
          else
            const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildDetailsStep(BuildContext context, PocImagesState state, ThemeData theme) {
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
              final cubit = context.read<PocImagesCubit>();
              cubit.savePizzaDetails(title, description);
              cubit.submitPizza();
            },
          ),
        ],
      ),
    );
  }

  void _showExitConfirmationDialog(BuildContext context, ThemeData theme) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "¿Salir del asistente?",
          style: theme.textTheme.displayMedium?.copyWith(
            color: theme.colorScheme.secondary,
            fontSize: 22,
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          "Si sales ahora, perderás el progreso actual de tu pizza. ¿Estás seguro?",
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.secondary.withAlpha(180),
          ),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              "Cancelar",
              style: TextStyle(color: theme.colorScheme.secondary, fontWeight: FontWeight.bold),
            ),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(); // Cierra el diálogo
              Navigator.of(context).pop(); // Vuelve a InitialView
            },
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
            ),
            child: const Text("Salir"),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String errorMessage, ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Column(
          children: [
            Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error, size: 48),
            const SizedBox(height: 16),
            Text(
              "¡Ups, hay un problema!",
              style: theme.textTheme.displayMedium?.copyWith(
                color: theme.colorScheme.secondary,
                fontSize: 22,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Text(
          errorMessage,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.secondary,
          ),
          textAlign: TextAlign.center,
        ),
        actions: [
          Center(
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text("Entendido"),
            ),
          ),
        ],
      ),
    );
  }
}
