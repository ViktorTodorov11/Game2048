import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../data/partida_dao.dart';
import '../data/partida_guardada_dao.dart';
import '../models/juego2048.dart';
import '../models/partida.dart';
import '../models/partida_guardada.dart';
import '../services/preferencias_service.dart';
import '../services/sesion.dart';
import '../widgets/board_widget.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/score_card.dart';

class JuegoScreen extends StatefulWidget {
  final bool continuar; // true = recuperar la partida guardada

  const JuegoScreen({super.key, required this.continuar});

  @override
  State<JuegoScreen> createState() => _JuegoScreenState();
}

// WidgetsBindingObserver nos avisa cuando la app pasa a segundo plano
class _JuegoScreenState extends State<JuegoScreen> with WidgetsBindingObserver {
  final _partidaDao = PartidaDao();
  final _guardadaDao = PartidaGuardadaDao();

  late Juego2048 _juego;
  Timer? _timer;
  int _segundos = 0;
  int _mejor = 0;

  bool _cargando = true;
  bool _terminada = false;
  bool _guardarAlSalir = true; // false si el usuario elige "salir sin guardar"
  bool _verDetalles = false; // se cambia con doble toque en la puntuación

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _iniciar();
  }

  Future<void> _iniciar() async {
    _mejor = await PreferenciasService.leerMejorPuntuacion();

    _juego = Juego2048(); // por defecto, partida nueva
    if (widget.continuar) {
      try {
        final guardada = await _guardadaDao.obtener();
        if (guardada != null) {
          _juego = Juego2048.desde(
              guardada.tablero, guardada.puntuacion, guardada.movimientos);
          _segundos = guardada.segundos;
        }
      } catch (e) {
        debugPrint('No se pudo recuperar la partida: $e');
      }
    }

    if (!mounted) return;
    setState(() => _cargando = false);
    _arrancarCronometro();
  }

  void _arrancarCronometro() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _segundos++);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState estado) {
    if (_cargando || _terminada) return;

    if (estado == AppLifecycleState.paused) {
      // La app pasa a segundo plano: paramos el reloj y guardamos
      _timer?.cancel();
      _guardarPartida();
    } else if (estado == AppLifecycleState.resumed) {
      _arrancarCronometro();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _guardarPartida(); // guardado automático al salir de la pantalla
    super.dispose();
  }

  /// Guarda la partida en curso (si procede)
  Future<void> _guardarPartida() async {
    if (_cargando || _terminada || !_guardarAlSalir) return;
    if (_juego.movimientos == 0) return; // no hay nada que guardar

    try {
      await _guardadaDao.guardar(PartidaGuardada(
        tablero: _juego.tablero,
        puntuacion: _juego.puntuacion,
        movimientos: _juego.movimientos,
        segundos: _segundos,
      ));
    } catch (e) {
      debugPrint('Error al guardar la partida: $e');
    }
  }

  void _aviso(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  // ---------- Movimiento ----------

  void _mover(Direccion direccion) {
    if (_terminada || _cargando) return;

    final seMovio = _juego.mover(direccion);
    if (!seMovio) return; // movimiento sin efecto: no cuenta

    setState(() {
      if (_juego.puntuacion > _mejor) _mejor = _juego.puntuacion;
    });

    if (_juego.terminado) _finDePartida();
  }

  Future<void> _finDePartida() async {
    _terminada = true;
    _guardarAlSalir = false; // la partida en curso se borra en la transacción
    _timer?.cancel();

    final partida = Partida(
      usuario: Sesion.usuario,
      puntuacion: _juego.puntuacion,
      fichaMaxima: _juego.fichaMaxima,
      movimientos: _juego.movimientos,
      duracionSegundos: _segundos,
      fecha: DateTime.now().toIso8601String(),
    );

    try {
      // Una transacción: guarda en el historial y borra la partida en curso
      await _partidaDao.finalizarPartida(partida);
      await PreferenciasService.guardarMejorPuntuacion(_juego.puntuacion);
    } catch (e) {
      if (mounted) _aviso('No se pudo guardar la partida: $e');
    }

    if (!mounted) return;
    final jugarOtra = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('¡Fin de la partida!'),
        content: Text(
            'Puntuación: ${_juego.puntuacion}\nFicha máxima: ${_juego.fichaMaxima}\nMovimientos: ${_juego.movimientos}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Volver al inicio'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Jugar de nuevo'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (jugarOtra == true) {
      _empezarDeNuevo();
    } else {
      Navigator.pop(context);
    }
  }

  void _empezarDeNuevo() {
    setState(() {
      _juego = Juego2048();
      _segundos = 0;
      _terminada = false;
      _guardarAlSalir = true;
    });
    _arrancarCronometro();
  }

  Future<void> _pulsarReinicio() async {
    // Si ya ha jugado, preguntamos antes de tirar la partida
    if (_juego.movimientos > 0 && !_terminada) {
      final ok = await ConfirmDialog.mostrar(
        context,
        titulo: 'Reiniciar',
        mensaje: '¿Seguro que quieres empezar otra partida? Se perderá la actual.',
        textoConfirmar: 'Reiniciar',
      );
      if (!ok || !mounted) return;
    }
    _empezarDeNuevo();
  }

  // ---------- Salir ----------

  Future<void> _intentarSalir() async {
    // Si no hay partida en curso, salimos directamente
    if (_cargando || _terminada || _juego.movimientos == 0) {
      _guardarAlSalir = false;
      Navigator.pop(context);
      return;
    }

    final opcion = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Salir de la partida?'),
        content: const Text('Tienes una partida en curso.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'cancelar'),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'sin_guardar'),
            child: const Text('Salir sin guardar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, 'guardar'),
            child: const Text('Guardar y salir'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (opcion == 'guardar') {
      await _guardarPartida();
      _guardarAlSalir = false; // ya está guardada, que dispose no la guarde otra vez
      if (mounted) Navigator.pop(context);
    } else if (opcion == 'sin_guardar') {
      _guardarAlSalir = false;
      Navigator.pop(context);
    }
    // si es "cancelar" (o null) no hacemos nada y seguimos jugando
  }

  // ---------- Interfaz ----------

  Widget _marcadores() {
    return Column(
      children: [
        Wrap(
          spacing: AppTheme.espacioPequeno,
          runSpacing: AppTheme.espacioPequeno,
          alignment: WrapAlignment.center,
          children: [
            // Doble toque en la puntuación: muestra u oculta la ficha máxima
            GestureDetector(
              onDoubleTap: () => setState(() => _verDetalles = !_verDetalles),
              child: ScoreCard(etiqueta: 'PUNTOS', valor: '${_juego.puntuacion}'),
            ),
            ScoreCard(etiqueta: 'MEJOR', valor: '$_mejor'),
            ScoreCard(etiqueta: 'MOVIMIENTOS', valor: '${_juego.movimientos}'),
            ScoreCard(etiqueta: 'TIEMPO', valor: formatoTiempo(_segundos)),
          ],
        ),
        if (_verDetalles)
          Padding(
            padding: const EdgeInsets.only(top: AppTheme.espacioPequeno),
            child: Text('Ficha máxima: ${_juego.fichaMaxima}',
                style: AppTheme.subtitulo),
          ),
      ],
    );
  }

  // Botones de flecha, por si el usuario prefiere pulsar en vez de deslizar
  Widget _botonesDireccion() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filledTonal(
          onPressed: () => _mover(Direccion.arriba),
          icon: const Icon(Icons.keyboard_arrow_up),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton.filledTonal(
              onPressed: () => _mover(Direccion.izquierda),
              icon: const Icon(Icons.keyboard_arrow_left),
            ),
            IconButton.filledTonal(
              onPressed: () => _mover(Direccion.abajo),
              icon: const Icon(Icons.keyboard_arrow_down),
            ),
            IconButton.filledTonal(
              onPressed: () => _mover(Direccion.derecha),
              icon: const Icon(Icons.keyboard_arrow_right),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // PopScope intercepta el botón "atrás" para preguntar antes de salir
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _intentarSalir();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('2048'),
          actions: [
            IconButton(
              tooltip: 'Reiniciar',
              onPressed: _cargando ? null : _pulsarReinicio,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: SafeArea(
          child: _cargando
              ? const Center(child: CircularProgressIndicator())
              : LayoutBuilder(builder: (context, c) {
                  final horizontal = c.maxWidth > c.maxHeight;

                  // El tablero es un cuadrado: su lado depende de la orientación
                  final espacioLado = horizontal ? c.maxHeight : c.maxWidth;
                  final lado = min(espacioLado - AppTheme.espacio * 2,
                      AppTheme.ladoMaximoTablero);

                  final tablero = BoardWidget(
                    tablero: _juego.tablero,
                    lado: lado,
                    onMover: _mover,
                  );

                  // Vertical: todo en columna. Horizontal: marcadores a la izquierda
                  // y tablero a la derecha.
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(AppTheme.espacio),
                    child: horizontal
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Flexible(
                                child: Column(
                                  children: [
                                    _marcadores(),
                                    const SizedBox(height: AppTheme.espacio),
                                    _botonesDireccion(),
                                  ],
                                ),
                              ),
                              tablero,
                            ],
                          )
                        : Column(
                            children: [
                              _marcadores(),
                              const SizedBox(height: AppTheme.espacio),
                              tablero,
                              const SizedBox(height: AppTheme.espacio),
                              _botonesDireccion(),
                            ],
                          ),
                  );
                }),
        ),
      ),
    );
  }
}
