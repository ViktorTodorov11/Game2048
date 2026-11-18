import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../data/partida_guardada_dao.dart';
import '../routes.dart';
import '../services/preferencias_service.dart';
import '../services/sesion.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/score_card.dart';

class InicioScreen extends StatefulWidget {
  /// Función para cambiar de pestaña en la barra de navegación
  final void Function(int) onIrA;

  const InicioScreen({super.key, required this.onIrA});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  final _guardadaDao = PartidaGuardadaDao();
  bool _hayPartidaGuardada = false;
  int _mejor = 0;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final guardada = await _guardadaDao.obtener();
      final mejor = await PreferenciasService.leerMejorPuntuacion();
      if (!mounted) return;
      setState(() {
        _hayPartidaGuardada = guardada != null;
        _mejor = mejor;
      });
    } catch (e) {
      debugPrint('Error cargando el inicio: $e');
    }
  }

  Future<void> _nuevaPartida() async {
    // Si hay una partida guardada, empezar otra la borra: preguntamos antes
    if (_hayPartidaGuardada) {
      final ok = await ConfirmDialog.mostrar(
        context,
        titulo: 'Nueva partida',
        mensaje: 'Tienes una partida guardada. Si empiezas otra se perderá. ¿Continuar?',
        textoConfirmar: 'Empezar',
      );
      if (!ok || !mounted) return;
    }

    try {
      await _guardadaDao.borrar();
    } catch (e) {
      debugPrint('No se pudo borrar la partida guardada: $e');
    }
    if (!mounted) return;
    await Navigator.pushNamed(context, Rutas.juego, arguments: false);
    _cargar(); // al volver, actualizamos el botón de continuar y la mejor puntuación
  }

  Future<void> _continuar() async {
    await Navigator.pushNamed(context, Rutas.juego, arguments: true);
    _cargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.espacio * 2),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('2048', style: AppTheme.tituloJuego),
                  const SizedBox(height: AppTheme.espacioPequeno),
                  Text('Hola, ${Sesion.usuario}', style: AppTheme.subtitulo),
                  const SizedBox(height: AppTheme.espacio),
                  ScoreCard(etiqueta: 'MEJOR PUNTUACIÓN', valor: '$_mejor'),
                  const SizedBox(height: AppTheme.espacio * 2),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _nuevaPartida,
                      child: const Text('Nueva partida'),
                    ),
                  ),
                  if (_hayPartidaGuardada) ...[
                    const SizedBox(height: AppTheme.espacioPequeno),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonal(
                        onPressed: _continuar,
                        child: const Text('Continuar partida'),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppTheme.espacio),
                  // Accesos rápidos a las otras pestañas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                          onPressed: () => widget.onIrA(1),
                          child: const Text('Historial')),
                      TextButton(
                          onPressed: () => widget.onIrA(2),
                          child: const Text('Ranking')),
                      TextButton(
                          onPressed: () => widget.onIrA(3),
                          child: const Text('Ajustes')),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
