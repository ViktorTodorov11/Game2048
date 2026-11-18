import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../data/partida_dao.dart';
import '../models/partida.dart';
import '../widgets/async_data_view.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/stat_card.dart';
import '../widgets/tile_widget.dart';

class DetalleScreen extends StatefulWidget {
  final int partidaId;

  const DetalleScreen({super.key, required this.partidaId});

  @override
  State<DetalleScreen> createState() => _DetalleScreenState();
}

class _DetalleScreenState extends State<DetalleScreen> {
  final _dao = PartidaDao();
  late Future<Partida?> _futuro;

  @override
  void initState() {
    super.initState();
    // Solo nos llega el id: los datos se consultan a la base de datos
    _futuro = _dao.obtenerPorId(widget.partidaId);
  }

  void _recargar() {
    setState(() {
      _futuro = _dao.obtenerPorId(widget.partidaId);
    });
  }

  Future<void> _eliminar() async {
    final ok = await ConfirmDialog.mostrar(
      context,
      titulo: 'Eliminar partida',
      mensaje: '¿Seguro que quieres eliminar esta partida?',
      textoConfirmar: 'Eliminar',
    );
    if (!ok || !mounted) return;

    try {
      await _dao.eliminar(widget.partidaId);
      if (!mounted) return;
      Navigator.pop(context, true); // true = se ha eliminado (el Historial se recarga)
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No se pudo eliminar: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de la partida'),
        actions: [
          IconButton(
            tooltip: 'Eliminar',
            icon: const Icon(Icons.delete_outline),
            onPressed: _eliminar,
          ),
        ],
      ),
      body: AsyncDataView<Partida?>(
        future: _futuro,
        onReintentar: _recargar,
        builder: (context, partida) {
          if (partida == null) {
            return const EmptyStateView(
              icono: Icons.search_off,
              mensaje: 'No se ha encontrado la partida',
            );
          }

          return ListView(
            padding: const EdgeInsets.all(AppTheme.espacio),
            children: [
              // Ficha máxima conseguida, dibujada con el mismo widget del tablero
              Center(
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: TileWidget(valor: partida.fichaMaxima),
                ),
              ),
              const SizedBox(height: AppTheme.espacio),
              StatCard(titulo: 'Jugador', valor: partida.usuario, icono: Icons.person),
              StatCard(titulo: 'Puntuación', valor: '${partida.puntuacion}', icono: Icons.star),
              StatCard(titulo: 'Ficha máxima', valor: '${partida.fichaMaxima}', icono: Icons.grid_view),
              StatCard(titulo: 'Movimientos', valor: '${partida.movimientos}', icono: Icons.swipe),
              StatCard(titulo: 'Duración', valor: partida.duracionTexto, icono: Icons.timer),
              StatCard(titulo: 'Fecha', valor: partida.fechaBonita, icono: Icons.calendar_today),
              StatCard(titulo: 'Tablero', valor: '${partida.tamanoTablero}x${partida.tamanoTablero}', icono: Icons.apps),
            ],
          );
        },
      ),
    );
  }
}
