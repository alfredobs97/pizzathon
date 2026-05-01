import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/poc_images/poc_images_cubit.dart';

class PizzaIngredientsStep extends StatefulWidget {
  const PizzaIngredientsStep({super.key});

  @override
  State<PizzaIngredientsStep> createState() => _PizzaIngredientsStepState();
}

class _PizzaIngredientsStepState extends State<PizzaIngredientsStep> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _baseIngredientController;
  late final TextEditingController _otherIngredientsController;

  @override
  void initState() {
    super.initState();
    final state = context.read<PocImagesCubit>().state;
    _baseIngredientController = TextEditingController(
      text: state.baseIngredient,
    );
    _otherIngredientsController = TextEditingController(
      text: state.otherIngredients,
    );
  }

  @override
  void dispose() {
    _baseIngredientController.dispose();
    _otherIngredientsController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      context.read<PocImagesCubit>().saveIngredients(
        baseIngredient: _baseIngredientController.text,
        otherIngredients: _otherIngredientsController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final secondaryColor = theme.colorScheme.secondary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'INGREDIENTES',
              style: theme.textTheme.displayMedium?.copyWith(
                color: secondaryColor,
                fontWeight: FontWeight.w900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildTextField(
              controller: _baseIngredientController,
              label: 'Ingrediente base',
              hint: 'Detalla ingrediente base',
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _otherIngredientsController,
              label: 'Resto de ingredientes',
              hint: 'Detalla todos los ingredientes',
              maxLines: 5,
            ),
            const SizedBox(height: 40),
            FilledButton(
              onPressed: _handleSubmit,
              style: FilledButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                'Confirmar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w400,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        hintText: hint,
        hintStyle: TextStyle(
          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.4),
          fontWeight: FontWeight.w400,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 3,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 3),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Obligatorio';
        }
        return null;
      },
    );
  }
}
