import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/poc_images/poc_images_cubit.dart';

class PizzaDetailsForm extends StatefulWidget {
  const PizzaDetailsForm({super.key});

  @override
  State<PizzaDetailsForm> createState() => _PizzaDetailsFormState();
}

class _PizzaDetailsFormState extends State<PizzaDetailsForm> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedStyle;
  late final TextEditingController _floursController;
  late final TextEditingController _prefermentController;
  late final TextEditingController _prefermentPercentageController;
  late final TextEditingController _hydrationController;
  late final TextEditingController _doughBallWeightController;
  late final TextEditingController _ovenController;
  late final TextEditingController _cookingTemperatureController;

  final List<String> _pizzaStyles = [
    'Contemporánea',
    'Napoletana',
    'New York',
    'Tonda clásica',
    'Tonda romana',
    'Teglia romana',
    'Padellino',
    'Pala romana',
  ];

  @override
  void initState() {
    super.initState();
    final state = context.read<PocImagesCubit>().state;

    _selectedStyle = state.pizzaStyle;
    _floursController = TextEditingController(text: state.flours);
    _prefermentController = TextEditingController(text: state.preferment);
    _prefermentPercentageController = TextEditingController(text: state.prefermentPercentage);
    _hydrationController = TextEditingController(text: state.hydration);
    _doughBallWeightController = TextEditingController(text: state.doughBallWeight);
    _ovenController = TextEditingController(text: state.oven);
    _cookingTemperatureController = TextEditingController(text: state.cookingTemperature);
  }

  @override
  void dispose() {
    _floursController.dispose();
    _prefermentController.dispose();
    _prefermentPercentageController.dispose();
    _hydrationController.dispose();
    _doughBallWeightController.dispose();
    _ovenController.dispose();
    _cookingTemperatureController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      context.read<PocImagesCubit>().savePizzaDetails(
        pizzaStyle: _selectedStyle ?? '',
        flours: _floursController.text,
        preferment: _prefermentController.text,
        prefermentPercentage: _prefermentPercentageController.text,
        hydration: _hydrationController.text,
        doughBallWeight: _doughBallWeightController.text,
        oven: _ovenController.text,
        cookingTemperature: _cookingTemperatureController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final secondaryColor = theme.colorScheme.secondary;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'DETALLES GENERALES',
            style: theme.textTheme.displayMedium?.copyWith(
              color: secondaryColor,
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Estilo de pizza
          _buildDropdownField(
            label: 'Estilo de pizza',
            hint: 'Selecciona estilo',
            value: _selectedStyle,
            items: _pizzaStyles,
            onChanged: (val) => setState(() => _selectedStyle = val),
          ),
          const SizedBox(height: 20),

          // Harinas
          _buildTextField(
            controller: _floursController,
            label: 'Harinas',
            hint: 'Especifica harinas',
          ),
          const SizedBox(height: 20),

          // Prefermento y %
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildTextField(
                  controller: _prefermentController,
                  label: 'Prefermento',
                  hint: 'Selecciona',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _prefermentPercentageController,
                  label: '% Prefermento',
                  hint: '%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Hidratación y Peso bola
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _hydrationController,
                  label: 'Hidratación final',
                  hint: '%',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _doughBallWeightController,
                  label: 'Peso de bola',
                  hint: 'gr',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Horno
          _buildTextField(controller: _ovenController, label: 'Horno', hint: 'Especifica horno'),
          const SizedBox(height: 20),

          // Temperatura
          _buildTextField(
            controller: _cookingTemperatureController,
            label: 'Temperaturas de cocción',
            hint: 'En Cº',
          ),
          const SizedBox(height: 40),

          FilledButton(
            onPressed: _handleSubmit,
            style: FilledButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            child: const Text(
              'Confirmar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return TextFormField(
      controller: controller,
      style: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w400, color: Colors.black),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 3),
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

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      items: items
          .map(
            (e) => DropdownMenuItem(
              value: e,
              child: Text(
                e,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w400, color: Colors.black),
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
      icon: Icon(Icons.keyboard_arrow_down, color: Theme.of(context).colorScheme.primary),
      dropdownColor: Theme.of(context).scaffoldBackgroundColor,
      style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.w500),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 3),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Selecciona uno';
        }
        return null;
      },
    );
  }
}
