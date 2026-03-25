import 'package:flutter/material.dart';

enum RolInstitucional {
  maestro,
  profesor,
  preceptor,
  secretario,
  director,
  rector,
  bibliotecario,
  tecnico,
  coordinador,
}

extension RolInstitucionalX on RolInstitucional {
  String get etiqueta => switch (this) {
    RolInstitucional.maestro => 'Maestro',
    RolInstitucional.profesor => 'Profesor',
    RolInstitucional.preceptor => 'Preceptor',
    RolInstitucional.secretario => 'Secretario',
    RolInstitucional.director => 'Director',
    RolInstitucional.rector => 'Rector',
    RolInstitucional.bibliotecario => 'Bibliotecario',
    RolInstitucional.tecnico => 'Tecnico',
    RolInstitucional.coordinador => 'Coordinador',
  };

  String get descripcionBreve => switch (this) {
    RolInstitucional.maestro =>
      'Seguimiento cotidiano del curso, asistencia, convivencia y familias.',
    RolInstitucional.profesor =>
      'Planificacion, asistencia por clase, evaluacion y evidencias.',
    RolInstitucional.preceptor =>
      'Control de inasistencias, novedades diarias y articulacion con alumnos.',
    RolInstitucional.secretario =>
      'Legajos, movimientos administrativos, constancias y trazabilidad.',
    RolInstitucional.director =>
      'Vista integral de indicadores, alertas y decisiones de gestion.',
    RolInstitucional.rector =>
      'Gobierno institucional, supervision academica y seguimiento transversal.',
    RolInstitucional.bibliotecario =>
      'Prestamos, recursos pedagogicos y apoyo documental.',
    RolInstitucional.tecnico =>
      'Mesa operativa, infraestructura, soporte y mantenimiento.',
    RolInstitucional.coordinador =>
      'Articulacion de equipos, acuerdos pedagogicos y acompanamiento.',
  };

  IconData get icono => switch (this) {
    RolInstitucional.maestro => Icons.cast_for_education_outlined,
    RolInstitucional.profesor => Icons.school_outlined,
    RolInstitucional.preceptor => Icons.fact_check_outlined,
    RolInstitucional.secretario => Icons.folder_copy_outlined,
    RolInstitucional.director => Icons.manage_accounts_outlined,
    RolInstitucional.rector => Icons.account_balance_outlined,
    RolInstitucional.bibliotecario => Icons.menu_book_outlined,
    RolInstitucional.tecnico => Icons.precision_manufacturing_outlined,
    RolInstitucional.coordinador => Icons.hub_outlined,
  };
}

enum NivelInstitucional { secundario, terciario, universitario }

extension NivelInstitucionalX on NivelInstitucional {
  String get etiqueta => switch (this) {
    NivelInstitucional.secundario => 'Secundario',
    NivelInstitucional.terciario => 'Terciario',
    NivelInstitucional.universitario => 'Universitario',
  };

  String get descripcion => switch (this) {
    NivelInstitucional.secundario =>
      'Ciclos, divisiones, seguimiento de trayectoria y convivencia escolar.',
    NivelInstitucional.terciario =>
      'Cohortes, espacios curriculares, practicas y trayectorias superiores.',
    NivelInstitucional.universitario =>
      'Catedras, comisiones, regularidad, examenes y volumen institucional.',
  };
}

enum DependenciaInstitucional { publica, privada }

extension DependenciaInstitucionalX on DependenciaInstitucional {
  String get etiqueta => switch (this) {
    DependenciaInstitucional.publica => 'Publica',
    DependenciaInstitucional.privada => 'Privada',
  };
}

enum PermisoModulo {
  panelInstitucional,
  academicoCatalogos,
  asistencias,
  reportes,
  agendaDocente,
  legajos,
  secretaria,
  biblioteca,
  preceptoria,
  incidencias,
  tableroGestion,
}

