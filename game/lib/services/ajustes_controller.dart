import 'package:flutter/material.dart';

import 'preferencias_service.dart';

/// Guarda el tema y la paleta que usa la app. Como es un ChangeNotifier,
/// al cambiar algo avisa y la app se redibuja al momento.
class AjustesController extends ChangeNotifier {
  ThemeMode modo = ThemeMode.system;
  int paleta = 0;

  /// Se llama en main() antes de runApp
  Future<void> cargar() async {
    modo = await PreferenciasService.leerModoTema();
    paleta = await PreferenciasService.leerPaleta();
  }

  Future<void> cambiarModo(ThemeMode nuevo) async {
    modo = nuevo;
    notifyListeners(); // primero redibujamos, luego guardamos
    await PreferenciasService.guardarModoTema(nuevo);
  }

  Future<void> cambiarPaleta(int nueva) async {
    paleta = nueva;
    notifyListeners();
    await PreferenciasService.guardarPaleta(nueva);
  }
}

/// Una única instancia para toda la app
final AjustesController ajustes = AjustesController();
