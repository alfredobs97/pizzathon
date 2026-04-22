import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizzathon/ui/blocs/poc_images/poc_images_cubit.dart';
import 'package:pizzathon/ui/blocs/poc_images/poc_images_state.dart';
import 'pizza_details_form.dart';
import 'pizza_photo_step_view.dart';
import 'pizza_stepper_widget.dart';
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
          showErrorDialog(context, state.errorMessage!, theme);
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
              icon: Icon(Icons.close, color: theme.colorScheme.secondary, size: 30),
              onPressed: () => showExitConfirmationDialog(context, theme),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Center(child: _buildStepper(context, state, theme)),
              ),
            ],
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
              return PizzaPhotoStepView(
                step: step,
                state: state,
                theme: theme,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStepper(BuildContext context, PocImagesState state, ThemeData theme) {
    final confirmedIndices = state.confirmedImages.keys.map((e) => e.index).toSet();

    return GestureDetector(
      onTap: () => _throwIngredient(),
      child: SizedBox(
        height: 40,
        width: 40,
        child: PizzaStepperWidget(
          currentStep: state.currentStep.index,
          totalSteps: PizzaPhotoStep.values.length,
          confirmedSteps: confirmedIndices,
          activeColor: theme.colorScheme.primary,
          crustColor: const Color(0xFFE0A96D),
          inactiveColor: theme.colorScheme.secondary.withAlpha(40),
        ),
      ),
    );
  }

  void _throwIngredient() {
    final overlayState = Overlay.of(context);
    final ingredients = ['🍕', '🍄', '🧅', '🍅', '🧀', '🫒', '🥓', '🍃', '🔥'];
    final ingredient = ingredients[math.Random().nextInt(ingredients.length)];

    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => _FlyingIngredient(
        ingredient: ingredient,
        onComplete: () => overlayEntry.remove(),
      ),
    );

    overlayState.insert(overlayEntry);
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
}

class _FlyingIngredient extends StatefulWidget {
  final String ingredient;
  final VoidCallback onComplete;

  const _FlyingIngredient({required this.ingredient, required this.onComplete});

  @override
  State<_FlyingIngredient> createState() => _FlyingIngredientState();
}

class _FlyingIngredientState extends State<_FlyingIngredient>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _xAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _xAnimation = Tween<double>(begin: -0.2, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 6 * math.pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = _controller.value;
        // Parábola para el efecto de lanzamiento: y = 4 * h * x * (1 - x)
        // h es la altura máxima del arco
        final arcHeight = size.height * 0.4;
        final yOffset = progress < 1.0 ? (math.sin(progress * math.pi) * -arcHeight) : 0.0;

        final xPos = size.width * _xAnimation.value;
        final yPos = (size.height * 0.5) + yOffset;

        return Positioned(
          left: xPos,
          top: yPos,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: Material(
              color: Colors.transparent,
              child: Text(
                widget.ingredient,
                style: const TextStyle(fontSize: 40),
              ),
            ),
          ),
        );
      },
    );
  }
}
