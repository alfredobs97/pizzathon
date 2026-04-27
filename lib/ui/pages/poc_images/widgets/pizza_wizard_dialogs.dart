import 'package:flutter/material.dart';

void showExitConfirmationDialog(BuildContext context, ThemeData theme) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      contentPadding: const EdgeInsets.all(24.0),
      content: Text(
        "Si cierras se borrará toda la información de tu pizza\n ¿Seguro quieres cerrar?",
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.secondary,
        ),
        textAlign: TextAlign.center,
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(
            "Volver a pizza",
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
          child: const Text("Cerrar"),
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
              backgroundColor: theme.colorScheme.secondary,
              padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 12),
            ),
            child: const Text("Ok"),
          ),
        ),
      ],
    ),
  );
}
