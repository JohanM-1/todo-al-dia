// lib/core/error/app_error_handler.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../errors/failures.dart';

/// Global error handler that provides user-friendly error messages in Spanish
/// and a fallback widget for uncaught exceptions.
class AppErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is Failure) {
      return _getFailureMessage(error);
    }

    if (error is Exception) {
      return _getExceptionMessage(error);
    }

    return 'Ocurrió un error inesperado. Por favor, intentá de nuevo.';
  }

  static String _getFailureMessage(Failure failure) {
    switch (failure) {
      case DatabaseFailure():
        return 'Error de base de datos. Por favor, reiniciá la app.';
      case VoiceFailure():
        return 'Error con el reconocimiento de voz. Probá usar el teclado.';
      case ValidationFailure():
        return failure.message;
      case ExportFailure():
        return 'Error al exportar. Verificá el almacenamiento.';
      case PermissionFailure():
        return 'Permiso requerido. Otorgalo en configuración.';
      default:
        return 'Ocurrió un error. Por favor, intentá de nuevo.';
    }
  }

  static String _getExceptionMessage(Exception error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('database') || errorString.contains('hive')) {
      return 'Error de base de datos. Por favor, reiniciá la app.';
    }

    if (errorString.contains('speech') || errorString.contains('voice')) {
      return 'Error con el reconocimiento de voz. Probá usar el teclado.';
    }

    if (errorString.contains('permission')) {
      return 'Permiso requerido. Otorgalo en configuración.';
    }

    if (errorString.contains('network') || errorString.contains('internet')) {
      return 'Sin conexión a internet.';
    }

    return 'Ocurrió un error. Por favor, intentá de nuevo.';
  }

  static void showErrorSnackBar(BuildContext context, dynamic error) {
    final message = getErrorMessage(error);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Cerrar',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  static void showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue[700],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[700],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Builds the fallback widget shown when an uncaught error occurs.
  static Widget buildErrorWidget(FlutterErrorDetails details) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Algo salió mal',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ha ocurrido un error inesperado. Por favor, intenta reiniciar la aplicación.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (kDebugMode) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SelectableText(
                        details.exceptionAsString(),
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  FilledButton.icon(
                    onPressed: () {
                      // ignore: avoid_print
                      print(details.exceptionAsString());
                    },
                    icon: const Icon(Icons.bug_report),
                    label: const Text('Ver detalles'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
