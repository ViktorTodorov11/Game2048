import 'package:flutter/material.dart';

import '../app_theme.dart';

/// Mensaje con icono para cuando no hay datos que mostrar
class EmptyStateView extends StatelessWidget {
  final IconData icono;
  final String mensaje;

  const EmptyStateView({super.key, required this.icono, required this.mensaje});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.espacio * 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 64, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: AppTheme.espacio),
            Text(mensaje, textAlign: TextAlign.center, style: AppTheme.subtitulo),
          ],
        ),
      ),
    );
  }
}
