import 'package:flutter/material.dart';

class PizzaDetailsForm extends StatefulWidget {
  final String? initialPizzaStyle;
  final String? initialFlours;
  final String? initialPreferment;
  final String? initialPrefermentPercentage;
  final String? initialHydration;
  final String? initialDoughBallWeight;
  final String? initialOven;
  final String? initialCookingTemperature;

  final Function({
    required String pizzaStyle,
    required String flours,
    required String preferment,
    required String prefermentPercentage,
    required String hydration,
    required String doughBallWeight,
    required String oven,
    required String cookingTemperature,
  }) onSubmit;

  const PizzaDetailsForm({
    super.key,
    this.initialPizzaStyle,
    this.initialFlours,
    this.initialPreferment,
    this.initialPrefermentPercentage,
    this.initialHydration,
    this.initialDoughBallWeight,
    this.initialOven,
    this.initialCookingTemperature,
    required this.onSubmit,
  });

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
    _selectedStyle = widget.initialPizzaStyle;
    _floursController = TextEditingController(text: widget.initialFlours);
    _prefermentController = TextEditingController(text: widget.initialPreferment);
    _prefermentPercentageController = TextEditingController(text: widget.initialPrefermentPercentage);
    _hydrationController = TextEditingController(text: widget.initialHydration);
    _doughBallWeightController = TextEditingController(text: widget.initialDoughBallWeight);
    _ovenController = TextEditingController(text: widget.initialOven);
    _cookingTemperatureController = TextEditingController(text: widget.initialCookingTemperature);
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
      widget.onSubmit(
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
            primaryColor: primaryColor,
            secondaryColor: secondaryColor,
          ),
          const SizedBox(height: 20),

          // Harinas
          _buildTextField(
            controller: _floursController,
            label: 'Harinas',
            hint: 'Especifica harinas',
            primaryColor: primaryColor,
            secondaryColor: secondaryColor,
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
                  primaryColor: primaryColor,
                  secondaryColor: secondaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _prefermentPercentageController,
                  label: '% Prefermento',
                  hint: '%',
                  primaryColor: primaryColor,
                  secondaryColor: secondaryColor,
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
                  primaryColor: primaryColor,
                  secondaryColor: secondaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _doughBallWeightController,
                  label: 'Peso de bola',
                  hint: 'gr',
                  primaryColor: primaryColor,
                  secondaryColor: secondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Horno
          _buildTextField(
            controller: _ovenController,
            label: 'Horno',
            hint: 'Especifica horno',
            primaryColor: primaryColor,
            secondaryColor: secondaryColor,
          ),
          const SizedBox(height: 20),

          // Temperatura
          _buildTextField(
            controller: _cookingTemperatureController,
            label: 'Temperaturas de cocción',
            hint: 'En Cº',
            primaryColor: primaryColor,
            secondaryColor: secondaryColor,
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required Color primaryColor,
    required Color secondaryColor,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: secondaryColor, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: secondaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        hintText: hint,
        hintStyle: TextStyle(
          color: secondaryColor.withValues(alpha: 0.4),
          fontWeight: FontWeight.w400,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 3),
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
    required Color primaryColor,
    required Color secondaryColor,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      items: items
          .map((e) => DropdownMenuItem(
                value: e,
                child: Text(
                  e,
                  style: TextStyle(
                    color: secondaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ))
          .toList(),
      onChanged: onChanged,
      icon: Icon(Icons.keyboard_arrow_down, color: primaryColor),
      dropdownColor: const Color(0xFFF8EEE3),
      style: TextStyle(color: secondaryColor, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: secondaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        hintText: hint,
        hintStyle: TextStyle(
          color: secondaryColor.withValues(alpha: 0.4),
          fontWeight: FontWeight.w400,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 3),
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
