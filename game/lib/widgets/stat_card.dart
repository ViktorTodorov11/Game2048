import 'package:flutter/material.dart';

import '../app_theme.dart';

/// Tarjeta con un icono, un título y un valor (se usa en Ranking y en Detalle)
class StatCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icono;

  const StatCard({
    super.key,
    required this.titulo,
    required this.valor,
    required this.icono,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icono),
        title: Text(titulo),
        trailing: Text(valor, style: AppTheme.valorMarcador),
      ),
    );
  }
}
