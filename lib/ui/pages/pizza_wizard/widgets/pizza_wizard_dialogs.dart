import 'package:flutter/material.dart';

Future<bool> showExitConfirmationDialog(BuildContext context) async {
  final theme = Theme.of(context);
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      contentPadding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
      content: Text(
        "Si cierras se borrará toda la información de tu pizza\n ¿Seguro quieres cerrar?",
        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.secondary),
        textAlign: TextAlign.center,
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        SizedBox(
          height: 56,
          child: TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              "Volver a pizza",
              style: TextStyle(color: theme.colorScheme.secondary, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SizedBox(
          height: 56,
          width: 100,
          child: FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: theme.colorScheme.primary),
            child: const Text("Cerrar"),
          ),
        ),
      ],
    ),
  );
  return result ?? false;
}

void showErrorDialog(BuildContext context, String errorMessage, ThemeData theme) {
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
            "Hay un problema",
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
        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.secondary),
        textAlign: TextAlign.center,
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            style: FilledButton.styleFrom(backgroundColor: theme.colorScheme.secondary),
            child: const Text("Ok"),
          ),
        ),
      ],
    ),
  );
}
