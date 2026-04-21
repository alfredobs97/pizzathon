import 'package:flutter/material.dart';

class PizzaDetailsForm extends StatefulWidget {
  final Function(String title, String description) onSubmit;

  const PizzaDetailsForm({super.key, required this.onSubmit});

  @override
  State<PizzaDetailsForm> createState() => _PizzaDetailsFormState();
}

class _PizzaDetailsFormState extends State<PizzaDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(
        _titleController.text, 
        _descriptionController.text
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Cuéntanos sobre tu creación',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _titleController,
            style: TextStyle(color: theme.colorScheme.secondary), 
            decoration: InputDecoration(
              labelText: 'Título de la pizza',
              labelStyle: TextStyle(color: theme.colorScheme.secondary.withOpacity(0.8)),
              hintText: 'Ej: La Diabólica de Caputo',
              hintStyle: TextStyle(color: theme.colorScheme.secondary.withOpacity(0.6)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El título es obligatorio.';
              }
              if (value.length < 5) {
                return 'El título debe tener al menos 5 caracteres.';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          TextFormField(
            controller: _descriptionController,
            maxLines: 5,
            style: TextStyle(color: theme.colorScheme.secondary),
            decoration: InputDecoration(
              labelText: 'Proceso y detalles',
              labelStyle: TextStyle(color: theme.colorScheme.secondary.withOpacity(0.8)),
              hintText: 'Describe cómo hiciste la masa, qué ingredientes usaste y cuánto tiempo estuvo en el horno...',
              hintStyle: TextStyle(color: theme.colorScheme.secondary.withOpacity(0.6)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
              ),
              alignLabelWithHint: true,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Por favor, describe un poco tu proceso.';
              }
              if (value.length < 20) {
                return 'Cuéntanos un poco más (mínimo 20 caracteres).';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),

          FilledButton(
            onPressed: _handleSubmit,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Enviar Participación',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
 