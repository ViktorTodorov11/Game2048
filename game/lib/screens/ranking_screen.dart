import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../data/partida_dao.dart';
import '../models/partida.dart';
import '../routes.dart';
import '../widgets/async_data_view.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/partida_list_item.dart';
import '../widgets/stat_card.dart';

/// Agrupa todo lo que necesita la pantalla para cargarlo de una vez
class _DatosRanking {
  final List<Partida> top;
  final Map<String, Object?> global;
  final List<Map<String, Object?>> jugadores;

  _DatosRanking(this.top, this.global, this.jugadores);
}

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  final _dao = PartidaDao();
  late Future<_DatosRanking> _futuro;

  @override
  void initState() {
    super.initState();
    _futuro = _cargar();
  }

  Future<_DatosRanking> _cargar() async {
    final top = await _dao.ranking();
    final global = await _dao.estadisticasGlobales();
    final jugadores = await _dao.estadisticasPorJugador();
    return _DatosRanking(top, global, jugadores);
  }

  void _recargar() {
    setState(() {
      _futuro = _cargar();
    });
  }

  Future<void> _refrescar() async {
    _recargar();
    await _futuro;
  }

  Widget _titulo(String texto) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppTheme.espacio, AppTheme.espacio, AppTheme.espacio, AppTheme.espacioPequeno),
      child: Text(texto, style: AppTheme.subtitulo.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ranking')),
      body: AsyncDataView<_DatosRanking>(
        future: _futuro,
        onReintentar: _recargar,
        builder: (context, datos) {
          final total = (datos.global['total'] as int?) ?? 0;

          if (total == 0) {
            return const EmptyStateView(
              icono: Icons.emoji_events_outlined,
              mensaje: 'Todavía no hay partidas para el ranking',
            );
          }

          // Si no hay partidas MAX/AVG/SUM salen null, por eso usamos "?? 0"
          final maxima = (datos.global['maxima'] as int?) ?? 0;
          final media = ((datos.global['media'] as num?) ?? 0).round();
          final ficha = (datos.global['ficha'] as int?) ?? 0;
          final tiempo = (datos.global['tiempo'] as int?) ?? 0;

          return RefreshIndicator(
            onRefresh: _refrescar,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                _titulo('Estadísticas globales'),
                StatCard(titulo: 'Partidas jugadas', valor: '$total', icono: Icons.sports_esports),
                StatCard(titulo: 'Puntuación máxima', valor: '$maxima', icono: Icons.star),
                StatCard(titulo: 'Puntuación media', valor: '$media', icono: Icons.bar_chart),
                StatCard(titulo: 'Ficha máxima', valor: '$ficha', icono: Icons.grid_view),
                StatCard(titulo: 'Tiempo total', valor: formatoTiempo(tiempo), icono: Icons.timer),
                _titulo('Top 10 partidas'),
                for (final p in datos.top)
                  PartidaListItem(
                    partida: p,
                    onTap: () async {
                      await Navigator.pushNamed(context, Rutas.detalle, arguments: p.id);
                      if (mounted) _recargar(); // por si la ha borrado desde el detalle
                    },
                  ),
                _titulo('Mejor puntuación por jugador'),
                for (final j in datos.jugadores)
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: Text('${j['usuario']}'),
                    subtitle: Text('${j['partidas']} partidas'),
                    trailing: Text('${j['mejor']}', style: AppTheme.valorMarcador),
                  ),
                const SizedBox(height: AppTheme.espacio),
              ],
            ),
          );
        },
      ),
    );
  }
}
