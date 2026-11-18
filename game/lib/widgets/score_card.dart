import 'package:flutter/material.dart';

import '../app_theme.dart';

/// Cuadro pequeño con una etiqueta y un valor (puntos, mejor, movimientos, tiempo)
class ScoreCard extends StatelessWidget {
  final String etiqueta;
  final String valor;

  const ScoreCard({super.key, required this.etiqueta, required this.valor});

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;

    return Container(
      constraints: const BoxConstraints(minWidth: 90),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.espacio,
        vertical: AppTheme.espacioPequeno,
      ),
      decoration: BoxDecoration(
        color: colores.primaryContainer,
        borderRadius: BorderRadius.circular(AppTheme.radio),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            etiqueta,
            style: AppTheme.etiquetaMarcador
                .copyWith(color: colores.onPrimaryContainer),
          ),
          Text(
            valor,
            style: AppTheme.valorMarcador
                .copyWith(color: colores.onPrimaryContainer),
          ),
        ],
      ),
    );
  }
}
