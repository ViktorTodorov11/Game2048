import 'dart:math';

enum Direccion { arriba, abajo, izquierda, derecha }

/// Lógica del 2048. El tablero es una lista de 16 números (4 filas x 4 columnas):
/// la posición de la fila f y la columna c es f * 4 + c. El 0 es una celda vacía.
class Juego2048 {
  List<int> tablero;
  int puntuacion;
  int movimientos;
  final Random _azar = Random();

  /// Partida nueva con dos fichas
  Juego2048()
      : tablero = List.filled(16, 0),
        puntuacion = 0,
        movimientos = 0 {
    _nuevaFicha();
    _nuevaFicha();
  }

  /// Partida recuperada de la base de datos
  Juego2048.desde(List<int> tableroGuardado, this.puntuacion, this.movimientos)
      : tablero = List.of(tableroGuardado);

  int get fichaMaxima => tablero.reduce(max);

  /// La partida acaba cuando no quedan huecos y no se puede fusionar nada
  bool get terminado {
    if (tablero.contains(0)) return false;
    for (int f = 0; f < 4; f++) {
      for (int c = 0; c < 4; c++) {
        final v = tablero[f * 4 + c];
        if (c < 3 && v == tablero[f * 4 + c + 1]) return false;
        if (f < 3 && v == tablero[(f + 1) * 4 + c]) return false;
      }
    }
    return true;
  }

  /// Mueve las fichas. Devuelve true si el tablero ha cambiado.
  bool mover(Direccion d) {
    bool seMovio = false;

    // Procesamos las 4 líneas (filas o columnas según la dirección)
    for (int i = 0; i < 4; i++) {
      final indices = _indicesLinea(i, d);
      final linea = indices.map((x) => tablero[x]).toList();
      final nueva = _mezclarLinea(linea);

      for (int j = 0; j < 4; j++) {
        if (tablero[indices[j]] != nueva[j]) seMovio = true;
        tablero[indices[j]] = nueva[j];
      }
    }

    if (seMovio) {
      movimientos++;
      _nuevaFicha();
    }
    return seMovio;
  }

  /// Posiciones de una línea ordenadas de forma que las fichas siempre
  /// se "pegan" al principio de la lista. Así solo hay que programar
  /// el movimiento hacia un lado.
  List<int> _indicesLinea(int i, Direccion d) {
    switch (d) {
      case Direccion.izquierda:
        return [i * 4, i * 4 + 1, i * 4 + 2, i * 4 + 3];
      case Direccion.derecha:
        return [i * 4 + 3, i * 4 + 2, i * 4 + 1, i * 4];
      case Direccion.arriba:
        return [i, 4 + i, 8 + i, 12 + i];
      case Direccion.abajo:
        return [12 + i, 8 + i, 4 + i, i];
    }
  }

  /// Junta las fichas de una línea hacia el principio y fusiona las iguales
  List<int> _mezclarLinea(List<int> linea) {
    final sinCeros = linea.where((v) => v != 0).toList();
    final resultado = <int>[];

    int i = 0;
    while (i < sinCeros.length) {
      if (i + 1 < sinCeros.length && sinCeros[i] == sinCeros[i + 1]) {
        final suma = sinCeros[i] * 2;
        resultado.add(suma);
        puntuacion += suma; // al fusionar se suma el valor nuevo
        i += 2; // saltamos las dos fichas fusionadas
      } else {
        resultado.add(sinCeros[i]);
        i++;
      }
    }

    // Rellenamos con ceros hasta tener 4
    while (resultado.length < 4) {
      resultado.add(0);
    }
    return resultado;
  }

  /// Pone un 2 (90%) o un 4 (10%) en una celda vacía al azar
  void _nuevaFicha() {
    final vacias = <int>[];
    for (int i = 0; i < 16; i++) {
      if (tablero[i] == 0) vacias.add(i);
    }
    if (vacias.isEmpty) return;
    final posicion = vacias[_azar.nextInt(vacias.length)];
    tablero[posicion] = _azar.nextInt(10) == 0 ? 4 : 2;
  }
}
