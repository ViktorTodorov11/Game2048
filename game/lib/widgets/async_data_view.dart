import 'package:flutter/material.dart';

import '../app_theme.dart';

/// Envuelve un FutureBuilder y gestiona los tres estados:
/// cargando, error (con botón Reintentar) y datos.
/// Así no repetimos el mismo código en cada pantalla.
class AsyncDataView<T> extends StatelessWidget {
  final Future<T> future;
  final Widget Function(BuildContext context, T datos) builder;
  final VoidCallback onReintentar;

  const AsyncDataView({
    super.key,
    required this.future,
    required this.builder,
    required this.onReintentar,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        // 1. Cargando
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        // 2. Error
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.espacio),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: AppTheme.espacioPequeno),
                  Text('Ha ocurrido un error:\n${snapshot.error}',
                      textAlign: TextAlign.center),
                  const SizedBox(height: AppTheme.espacio),
                  FilledButton(
                      onPressed: onReintentar, child: const Text('Reintentar')),
                ],
              ),
            ),
          );
        }

        // 3. Datos
        return builder(context, snapshot.data as T);
      },
    );
  }
}
