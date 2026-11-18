import 'package:sqflite/sqflite.dart';

import '../models/partida.dart';
import 'database_helper.dart';

/// Todas las consultas SQL de las partidas están aquí.
/// Las pantallas nunca escriben SQL.
class PartidaDao {
  Future<Database> get _db => DatabaseHelper.instancia.database;

  /// Inserta una partida en el historial. Si ya existe ese id la reemplaza
  /// (así sirve también para "deshacer" un borrado).
  Future<int> insertar(Partida p) async {
    final db = await _db;
    return db.insert('partidas', p.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Fin de partida con TRANSACCIÓN: o se hacen las dos cosas
  /// (guardar en el historial y borrar la partida en curso) o ninguna.
  Future<void> finalizarPartida(Partida p) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.insert('partidas', p.toMap());
      await txn.delete('partida_guardada', where: 'id = ?', whereArgs: [1]);
    });
  }

  /// Historial ordenado por fecha descendente, con filtros opcionales.
  /// El "where" solo contiene trozos fijos con "?", los valores van en whereArgs.
  Future<List<Partida>> listar({String? usuario, int? fichaMinima}) async {
    final db = await _db;
    final condiciones = <String>[];
    final argumentos = <Object?>[];

    if (usuario != null && usuario.isNotEmpty) {
      condiciones.add('usuario LIKE ?');
      argumentos.add('%$usuario%');
    }
    if (fichaMinima != null && fichaMinima > 0) {
      condiciones.add('ficha_maxima >= ?');
      argumentos.add(fichaMinima);
    }

    final filas = await db.query(
      'partidas',
      where: condiciones.isEmpty ? null : condiciones.join(' AND '),
      whereArgs: argumentos.isEmpty ? null : argumentos,
      orderBy: 'fecha DESC',
    );
    return filas.map((f) => Partida.fromMap(f)).toList();
  }

  /// Detalle de una partida por id (null si no existe)
  Future<Partida?> obtenerPorId(int id) async {
    final db = await _db;
    final filas =
        await db.query('partidas', where: 'id = ?', whereArgs: [id], limit: 1);
    if (filas.isEmpty) return null;
    return Partida.fromMap(filas.first);
  }

  Future<void> eliminar(int id) async {
    final db = await _db;
    await db.delete('partidas', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> eliminarTodas() async {
    final db = await _db;
    await db.delete('partidas');
  }

  /// Top 10 por puntuación
  Future<List<Partida>> ranking() async {
    final db = await _db;
    final filas =
        await db.query('partidas', orderBy: 'puntuacion DESC', limit: 10);
    return filas.map((f) => Partida.fromMap(f)).toList();
  }

  /// Estadísticas globales con COUNT, MAX, AVG y SUM.
  /// Si no hay partidas, MAX/AVG/SUM salen null.
  Future<Map<String, Object?>> estadisticasGlobales() async {
    final db = await _db;
    final filas = await db.rawQuery('''
      SELECT COUNT(*) AS total,
             MAX(puntuacion) AS maxima,
             AVG(puntuacion) AS media,
             MAX(ficha_maxima) AS ficha,
             SUM(duracion_segundos) AS tiempo
      FROM partidas
    ''');
    return filas.first;
  }

  /// Mejor puntuación y nº de partidas de cada jugador (GROUP BY)
  Future<List<Map<String, Object?>>> estadisticasPorJugador() async {
    final db = await _db;
    return db.rawQuery('''
      SELECT usuario, MAX(puntuacion) AS mejor, COUNT(*) AS partidas
      FROM partidas
      GROUP BY usuario
      ORDER BY mejor DESC
    ''');
  }
}
