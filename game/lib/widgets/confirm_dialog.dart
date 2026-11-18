import 'package:flutter/material.dart';

/// Diálogo de confirmación reutilizable.
/// Uso: final ok = await ConfirmDialog.mostrar(context, titulo: ..., mensaje: ...);
class ConfirmDialog extends StatelessWidget {
  final String titulo;
  final String mensaje;
  final String textoConfirmar;
  final String textoCancelar;

  const ConfirmDialog({
    super.key,
    required this.titulo,
    required this.mensaje,
    this.textoConfirmar = 'Aceptar',
    this.textoCancelar = 'Cancelar',
  });

  /// Muestra el diálogo y devuelve true si el usuario confirma
  static Future<bool> mostrar(
    BuildContext context, {
    required String titulo,
    required String mensaje,
    String textoConfirmar = 'Aceptar',
    String textoCancelar = 'Cancelar',
  }) async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        titulo: titulo,
        mensaje: mensaje,
        textoConfirmar: textoConfirmar,
        textoCancelar: textoCancelar,
      ),
    );
    // Si lo cierran tocando fuera el resultado es null -> lo tomamos como "no"
    return resultado ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(titulo),
      content: Text(mensaje),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(textoCancelar),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(textoConfirmar),
        ),
      ],
    );
  }
}
