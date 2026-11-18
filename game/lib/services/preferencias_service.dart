import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Todo el acceso a SharedPreferences está aquí.
/// Las claves son constantes para no repetir cadenas por el código.
class PreferenciasService {
  static const String _claveTema = 'modo_tema';
  static const String _clavePaleta = 'paleta_fichas';
  static const String _claveUltimoUsuario = 'ultimo_usuario';
  static const String _claveMejorPuntuacion = 'mejor_puntuacion';

  static Future<void> guardarModoTema(ThemeMode modo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_claveTema, modo.name); // "light", "dark" o "system"
  }

  /// Si no hay nada guardado devuelve ThemeMode.system
  static Future<ThemeMode> leerModoTema() async {
    final prefs = await SharedPreferences.getInstance();
    final texto = prefs.getString(_claveTema);
    if (texto == null) return ThemeMode.system;
    return ThemeMode.values.firstWhere(
      (m) => m.name == texto,
      orElse: () => ThemeMode.system,
    );
  }

  static Future<void> guardarPaleta(int indice) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_clavePaleta, indice);
  }

  static Future<int> leerPaleta() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_clavePaleta) ?? 0;
  }

  // Ampliación opcional: último jugador y mejor puntuación
  static Future<void> guardarUltimoUsuario(String usuario) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_claveUltimoUsuario, usuario);
  }

  static Future<String?> leerUltimoUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_claveUltimoUsuario);
  }

  /// Solo guarda la puntuación si supera a la que ya había
  static Future<void> guardarMejorPuntuacion(int puntos) async {
    final prefs = await SharedPreferences.getInstance();
    final actual = prefs.getInt(_claveMejorPuntuacion) ?? 0;
    if (puntos > actual) {
      await prefs.setInt(_claveMejorPuntuacion, puntos);
    }
  }

  static Future<int> leerMejorPuntuacion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_claveMejorPuntuacion) ?? 0;
  }
}
