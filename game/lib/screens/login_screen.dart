import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../data/usuario_dao.dart';
import '../routes.dart';
import '../services/preferencias_service.dart';
import '../services/sesion.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usuarioCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _usuarioDao = UsuarioDao();
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _rellenarUltimoUsuario();
  }

  // Si ya entró alguien antes, le ponemos su nombre para ahorrar tiempo
  Future<void> _rellenarUltimoUsuario() async {
    final ultimo = await PreferenciasService.leerUltimoUsuario();
    if (ultimo != null && mounted) {
      _usuarioCtrl.text = ultimo;
    }
  }

  @override
  void dispose() {
    _usuarioCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _mensaje(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> _entrar() async {
    final usuario = _usuarioCtrl.text.trim();
    final password = _passCtrl.text;

    if (usuario.isEmpty || password.isEmpty) {
      _mensaje('Rellena el usuario y la contraseña');
      return;
    }

    setState(() => _cargando = true);
    try {
      final correcto = await _usuarioDao.login(usuario, password);
      if (!mounted) return;

      if (correcto) {
        Sesion.usuario = usuario;
        await PreferenciasService.guardarUltimoUsuario(usuario);
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, Rutas.home);
      } else {
        _mensaje('Usuario o contraseña incorrectos');
      }
    } catch (e) {
      if (mounted) _mensaje('Error al iniciar sesión: $e');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
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
                  const SizedBox(height: AppTheme.espacio * 2),
                  TextField(
                    controller: _usuarioCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Usuario',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppTheme.espacio),
                  TextField(
                    controller: _passCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppTheme.espacio * 2),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _cargando ? null : _entrar,
                      child: _cargando
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Entrar'),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      // Si se registra, volvemos con su nombre de usuario
                      final nuevo =
                          await Navigator.pushNamed(context, Rutas.registro);
                      if (nuevo is String) _usuarioCtrl.text = nuevo;
                    },
                    child: const Text('Crear cuenta'),
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
