import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Abre la base de datos game2048.db. Es un singleton: solo existe
/// una instancia en toda la app (DatabaseHelper.instancia).
class DatabaseHelper {
  static final DatabaseHelper instancia = DatabaseHelper._interno();
  DatabaseHelper._interno();

  static const int _version = 2;
  Future<Database>? _futuroDb;

  Future<Database> get database {
    // Guardamos el Future para que, aunque pidan la BD dos veces a la vez,
    // solo se abra una vez
    _futuroDb ??= _abrir();
    return _futuroDb!;
  }

  Future<Database> _abrir() async {
    final ruta = join(await getDatabasesPath(), 'game2048.db');
    return openDatabase(
      ruta,
      version: _version,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _crearTablas,
      onUpgrade: _migrar,
    );
  }

  Future<void> _crearTablas(Database db, int version) async {
    // Nota: la columna se llama "contrasena" (sin ñ) para evitar problemas con SQL
    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario TEXT NOT NULL UNIQUE,
        fecha_registro TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        contrasena TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE partidas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario TEXT NOT NULL,
        puntuacion INTEGER NOT NULL,
        ficha_maxima INTEGER NOT NULL,
        movimientos INTEGER NOT NULL,
        duracion_segundos INTEGER NOT NULL,
        fecha TEXT NOT NULL,
        tamano_tablero INTEGER NOT NULL DEFAULT 4
      )
    ''');

    await db.execute('''
      CREATE TABLE partida_guardada (
        id INTEGER PRIMARY KEY,
        tablero TEXT NOT NULL,
        puntuacion INTEGER NOT NULL,
        movimientos INTEGER NOT NULL,
        segundos_transcurridos INTEGER NOT NULL
      )
    ''');
  }

  /// Migraciones. Se ejecuta si el móvil tenía una versión antigua de la BD.
  Future<void> _migrar(Database db, int versionAntigua, int versionNueva) async {
    if (versionAntigua < 2) {
      // Versión 1 -> 2: columna nueva con valor por defecto 4.
      // Las partidas que ya existían se conservan y reciben el 4.
      await db.execute(
          'ALTER TABLE partidas ADD COLUMN tamano_tablero INTEGER NOT NULL DEFAULT 4');
    }
  }
}
