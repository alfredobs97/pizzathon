import 'package:flutter/material.dart';

void showExitConfirmationDialog(BuildContext context, ThemeData theme) {
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
            style: TextStyle(
              color: theme.colorScheme.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(dialogContext).pop();
            Navigator.of(context).pop();
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

void showErrorDialog(
  BuildContext context,
  String errorMessage,
  ThemeData theme,
) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Column(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: theme.colorScheme.error,
            size: 48,
          ),
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
