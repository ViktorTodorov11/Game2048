import 'dart:math';

import 'package:flutter/material.dart';

/// Colores de las fichas. Van dentro del tema (ThemeExtension) para que
/// cambien solos al pasar de modo claro a oscuro.
class ColoresFicha extends ThemeExtension<ColoresFicha> {
  final Color inicio; // color de la ficha de valor 2
  final Color fin; // color de la ficha de valor 2048
  final Color fondoTablero;
  final Color celdaVacia;

  const ColoresFicha({
    required this.inicio,
    required this.fin,
    required this.fondoTablero,
    required this.celdaVacia,
  });

  /// Color de una ficha: mezcla entre "inicio" y "fin" según su valor.
  /// 2 -> casi "inicio", 2048 -> "fin".
  Color colorDe(int valor) {
    if (valor == 0) return celdaVacia;
    final t = ((log(valor) / ln2) - 1) / 10; // log2(2)=1 ... log2(2048)=11
    return Color.lerp(inicio, fin, max(0.0, min(1.0, t)))!;
  }

  @override
  ColoresFicha copyWith(
      {Color? inicio, Color? fin, Color? fondoTablero, Color? celdaVacia}) {
    return ColoresFicha(
      inicio: inicio ?? this.inicio,
      fin: fin ?? this.fin,
      fondoTablero: fondoTablero ?? this.fondoTablero,
      celdaVacia: celdaVacia ?? this.celdaVacia,
    );
  }

  @override
  ColoresFicha lerp(ThemeExtension<ColoresFicha>? other, double t) {
    if (other is! ColoresFicha) return this;
    return ColoresFicha(
      inicio: Color.lerp(inicio, other.inicio, t)!,
      fin: Color.lerp(fin, other.fin, t)!,
      fondoTablero: Color.lerp(fondoTablero, other.fondoTablero, t)!,
      celdaVacia: Color.lerp(celdaVacia, other.celdaVacia, t)!,
    );
  }
}

/// Constantes visuales y temas de la app. Ningún color ni tamaño
/// se escribe a mano en las pantallas.
class AppTheme {
  // Espaciados
  static const double espacio = 16;
  static const double espacioPequeno = 8;

  // Tamaños
  static const double radio = 12;
  static const double radioFicha = 8;
  static const double margenFicha = 4;
  static const double ladoMaximoTablero = 420;

  // Gestos y animaciones
  static const double umbralGesto = 20; // píxeles mínimos para contar un swipe
  static const Duration duracionAnimacion = Duration(milliseconds: 180);

  // Estilos de texto
  static const TextStyle tituloJuego =
      TextStyle(fontSize: 56, fontWeight: FontWeight.bold);
  static const TextStyle subtitulo = TextStyle(fontSize: 18);
  static const TextStyle etiquetaMarcador =
      TextStyle(fontSize: 12, fontWeight: FontWeight.w600);
  static const TextStyle valorMarcador =
      TextStyle(fontSize: 22, fontWeight: FontWeight.bold);

  // Paletas de color de las fichas (se elige en Ajustes)
  static const List<String> nombresPaletas = ['Naranja', 'Azul', 'Verde'];
  static const List<Color> _coloresPaleta = [
    Color(0xFFEC8D3C),
    Color(0xFF2E7BD6),
    Color(0xFF2E9E5B),
  ];

  /// Crea el tema claro u oscuro con la paleta elegida.
  static ThemeData construir(Brightness brillo, int paleta) {
    final oscuro = brillo == Brightness.dark;
    final base = _coloresPaleta[paleta];

    final fichas = ColoresFicha(
      inicio: oscuro ? const Color(0xFF4A4F5C) : const Color(0xFFEEE4DA),
      fin: base,
      fondoTablero: oscuro ? const Color(0xFF22252D) : const Color(0xFFBBADA0),
      celdaVacia: oscuro ? const Color(0xFF343944) : const Color(0xFFCDC1B4),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: base, brightness: brillo),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radio)),
        ),
      ),
      extensions: [fichas],
    );
  }
}
