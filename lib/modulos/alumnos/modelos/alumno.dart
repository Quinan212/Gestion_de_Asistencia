class Alumno {
  final int id;
  final String apellido;
  final String nombre;
  final int? edad;
  final String? documento;
  final String? email;
  final String? telefono;
  final String? fotoPath;
  final int? institucionId;
  final int? carreraId;
  final String? institucionNombre;
  final String? carreraNombre;
  final bool activo;
  final DateTime creadoEn;

  const Alumno({
    required this.id,
    required this.apellido,
    required this.nombre,
    required this.edad,
    required this.documento,
    required this.email,
    required this.telefono,
    required this.fotoPath,
    required this.institucionId,
    required this.carreraId,
    required this.institucionNombre,
    required this.carreraNombre,
    required this.activo,
    required this.creadoEn,
  });

  String get nombreCompleto => '$apellido, $nombre';

  String get contextoAcademico {
    final inst = (institucionNombre ?? '').trim();
    final carr = (carreraNombre ?? '').trim();
    if (inst.isEmpty && carr.isEmpty) return '';
    if (inst.isEmpty) return carr;
    if (carr.isEmpty) return inst;
    return '$inst - $carr';
  }
}
