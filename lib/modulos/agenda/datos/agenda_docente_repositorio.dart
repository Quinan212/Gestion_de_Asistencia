import 'dart:developer' as developer;
import 'dart:math' as math;

import 'package:drift/drift.dart';

import '/infraestructura/base_de_datos/base_de_datos.dart';

import '../modelos/acuerdo_convivencia.dart';
import '../modelos/agenda_docente_item.dart';
import '../modelos/alerta_automatica_docente.dart';
import '../modelos/auditoria_docente_item.dart';
import '../modelos/agrupamiento_pedagogico_item.dart';
import '../modelos/cierre_institucion_curso_item.dart';
import '../modelos/comparacion_temporal.dart';
import '../modelos/contenido_curso.dart';
import '../modelos/dashboard_institucion_item.dart';
import '../modelos/evento_cronologico_alumno.dart';
import '../modelos/evidencia_docente.dart';
import '../modelos/evaluacion_curso.dart';
import '../modelos/evaluacion_instancia.dart';
import '../modelos/ficha_pedagogica_curso.dart';
import '../modelos/historial_alumno_inteligente.dart';
import '../modelos/horario_curso.dart';
import '../modelos/intervencion_docente.dart';
import '../modelos/panel_pendiente_accionable.dart';
import '../modelos/perfil_estable_curso.dart';
import '../modelos/plantilla_docente.dart';
import '../modelos/regla_institucion.dart';
import '../modelos/resultado_evaluacion_alumno.dart';
import '../modelos/resumen_cierre_curso.dart';
import '../modelos/rubrica_simple.dart';
import '../modelos/sintesis_periodo.dart';

part 'agenda_docente_repositorio_agenda_horarios.dart';
part 'agenda_docente_repositorio_intervenciones_acuerdos_reglas.dart';
part 'agenda_docente_repositorio_evidencias_plantillas_agrupamiento.dart';
part 'agenda_docente_repositorio_dashboard_ficha_contenidos.dart';
part 'agenda_docente_repositorio_evaluaciones_historial.dart';
part 'agenda_docente_repositorio_cierres_alertas.dart';
part 'agenda_docente_repositorio_pendientes_cronologia.dart';
part 'agenda_docente_repositorio_sintesis_periodo.dart';
part 'agenda_docente_repositorio_perfil_comparacion.dart';
part 'agenda_docente_repositorio_helpers.dart';
part 'agenda_docente_repositorio_privados.dart';

class AgendaDocenteRepositorio {
  final BaseDeDatos _db;

  AgendaDocenteRepositorio(this._db);
}
