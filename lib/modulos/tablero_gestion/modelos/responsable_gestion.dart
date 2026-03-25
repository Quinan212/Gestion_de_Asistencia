import 'package:gestion_de_asistencias/modulos/panel_institucional/modelos/perfil_institucional.dart';

class ResponsableGestion {
  final int id;
  final String nombre;
  final String area;
  final String rolDestino;
  final String nivelDestino;
  final String dependenciaDestino;
  final bool activo;
  final int alertasActivas;
  final int seguimientosResueltos;

  const ResponsableGestion({
    required this.id,
    required this.nombre,
    required this.area,
    required this.rolDestino,
    required this.nivelDestino,
    required this.dependenciaDestino,
    required this.activo,
    this.alertasActivas = 0,
    this.seguimientosResueltos = 0,
  });

  String get etiqueta => '$nombre | $area';

  String get estadoEtiqueta => activo ? 'Activo' : 'Inactivo';
}

class ResponsableGestionBorrador {
  final int? id;
  final String nombre;
  final String area;
  final RolInstitucional rol;
  final NivelInstitucional nivel;
  final DependenciaInstitucional dependencia;
  final bool activo;

  const ResponsableGestionBorrador({
    this.id,
    required this.nombre,
    required this.area,
    required this.rol,
    required this.nivel,
    required this.dependencia,
    this.activo = true,
  });

  factory ResponsableGestionBorrador.desdeContexto(
    ContextoInstitucional contexto,
  ) {
    return ResponsableGestionBorrador(
      nombre: '',
      area: '',
      rol: contexto.rol,
      nivel: contexto.nivel,
      dependencia: contexto.dependencia,
    );
  }

  factory ResponsableGestionBorrador.desdeResponsable(
    ResponsableGestion responsable,
  ) {
    return ResponsableGestionBorrador(
      id: responsable.id,
      nombre: responsable.nombre,
      area: responsable.area,
      rol: RolInstitucional.values.firstWhere(
        (item) => item.name == responsable.rolDestino,
      ),
      nivel: NivelInstitucional.values.firstWhere(
        (item) => item.name == responsable.nivelDestino,
      ),
      dependencia: DependenciaInstitucional.values.firstWhere(
        (item) => item.name == responsable.dependenciaDestino,
      ),
      activo: responsable.activo,
    );
  }
}
