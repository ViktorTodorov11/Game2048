/// Pasa segundos a texto mm:ss (por ejemplo 75 -> 01:15)
String formatoTiempo(int segundos) {
  final m = (segundos ~/ 60).toString().padLeft(2, '0');
  final s = (segundos % 60).toString().padLeft(2, '0');
  return '$m:$s';
}

/// Una partida terminada (fila de la tabla partidas)
class Partida {
  final int? id;
  final String usuario;
  final int puntuacion;
  final int fichaMaxima;
  final int movimientos;
  final int duracionSegundos;
  final String fecha; // ISO 8601
  final int tamanoTablero; // columna añadida en la versión 2 de la BD

  const Partida({
    this.id,
    required this.usuario,
    required this.puntuacion,
    required this.fichaMaxima,
    required this.movimientos,
    required this.duracionSegundos,
    required this.fecha,
    this.tamanoTablero = 4,
  });

  Map<String, Object?> toMap() {
    final mapa = <String, Object?>{
      'usuario': usuario,
      'puntuacion': puntuacion,
      'ficha_maxima': fichaMaxima,
      'movimientos': movimientos,
      'duracion_segundos': duracionSegundos,
      'fecha': fecha,
      'tamano_tablero': tamanoTablero,
    };
    // Si no tiene id dejamos que SQLite lo genere solo.
    // Si lo tiene (por ejemplo al deshacer un borrado) lo conservamos.
    if (id != null) mapa['id'] = id;
    return mapa;
  }

  factory Partida.fromMap(Map<String, Object?> m) {
    return Partida(
      id: m['id'] as int?,
      usuario: m['usuario'] as String,
      puntuacion: m['puntuacion'] as int,
      fichaMaxima: m['ficha_maxima'] as int,
      movimientos: m['movimientos'] as int,
      duracionSegundos: m['duracion_segundos'] as int,
      fecha: m['fecha'] as String,
      tamanoTablero: (m['tamano_tablero'] as int?) ?? 4,
    );
  }

  /// Fecha en formato dd/mm/aaaa hh:mm para mostrarla en pantalla
  String get fechaBonita {
    final d = DateTime.parse(fecha);
    String dos(int n) => n.toString().padLeft(2, '0');
    return '${dos(d.day)}/${dos(d.month)}/${d.year} ${dos(d.hour)}:${dos(d.minute)}';
  }

  String get duracionTexto => formatoTiempo(duracionSegundos);
}
