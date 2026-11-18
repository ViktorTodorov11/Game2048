import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../data/partida_dao.dart';
import '../models/partida.dart';
import '../routes.dart';
import '../widgets/async_data_view.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/partida_list_item.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  final _dao = PartidaDao();
  final _jugadorCtrl = TextEditingController();
  int _fichaMinima = 0; // 0 = todas
  late Future<List<Partida>> _futuro;

  @override
  void initState() {
    super.initState();
    _futuro = _cargar();
  }

  @override
  void dispose() {
    _jugadorCtrl.dispose();
    super.dispose();
  }

  Future<List<Partida>> _cargar() {
    return _dao.listar(
      usuario: _jugadorCtrl.text.trim(),
      fichaMinima: _fichaMinima,
    );
  }

  void _recargar() {
    setState(() {
      _futuro = _cargar();
    });
  }

  // Para el "tirar hacia abajo para recargar"
  Future<void> _refrescar() async {
    _recargar();
    await _futuro;
  }

  void _mensaje(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> _abrirDetalle(int id) async {
    final eliminada = await Navigator.pushNamed(context, Rutas.detalle, arguments: id);
    if (!mounted) return;
    if (eliminada == true) {
      _recargar();
      _mensaje('Partida eliminada');
    }
  }

  /// Borrado al deslizar: se borra y se ofrece "Deshacer"
  Future<void> _eliminarConDeshacer(Partida p) async {
    try {
      await _dao.eliminar(p.id!);
    } catch (e) {
      if (mounted) {
        _mensaje('No se pudo eliminar: $e');
        _recargar();
      }
      return;
    }
    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Partida eliminada'),
        action: SnackBarAction(
          label: 'Deshacer',
          onPressed: () async {
            // Volvemos a insertar la misma partida (con su mismo id)
            await _dao.insertar(p);
            if (mounted) _recargar();
          },
        ),
      ),
    );
  }

  /// Borrado desde el menú de pulsación larga: pide confirmación
  Future<void> _eliminarConConfirmacion(Partida p) async {
    final ok = await ConfirmDialog.mostrar(
      context,
      titulo: 'Eliminar partida',
      mensaje: '¿Seguro que quieres eliminar esta partida?',
      textoConfirmar: 'Eliminar',
    );
    if (!ok || !mounted) return;

    try {
      await _dao.eliminar(p.id!);
      if (!mounted) return;
      _recargar();
      _mensaje('Partida eliminada');
    } catch (e) {
      if (mounted) _mensaje('No se pudo eliminar: $e');
    }
  }

  // Menú de opciones al mantener pulsada una partida
  void _mostrarMenu(Partida p) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Ver detalle'),
              onTap: () {
                Navigator.pop(ctx);
                _abrirDetalle(p.id!);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Eliminar'),
              onTap: () {
                Navigator.pop(ctx);
                _eliminarConConfirmacion(p);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _filtros() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.espacio),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _jugadorCtrl,
              decoration: InputDecoration(
                labelText: 'Jugador',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _recargar,
                ),
              ),
              onSubmitted: (_) => _recargar(),
            ),
          ),
          const SizedBox(width: AppTheme.espacio),
          DropdownButton<int>(
            value: _fichaMinima,
            items: const [
              DropdownMenuItem(value: 0, child: Text('Todas')),
              DropdownMenuItem(value: 128, child: Text('≥ 128')),
              DropdownMenuItem(value: 256, child: Text('≥ 256')),
              DropdownMenuItem(value: 512, child: Text('≥ 512')),
              DropdownMenuItem(value: 1024, child: Text('≥ 1024')),
              DropdownMenuItem(value: 2048, child: Text('≥ 2048')),
            ],
            onChanged: (valor) {
              _fichaMinima = valor ?? 0;
              _recargar();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial')),
      body: Column(
        children: [
          _filtros(),
          Expanded(
            child: AsyncDataView<List<Partida>>(
              future: _futuro,
              onReintentar: _recargar,
              builder: (context, lista) {
                if (lista.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: _refrescar,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 80),
                        EmptyStateView(
                          icono: Icons.history,
                          mensaje: 'No hay partidas todavía.\n¡Juega una!',
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _refrescar,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: lista.length,
                    itemBuilder: (context, i) {
                      final partida = lista[i];
                      return Dismissible(
                        key: ValueKey(partida.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Theme.of(context).colorScheme.error,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: AppTheme.espacio),
                          child: Icon(Icons.delete,
                              color: Theme.of(context).colorScheme.onError),
                        ),
                        onDismissed: (_) {
                          // Quitamos la partida de la lista que ya tenemos en pantalla
                          // (Dismissible lo exige) y luego la borramos de la BD
                          lista.remove(partida);
                          _eliminarConDeshacer(partida);
                        },
                        child: PartidaListItem(
                          partida: partida,
                          onTap: () => _abrirDetalle(partida.id!),
                          onLongPress: () => _mostrarMenu(partida),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
