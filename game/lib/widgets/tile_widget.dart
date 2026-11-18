import 'package:flutter/material.dart';

import '../app_theme.dart';

/// Una ficha del tablero (o una celda vacía si el valor es 0).
/// El color sale del tema, no está escrito a mano.
class TileWidget extends StatelessWidget {
  final int valor;

  const TileWidget({super.key, required this.valor});

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).extension<ColoresFicha>()!;
    final fondo = colores.colorDe(valor);
    // Si el fondo es claro usamos texto oscuro y al revés
    final colorTexto = fondo.computeLuminance() > 0.5 ? Colors.black87 : Colors.white;

    // Tamaño de letra más pequeño cuando el número tiene más cifras
    double tamanoLetra = 28;
    if (valor >= 100) tamanoLetra = 24;
    if (valor >= 1000) tamanoLetra = 19;

    return AnimatedContainer(
      duration: AppTheme.duracionAnimacion,
      margin: const EdgeInsets.all(AppTheme.margenFicha),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(AppTheme.radioFicha),
      ),
      // Cuando cambia el número, el texto nuevo aparece con una animación de escala
      child: AnimatedSwitcher(
        duration: AppTheme.duracionAnimacion,
        transitionBuilder: (child, animacion) =>
            ScaleTransition(scale: animacion, child: child),
        child: valor == 0
            ? const SizedBox.shrink(key: ValueKey(0))
            : Text(
                '$valor',
                key: ValueKey(valor),
                style: TextStyle(
                  fontSize: tamanoLetra,
                  fontWeight: FontWeight.bold,
                  color: colorTexto,
                ),
              ),
      ),
    );
  }
}
