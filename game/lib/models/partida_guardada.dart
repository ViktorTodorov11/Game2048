import 'dart:convert';

/// La partida en curso. En la tabla solo hay una fila (id = 1).
class PartidaGuardada {
  final List<int> tablero; // 16 valores
  final int puntuacion;
  final int movimientos;
  final int segundos;

  const PartidaGuardada({
    required this.tablero,
    required this.puntuacion,
    required this.movimientos,
    required this.segundos,
  });

  Map<String, Object?> toMap() {
    return {
      'id': 1,
      'tablero': jsonEncode(tablero), // lista -> texto JSON
      'puntuacion': puntuacion,
      'movimientos': movimientos,
      'segundos_transcurridos': segundos,
    };
  }

  factory PartidaGuardada.fromMap(Map<String, Object?> m) {
    return PartidaGuardada(
      tablero: List<int>.from(jsonDecode(m['tablero'] as String)), // texto -> lista
      puntuacion: m['puntuacion'] as int,
      movimientos: m['movimientos'] as int,
      segundos: m['segundos_transcurridos'] as int,
    );
  }
}