extension PermisoModuloX on PermisoModulo {
  String get etiqueta => switch (this) {
    PermisoModulo.panelInstitucional => 'Panel institucional',
    PermisoModulo.academicoCatalogos => 'Catalogos academicos',
    PermisoModulo.asistencias => 'Asistencias',
    PermisoModulo.reportes => 'Reportes',
    PermisoModulo.agendaDocente => 'Agenda docente',
    PermisoModulo.legajos => 'Legajos',
    PermisoModulo.secretaria => 'Secretaria',
    PermisoModulo.biblioteca => 'Biblioteca',
    PermisoModulo.preceptoria => 'Preceptoria',
    PermisoModulo.incidencias => 'Incidencias institucionales',
    PermisoModulo.tableroGestion => 'Tablero de gestion',
  };

  IconData get icono => switch (this) {
    PermisoModulo.panelInstitucional => Icons.space_dashboard_outlined,
    PermisoModulo.academicoCatalogos => Icons.account_balance_outlined,
    PermisoModulo.asistencias => Icons.fact_check_outlined,
    PermisoModulo.reportes => Icons.bar_chart_outlined,
    PermisoModulo.agendaDocente => Icons.event_note_outlined,
    PermisoModulo.legajos => Icons.folder_open_outlined,
    PermisoModulo.secretaria => Icons.work_history_outlined,
    PermisoModulo.biblioteca => Icons.menu_book_outlined,
    PermisoModulo.preceptoria => Icons.fact_check_outlined,
    PermisoModulo.incidencias => Icons.hub_outlined,
    PermisoModulo.tableroGestion => Icons.insights_outlined,
  };
}

class ContextoInstitucional {
  final RolInstitucional rol;
  final NivelInstitucional nivel;
  final DependenciaInstitucional dependencia;

  const ContextoInstitucional({
    required this.rol,
    required this.nivel,
    required this.dependencia,
  });

  const ContextoInstitucional.predeterminado()
    : rol = RolInstitucional.director,
      nivel = NivelInstitucional.secundario,
      dependencia = DependenciaInstitucional.publica;

  ContextoInstitucional copyWith({
    RolInstitucional? rol,
    NivelInstitucional? nivel,
    DependenciaInstitucional? dependencia,
  }) {
    return ContextoInstitucional(
      rol: rol ?? this.rol,
      nivel: nivel ?? this.nivel,
      dependencia: dependencia ?? this.dependencia,
    );
  }

  Set<PermisoModulo> get permisos => permisosParaRol(rol);

  bool tienePermiso(PermisoModulo permiso) => permisos.contains(permiso);

  static Set<PermisoModulo> permisosParaRol(RolInstitucional rol) {
    switch (rol) {
      case RolInstitucional.maestro:
      case RolInstitucional.profesor:
        return {
          PermisoModulo.panelInstitucional,
          PermisoModulo.asistencias,
          PermisoModulo.agendaDocente,
          PermisoModulo.reportes,
        };
      case RolInstitucional.preceptor:
        return {
          PermisoModulo.panelInstitucional,
          PermisoModulo.academicoCatalogos,
          PermisoModulo.asistencias,
          PermisoModulo.reportes,
          PermisoModulo.preceptoria,
        };
      case RolInstitucional.secretario:
        return {
          PermisoModulo.panelInstitucional,
          PermisoModulo.academicoCatalogos,
          PermisoModulo.asistencias,
          PermisoModulo.reportes,
          PermisoModulo.legajos,
          PermisoModulo.secretaria,
          PermisoModulo.biblioteca,
          PermisoModulo.incidencias,
        };
      case RolInstitucional.director:
      case RolInstitucional.rector:
        return {
          PermisoModulo.panelInstitucional,
          PermisoModulo.academicoCatalogos,
          PermisoModulo.asistencias,
          PermisoModulo.reportes,
          PermisoModulo.agendaDocente,
          PermisoModulo.legajos,
          PermisoModulo.secretaria,
          PermisoModulo.biblioteca,
          PermisoModulo.preceptoria,
          PermisoModulo.incidencias,
          PermisoModulo.tableroGestion,
        };
      case RolInstitucional.bibliotecario:
        return {
          PermisoModulo.panelInstitucional,
          PermisoModulo.reportes,
          PermisoModulo.legajos,
          PermisoModulo.biblioteca,
        };
      case RolInstitucional.tecnico:
        return {
          PermisoModulo.panelInstitucional,
          PermisoModulo.reportes,
          PermisoModulo.incidencias,
          PermisoModulo.tableroGestion,
        };
      case RolInstitucional.coordinador:
        return {
          PermisoModulo.panelInstitucional,
          PermisoModulo.academicoCatalogos,
          PermisoModulo.asistencias,
          PermisoModulo.reportes,
          PermisoModulo.agendaDocente,
          PermisoModulo.incidencias,
          PermisoModulo.tableroGestion,
        };
    }
  }
}

