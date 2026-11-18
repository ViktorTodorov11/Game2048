import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../data/usuario_dao.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _usuarioCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _pass2Ctrl = TextEditingController();
  final _usuarioDao = UsuarioDao();
  bool _cargando = false;

  @override
  void dispose() {
    _usuarioCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _pass2Ctrl.dispose();
    super.dispose();
  }

  void _mensaje(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  /// Devuelve un texto con el error, o null si todo está bien
  String? _validar() {
    final usuario = _usuarioCtrl.text.trim();
    final email = _emailCtrl.text.trim();

    if (usuario.length < 3) return 'El usuario debe tener al menos 3 caracteres';

    // Comprobamos que el email tenga forma de algo@algo.algo
    final formatoEmail = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!formatoEmail.hasMatch(email)) return 'El email no es válido';

    if (_passCtrl.text.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    if (_passCtrl.text != _pass2Ctrl.text) return 'Las contraseñas no coinciden';

    return null;
  }

  Future<void> _registrar() async {
    final error = _validar();
    if (error != null) {
      _mensaje(error);
      return;
    }

    setState(() => _cargando = true);
    try {
      final usuario = _usuarioCtrl.text.trim();
      await _usuarioDao.registrar(usuario, _emailCtrl.text.trim(), _passCtrl.text);
      if (!mounted) return;
      _mensaje('Cuenta creada. Ya puedes entrar');
      Navigator.pop(context, usuario);
    } catch (e) {
      // Por ejemplo, si el usuario o el email ya existen
      if (mounted) _mensaje(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.espacio * 2),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _usuarioCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Usuario', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: AppTheme.espacio),
                  TextField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                        labelText: 'Email', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: AppTheme.espacio),
                  TextField(
                    controller: _passCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                        labelText: 'Contraseña', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: AppTheme.espacio),
                  TextField(
                    controller: _pass2Ctrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                        labelText: 'Repite la contraseña',
                        border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: AppTheme.espacio * 2),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _cargando ? null : _registrar,
                      child: const Text('Registrarme'),
                    ),
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
