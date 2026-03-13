import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tablas/tabla_alumnos.dart';
import 'tablas/tabla_instituciones.dart';
import 'tablas/tabla_carreras.dart';
import 'tablas/tabla_materias.dart';
import 'tablas/tabla_cursos.dart';
import 'tablas/tabla_inscripciones.dart';
import 'tablas/tabla_clases.dart';
import 'tablas/tabla_asistencias.dart';
import 'tablas/tabla_notas_manuales.dart';

part 'base_de_datos.g.dart';

@DriftDatabase(
  tables: [
    TablaAlumnos,
    TablaInstituciones,
    TablaCarreras,
    TablaMaterias,
    TablaCursos,
    TablaInscripciones,
    TablaClases,
    TablaAsistencias,
    TablaNotasManuales,
  ],
)
class BaseDeDatos extends _$BaseDeDatos {
  BaseDeDatos() : super(_abrirConexion());

  @override
  int get schemaVersion => 31;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _crearTablasAgendaDocenteSiFaltan();
      await _crearTablasSeguimientoPedagogicoSiFaltan();
      await _crearTablasEvaluacionesSiFaltan();
      await _adaptarEvaluacionesPorInstanciaSiFalta();
      await _crearTablaEvidenciasSiFalta();
      await _crearTablaPlantillasDocentesSiFalta();
      await _crearTablaAcuerdosConvivenciaSiFalta();
      await _crearTablaReglasInstitucionSiFalta();
      await _normalizarCatalogoMateriasSiHaceFalta();
      await _agregarCamposBitacoraClaseSiFaltan();
      await _crearTablaPerfilEstableCursoSiFalta();
      await _crearTablaRubricasSimplesSiFalta();
      await _crearTablaAuditoriaDocenteSiFalta();
    },
    onUpgrade: (m, from, to) async {
      Future<void> ejecutarPaso(
        String nombre,
        Future<void> Function() paso,
      ) async {
        try {
          await paso();
        } catch (e, st) {
          stderr.writeln('[DB][MIGRATION][$nombre] $e');
          stderr.writeln(st);
        }
      }

      if (from < 9) {
        await ejecutarPaso('from<9 _crearTablasAsistenciaSiFaltan', () async {
          await _crearTablasAsistenciaSiFaltan();
        });
      }
      if (from < 11) {
        await ejecutarPaso('from<11 _crearTablasCatalogosSiFaltan', () async {
          await _crearTablasCatalogosSiFaltan();
        });
      }
      if (from < 12) {
        await ejecutarPaso(
          'from<12 _adaptarCatalogoCarrerasSiHaceFalta',
          () async {
            await _adaptarCatalogoCarrerasSiHaceFalta();
          },
        );
      }
      if (from < 13) {
        await ejecutarPaso(
          'from<13 _repararTablaMateriasSiHaceFalta',
          () async {
            await _repararTablaMateriasSiHaceFalta();
          },
        );
      }
      if (from < 14) {
        await ejecutarPaso('from<14 _agregarEdadAlumnosSiFalta', () async {
          await _agregarEdadAlumnosSiFalta();
        });
      }
      if (from < 15) {
        await ejecutarPaso('from<15 _crearTablaNotasManualesSiFalta', () async {
          await _crearTablaNotasManualesSiFalta();
        });
      }
      if (from < 16) {
        await ejecutarPaso(
          'from<16 _agregarCamposDetalleAsistenciaSiFaltan',
          () async {
            await _agregarCamposDetalleAsistenciaSiFaltan();
          },
        );
      }
      if (from < 17) {
        await ejecutarPaso(
          'from<17 _crearTablasAgendaDocenteSiFaltan',
          () async {
            await _crearTablasAgendaDocenteSiFaltan();
          },
        );
      }
      if (from < 18) {
        await ejecutarPaso(
          'from<18 _crearTablasAgendaDocenteSiFaltan',
          () async {
            await _crearTablasAgendaDocenteSiFaltan();
          },
        );
      }
      if (from < 19) {
        await ejecutarPaso(
          'from<19 _crearTablasSeguimientoPedagogicoSiFaltan',
          () async {
            await _crearTablasSeguimientoPedagogicoSiFaltan();
          },
        );
      }
      if (from < 20) {
        await ejecutarPaso(
          'from<20 _crearTablasEvaluacionesSiFaltan',
          () async {
            await _crearTablasEvaluacionesSiFaltan();
          },
        );
      }
      if (from < 21) {
        await ejecutarPaso('from<21 _crearTablaEvidenciasSiFalta', () async {
          await _crearTablaEvidenciasSiFalta();
        });
      }
      if (from < 22) {
        await ejecutarPaso(
          'from<22 _crearTablaPlantillasDocentesSiFalta',
          () async {
            await _crearTablaPlantillasDocentesSiFalta();
          },
        );
      }
      if (from < 23) {
        await ejecutarPaso(
          'from<23 _crearTablaAcuerdosConvivenciaSiFalta',
          () async {
            await _crearTablaAcuerdosConvivenciaSiFalta();
          },
        );
        await ejecutarPaso(
          'from<23 _crearTablaReglasInstitucionSiFalta',
          () async {
            await _crearTablaReglasInstitucionSiFalta();
          },
        );
      }
      if (from < 24) {
        await ejecutarPaso(
          'from<24 _crearTablasEvaluacionesSiFaltan',
          () async {
            await _crearTablasEvaluacionesSiFaltan();
          },
        );
        await ejecutarPaso(
          'from<24 _adaptarEvaluacionesPorInstanciaSiFalta',
          () async {
            await _adaptarEvaluacionesPorInstanciaSiFalta();
          },
        );
        await ejecutarPaso(
          'from<24 _crearTablaReglasInstitucionSiFalta',
          () async {
            await _crearTablaReglasInstitucionSiFalta();
          },
        );
      }
      if (from < 25) {
        await ejecutarPaso('from<25 _crearTablaEvidenciasSiFalta', () async {
          await _crearTablaEvidenciasSiFalta();
        });
      }
      if (from < 26) {
        await ejecutarPaso(
          'from<26 _agregarCamposBitacoraClaseSiFaltan',
          () async {
            await _agregarCamposBitacoraClaseSiFaltan();
          },
        );
      }
      if (from < 27) {
        await ejecutarPaso(
          'from<27 _crearTablaPerfilEstableCursoSiFalta',
          () async {
            await _crearTablaPerfilEstableCursoSiFalta();
          },
        );
      }
      if (from < 28) {
        await ejecutarPaso(
          'from<28 _crearTablaRubricasSimplesSiFalta',
          () async {
            await _crearTablaRubricasSimplesSiFalta();
          },
        );
        await ejecutarPaso(
          'from<28 _crearTablaAuditoriaDocenteSiFalta',
          () async {
            await _crearTablaAuditoriaDocenteSiFalta();
          },
        );
      }
      if (from < 29) {
        await ejecutarPaso(
          'from<29 _crearTablaReglasInstitucionSiFalta',
          () async {
            await _crearTablaReglasInstitucionSiFalta();
          },
        );
      }
      if (from < 30) {
        await ejecutarPaso(
          'from<30 _normalizarCatalogoMateriasSiHaceFalta',
          () async {
            await _normalizarCatalogoMateriasSiHaceFalta();
          },
        );
      }
      if (from < 31) {
        await ejecutarPaso(
          'from<31 _normalizarCatalogoMateriasSiHaceFalta',
          () async {
            await _normalizarCatalogoMateriasSiHaceFalta();
          },
        );
      }

      // Sanidad final: asegura que el nucleo (catalogos + alumnos + asistencia)
      // quede operativo incluso si algun paso opcional falla en esquemas legacy.
      await ejecutarPaso('final _crearTablasCatalogosSiFaltan', () async {
        await _crearTablasCatalogosSiFaltan();
      });
      await ejecutarPaso('final _adaptarCatalogoCarrerasSiHaceFalta', () async {
        await _adaptarCatalogoCarrerasSiHaceFalta();
      });
      await ejecutarPaso('final _repararTablaMateriasSiHaceFalta', () async {
        await _repararTablaMateriasSiHaceFalta();
      });
      await ejecutarPaso('final _agregarEdadAlumnosSiFalta', () async {
        await _agregarEdadAlumnosSiFalta();
      });
      await ejecutarPaso('final _crearTablaNotasManualesSiFalta', () async {
        await _crearTablaNotasManualesSiFalta();
      });
      await ejecutarPaso('final _crearTablasAsistenciaSiFaltan', () async {
        await _crearTablasAsistenciaSiFaltan();
      });
      await ejecutarPaso(
        'final _agregarCamposDetalleAsistenciaSiFaltan',
        () async {
          await _agregarCamposDetalleAsistenciaSiFaltan();
        },
      );
    },
  );
  Future<void> cerrar() async => close();

  Future<void> _normalizarCatalogoMateriasSiHaceFalta() async {
    try {
      await _crearTablasCatalogosSiFaltan();
      await _adaptarCatalogoCarrerasSiHaceFalta();
      await _repararTablaMateriasSiHaceFalta();
    } catch (_) {
      // Rescate defensivo para no dejar la app inutilizable por un esquema viejo/inconsistente.
      await _reparacionCatalogoRescate();
    }
  }

  Future<void> _reparacionCatalogoRescate() async {
    await _crearTablasCatalogosSiFaltan();
    await _asegurarCarrerasGenerales();

    if (!await _existeColumna('tabla_materias', 'carrera_id')) {
      await customStatement(
        'ALTER TABLE tabla_materias ADD COLUMN carrera_id INTEGER NULL REFERENCES tabla_carreras (id)',
      );
    }
    if (!await _existeColumna('tabla_materias', 'anio_cursada')) {
      await customStatement(
        'ALTER TABLE tabla_materias ADD COLUMN anio_cursada INTEGER NULL',
      );
    }
    if (!await _existeColumna('tabla_materias', 'curso')) {
      await customStatement(
        'ALTER TABLE tabla_materias ADD COLUMN curso TEXT NULL',
      );
    }

    await customStatement(
      'UPDATE tabla_materias SET anio_cursada = 1 WHERE anio_cursada IS NULL',
    );
    await customStatement(
      "UPDATE tabla_materias SET curso = 'A' WHERE curso IS NULL OR TRIM(curso) = ''",
    );

    final tieneInstitucionId = await _existeColumna(
      'tabla_materias',
      'institucion_id',
    );
    if (tieneInstitucionId) {
      await customStatement('''
        UPDATE tabla_materias
        SET carrera_id = COALESCE(
          carrera_id,
          (
            SELECT c.id
            FROM tabla_carreras c
            WHERE c.institucion_id = tabla_materias.institucion_id
            ORDER BY c.id
            LIMIT 1
          ),
          (
            SELECT c2.id
            FROM tabla_carreras c2
            ORDER BY c2.id
            LIMIT 1
          )
        )
        WHERE carrera_id IS NULL;
      ''');
    } else {
      await customStatement('''
        UPDATE tabla_materias
        SET carrera_id = COALESCE(
          carrera_id,
          (
            SELECT c2.id
            FROM tabla_carreras c2
            ORDER BY c2.id
            LIMIT 1
          )
        )
        WHERE carrera_id IS NULL;
      ''');
    }
  }

  Future<void> _crearTablaRubricasSimplesSiFalta() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS tabla_rubricas_simples (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        institucion TEXT NULL,
        curso_id INTEGER NULL REFERENCES tabla_cursos (id) ON DELETE SET NULL,
        tipo TEXT NOT NULL DEFAULT 'trabajo_practico',
        titulo TEXT NOT NULL,
        criterios TEXT NOT NULL DEFAULT '',
        orden INTEGER NOT NULL DEFAULT 0,
        uso_count INTEGER NOT NULL DEFAULT 0,
        actualizado_en INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER))
      );
    ''');
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_rubricas_contexto ON tabla_rubricas_simples (institucion, curso_id, tipo, orden, id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_rubricas_uso ON tabla_rubricas_simples (uso_count DESC, actualizado_en DESC)',
    );
  }

  Future<void> _crearTablaAuditoriaDocenteSiFalta() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS tabla_auditoria_docente (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        entidad TEXT NOT NULL,
        entidad_id INTEGER NULL,
        campo TEXT NOT NULL,
        valor_anterior TEXT NULL,
        valor_nuevo TEXT NULL,
        contexto TEXT NULL,
        curso_id INTEGER NULL REFERENCES tabla_cursos (id) ON DELETE SET NULL,
        institucion TEXT NULL,
        usuario TEXT NOT NULL DEFAULT 'docente',
        creado_en INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER))
      );
    ''');
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_auditoria_entidad_fecha ON tabla_auditoria_docente (entidad, creado_en DESC, id DESC)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_auditoria_curso_fecha ON tabla_auditoria_docente (curso_id, creado_en DESC, id DESC)',
    );
  }

  Future<void> _crearTablaPerfilEstableCursoSiFalta() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS tabla_perfil_estable_curso (
        curso_id INTEGER NOT NULL PRIMARY KEY REFERENCES tabla_cursos (id) ON DELETE CASCADE,
        ritmo TEXT NOT NULL DEFAULT '',
        clima TEXT NOT NULL DEFAULT '',
        estrategias_funcionan TEXT NOT NULL DEFAULT '',
        dificultades_frecuentes TEXT NOT NULL DEFAULT '',
        autonomia TEXT NOT NULL DEFAULT '',
        actualizado_en INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER))
      );
    ''');
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_perfil_estable_actualizado ON tabla_perfil_estable_curso (actualizado_en DESC)',
    );
  }

  Future<void> _crearTablaAcuerdosConvivenciaSiFalta() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS tabla_acuerdos_convivencia (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        curso_id INTEGER NOT NULL REFERENCES tabla_cursos (id) ON DELETE CASCADE,
        fecha INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)),
        tipo TEXT NOT NULL DEFAULT 'acuerdo',
        descripcion TEXT NOT NULL,
        estrategia TEXT NULL,
        reiterada INTEGER NOT NULL DEFAULT 0,
        resuelta INTEGER NOT NULL DEFAULT 0,
        creado_en INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER))
      );
    ''');
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_acuerdos_convivencia_curso_fecha ON tabla_acuerdos_convivencia (curso_id, fecha DESC, id DESC)',
    );
  }

  Future<void> _crearTablaReglasInstitucionSiFalta() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS tabla_reglas_institucion (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        institucion TEXT NOT NULL UNIQUE,
        escala_calificacion TEXT NOT NULL DEFAULT 'numerica_10',
        nota_aprobacion TEXT NOT NULL DEFAULT '6',
        asistencia_minima REAL NOT NULL DEFAULT 75.0,
        max_recuperatorios INTEGER NOT NULL DEFAULT 1,
        recuperatorio_reemplaza_nota INTEGER NOT NULL DEFAULT 1,
        recuperatorio_solo_cambia_condicion INTEGER NOT NULL DEFAULT 0,
        recuperatorio_obligatorio INTEGER NOT NULL DEFAULT 0,
        ausente_justificado_no_penaliza INTEGER NOT NULL DEFAULT 1,
        regimen_asistencia TEXT NULL,
        criterios_generales TEXT NULL,
        observaciones_estandar TEXT NULL,
        actualizado_en INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER))
      );
    ''');
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_reglas_institucion_nombre ON tabla_reglas_institucion (institucion)',
    );

    if (!await _existeColumna(
      'tabla_reglas_institucion',
      'max_recuperatorios',
    )) {
      await customStatement(
        'ALTER TABLE tabla_reglas_institucion ADD COLUMN max_recuperatorios INTEGER NOT NULL DEFAULT 1',
      );
    }
    if (!await _existeColumna(
      'tabla_reglas_institucion',
      'recuperatorio_reemplaza_nota',
    )) {
      await customStatement(
        'ALTER TABLE tabla_reglas_institucion ADD COLUMN recuperatorio_reemplaza_nota INTEGER NOT NULL DEFAULT 1',
      );
    }
    if (!await _existeColumna(
      'tabla_reglas_institucion',
      'recuperatorio_solo_cambia_condicion',
    )) {
      await customStatement(
        'ALTER TABLE tabla_reglas_institucion ADD COLUMN recuperatorio_solo_cambia_condicion INTEGER NOT NULL DEFAULT 0',
      );
    }
    if (!await _existeColumna(
      'tabla_reglas_institucion',
      'recuperatorio_obligatorio',
    )) {
      await customStatement(
        'ALTER TABLE tabla_reglas_institucion ADD COLUMN recuperatorio_obligatorio INTEGER NOT NULL DEFAULT 0',
      );
    }
    if (!await _existeColumna(
      'tabla_reglas_institucion',
      'ausente_justificado_no_penaliza',
    )) {
      await customStatement(
        'ALTER TABLE tabla_reglas_institucion ADD COLUMN ausente_justificado_no_penaliza INTEGER NOT NULL DEFAULT 1',
      );
    }
    if (!await _existeColumna(
      'tabla_reglas_institucion',
      'observaciones_estandar',
    )) {
      await customStatement(
        'ALTER TABLE tabla_reglas_institucion ADD COLUMN observaciones_estandar TEXT NULL',
      );
    }
  }

  Future<void> _crearTablaPlantillasDocentesSiFalta() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS tabla_plantillas_docentes (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        institucion TEXT NULL,
        curso_id INTEGER NULL REFERENCES tabla_cursos (id) ON DELETE SET NULL,
        tipo TEXT NOT NULL DEFAULT 'mensaje_base',
        titulo TEXT NOT NULL,
        contenido TEXT NOT NULL,
        atajo TEXT NULL,
        orden INTEGER NOT NULL DEFAULT 0,
        uso_count INTEGER NOT NULL DEFAULT 0,
        creado_en INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)),
        actualizado_en INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER))
      );
    ''');
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_plantillas_docentes_contexto ON tabla_plantillas_docentes (institucion, curso_id, tipo, orden, id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_plantillas_docentes_uso ON tabla_plantillas_docentes (uso_count DESC, actualizado_en DESC)',
    );
  }

  Future<void> _crearTablaEvidenciasSiFalta() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS tabla_evidencias_docentes (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        curso_id INTEGER NOT NULL REFERENCES tabla_cursos (id) ON DELETE CASCADE,
        clase_id INTEGER NULL REFERENCES tabla_clases (id) ON DELETE SET NULL,
        alumno_id INTEGER NULL REFERENCES tabla_alumnos (id) ON DELETE SET NULL,
        evaluacion_id INTEGER NULL REFERENCES tabla_evaluaciones_curso (id) ON DELETE SET NULL,
        evaluacion_instancia_id INTEGER NULL REFERENCES tabla_evaluaciones_instancia (id) ON DELETE SET NULL,
        fecha INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)),
        tipo TEXT NOT NULL DEFAULT 'observacion',
        titulo TEXT NOT NULL,
        descripcion TEXT NULL,
        archivo_path TEXT NULL,
        creado_en INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER))
      );
    ''');
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_evidencias_curso_fecha ON tabla_evidencias_docentes (curso_id, fecha DESC, id DESC)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_evidencias_alumno_fecha ON tabla_evidencias_docentes (alumno_id, fecha DESC)',
    );
    if (!await _existeColumna('tabla_evidencias_docentes', 'evaluacion_id')) {
      await customStatement(
        'ALTER TABLE tabla_evidencias_docentes ADD COLUMN evaluacion_id INTEGER NULL',
      );
    }
    if (!await _existeColumna(
      'tabla_evidencias_docentes',
      'evaluacion_instancia_id',
    )) {
      await customStatement(
        'ALTER TABLE tabla_evidencias_docentes ADD COLUMN evaluacion_instancia_id INTEGER NULL',
      );
    }
    final tieneEvalId = await _existeColumna(
      'tabla_evidencias_docentes',
      'evaluacion_id',
    );
    final tieneEvalInstancia = await _existeColumna(
      'tabla_evidencias_docentes',
      'evaluacion_instancia_id',
    );
    if (tieneEvalId) {
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_evidencias_eval ON tabla_evidencias_docentes (evaluacion_id, fecha DESC)',
      );
    }
    if (tieneEvalInstancia) {
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_evidencias_eval_instancia ON tabla_evidencias_docentes (evaluacion_instancia_id, fecha DESC)',
      );
    }
  }

  Future<void> _crearTablasEvaluacionesSiFaltan() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS tabla_evaluaciones_curso (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        curso_id INTEGER NOT NULL REFERENCES tabla_cursos (id) ON DELETE CASCADE,
        fecha INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)),
        tipo TEXT NOT NULL,
        titulo TEXT NOT NULL,
        descripcion TEXT NULL,
        estado TEXT NOT NULL DEFAULT 'abierta',
        creado_en INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)),
        actualizado_en INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER))
      );
    ''');
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_evaluaciones_curso_fecha ON tabla_evaluaciones_curso (curso_id, fecha DESC)',
    );

    await customStatement('''
      CREATE TABLE IF NOT EXISTS tabla_evaluaciones_instancia (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        evaluacion_id INTEGER NOT NULL REFERENCES tabla_evaluaciones_curso (id) ON DELETE CASCADE,
        tipo_instancia TEXT NOT NULL DEFAULT 'original',
        orden INTEGER NOT NULL DEFAULT 0,
        fecha INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)),
        observacion TEXT NULL,
        estado TEXT NOT NULL DEFAULT 'abierta',
        creado_en INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)),
        actualizado_en INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)),
        UNIQUE (evaluacion_id, tipo_instancia),
        UNIQUE (evaluacion_id, orden)
      );
    ''');
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_eval_instancia_eval_orden ON tabla_evaluaciones_instancia (evaluacion_id, orden ASC)',
    );

    await customStatement('''
      CREATE TABLE IF NOT EXISTS tabla_evaluaciones_alumno (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        evaluacion_id INTEGER NOT NULL REFERENCES tabla_evaluaciones_curso (id) ON DELETE CASCADE,
        evaluacion_instancia_id INTEGER NOT NULL REFERENCES tabla_evaluaciones_instancia (id) ON DELETE CASCADE,
        alumno_id INTEGER NOT NULL REFERENCES tabla_alumnos (id) ON DELETE CASCADE,
        estado TEXT NOT NULL DEFAULT 'pendiente',
        calificacion TEXT NULL,
        entrega_complementaria INTEGER NOT NULL DEFAULT 0,
        ausente_justificado INTEGER NOT NULL DEFAULT 0,
        observacion TEXT NULL,
        actualizado_en INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)),
        UNIQUE (evaluacion_instancia_id, alumno_id)
      );
    ''');
    final tieneInstanciaEnEvaluacionesAlumno = await _existeColumna(
      'tabla_evaluaciones_alumno',
      'evaluacion_instancia_id',
    );
    if (tieneInstanciaEnEvaluacionesAlumno) {
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_eval_alumno_eval ON tabla_evaluaciones_alumno (evaluacion_id, evaluacion_instancia_id, estado)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_eval_alumno_alumno ON tabla_evaluaciones_alumno (alumno_id, evaluacion_id, evaluacion_instancia_id)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_eval_alumno_instancia ON tabla_evaluaciones_alumno (evaluacion_instancia_id, alumno_id)',
      );
    } else {
      // Compatibilidad con esquema previo (sin evaluacion_instancia_id).
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_eval_alumno_eval_legacy ON tabla_evaluaciones_alumno (evaluacion_id, estado)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_eval_alumno_alumno_legacy ON tabla_evaluaciones_alumno (alumno_id, evaluacion_id)',
      );
    }
  }

  Future<void> _adaptarEvaluacionesPorInstanciaSiFalta() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS tabla_evaluaciones_instancia (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        evaluacion_id INTEGER NOT NULL REFERENCES tabla_evaluaciones_curso (id) ON DELETE CASCADE,
        tipo_instancia TEXT NOT NULL DEFAULT 'original',
        orden INTEGER NOT NULL DEFAULT 0,
        fecha INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)),
        observacion TEXT NULL,
        estado TEXT NOT NULL DEFAULT 'abierta',
        creado_en INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)),
        actualizado_en INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)),
        UNIQUE (evaluacion_id, tipo_instancia),
        UNIQUE (evaluacion_id, orden)
      );
    ''');
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_eval_instancia_eval_orden ON tabla_evaluaciones_instancia (evaluacion_id, orden ASC)',
    );

    final tieneInstanciaEnEvaluacionesAlumno = await _existeColumna(
      'tabla_evaluaciones_alumno',
      'evaluacion_instancia_id',
    );
    final tieneAusenteJustificadoEnEvaluacionesAlumno = await _existeColumna(
      'tabla_evaluaciones_alumno',
      'ausente_justificado',
    );
    final requiereRebuild = await _evaluacionesAlumnoRequiereRebuild();
    if (requiereRebuild) {
      await customStatement('''
        INSERT INTO tabla_evaluaciones_instancia (
          evaluacion_id,
          tipo_instancia,
          orden,
          fecha,
          observacion,
          estado,
          creado_en,
          actualizado_en
        )
        SELECT
          e.id,
          'original',
          0,
          e.fecha,
          e.descripcion,
          COALESCE(NULLIF(TRIM(e.estado), ''), 'abierta'),
          e.creado_en,
          e.actualizado_en
        FROM tabla_evaluaciones_curso e
        WHERE NOT EXISTS (
          SELECT 1
          FROM tabla_evaluaciones_instancia i
          WHERE i.evaluacion_id = e.id
        );
      ''');

      await customStatement('''
        CREATE TABLE IF NOT EXISTS tabla_evaluaciones_alumno_tmp (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          evaluacion_id INTEGER NOT NULL REFERENCES tabla_evaluaciones_curso (id) ON DELETE CASCADE,
          evaluacion_instancia_id INTEGER NOT NULL REFERENCES tabla_evaluaciones_instancia (id) ON DELETE CASCADE,
          alumno_id INTEGER NOT NULL REFERENCES tabla_alumnos (id) ON DELETE CASCADE,
          estado TEXT NOT NULL DEFAULT 'pendiente',
          calificacion TEXT NULL,
          entrega_complementaria INTEGER NOT NULL DEFAULT 0,
          ausente_justificado INTEGER NOT NULL DEFAULT 0,
          observacion TEXT NULL,
          actualizado_en INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)),
          UNIQUE (evaluacion_instancia_id, alumno_id)
        );
      ''');

      final exprInstancia = tieneInstanciaEnEvaluacionesAlumno
          ? 'ea.evaluacion_instancia_id'
          : 'NULL';
      final exprAusenteJustificado = tieneAusenteJustificadoEnEvaluacionesAlumno
          ? 'ea.ausente_justificado'
          : '0';

      await customStatement('''
        INSERT OR REPLACE INTO tabla_evaluaciones_alumno_tmp (
          id,
          evaluacion_id,
          evaluacion_instancia_id,
          alumno_id,
          estado,
          calificacion,
          entrega_complementaria,
          ausente_justificado,
          observacion,
          actualizado_en
        )
        SELECT
          ea.id,
          ea.evaluacion_id,
          COALESCE(
            $exprInstancia,
            (
              SELECT i.id
              FROM tabla_evaluaciones_instancia i
              WHERE i.evaluacion_id = ea.evaluacion_id
              ORDER BY i.orden ASC, i.id ASC
              LIMIT 1
            )
          ) AS evaluacion_instancia_id,
          ea.alumno_id,
          COALESCE(NULLIF(TRIM(ea.estado), ''), 'pendiente') AS estado,
          ea.calificacion,
          COALESCE(ea.entrega_complementaria, 0) AS entrega_complementaria,
          COALESCE($exprAusenteJustificado, 0) AS ausente_justificado,
          ea.observacion,
          COALESCE(ea.actualizado_en, CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)) AS actualizado_en
        FROM tabla_evaluaciones_alumno ea;
      ''');

      await customStatement('PRAGMA foreign_keys = OFF');
      try {
        await customStatement('DROP TABLE tabla_evaluaciones_alumno');
        await customStatement(
          'ALTER TABLE tabla_evaluaciones_alumno_tmp RENAME TO tabla_evaluaciones_alumno',
        );
      } finally {
        await customStatement('PRAGMA foreign_keys = ON');
      }
    } else if (!await _existeColumna(
      'tabla_evaluaciones_alumno',
      'ausente_justificado',
    )) {
      await customStatement(
        'ALTER TABLE tabla_evaluaciones_alumno ADD COLUMN ausente_justificado INTEGER NOT NULL DEFAULT 0',
      );
    }

    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_eval_alumno_eval ON tabla_evaluaciones_alumno (evaluacion_id, evaluacion_instancia_id, estado)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_eval_alumno_alumno ON tabla_evaluaciones_alumno (alumno_id, evaluacion_id, evaluacion_instancia_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_eval_alumno_instancia ON tabla_evaluaciones_alumno (evaluacion_instancia_id, alumno_id)',
    );

    await customStatement('''
      INSERT INTO tabla_evaluaciones_instancia (
        evaluacion_id,
        tipo_instancia,
        orden,
        fecha,
        observacion,
        estado,
        creado_en,
        actualizado_en
      )
      SELECT
        e.id,
        'original',
        0,
        e.fecha,
        e.descripcion,
        COALESCE(NULLIF(TRIM(e.estado), ''), 'abierta'),
        e.creado_en,
        e.actualizado_en
      FROM tabla_evaluaciones_curso e
      WHERE NOT EXISTS (
        SELECT 1
        FROM tabla_evaluaciones_instancia i
        WHERE i.evaluacion_id = e.id
      );
    ''');

    await customStatement('''
      UPDATE tabla_evaluaciones_alumno
      SET evaluacion_instancia_id = (
        SELECT i.id
        FROM tabla_evaluaciones_instancia i
        WHERE i.evaluacion_id = tabla_evaluaciones_alumno.evaluacion_id
        ORDER BY i.orden ASC, i.id ASC
        LIMIT 1
      )
      WHERE evaluacion_instancia_id IS NULL;
    ''');
  }

  Future<void> _crearTablasSeguimientoPedagogicoSiFaltan() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS tabla_ficha_pedagogica_curso (
        curso_id INTEGER NOT NULL PRIMARY KEY REFERENCES tabla_cursos (id) ON DELETE CASCADE,
        contenidos_dados TEXT NOT NULL DEFAULT '',
        contenidos_pendientes TEXT NOT NULL DEFAULT '',
        ritmo_grupo TEXT NOT NULL DEFAULT '',
        observaciones_generales TEXT NOT NULL DEFAULT '',
        alertas_didacticas TEXT NOT NULL DEFAULT '',
        actualizado_en INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER))
      );
    ''');

    await customStatement('''
      CREATE TABLE IF NOT EXISTS tabla_contenidos_curso (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        curso_id INTEGER NOT NULL REFERENCES tabla_cursos (id) ON DELETE CASCADE,
        contenido TEXT NOT NULL,
        estado TEXT NOT NULL DEFAULT 'pendiente',
        orden INTEGER NOT NULL DEFAULT 0,
        actualizado_en INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER))
      );
    ''');
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_contenidos_curso_orden ON tabla_contenidos_curso (curso_id, orden, id)',
    );
  }

  Future<void> _crearTablasAgendaDocenteSiFaltan() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS tabla_horarios_curso (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        curso_id INTEGER NOT NULL REFERENCES tabla_cursos (id) ON DELETE CASCADE,
        dia_semana INTEGER NOT NULL,
        hora_inicio TEXT NOT NULL,
        hora_fin TEXT NULL,
        aula TEXT NULL,
        activo INTEGER NOT NULL DEFAULT 1,
        creado_en INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER))
      );
    ''');
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_horarios_curso_dia ON tabla_horarios_curso (curso_id, dia_semana, activo)',
    );

    await customStatement('''
      CREATE TABLE IF NOT EXISTS tabla_intervenciones_docentes (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        curso_id INTEGER NULL REFERENCES tabla_cursos (id) ON DELETE CASCADE,
        alumno_id INTEGER NULL REFERENCES tabla_alumnos (id) ON DELETE SET NULL,
        fecha INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)),
        tipo TEXT NOT NULL,
        descripcion TEXT NOT NULL,
        seguimiento TEXT NULL,
        resuelta INTEGER NOT NULL DEFAULT 0,
        creado_en INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER))
      );
    ''');
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_intervenciones_curso_fecha ON tabla_intervenciones_docentes (curso_id, fecha DESC)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_intervenciones_alumno_fecha ON tabla_intervenciones_docentes (alumno_id, fecha DESC)',
    );

    await customStatement('''
      CREATE TABLE IF NOT EXISTS tabla_alertas_docentes_snooze (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        clave TEXT NOT NULL UNIQUE,
        pospuesta_hasta INTEGER NOT NULL,
        creado_en INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER))
      );
    ''');
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_alertas_snooze_hasta ON tabla_alertas_docentes_snooze (pospuesta_hasta)',
    );
  }

  Future<void> _crearTablaNotasManualesSiFalta() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS tabla_notas_manuales (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        alumno_id INTEGER NOT NULL REFERENCES tabla_alumnos (id) ON DELETE CASCADE,
        curso_id INTEGER NULL,
        clave_contexto TEXT NOT NULL,
        nota TEXT NOT NULL DEFAULT '',
        actualizado_en INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)),
        UNIQUE (alumno_id, clave_contexto)
      );
    ''');
  }

  Future<void> _crearTablasAsistenciaSiFaltan() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS tabla_alumnos (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        apellido TEXT NOT NULL,
        nombre TEXT NOT NULL,
        edad INTEGER NULL,
        documento TEXT NULL,
        email TEXT NULL,
        telefono TEXT NULL,
        foto_path TEXT NULL,
        activo INTEGER NOT NULL DEFAULT 1,
        creado_en INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER))
      );
    ''');

    await customStatement('''
      CREATE TABLE IF NOT EXISTS tabla_cursos (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        division TEXT NULL,
        materia TEXT NULL,
        turno TEXT NULL,
        anio INTEGER NULL,
        activo INTEGER NOT NULL DEFAULT 1,
        creado_en INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER))
      );
    ''');

    await customStatement('''
      CREATE TABLE IF NOT EXISTS tabla_inscripciones (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        alumno_id INTEGER NOT NULL REFERENCES tabla_alumnos (id) ON DELETE CASCADE,
        curso_id INTEGER NOT NULL REFERENCES tabla_cursos (id) ON DELETE CASCADE,
        fecha_alta INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)),
        activo INTEGER NOT NULL DEFAULT 1,
        UNIQUE (alumno_id, curso_id)
      );
    ''');

    await customStatement('''
      CREATE TABLE IF NOT EXISTS tabla_clases (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        curso_id INTEGER NOT NULL REFERENCES tabla_cursos (id) ON DELETE CASCADE,
        fecha INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)),
        tema TEXT NULL,
        observacion TEXT NULL,
        actividad_dia TEXT NULL,
        estado_contenido TEXT NULL,
        resultado_actividad TEXT NULL
      );
    ''');

    await customStatement('''
      CREATE TABLE IF NOT EXISTS tabla_asistencias (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        clase_id INTEGER NOT NULL REFERENCES tabla_clases (id) ON DELETE CASCADE,
        alumno_id INTEGER NOT NULL REFERENCES tabla_alumnos (id) ON DELETE CASCADE,
        estado TEXT NOT NULL DEFAULT 'presente',
        observacion TEXT NULL,
        justificada INTEGER NOT NULL DEFAULT 0,
        detalle_justificacion TEXT NULL,
        actividad_entregada INTEGER NOT NULL DEFAULT 0,
        nota_actividad TEXT NULL,
        detalle_actividad TEXT NULL,
        registrado_en INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)),
        UNIQUE (clase_id, alumno_id)
      );
    ''');
  }

  Future<void> _agregarCamposDetalleAsistenciaSiFaltan() async {
    if (!await _existeColumna('tabla_clases', 'actividad_dia')) {
      await customStatement(
        'ALTER TABLE tabla_clases ADD COLUMN actividad_dia TEXT NULL',
      );
    }

    if (!await _existeColumna('tabla_asistencias', 'justificada')) {
      await customStatement(
        'ALTER TABLE tabla_asistencias ADD COLUMN justificada INTEGER NOT NULL DEFAULT 0',
      );
    }
    if (!await _existeColumna('tabla_asistencias', 'detalle_justificacion')) {
      await customStatement(
        'ALTER TABLE tabla_asistencias ADD COLUMN detalle_justificacion TEXT NULL',
      );
    }
    if (!await _existeColumna('tabla_asistencias', 'actividad_entregada')) {
      await customStatement(
        'ALTER TABLE tabla_asistencias ADD COLUMN actividad_entregada INTEGER NOT NULL DEFAULT 0',
      );
    }
    if (!await _existeColumna('tabla_asistencias', 'nota_actividad')) {
      await customStatement(
        'ALTER TABLE tabla_asistencias ADD COLUMN nota_actividad TEXT NULL',
      );
    }
    if (!await _existeColumna('tabla_asistencias', 'detalle_actividad')) {
      await customStatement(
        'ALTER TABLE tabla_asistencias ADD COLUMN detalle_actividad TEXT NULL',
      );
    }

    if (!await _existeColumna('tabla_alumnos', 'foto_path')) {
      await customStatement(
        'ALTER TABLE tabla_alumnos ADD COLUMN foto_path TEXT NULL',
      );
    }
  }

  Future<void> _agregarCamposBitacoraClaseSiFaltan() async {
    if (!await _existeColumna('tabla_clases', 'estado_contenido')) {
      await customStatement(
        'ALTER TABLE tabla_clases ADD COLUMN estado_contenido TEXT NULL',
      );
    }
    if (!await _existeColumna('tabla_clases', 'resultado_actividad')) {
      await customStatement(
        'ALTER TABLE tabla_clases ADD COLUMN resultado_actividad TEXT NULL',
      );
    }
  }

  Future<void> _agregarEdadAlumnosSiFalta() async {
    if (!await _existeColumna('tabla_alumnos', 'edad')) {
      await customStatement(
        'ALTER TABLE tabla_alumnos ADD COLUMN edad INTEGER NULL',
      );
    }
  }

  Future<void> _crearTablasCatalogosSiFaltan() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS tabla_instituciones (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        activo INTEGER NOT NULL DEFAULT 1,
        creado_en INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)),
        UNIQUE (nombre)
      );
    ''');

    await customStatement('''
      CREATE TABLE IF NOT EXISTS tabla_carreras (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        institucion_id INTEGER NOT NULL REFERENCES tabla_instituciones (id) ON DELETE CASCADE,
        nombre TEXT NOT NULL,
        activo INTEGER NOT NULL DEFAULT 1,
        creado_en INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)),
        UNIQUE (institucion_id, nombre)
      );
    ''');

    await customStatement('''
      CREATE TABLE IF NOT EXISTS tabla_materias (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        institucion_id INTEGER NOT NULL REFERENCES tabla_instituciones (id) ON DELETE CASCADE,
        nombre TEXT NOT NULL,
        activo INTEGER NOT NULL DEFAULT 1,
        creado_en INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)),
        UNIQUE (institucion_id, nombre)
      );
    ''');

    if (!await _existeColumna('tabla_cursos', 'institucion_id')) {
      await customStatement(
        'ALTER TABLE tabla_cursos ADD COLUMN institucion_id INTEGER NULL REFERENCES tabla_instituciones (id)',
      );
    }

    if (!await _existeColumna('tabla_cursos', 'materia_id')) {
      await customStatement(
        'ALTER TABLE tabla_cursos ADD COLUMN materia_id INTEGER NULL REFERENCES tabla_materias (id)',
      );
    }
  }

  Future<void> _adaptarCatalogoCarrerasSiHaceFalta() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS tabla_carreras (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        institucion_id INTEGER NOT NULL REFERENCES tabla_instituciones (id) ON DELETE CASCADE,
        nombre TEXT NOT NULL,
        activo INTEGER NOT NULL DEFAULT 1,
        creado_en INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)),
        UNIQUE (institucion_id, nombre)
      );
    ''');

    if (!await _existeColumna('tabla_materias', 'carrera_id')) {
      await customStatement(
        'ALTER TABLE tabla_materias ADD COLUMN carrera_id INTEGER NULL REFERENCES tabla_carreras (id)',
      );
    }
    if (!await _existeColumna('tabla_materias', 'anio_cursada')) {
      await customStatement(
        'ALTER TABLE tabla_materias ADD COLUMN anio_cursada INTEGER NULL',
      );
    }
    if (!await _existeColumna('tabla_materias', 'curso')) {
      await customStatement(
        'ALTER TABLE tabla_materias ADD COLUMN curso TEXT NULL',
      );
    }

    if (!await _existeColumna('tabla_cursos', 'carrera_id')) {
      await customStatement(
        'ALTER TABLE tabla_cursos ADD COLUMN carrera_id INTEGER NULL REFERENCES tabla_carreras (id)',
      );
    }

    if (!await _existeColumna('tabla_alumnos', 'institucion_id')) {
      await customStatement(
        'ALTER TABLE tabla_alumnos ADD COLUMN institucion_id INTEGER NULL REFERENCES tabla_instituciones (id)',
      );
    }
    if (!await _existeColumna('tabla_alumnos', 'carrera_id')) {
      await customStatement(
        'ALTER TABLE tabla_alumnos ADD COLUMN carrera_id INTEGER NULL REFERENCES tabla_carreras (id)',
      );
    }

    await _asegurarCarrerasGenerales();

    final tieneInstitucionIdEnMaterias = await _existeColumna(
      'tabla_materias',
      'institucion_id',
    );
    if (tieneInstitucionIdEnMaterias) {
      await customStatement('''
        UPDATE tabla_materias
        SET carrera_id = (
          SELECT c.id
          FROM tabla_carreras c
          WHERE c.institucion_id = tabla_materias.institucion_id
          ORDER BY c.id
          LIMIT 1
        )
        WHERE carrera_id IS NULL;
      ''');
    }

    await customStatement(
      'UPDATE tabla_materias SET anio_cursada = 1 WHERE anio_cursada IS NULL',
    );
    await customStatement(
      "UPDATE tabla_materias SET curso = 'A' WHERE curso IS NULL OR TRIM(curso) = ''",
    );
  }

  Future<void> _repararTablaMateriasSiHaceFalta() async {
    final existeInstitucionIdEnMaterias = await _existeColumna(
      'tabla_materias',
      'institucion_id',
    );
    if (!existeInstitucionIdEnMaterias) return;

    await _asegurarCarrerasGenerales();

    final tieneCarreraId = await _existeColumna('tabla_materias', 'carrera_id');
    final tieneAnio = await _existeColumna('tabla_materias', 'anio_cursada');
    final tieneCurso = await _existeColumna('tabla_materias', 'curso');
    final tieneActivo = await _existeColumna('tabla_materias', 'activo');
    final tieneCreadoEn = await _existeColumna('tabla_materias', 'creado_en');

    final carreraExpr = tieneCarreraId ? 'm.carrera_id' : 'NULL';
    final anioExpr = tieneAnio ? 'm.anio_cursada' : 'NULL';
    final cursoExpr = tieneCurso ? 'm.curso' : 'NULL';
    final activoExpr = tieneActivo ? 'm.activo' : '1';
    final creadoEnExpr = tieneCreadoEn
        ? 'm.creado_en'
        : "CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)";

    await customStatement('''
      CREATE TABLE IF NOT EXISTS tabla_materias_tmp (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        carrera_id INTEGER NOT NULL REFERENCES tabla_carreras (id) ON DELETE CASCADE,
        nombre TEXT NOT NULL,
        anio_cursada INTEGER NOT NULL,
        curso TEXT NOT NULL,
        activo INTEGER NOT NULL DEFAULT 1,
        creado_en INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)),
        UNIQUE (carrera_id, nombre, anio_cursada, curso)
      );
    ''');

    await customStatement('''
      INSERT OR IGNORE INTO tabla_materias_tmp (
        id,
        carrera_id,
        nombre,
        anio_cursada,
        curso,
        activo,
        creado_en
      )
      SELECT
        m.id,
        COALESCE(
          $carreraExpr,
          (
            SELECT c.id
            FROM tabla_carreras c
            WHERE c.institucion_id = m.institucion_id
            ORDER BY c.id
            LIMIT 1
          ),
          (
            SELECT c2.id
            FROM tabla_carreras c2
            ORDER BY c2.id
            LIMIT 1
          )
        ) AS carrera_id,
        m.nombre,
        COALESCE($anioExpr, 1) AS anio_cursada,
        COALESCE(NULLIF(TRIM($cursoExpr), ''), 'A') AS curso,
        COALESCE($activoExpr, 1) AS activo,
        COALESCE($creadoEnExpr, CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)) AS creado_en
      FROM tabla_materias m;
    ''');

    await customStatement('PRAGMA foreign_keys = OFF');
    try {
      await customStatement('DROP TABLE tabla_materias');
      await customStatement(
        'ALTER TABLE tabla_materias_tmp RENAME TO tabla_materias',
      );
    } finally {
      await customStatement('PRAGMA foreign_keys = ON');
    }
  }

  Future<void> _asegurarCarrerasGenerales() async {
    final instituciones = await customSelect(
      'SELECT id FROM tabla_instituciones',
    ).get();
    for (final row in instituciones) {
      final instId = row.read<int>('id');
      await customStatement(
        "INSERT OR IGNORE INTO tabla_carreras (institucion_id, nombre, activo, creado_en) VALUES ($instId, 'General', 1, CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER))",
      );
    }
  }

  Future<bool> _existeColumna(String tabla, String columna) async {
    final rows = await customSelect('PRAGMA table_info($tabla)').get();
    for (final row in rows) {
      final nombre = row.read<String>('name');
      if (nombre == columna) return true;
    }
    return false;
  }

  Future<bool> _evaluacionesAlumnoRequiereRebuild() async {
    final existeInstancia = await _existeColumna(
      'tabla_evaluaciones_alumno',
      'evaluacion_instancia_id',
    );
    if (!existeInstancia) return true;

    final row = await customSelect('''
      SELECT sql
      FROM sqlite_master
      WHERE type = 'table'
        AND name = 'tabla_evaluaciones_alumno'
      LIMIT 1
      ''').getSingleOrNull();
    if (row == null) return true;
    final sql = (row.read<String?>('sql') ?? '').toLowerCase();
    if (sql.contains('unique (evaluacion_id, alumno_id)')) return true;
    if (!sql.contains('unique (evaluacion_instancia_id, alumno_id)')) {
      return true;
    }
    return false;
  }
}

LazyDatabase _abrirConexion() {
  return LazyDatabase(() async {
    final carpeta = await getApplicationDocumentsDirectory();
    final archivo = File(p.join(carpeta.path, 'gestion_de_asistencias.sqlite'));
    return NativeDatabase(archivo);
  });
}
