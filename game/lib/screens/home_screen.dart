import 'package:flutter/material.dart';

import 'ajustes_screen.dart';
import 'historial_screen.dart';
import 'inicio_screen.dart';
import 'ranking_screen.dart';

/// Pantalla principal con la barra de navegación inferior (NavigationBar).
/// Cada pestaña es una pantalla distinta.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _indice = 0;

  // No usamos IndexedStack a propósito: así cada pestaña se vuelve a crear
  // al entrar y recarga sus datos de la base de datos.
  Widget _paginaActual() {
    switch (_indice) {
      case 0:
        return InicioScreen(onIrA: (i) => setState(() => _indice = i));
      case 1:
        return const HistorialScreen();
      case 2:
        return const RankingScreen();
      default:
        return const AjustesScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _paginaActual(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice,
        onDestinationSelected: (i) => setState(() => _indice = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Inicio'),
          NavigationDestination(
              icon: Icon(Icons.history), label: 'Historial'),
          NavigationDestination(
              icon: Icon(Icons.emoji_events_outlined),
              selectedIcon: Icon(Icons.emoji_events),
              label: 'Ranking'),
          NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Ajustes'),
        ],
      ),
    );
  }
}
