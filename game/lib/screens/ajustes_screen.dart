import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../data/partida_dao.dart';
import '../routes.dart';
import '../services/ajustes_controller.dart';
import '../services/sesion.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/tile_widget.dart';

class AjustesScreen extends StatelessWidget {
  const AjustesScreen({super.key});

  Future<void> _borrarHistorial(BuildContext context) async {
    final ok = await ConfirmDialog.mostrar(
      context,
      titulo: 'Borrar historial',
      mensaje: 'Se eliminarán TODAS las partidas. Esta acción no se puede deshacer.',
      textoConfirmar: 'Borrar todo',
    );
    if (!ok || !context.mounted) return;

    try {
      await PartidaDao().eliminarTodas();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Historial borrado')));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No se pudo borrar: $e')));
    }
  }

  void _cerrarSesion(BuildContext context) {
    Sesion.usuario = '';
    // Quitamos todas las pantallas anteriores y volvemos al login
    Navigator.pushNamedAndRemoveUntil(context, Rutas.login, (ruta) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      // Escuchamos al controlador para que los botones se actualicen al cambiar
      body: ListenableBuilder(
        listenable: ajustes,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(AppTheme.espacio),
            children: [
              const Text('Tema', style: AppTheme.subtitulo),
              const SizedBox(height: AppTheme.espacioPequeno),
              SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(value: ThemeMode.light, label: Text('Claro')),
                  ButtonSegment(value: ThemeMode.dark, label: Text('Oscuro')),
                  ButtonSegment(value: ThemeMode.system, label: Text('Sistema')),
                ],
                selected: {ajustes.modo},
                onSelectionChanged: (seleccion) =>
                    ajustes.cambiarModo(seleccion.first),
              ),
              const SizedBox(height: AppTheme.espacio * 2),
              const Text('Colores de las fichas', style: AppTheme.subtitulo),
              const SizedBox(height: AppTheme.espacioPequeno),
              Wrap(
                spacing: AppTheme.espacioPequeno,
                children: [
                  for (int i = 0; i < AppTheme.nombresPaletas.length; i++)
                    ChoiceChip(
                      label: Text(AppTheme.nombresPaletas[i]),
                      selected: ajustes.paleta == i,
                      onSelected: (_) => ajustes.cambiarPaleta(i),
                    ),
                ],
              ),
              const SizedBox(height: AppTheme.espacio),
              // Vista previa con algunas fichas
              SizedBox(
                height: 70,
                child: Row(
                  children: const [
                    Expanded(child: TileWidget(valor: 2)),
                    Expanded(child: TileWidget(valor: 16)),
                    Expanded(child: TileWidget(valor: 128)),
                    Expanded(child: TileWidget(valor: 1024)),
                    Expanded(child: TileWidget(valor: 2048)),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.espacio * 2),
              OutlinedButton.icon(
                onPressed: () => _borrarHistorial(context),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Borrar historial'),
              ),
              const SizedBox(height: AppTheme.espacioPequeno),
              OutlinedButton.icon(
                onPressed: () => _cerrarSesion(context),
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar sesión'),
              ),
            ],
          );
        },
      ),
    );
  }
}
