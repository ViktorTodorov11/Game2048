import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'routes.dart';
import 'services/ajustes_controller.dart';

Future<void> main() async {
  // Hay que inicializar Flutter antes de usar shared_preferences
  WidgetsFlutterBinding.ensureInitialized();

  // Leemos el tema y la paleta ANTES de runApp para que no parpadee
  // el tema equivocado al arrancar
  await ajustes.cargar();

  runApp(const Juego2048App());
}

class Juego2048App extends StatelessWidget {
  const Juego2048App({super.key});

  @override
  Widget build(BuildContext context) {
    // ListenableBuilder vuelve a construir la app cuando cambian los ajustes,
    // así el tema cambia en tiempo real sin reiniciar
    return ListenableBuilder(
      listenable: ajustes,
      builder: (context, _) {
        return MaterialApp(
          title: '2048',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.construir(Brightness.light, ajustes.paleta),
          darkTheme: AppTheme.construir(Brightness.dark, ajustes.paleta),
          themeMode: ajustes.modo,
          initialRoute: Rutas.login,
          onGenerateRoute: Rutas.generar,
        );
      },
    );
  }
}
