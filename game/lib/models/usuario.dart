class Usuario {
  final int? id;
  final String usuario;
  final String fechaRegistro; // ISO 8601
  final String email;
  final String contrasena; // guardada como "sal:hash", nunca en claro

  const Usuario({
    this.id,
    required this.usuario,
    required this.fechaRegistro,
    required this.email,
    required this.contrasena,
  });

  Map<String, Object?> toMap() {
    final mapa = <String, Object?>{
      'usuario': usuario,
      'fecha_registro': fechaRegistro,
      'email': email,
      'contrasena': contrasena,
    };
    if (id != null) mapa['id'] = id;
    return mapa;
  }

  factory Usuario.fromMap(Map<String, Object?> m) {
    return Usuario(
      id: m['id'] as int?,
      usuario: m['usuario'] as String,
      fechaRegistro: m['fecha_registro'] as String,
      email: m['email'] as String,
      contrasena: m['contrasena'] as String,
    );
  }
}
