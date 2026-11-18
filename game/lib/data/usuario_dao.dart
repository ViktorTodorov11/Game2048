import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import '../models/usuario.dart';
import 'database_helper.dart';

class UsuarioDao {
  /// Registra un usuario nuevo. Lanza una Exception si el usuario o el email ya existen.
  Future<void> registrar(String usuario, String email, String password) async {
    final db = await DatabaseHelper.instancia.database;

    final existe = await db.query(
      'usuarios',
      where: 'usuario = ? OR email = ?',
      whereArgs: [usuario, email],
      limit: 1,
    );
    if (existe.isNotEmpty) {
      throw Exception('El usuario o el email ya están registrados');
    }

    final sal = _generarSal();
    final nuevo = Usuario(
      usuario: usuario,
      fechaRegistro: DateTime.now().toIso8601String(),
      email: email,
      contrasena: '$sal:${_hash(sal, password)}',
    );
    await db.insert('usuarios', nuevo.toMap());
  }

  /// Devuelve true si el usuario existe y la contraseña es correcta
  Future<bool> login(String usuario, String password) async {
    final db = await DatabaseHelper.instancia.database;

    final filas = await db.query(
      'usuarios',
      where: 'usuario = ?',
      whereArgs: [usuario],
      limit: 1,
    );
    if (filas.isEmpty) return false;

    final guardada = Usuario.fromMap(filas.first).contrasena;
    final partes = guardada.split(':'); // [sal, hash]
    return _hash(partes[0], password) == partes[1];
  }

  // La contraseña se guarda con SHA-256 y una sal aleatoria distinta
  // para cada usuario. Nunca se guarda en claro.
  String _hash(String sal, String password) {
    return sha256.convert(utf8.encode(sal + password)).toString();
  }

  String _generarSal() {
    final azar = Random.secure();
    final bytes = List<int>.generate(16, (_) => azar.nextInt(256));
    return base64Encode(bytes);
  }
}
