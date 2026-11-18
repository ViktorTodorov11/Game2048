import 'package:flutter/material.dart';

import '../models/partida.dart';

/// Una fila de partida (se usa en Historial y en Ranking)
class PartidaListItem extends StatelessWidget {
  final Partida partida;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const PartidaListItem({
    super.key,
    required this.partida,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      onLongPress: onLongPress,
      leading: CircleAvatar(
        child: Text('${partida.fichaMaxima}', style: const TextStyle(fontSize: 12)),
      ),
      title: Text('${partida.puntuacion} puntos - ${partida.usuario}'),
      subtitle: Text(
        '${partida.fechaBonita}  |  ${partida.movimientos} mov.  |  ${partida.duracionTexto}',
      ),
    );
  }
}
