import 'package:flutter/material.dart';

import 'screens/detalle_screen.dart';
import 'screens/home_screen.dart';
import 'screens/juego_screen.dart';
import 'screens/login_screen.dart';
import 'screens/registro_screen.dart';

/// Todas las rutas de la app están aquí, en un único archivo.
/// Es el único sitio donde se crean MaterialPageRoute.
class Rutas {
  static const String login = '/login';
  static const String registro = '/registro';
  static const String home = '/home';
  static const String juego = '/juego';
  static const String detalle = '/detalle';

  static Route<dynamic> generar(RouteSettings settings) {
    switch (settings.name) {
      case registro:
        return MaterialPageRoute(
            builder: (_) => const RegistroScreen(), settings: settings);
      case home:
        return MaterialPageRoute(
            builder: (_) => const HomeScreen(), settings: settings);
      case juego:
        // argumento: true = continuar la partida guardada, false = nueva
        final continuar = (settings.arguments as bool?) ?? false;
        return MaterialPageRoute(
            builder: (_) => JuegoScreen(continuar: continuar),
            settings: settings);
      case detalle:
        // argumento: el id de la partida (la pantalla la consulta en la BD)
        final id = settings.arguments as int;
        return MaterialPageRoute(
            builder: (_) => DetalleScreen(partidaId: id), settings: settings);
      case login:
      default:
        return MaterialPageRoute(
            builder: (_) => const LoginScreen(), settings: settings);
    }
  }
}
