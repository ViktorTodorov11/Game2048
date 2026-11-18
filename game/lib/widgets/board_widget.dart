import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../models/juego2048.dart';
import 'tile_widget.dart';

/// El tablero 4x4 con detección de gestos (deslizar con el dedo).
/// Es StatefulWidget porque guarda cuánto se ha movido el dedo.
class BoardWidget extends StatefulWidget {
  final List<int> tablero; // 16 valores
  final double lado; // tamaño del cuadrado en píxeles
  final void Function(Direccion) onMover;

  const BoardWidget({
    super.key,
    required this.tablero,
    required this.lado,
    required this.onMover,
  });

  @override
  State<BoardWidget> createState() => _BoardWidgetState();
}

class _BoardWidgetState extends State<BoardWidget> {
  // Desplazamiento acumulado del dedo desde que empezó el gesto
  double _dx = 0;
  double _dy = 0;

  void _detectarDireccion() {
    // Si el dedo se ha movido muy poco, no cuenta como deslizamiento
    if (_dx.abs() < AppTheme.umbralGesto && _dy.abs() < AppTheme.umbralGesto) {
      return;
    }

    // Gana el eje en el que el dedo se ha movido más (dirección dominante)
    if (_dx.abs() > _dy.abs()) {
      widget.onMover(_dx > 0 ? Direccion.derecha : Direccion.izquierda);
    } else {
      widget.onMover(_dy > 0 ? Direccion.abajo : Direccion.arriba);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).extension<ColoresFicha>()!;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: (_) {
        _dx = 0;
        _dy = 0;
      },
      onPanUpdate: (detalles) {
        _dx += detalles.delta.dx;
        _dy += detalles.delta.dy;
      },
      onPanEnd: (_) => _detectarDireccion(),
      child: Container(
        width: widget.lado,
        height: widget.lado,
        padding: const EdgeInsets.all(AppTheme.margenFicha),
        decoration: BoxDecoration(
          color: colores.fondoTablero,
          borderRadius: BorderRadius.circular(AppTheme.radio),
        ),
        child: GridView.count(
          crossAxisCount: 4,
          padding: EdgeInsets.zero,
          // Sin scroll, para que no se coma los gestos
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (final valor in widget.tablero) TileWidget(valor: valor),
          ],
        ),
      ),
    );
  }
}