class PrioridadOperativa {
  final String titulo;
  final String descripcion;
  final IconData icono;
  final String impacto;

  const PrioridadOperativa({
    required this.titulo,
    required this.descripcion,
    required this.icono,
    required this.impacto,
  });
}

class ModuloRecomendado {
  final String titulo;
  final String descripcion;
  final String estado;
  final IconData icono;

  const ModuloRecomendado({
    required this.titulo,
    required this.descripcion,
    required this.estado,
    required this.icono,
  });
}

class PerfilInstitucionalResumen {
  final String titulo;
  final String resumen;
  final String foco;
  final List<PrioridadOperativa> prioridades;
  final List<ModuloRecomendado> modulos;
  final Set<PermisoModulo> permisos;

  const PerfilInstitucionalResumen({
    required this.titulo,
    required this.resumen,
    required this.foco,
    required this.prioridades,
    required this.modulos,
    required this.permisos,
  });
}

class CatalogoPerfilesInstitucionales {
  const CatalogoPerfilesInstitucionales._();

  static PerfilInstitucionalResumen construir({
    required RolInstitucional rol,
    required NivelInstitucional nivel,
    required DependenciaInstitucional dependencia,
  }) {
    final permisos = ContextoInstitucional.permisosParaRol(rol);
    final contexto = '${nivel.etiqueta} ${dependencia.etiqueta.toLowerCase()}';

    final prioridadesBase = <PrioridadOperativa>[
      PrioridadOperativa(
        titulo: 'Asistencia trazable',
        descripcion:
            'Registrar cada movimiento con fecha, curso, justificacion y responsable.',
        icono: Icons.how_to_reg_outlined,
        impacto: 'Critico',
      ),
      PrioridadOperativa(
        titulo: 'Alertas tempranas',
        descripcion:
            'Detectar ausentismo reiterado, riesgo pedagogico y cortes operativos.',
        icono: Icons.warning_amber_outlined,
        impacto: 'Alto',
      ),
      PrioridadOperativa(
        titulo: 'Circuitos administrativos',
        descripcion:
            'Unificar constancias, cierres, novedades y evidencias institucionales.',
        icono: Icons.route_outlined,
        impacto: 'Alto',
      ),
    ];

    final modulosBase = <ModuloRecomendado>[
      ModuloRecomendado(
        titulo: 'Panel institucional',
        descripcion:
            'Entrada por perfil con lectura operativa y prioridades del dia.',
        estado: 'En construccion',
        icono: Icons.space_dashboard_outlined,
      ),
      ModuloRecomendado(
        titulo: 'Asistencias',
        descripcion:
            'Carga por clase, seguimiento de inasistencias y consolidado por curso.',
        estado: 'Activo',
        icono: Icons.fact_check_outlined,
      ),
      ModuloRecomendado(
        titulo: 'Agenda docente',
        descripcion:
            'Evidencias, evaluaciones, rubricas, pendientes e intervenciones.',
        estado: 'Activo',
        icono: Icons.event_note_outlined,
      ),
      ModuloRecomendado(
        titulo: 'Legajos y documental',
        descripcion:
            'Constancias, movimientos administrativos y trazabilidad por actor.',
        estado: 'Proximo',
        icono: Icons.folder_open_outlined,
      ),
    ];

    switch (rol) {
      case RolInstitucional.maestro:
      case RolInstitucional.profesor:
        return PerfilInstitucionalResumen(
          titulo: '${rol.etiqueta} en ${contexto[0].toUpperCase()}${contexto.substring(1)}',
          resumen:
              'La experiencia debe priorizar trabajo de aula, seguimiento de alumnos y continuidad pedagogica sin friccion.',
          foco:
              'Necesita decisiones rapidas por curso, acceso directo a clases, evaluaciones y observaciones de trayectoria.',
          prioridades: [
            PrioridadOperativa(
              titulo: 'Clase en curso',
              descripcion:
                  'Abrir el curso correcto, tomar asistencia y registrar tema sin pasos extra.',
              icono: Icons.play_lesson_outlined,
              impacto: 'Inmediato',
            ),
            PrioridadOperativa(
              titulo: 'Seguimiento pedagogico',
              descripcion:
                  'Relacionar asistencia, evaluaciones e intervenciones en un mismo flujo.',
              icono: Icons.timeline_outlined,
              impacto: 'Alto',
            ),
            ...prioridadesBase,
          ],
          modulos: [
            modulosBase[1],
            modulosBase[2],
            ModuloRecomendado(
              titulo: 'Cuaderno institucional',
              descripcion:
                  'Observaciones, acuerdos y comunicaciones de curso con contexto historico.',
              estado: 'Proximo',
              icono: Icons.auto_stories_outlined,
            ),
            modulosBase[0],
          ],
          permisos: permisos,
        );
      case RolInstitucional.preceptor:
        return PerfilInstitucionalResumen(
          titulo: 'Preceptoria para $contexto',
          resumen:
              'Debe resolver control diario, novedades por division y derivaciones sin perder trazabilidad.',
          foco:
              'Necesita tablero rapido de inasistencias, tardanzas, alertas y comunicaciones por alumno.',
          prioridades: [
            PrioridadOperativa(
              titulo: 'Novedades del turno',
              descripcion:
                  'Centralizar ausencias, retiros, ingresos tardios y observaciones.',
              icono: Icons.today_outlined,
              impacto: 'Inmediato',
            ),
            ...prioridadesBase,
          ],
          modulos: [
            modulosBase[1],
            ModuloRecomendado(
              titulo: 'Turnos y novedades',
              descripcion:
                  'Mesa diaria con resumen por division, alumno y franja horaria.',
              estado: 'Proximo',
              icono: Icons.notifications_active_outlined,
            ),
            modulosBase[0],
            modulosBase[3],
          ],
          permisos: permisos,
        );
      case RolInstitucional.secretario:
        return PerfilInstitucionalResumen(
          titulo: 'Secretaria academica para $contexto',
          resumen:
              'La app debe sostener procesos administrativos reales, con consistencia documental y seguimiento de cambios.',
          foco:
              'Necesita estructura academica clara, movimientos auditables y exportaciones operativas.',
          prioridades: [
            PrioridadOperativa(
              titulo: 'Legajos consistentes',
              descripcion:
                  'Evitar datos dispersos entre alumnos, cursos, materias y constancias.',
              icono: Icons.badge_outlined,
              impacto: 'Critico',
            ),
            ...prioridadesBase,
          ],
          modulos: [
            modulosBase[3],
            ModuloRecomendado(
              titulo: 'Matriculacion e inscripciones',
              descripcion:
                  'Altas, pases, regularidad y trazabilidad de movimientos administrativos.',
              estado: 'Proximo',
              icono: Icons.assignment_ind_outlined,
            ),
            modulosBase[0],
            ModuloRecomendado(
              titulo: 'Reportes oficiales',
              descripcion:
                  'Exportaciones por curso, alumno, ciclo lectivo y cierres administrativos.',
              estado: 'Activo',
              icono: Icons.summarize_outlined,
            ),
          ],
          permisos: permisos,
        );
      case RolInstitucional.director:
      case RolInstitucional.rector:
        return PerfilInstitucionalResumen(
          titulo: '${rol.etiqueta} con vista institucional',
          resumen:
              'La lectura directiva debe unir operacion diaria, tendencias, alertas y capacidad de accion.',
          foco:
              'Necesita un tablero transversal que combine asistencia, cobertura academica, pendientes y evidencia de gestion.',
          prioridades: [
            PrioridadOperativa(
              titulo: 'Indicadores de riesgo',
              descripcion:
                  'Cruzar ausentismo, cursos sin clase registrada y alumnos con seguimiento critico.',
              icono: Icons.monitor_heart_outlined,
              impacto: 'Critico',
            ),
            PrioridadOperativa(
              titulo: 'Lectura por sede o nivel',
              descripcion:
                  'Poder bajar del total institucional al curso o actor responsable.',
              icono: Icons.account_tree_outlined,
              impacto: 'Alto',
            ),
            ...prioridadesBase,
          ],
          modulos: [
            modulosBase[0],
            ModuloRecomendado(
              titulo: 'Tablero de gestion',
              descripcion:
                  'Indicadores diarios, comparativas temporales y alertas accionables.',
              estado: 'Proximo',
              icono: Icons.insights_outlined,
            ),
            ModuloRecomendado(
              titulo: 'Auditoria institucional',
              descripcion:
                  'Registro de cambios, cierres, decisiones y evidencia administrativa.',
              estado: 'Proximo',
              icono: Icons.policy_outlined,
            ),
            modulosBase[3],
          ],
          permisos: permisos,
        );
      case RolInstitucional.bibliotecario:
        return PerfilInstitucionalResumen(
          titulo: 'Biblioteca integrada a la institucion',
          resumen:
              'El bibliotecario necesita visibilidad de alumnos, cursos y recursos para acompanar la trayectoria.',
          foco:
              'Debe articular prestamos, materiales y acompanamiento con contexto academico.',
          prioridades: [
            PrioridadOperativa(
              titulo: 'Recursos por curso',
              descripcion:
                  'Vincular materiales y prestamos con materias, cohortes y necesidades reales.',
              icono: Icons.library_books_outlined,
              impacto: 'Alto',
            ),
            ...prioridadesBase,
          ],
          modulos: [
            ModuloRecomendado(
              titulo: 'Biblioteca y prestamos',
              descripcion:
                  'Inventario, prestamos, devoluciones y vinculacion con alumnos.',
              estado: 'Proximo',
              icono: Icons.local_library_outlined,
            ),
            modulosBase[0],
            modulosBase[3],
          ],
          permisos: permisos,
        );
      case RolInstitucional.tecnico:
        return PerfilInstitucionalResumen(
          titulo: 'Soporte tecnico institucional',
          resumen:
              'El area tecnica necesita resolver incidencias sin quedar fuera del pulso academico.',
          foco:
              'Debe registrar equipos, conectividad, solicitudes y criticidad por sector.',
          prioridades: [
            PrioridadOperativa(
              titulo: 'Mesa de ayuda',
              descripcion:
                  'Canalizar incidentes y vincularlos con sede, aula, actor y urgencia.',
              icono: Icons.support_agent_outlined,
              impacto: 'Critico',
            ),
            ...prioridadesBase,
          ],
          modulos: [
            ModuloRecomendado(
              titulo: 'Infraestructura y soporte',
              descripcion:
                  'Incidentes, equipos, conectividad y mantenimientos programados.',
              estado: 'Proximo',
              icono: Icons.settings_suggest_outlined,
            ),
            modulosBase[0],
            modulosBase[3],
          ],
          permisos: permisos,
        );
      case RolInstitucional.coordinador:
        return PerfilInstitucionalResumen(
          titulo: 'Coordinacion academica institucional',
          resumen:
              'La coordinacion necesita una capa de articulacion entre docentes, alumnos y direccion.',
          foco:
              'Debe convertir informacion dispersa en decisiones y acuerdos pedagogicos concretos.',
          prioridades: [
            PrioridadOperativa(
              titulo: 'Seguimiento de cohortes',
              descripcion:
                  'Leer trayectorias por grupo, materia y periodo con criterio de intervencion.',
              icono: Icons.groups_2_outlined,
              impacto: 'Alto',
            ),
            ...prioridadesBase,
          ],
          modulos: [
            modulosBase[2],
            ModuloRecomendado(
              titulo: 'Acuerdos y articulacion',
              descripcion:
                  'Seguimiento de compromisos, reuniones y acciones por equipo docente.',
              estado: 'Proximo',
              icono: Icons.handshake_outlined,
            ),
            modulosBase[0],
          ],
          permisos: permisos,
        );
    }
  }
}
