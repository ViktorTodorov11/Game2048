import 'package:sqflite/sqflite.dart';

import '../models/partida_guardada.dart';
import 'database_helper.dart';

class PartidaGuardadaDao {
  /// Guarda la partida en curso (siempre en la fila con id = 1)
  Future<void> guardar(PartidaGuardada p) async {
    final db = await DatabaseHelper.instancia.database;
    await db.insert('partida_guardada', p.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Devuelve la partida guardada, o null si no hay ninguna
  Future<PartidaGuardada?> obtener() async {
    final db = await DatabaseHelper.instancia.database;
    final filas = await db.query('partida_guardada',
        where: 'id = ?', whereArgs: [1], limit: 1);
    if (filas.isEmpty) return null;
    return PartidaGuardada.fromMap(filas.first);
  }

  Future<void> borrar() async {
    final db = await DatabaseHelper.instancia.database;
    await db.delete('partida_guardada', where: 'id = ?', whereArgs: [1]);
  }
}
