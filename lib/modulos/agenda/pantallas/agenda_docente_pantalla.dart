import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '/aplicacion/utiles/layout_app.dart';
import '/aplicacion/widgets/estado_lista.dart';
import '/aplicacion/widgets/panel_controles_modulo.dart';
import '/infraestructura/dep_inyeccion/proveedores.dart';
import '/infraestructura/servicios/exportacion_csv.dart';
import '/modulos/agenda/datos/agenda_docente_repositorio.dart';
import '/modulos/alumnos/modelos/alumno.dart';
import '/modulos/asistencias/modelos/clase_asistencia.dart';
import '/modulos/asistencias/modelos/estado_asistencia.dart';
import '/modulos/asistencias/modelos/registro_asistencia_alumno.dart';

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
import '../modelos/resultado_evaluacion_alumno.dart';
import '../modelos/resumen_cierre_curso.dart';
import '../modelos/rubrica_simple.dart';
import '../modelos/sintesis_periodo.dart';

part 'agenda_docente_pantalla_horarios_intervenciones.dart';
part 'agenda_docente_pantalla_acuerdos_reglas.dart';
part 'agenda_docente_pantalla_agrupamiento_plantillas.dart';
part 'agenda_docente_pantalla_evaluaciones.dart';
part 'agenda_docente_pantalla_evidencias_clase_actual.dart';
part 'agenda_docente_pantalla_ficha_dashboard.dart';
part 'agenda_docente_pantalla_cierres_helpers.dart';
part 'agenda_docente_pantalla_pendientes_cronologia.dart';
part 'agenda_docente_pantalla_sintesis_periodo.dart';
part 'agenda_docente_pantalla_perfil_estable.dart';
part 'agenda_docente_pantalla_rubricas.dart';
part 'agenda_docente_pantalla_auditoria.dart';

Widget _textoElidido(String valor, {int maxLines = 1, TextAlign? textAlign}) {
  return Text(
    valor,
    maxLines: maxLines,
    overflow: TextOverflow.ellipsis,
    textAlign: textAlign,
  );
}

DropdownMenuItem<T> _itemMenuElidido<T>(T value, String label) {
  return DropdownMenuItem<T>(value: value, child: _textoElidido(label));
}

Widget _tituloDialogoCurso(String prefijo, String tituloCurso) {
  return Text(
    '$prefijo - $tituloCurso',
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
  );
}

String _descripcionFuncionAgenda(String clave) {
  switch (clave) {
    case 'agenda':
      return 'Usa esta vista como tablero docente del dia. Desde aqui puedes ver que cursos requieren atencion, abrir la clase actual, revisar alertas y saltar a cada modulo sin recorrer varias pantallas.';
    case 'tablero':
      return 'Resume lo mas importante del dia: cantidad de cursos, asistencia pendiente, alertas altas y evaluaciones cercanas. Si aparece un curso prioritario, conviene empezar por ahi.';
    case 'automatizaciones':
      return 'Estas sugerencias se generan automaticamente segun riesgo, pendientes, asistencia y evaluaciones proximas. Sirven para decidir rapido que accion conviene hacer primero.';
    case 'acciones':
      return 'Este panel reune accesos directos a tareas transversales. Utilizalo cuando necesites ir a una funcion puntual sin abrir un curso especifico.';
    case 'filtros_agenda':
      return 'Filtra la agenda por institucion o nivel de riesgo para concentrarte en un subconjunto de cursos. La lista central se actualiza en base a estos criterios.';
    case 'alertas':
      return 'Las alertas detectan situaciones que merecen seguimiento: ausencias repetidas, bajas entregas, clases incompletas o rendimiento comprometido. Puedes filtrarlas o posponerlas para revisarlas despues.';
    case 'horarios':
      return 'Aqui defines los bloques semanales reales del curso. Estos horarios se usan para detectar curso actual o proximo y para ordenar mejor la agenda diaria.';
    case 'intervenciones':
      return 'Registra acciones docentes concretas sobre el proceso del grupo o de un alumno. Conviene usarlo para dejar trazabilidad breve de seguimientos, avisos, acuerdos o recomendaciones.';
    case 'historial':
      return 'Muestra una lectura rapida del estado real de cada alumno. Sirve para detectar riesgo, revisar continuidad y abrir la cronologia o la sintesis individual.';
    case 'ficha':
      return 'La ficha pedagogica resume como viene el curso en terminos didacticos. Utilizala para anotar contenidos dados, pendientes, ritmo del grupo y observaciones generales.';
    case 'dashboard':
      return 'Este tablero consolida indicadores por institucion y ayuda a priorizar donde intervenir. Es util para una mirada transversal cuando trabajas con varios cursos o sedes.';
    case 'evidencias':
      return 'Permite registrar respaldos breves del trabajo docente: observaciones, archivos, fotos o notas vinculadas a clase, alumno, evaluacion o instancia.';
    case 'clase_actual':
      return 'Esta es la vista operativa de clase. En un solo flujo puedes cargar tema, observacion, actividad, asistencia y cierre real de lo que ocurrio en el aula.';
    case 'evaluaciones':
      return 'Administra evaluaciones del curso como procesos completos. Desde aqui puedes crear la evaluacion, cargar resultados, cerrar instancias y generar recuperatorios.';
    case 'resultados':
      return 'Aqui se registran los resultados por alumno y por instancia. La app calcula la condicion final visible y respeta las reglas institucionales configuradas.';
    case 'pendientes':
      return 'Este panel reune trabajo docente accionable en una sola lista: evaluaciones por cerrar, entregas por corregir, alumnos en riesgo, alertas y clases incompletas.';
    case 'cronologia':
      return 'La cronologia ordena en una linea temporal faltas, entregas, intervenciones, evaluaciones y observaciones del alumno. Sirve para seguimiento fino y justificacion.';
    case 'sintesis_curso':
      return 'Resume el periodo del curso con asistencia, rendimiento, contenidos, riesgo y estado evaluativo. Es util para cierres, reuniones o lectura rapida del grupo.';
    case 'sintesis_alumno':
      return 'Resume el periodo del alumno con asistencia, evaluaciones, alertas, pendientes y situacion general. Puede usarse como base para informes o reuniones.';
    case 'perfil':
      return 'El perfil estable concentra rasgos duraderos del grupo: clima, autonomia, estrategias que funcionan mejor y dificultades frecuentes. Ayuda a no reinventar cada clase.';
    case 'rubricas':
      return 'Las rubricas permiten reutilizar criterios breves de evaluacion. Puedes aplicarlas en devoluciones, observaciones, resultados o evidencias para ganar consistencia.';
    case 'acuerdos':
      return 'Sirve para registrar acuerdos de convivencia, situaciones reiteradas y estrategias de seguimiento sin convertir la app en un expediente pesado.';
    case 'reglas':
      return 'Aqui defines criterios pedagogicos de la institucion: escala, nota minima, asistencia y reglas de recuperatorios. Estas reglas impactan en el calculo final de evaluaciones.';
    case 'auditoria':
      return 'La auditoria muestra cambios sensibles registrados por la app. Es util para rastrear modificaciones en notas, reglas, estados o procesos evaluativos.';
    case 'cierre_institucional':
      return 'Este panel prepara un resumen consolidado por institucion con asistencia, riesgo, evaluaciones y observaciones clave. Sirve para cierres de periodo.';
    case 'cierre_curso':
      return 'Genera un resumen breve del curso con datos centrales del periodo. Puedes usarlo como base para devoluciones internas o informes.';
    default:
      return '';
  }
}

Future<bool> agendaAbrirHorariosCurso(
  BuildContext context,
  AgendaDocenteItem item,
) async {
  final actuales = await Proveedores.agendaDocenteRepositorio
      .listarHorariosCurso(item.cursoId);
  if (!context.mounted) return false;

  final cambios = await _mostrarDialogoHorarios(
    context,
    '${item.materia} (${item.etiquetaCurso})',
    actuales,
  );
  if (cambios == null) return false;

  await Proveedores.agendaDocenteRepositorio.guardarHorariosCurso(
    cursoId: item.cursoId,
    horarios: cambios,
  );
  Proveedores.notificarDatosActualizados(
    mensaje: 'Horarios actualizados para ${item.materia}',
  );
  return true;
}

Future<bool> agendaAbrirIntervencionesCurso(
  BuildContext context,
  AgendaDocenteItem item,
) async {
  final huboCambios = await _mostrarDialogoIntervenciones(
    context,
    item.cursoId,
    '${item.materia} (${item.etiquetaCurso})',
    item.institucion,
  );
  if (huboCambios == true) {
    Proveedores.notificarDatosActualizados(
      mensaje: 'Intervenciones docentes actualizadas',
    );
    return true;
  }
  return false;
}

Future<bool> agendaAbrirHistorialCurso(
  BuildContext context,
  AgendaDocenteItem item, {
  required DateTime fechaReferencia,
}) async {
  final huboCambios = await showDialog<bool>(
    context: context,
    builder: (context) => _DialogHistorialAlumnos(
      cursoId: item.cursoId,
      tituloCurso: '${item.materia} (${item.etiquetaCurso})',
      fechaReferencia: fechaReferencia,
    ),
  );
  return huboCambios == true;
}

Future<bool> agendaAbrirEvaluacionesCurso(
  BuildContext context,
  AgendaDocenteItem item,
) async {
  final huboCambios = await showDialog<bool>(
    context: context,
    builder: (context) => _DialogEvaluacionesCurso(
      cursoId: item.cursoId,
      tituloCurso: '${item.materia} (${item.etiquetaCurso})',
      institucion: item.institucion,
    ),
  );
  if (huboCambios == true) {
    Proveedores.notificarDatosActualizados(
      mensaje: 'Evaluaciones actualizadas',
    );
    return true;
  }
  return false;
}

Future<bool> agendaAbrirEvidenciasCurso(
  BuildContext context,
  AgendaDocenteItem item, {
  required DateTime fechaReferencia,
}) async {
  final huboCambios = await showDialog<bool>(
    context: context,
    builder: (context) => _DialogEvidenciasCurso(
      cursoId: item.cursoId,
      institucion: item.institucion,
      tituloCurso: '${item.materia} (${item.etiquetaCurso})',
      fechaReferencia: fechaReferencia,
    ),
  );
  if (huboCambios == true) {
    Proveedores.notificarDatosActualizados(mensaje: 'Evidencias actualizadas');
    return true;
  }
  return false;
}

Future<bool> agendaAbrirFichaCurso(
  BuildContext context,
  AgendaDocenteItem item,
) async {
  final huboCambios = await showDialog<bool>(
    context: context,
    builder: (context) => _DialogFichaPedagogica(
      cursoId: item.cursoId,
      tituloCurso: '${item.materia} (${item.etiquetaCurso})',
    ),
  );
  if (huboCambios == true) {
    Proveedores.notificarDatosActualizados(
      mensaje: 'Ficha pedagogica actualizada',
    );
    return true;
  }
  return false;
}

Future<bool> agendaAbrirAcuerdosCurso(
  BuildContext context,
  AgendaDocenteItem item,
) async {
  final huboCambios = await showDialog<bool>(
    context: context,
    builder: (context) => _DialogAcuerdosConvivencia(
      cursoId: item.cursoId,
      tituloCurso: '${item.materia} (${item.etiquetaCurso})',
      institucion: item.institucion,
    ),
  );
  if (huboCambios == true) {
    Proveedores.notificarDatosActualizados(
      mensaje: 'Acuerdos de convivencia actualizados',
    );
    return true;
  }
  return false;
}

Future<bool> agendaAbrirReglasInstitucion(
  BuildContext context,
  AgendaDocenteItem item,
) async {
  final huboCambios = await showDialog<bool>(
    context: context,
    builder: (context) =>
        _DialogReglasInstitucion(institucion: item.institucion),
  );
  if (huboCambios == true) {
    Proveedores.notificarDatosActualizados(
      mensaje: 'Reglas institucionales actualizadas',
    );
    return true;
  }
  return false;
}

Future<bool> agendaAbrirAgrupamientoCurso(
  BuildContext context,
  AgendaDocenteItem item,
) async {
  await showDialog<void>(
    context: context,
    builder: (context) => _DialogAgrupamientoCurso(
      cursoId: item.cursoId,
      tituloCurso: '${item.materia} (${item.etiquetaCurso})',
    ),
  );
  return false;
}

Future<bool> agendaAbrirPlantillasCurso(
  BuildContext context,
  AgendaDocenteItem item,
) async {
  final huboCambios = await showDialog<bool>(
    context: context,
    builder: (context) => _DialogPlantillasCurso(
      cursoId: item.cursoId,
      institucion: item.institucion,
      tituloCurso: '${item.materia} (${item.etiquetaCurso})',
    ),
  );
  if (huboCambios == true) {
    Proveedores.notificarDatosActualizados(mensaje: 'Plantillas actualizadas');
    return true;
  }
  return false;
}

Future<bool> agendaAbrirRubricasCurso(
  BuildContext context,
  AgendaDocenteItem item,
) async {
  final huboCambios = await showDialog<bool>(
    context: context,
    builder: (context) => _DialogRubricasCurso(
      cursoId: item.cursoId,
      institucion: item.institucion,
      tituloCurso: '${item.materia} (${item.etiquetaCurso})',
    ),
  );
  if (huboCambios == true) {
    Proveedores.notificarDatosActualizados(mensaje: 'Rubricas actualizadas');
    return true;
  }
  return false;
}

Future<bool> agendaAbrirClaseActualCurso(
  BuildContext context,
  AgendaDocenteItem item, {
  required DateTime fechaReferencia,
}) async {
  final huboCambios = await showDialog<bool>(
    context: context,
    builder: (context) => _DialogClaseActualRapida(
      cursoId: item.cursoId,
      tituloCurso: '${item.materia} (${item.etiquetaCurso})',
      fecha: fechaReferencia,
    ),
  );
  if (huboCambios == true) {
    Proveedores.notificarDatosActualizados(mensaje: 'Clase actual actualizada');
    return true;
  }
  return false;
}

Future<bool> agendaAbrirPerfilEstableCurso(
  BuildContext context,
  AgendaDocenteItem item,
) async {
  final huboCambios = await showDialog<bool>(
    context: context,
    builder: (context) => _DialogPerfilEstableCurso(
      cursoId: item.cursoId,
      tituloCurso: '${item.materia} (${item.etiquetaCurso})',
    ),
  );
  if (huboCambios == true) {
    Proveedores.notificarDatosActualizados(
      mensaje: 'Perfil estable del curso actualizado',
    );
    return true;
  }
  return false;
}

Future<bool> agendaAbrirCierreCurso(
  BuildContext context,
  AgendaDocenteItem item, {
  required DateTime fechaReferencia,
}) async {
  final resumen = await showDialog<ResumenCierreCurso>(
    context: context,
    builder: (context) => _DialogCierreCurso(
      cursoId: item.cursoId,
      cursoEtiqueta: '${item.materia} (${item.etiquetaCurso})',
      fechaReferencia: fechaReferencia,
    ),
  );
  if (resumen == null) return false;
  final texto = resumen.generarTexto('${item.materia} (${item.etiquetaCurso})');
  await Clipboard.setData(ClipboardData(text: texto));
  if (!context.mounted) return false;
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Resumen de cierre copiado al portapapeles')),
  );
  return false;
}

Future<bool> agendaAbrirSintesisPeriodoCurso(
  BuildContext context,
  AgendaDocenteItem item, {
  required DateTime fechaReferencia,
}) async {
  await showDialog<void>(
    context: context,
    builder: (context) => _DialogSintesisPeriodoCurso(
      cursoId: item.cursoId,
      cursoEtiqueta: '${item.materia} (${item.etiquetaCurso})',
      fechaReferencia: fechaReferencia,
    ),
  );
  return false;
}

Future<bool> agendaAbrirPendientesAccionables(
  BuildContext context, {
  required DateTime fechaReferencia,
}) async {
  final abierto = await showDialog<bool>(
    context: context,
    builder: (context) =>
        _DialogPendientesAccionables(fechaReferencia: fechaReferencia),
  );
  return abierto == true;
}

Future<bool> agendaAbrirCursoActualOProximo(
  BuildContext context, {
  required DateTime fechaReferencia,
}) async {
  final agenda = await Proveedores.agendaDocenteRepositorio.listarAgendaDia(
    fechaReferencia,
  );
  if (!context.mounted) return false;
  if (agenda.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No hay cursos disponibles hoy')),
    );
    return false;
  }

  final ahora = DateTime.now();
  final referencia = _esMismoDia(fechaReferencia, _soloFecha(ahora))
      ? ahora
      : DateTime(
          fechaReferencia.year,
          fechaReferencia.month,
          fechaReferencia.day,
          12,
          0,
        );

  _CandidatoCursoRapido? actual;
  _CandidatoCursoRapido? proximo;

  for (final item in agenda) {
    final bloques = item.bloquesHorarios
        .map(_parsearBloqueHorarioMenu)
        .whereType<_BloqueHorarioParseado>()
        .toList(growable: false);
    for (final b in bloques) {
      final inicio = DateTime(
        fechaReferencia.year,
        fechaReferencia.month,
        fechaReferencia.day,
        b.horaInicio,
        b.minutoInicio,
      );
      final fin =
          DateTime(
            fechaReferencia.year,
            fechaReferencia.month,
            fechaReferencia.day,
            b.horaFin ?? b.horaInicio,
            b.minutoFin ?? (b.minutoInicio + 50) % 60,
          ).add(
            b.horaFin == null && b.minutoInicio + 50 >= 60
                ? const Duration(hours: 1)
                : Duration.zero,
          );

      if (!referencia.isBefore(inicio) && !referencia.isAfter(fin)) {
        final cand = _CandidatoCursoRapido(
          item: item,
          inicio: inicio,
          fin: fin,
        );
        if (actual == null || cand.inicio.isBefore(actual.inicio)) {
          actual = cand;
        }
      } else if (inicio.isAfter(referencia)) {
        final cand = _CandidatoCursoRapido(
          item: item,
          inicio: inicio,
          fin: fin,
        );
        if (proximo == null || cand.inicio.isBefore(proximo.inicio)) {
          proximo = cand;
        }
      }
    }
  }

  final elegido = actual ?? proximo;
  final item = elegido?.item ?? agenda.first;
  final huboCambios = await agendaAbrirClaseActualCurso(
    context,
    item,
    fechaReferencia: fechaReferencia,
  );
  if (!context.mounted) return huboCambios;
  final etiqueta = actual != null
      ? 'Curso en curso'
      : (proximo != null ? 'Proximo curso' : 'Curso sugerido');
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('$etiqueta: ${item.materia} (${item.etiquetaCurso})'),
    ),
  );
  return huboCambios;
}

Future<bool> agendaAbrirAlertasAutomaticas(
  BuildContext context, {
  required DateTime fechaReferencia,
}) async {
  final alertas = await Proveedores.agendaDocenteRepositorio
      .listarAlertasAutomaticas(fechaReferencia);
  if (!context.mounted) return false;
  await showDialog<void>(
    context: context,
    builder: (context) => _DialogAlertasAutomaticas(
      fechaReferencia: fechaReferencia,
      alertas: alertas,
    ),
  );
  return false;
}

Future<bool> agendaAbrirAutomatizacionesDocentes(
  BuildContext context, {
  required DateTime fechaReferencia,
}) async {
  final agenda = await Proveedores.agendaDocenteRepositorio.listarAgendaDia(
    fechaReferencia,
  );
  final alertas = await Proveedores.agendaDocenteRepositorio
      .listarAlertasAutomaticas(fechaReferencia);
  if (!context.mounted) return false;
  await showDialog<void>(
    context: context,
    builder: (context) => _DialogAutomatizacionesDocentes(
      fechaReferencia: fechaReferencia,
      sugerencias: _generarAutomatizacionesMenu(
        agenda: agenda,
        alertas: alertas,
        fechaReferencia: fechaReferencia,
      ),
    ),
  );
  return false;
}

Future<bool> agendaAbrirCierreInstitucional(
  BuildContext context, {
  required DateTime fechaReferencia,
  String? institucionSugerida,
}) async {
  final huboCambios = await showDialog<bool>(
    context: context,
    builder: (context) => _DialogCierreInstitucional(
      fechaReferencia: fechaReferencia,
      institucionSugerida: institucionSugerida,
    ),
  );
  if (huboCambios == true) {
    Proveedores.notificarDatosActualizados(
      mensaje: 'Cierre institucional actualizado',
    );
    return true;
  }
  return false;
}

Future<bool> agendaAbrirDashboardEjecutivo(
  BuildContext context, {
  required DateTime fechaReferencia,
}) async {
  await showDialog<void>(
    context: context,
    builder: (context) =>
        _DialogDashboardEjecutivo(fechaReferencia: fechaReferencia),
  );
  return false;
}

Future<bool> agendaAbrirAuditoriaDocente(
  BuildContext context, {
  required DateTime fechaReferencia,
}) async {
  final agenda = await Proveedores.agendaDocenteRepositorio.listarAgendaDia(
    fechaReferencia,
  );
  if (!context.mounted) return false;
  await showDialog<void>(
    context: context,
    builder: (context) => _DialogAuditoriaDocente(
      fechaReferencia: fechaReferencia,
      agenda: agenda,
    ),
  );
  return false;
}

_BloqueHorarioParseado? _parsearBloqueHorarioMenu(String texto) {
  final base = texto.split('(').first.trim();
  if (base.isEmpty) return null;
  final m = RegExp(
    r'([01]\d|2[0-3]):([0-5]\d)(?:\s*-\s*([01]\d|2[0-3]):([0-5]\d))?',
  ).firstMatch(base);
  if (m == null) return null;
  final hi = int.tryParse(m.group(1)!);
  final mi = int.tryParse(m.group(2)!);
  final hf = m.group(3) == null ? null : int.tryParse(m.group(3)!);
  final mf = m.group(4) == null ? null : int.tryParse(m.group(4)!);
  if (hi == null || mi == null) return null;
  return _BloqueHorarioParseado(
    horaInicio: hi,
    minutoInicio: mi,
    horaFin: hf,
    minutoFin: mf,
  );
}

int _puntajeRiesgoCursoMenu(
  AgendaDocenteItem item,
  List<AlertaAutomaticaDocente> alertas,
) {
  var puntaje = 0;
  if (item.alumnosPendientes >= 6) {
    puntaje += 2;
  } else if (item.alumnosPendientes >= 3) {
    puntaje += 1;
  }
  if (item.actividadesSinEntregar >= 8) {
    puntaje += 2;
  } else if (item.actividadesSinEntregar >= 4) {
    puntaje += 1;
  }
  if (item.trabajosSinCorregir >= 10) {
    puntaje += 2;
  } else if (item.trabajosSinCorregir >= 5) {
    puntaje += 1;
  }
  final alertasAltas = alertas
      .where((a) => a.cursoId == item.cursoId && a.severidad == 'alta')
      .length;
  final alertasMedias = alertas
      .where((a) => a.cursoId == item.cursoId && a.severidad == 'media')
      .length;
  puntaje += (alertasAltas * 2) + alertasMedias;
  return puntaje;
}

String _nivelRiesgoCursoMenu(
  AgendaDocenteItem item,
  List<AlertaAutomaticaDocente> alertas,
) {
  final puntaje = _puntajeRiesgoCursoMenu(item, alertas);
  if (puntaje >= 6) return 'alto';
  if (puntaje >= 3) return 'medio';
  return 'bajo';
}

List<_SugerenciaMenuAutomatica> _generarAutomatizacionesMenu({
  required List<AgendaDocenteItem> agenda,
  required List<AlertaAutomaticaDocente> alertas,
  required DateTime fechaReferencia,
}) {
  final out = <_SugerenciaMenuAutomatica>[];
  final altas = alertas.where((a) => a.severidad == 'alta').length;
  final hoySinAsistencia = agenda
      .where((x) => x.tieneClaseHoy && !x.asistenciaInicializada)
      .toList(growable: false);
  final riesgoAlto = agenda
      .where((x) => _nivelRiesgoCursoMenu(x, alertas) == 'alto')
      .toList(growable: false);
  final conCorrecciones = agenda
      .where((x) => x.trabajosSinCorregir >= 8)
      .toList(growable: false);
  final proximasEval = agenda
      .where((x) {
        final fecha = x.proximaEvaluacionFecha;
        if (fecha == null) return false;
        final delta = _soloFecha(
          fecha,
        ).difference(_soloFecha(fechaReferencia)).inDays;
        return delta >= 0 && delta <= 3;
      })
      .toList(growable: false);

  if (hoySinAsistencia.isNotEmpty) {
    final curso = hoySinAsistencia.first;
    out.add(
      _SugerenciaMenuAutomatica(
        icono: Icons.fact_check_outlined,
        titulo: 'Completar asistencia de clase actual',
        detalle:
            '${curso.materia} (${curso.etiquetaCurso}) tiene clase hoy sin planilla inicializada.',
      ),
    );
  }

  if (riesgoAlto.isNotEmpty) {
    final curso = riesgoAlto.first;
    out.add(
      _SugerenciaMenuAutomatica(
        icono: Icons.priority_high_outlined,
        titulo: 'Priorizar seguimiento de riesgo alto',
        detalle:
            '${riesgoAlto.length} curso(s) en riesgo alto. Empezar por ${curso.materia} (${curso.etiquetaCurso}).',
      ),
    );
  }

  if (conCorrecciones.isNotEmpty) {
    final curso = conCorrecciones.first;
    out.add(
      _SugerenciaMenuAutomatica(
        icono: Icons.rule_folder_outlined,
        titulo: 'Cerrar evaluaciones o correcciones pendientes',
        detalle:
            '${curso.materia} (${curso.etiquetaCurso}) acumula ${curso.trabajosSinCorregir} trabajos sin corregir.',
      ),
    );
  }

  if (proximasEval.isNotEmpty) {
    final curso = proximasEval.first;
    final fecha = curso.proximaEvaluacionFecha!;
    out.add(
      _SugerenciaMenuAutomatica(
        icono: Icons.event_available_outlined,
        titulo: 'Preparar evaluacion proxima',
        detalle:
            '${curso.materia} (${curso.etiquetaCurso}) tiene evaluacion el ${_fechaCorta(fecha)}.',
      ),
    );
  }

  if (altas >= 3) {
    out.add(
      _SugerenciaMenuAutomatica(
        icono: Icons.warning_amber_outlined,
        titulo: 'Revisar alertas altas',
        detalle:
            'Hay $altas alertas de severidad alta. Conviene revisar pendientes y seguimiento.',
      ),
    );
  }

  return out.take(5).toList(growable: false);
}

class _DialogAlertasAutomaticas extends StatelessWidget {
  final DateTime fechaReferencia;
  final List<AlertaAutomaticaDocente> alertas;

  const _DialogAlertasAutomaticas({
    required this.fechaReferencia,
    required this.alertas,
  });

  @override
  Widget build(BuildContext context) {
    final altas = alertas.where((a) => a.severidad == 'alta').length;
    final medias = alertas.where((a) => a.severidad == 'media').length;
    final bajas = alertas.where((a) => a.severidad == 'baja').length;

    return AlertDialog(
      title: Text('Alertas automaticas - ${_fechaLarga(fechaReferencia)}'),
      content: SizedBox(
        width: _anchoDialogo(context, 860),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text('Total ${alertas.length}')),
                Chip(label: Text('Altas $altas')),
                Chip(label: Text('Medias $medias')),
                Chip(label: Text('Bajas $bajas')),
              ],
            ),
            const SizedBox(height: 10),
            Flexible(
              child: alertas.isEmpty
                  ? const Center(child: Text('No hay alertas activas.'))
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: alertas.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final alerta = alertas[index];
                        final curso = [alerta.materia, alerta.etiquetaCurso]
                            .whereType<String>()
                            .where((x) => x.trim().isNotEmpty)
                            .join(' | ');
                        return ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            alerta.severidad == 'alta'
                                ? Icons.warning_rounded
                                : alerta.severidad == 'media'
                                ? Icons.info_rounded
                                : Icons.notifications_none_rounded,
                          ),
                          title: Text(alerta.mensaje),
                          subtitle: Text(
                            curso.isEmpty
                                ? (alerta.institucion ?? 'Sin referencia')
                                : curso,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}

class _DialogAutomatizacionesDocentes extends StatelessWidget {
  final DateTime fechaReferencia;
  final List<_SugerenciaMenuAutomatica> sugerencias;

  const _DialogAutomatizacionesDocentes({
    required this.fechaReferencia,
    required this.sugerencias,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Automatizaciones - ${_fechaLarga(fechaReferencia)}'),
      content: SizedBox(
        width: _anchoDialogo(context, 820),
        child: sugerencias.isEmpty
            ? const Text('No hay sugerencias automaticas para este momento.')
            : ListView.separated(
                shrinkWrap: true,
                itemCount: sugerencias.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final sugerencia = sugerencias[index];
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(sugerencia.icono),
                    title: Text(sugerencia.titulo),
                    subtitle: Text(sugerencia.detalle),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}

class _SugerenciaMenuAutomatica {
  final IconData icono;
  final String titulo;
  final String detalle;

  const _SugerenciaMenuAutomatica({
    required this.icono,
    required this.titulo,
    required this.detalle,
  });
}

Widget _bloqueDescripcionFuncion(
  BuildContext context,
  String clave, {
  EdgeInsetsGeometry padding = const EdgeInsets.all(10),
}) {
  final texto = _descripcionFuncionAgenda(clave).trim();
  if (texto.isEmpty) return const SizedBox.shrink();
  final cs = Theme.of(context).colorScheme;
  return Container(
    width: double.infinity,
    padding: padding,
    decoration: BoxDecoration(
      color: cs.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.85)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline, size: 18, color: cs.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(texto, style: Theme.of(context).textTheme.bodySmall),
        ),
      ],
    ),
  );
}

double _anchoDialogo(BuildContext context, double anchoObjetivo) {
  final disponible = MediaQuery.sizeOf(context).width - 96;
  if (disponible < 320) return 320;
  return disponible < anchoObjetivo ? disponible : anchoObjetivo;
}

double _altoDialogo(BuildContext context, double altoObjetivo) {
  final disponible = MediaQuery.sizeOf(context).height - 120;
  if (disponible < 320) return 320;
  return disponible < altoObjetivo ? disponible : altoObjetivo;
}

class AgendaDocentePantalla extends StatefulWidget {
  const AgendaDocentePantalla({super.key});

  @override
  State<AgendaDocentePantalla> createState() => _AgendaDocentePantallaState();
}

class _AgendaDocentePantallaState extends State<AgendaDocentePantalla> {
  late final VoidCallback _datosVersionListener;

  DateTime _fecha = _soloFecha(DateTime.now());
  bool _cargando = true;
  bool _sincronizando = false;
  String? _error;
  List<AgendaDocenteItem> _agenda = const [];
  List<AlertaAutomaticaDocente> _alertas = const [];
  String _filtroSeveridad = 'todas';
  String _filtroInstitucion = 'todas';
  int? _filtroCursoId;
  String _filtroInstitucionAgenda = 'todas';
  String _filtroRiesgoAgenda = 'todos';
  final Set<int> _cursosCreandoClase = <int>{};
  final Set<int> _clasesInicializando = <int>{};
  final Set<String> _alertasPosponiendo = <String>{};

  @override
  void initState() {
    super.initState();
    _datosVersionListener = _onDatosVersionChanged;
    Proveedores.datosVersion.addListener(_datosVersionListener);
    _cargarAgenda();
  }

  @override
  void dispose() {
    Proveedores.datosVersion.removeListener(_datosVersionListener);
    super.dispose();
  }

  void _onDatosVersionChanged() {
    if (!mounted) return;
    _cargarAgenda(silencioso: true);
  }

  Future<void> _cargarAgenda({bool silencioso = false}) async {
    final conservarVista =
        silencioso && (_agenda.isNotEmpty || _alertas.isNotEmpty);
    setState(() {
      _cargando = !conservarVista;
      _sincronizando = conservarVista;
      if (!conservarVista) {
        _error = null;
      }
    });

    List<AgendaDocenteItem>? agenda;
    List<AlertaAutomaticaDocente>? alertas;

    try {
      agenda = await Proveedores.agendaDocenteRepositorio.listarAgendaDia(
        _fecha,
      );
    } catch (e, st) {
      debugPrint('Error al cargar agenda del dia: $e');
      debugPrintStack(stackTrace: st);
    }

    try {
      alertas = await Proveedores.agendaDocenteRepositorio
          .listarAlertasAutomaticas(_fecha);
    } catch (e, st) {
      debugPrint('Error al cargar alertas automaticas: $e');
      debugPrintStack(stackTrace: st);
    }

    if (!mounted) return;

    if (agenda != null) {
      final agendaCargada = agenda;
      setState(() {
        _agenda = agendaCargada;
        _alertas = alertas ?? const [];
        _normalizarFiltrosAlertas();
        _normalizarFiltrosAgenda();
        _error = null;
        _cargando = false;
        _sincronizando = false;
      });
      return;
    }

    setState(() {
      if (!conservarVista) {
        _error = 'No se pudo cargar la agenda docente';
      }
      if (alertas != null) {
        _alertas = alertas;
        _normalizarFiltrosAlertas();
      }
      _cargando = false;
      _sincronizando = false;
    });
  }

  Future<void> _cambiarDia(int deltaDias) async {
    setState(() => _fecha = _fecha.add(Duration(days: deltaDias)));
    await _cargarAgenda();
  }

  Future<void> _irAHoy() async {
    final hoy = _soloFecha(DateTime.now());
    if (_esMismoDia(_fecha, hoy)) return;
    setState(() => _fecha = hoy);
    await _cargarAgenda();
  }

  Future<void> _crearClaseDelDia(AgendaDocenteItem item) async {
    if (_cursosCreandoClase.contains(item.cursoId)) return;
    setState(() => _cursosCreandoClase.add(item.cursoId));

    try {
      final inscriptos = await Proveedores.cursosRepositorio
          .contarInscritosActivos(item.cursoId);
      final temaInicial =
          item.continuarHoy.trim().toLowerCase() == 'sin tema previo registrado'
          ? null
          : item.continuarHoy;
      final horariosDelDia = await Proveedores.asistenciasRepositorio
          .listarHorariosCursoParaFecha(cursoId: item.cursoId, fecha: _fecha);
      final horarioClase = horariosDelDia.isEmpty ? null : horariosDelDia.first;

      final claseId = await Proveedores.asistenciasRepositorio.crearClase(
        cursoId: item.cursoId,
        fecha: _fecha,
        tema: temaInicial,
        horario: horarioClase,
      );

      if (inscriptos > 0) {
        await Proveedores.asistenciasRepositorio.marcarEstadoParaTodos(
          claseId: claseId,
          cursoId: item.cursoId,
          estado: EstadoAsistencia.pendiente,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Clase creada para el dia seleccionado')),
      );
      await _cargarAgenda();
    } finally {
      if (mounted) {
        setState(() => _cursosCreandoClase.remove(item.cursoId));
      }
    }
  }

  Future<void> _inicializarAsistenciaHoy(AgendaDocenteItem item) async {
    final claseId = item.claseHoyId;
    if (claseId == null || _clasesInicializando.contains(claseId)) return;
    setState(() => _clasesInicializando.add(claseId));

    try {
      await Proveedores.asistenciasRepositorio.marcarEstadoParaTodos(
        claseId: claseId,
        cursoId: item.cursoId,
        estado: EstadoAsistencia.pendiente,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Asistencia inicializada en pendiente')),
      );
      await _cargarAgenda();
    } finally {
      if (mounted) {
        setState(() => _clasesInicializando.remove(claseId));
      }
    }
  }

  Future<void> _abrirHorariosCurso(AgendaDocenteItem item) async {
    final actuales = await Proveedores.agendaDocenteRepositorio
        .listarHorariosCurso(item.cursoId);
    if (!mounted) return;

    final cambios = await _mostrarDialogoHorarios(
      context,
      '${item.materia} (${item.etiquetaCurso})',
      actuales,
    );
    if (cambios == null) return;

    await Proveedores.agendaDocenteRepositorio.guardarHorariosCurso(
      cursoId: item.cursoId,
      horarios: cambios,
    );
    Proveedores.notificarDatosActualizados(
      mensaje: 'Horarios actualizados para ${item.materia}',
    );
    await _cargarAgenda();
  }

  Future<void> _abrirIntervencionesCurso(AgendaDocenteItem item) async {
    final huboCambios = await _mostrarDialogoIntervenciones(
      context,
      item.cursoId,
      '${item.materia} (${item.etiquetaCurso})',
      item.institucion,
    );
    if (huboCambios == true) {
      Proveedores.notificarDatosActualizados(
        mensaje: 'Intervenciones docentes actualizadas',
      );
      await _cargarAgenda();
    }
  }

  Future<void> _abrirAcuerdosCurso(AgendaDocenteItem item) async {
    final huboCambios = await showDialog<bool>(
      context: context,
      builder: (context) => _DialogAcuerdosConvivencia(
        cursoId: item.cursoId,
        tituloCurso: '${item.materia} (${item.etiquetaCurso})',
        institucion: item.institucion,
      ),
    );
    if (huboCambios == true) {
      Proveedores.notificarDatosActualizados(
        mensaje: 'Acuerdos de convivencia actualizados',
      );
      await _cargarAgenda();
    }
  }

  Future<void> _abrirReglasInstitucion(AgendaDocenteItem item) async {
    final huboCambios = await showDialog<bool>(
      context: context,
      builder: (context) =>
          _DialogReglasInstitucion(institucion: item.institucion),
    );
    if (huboCambios == true) {
      Proveedores.notificarDatosActualizados(
        mensaje: 'Reglas institucionales actualizadas',
      );
      await _cargarAgenda();
    }
  }

  Future<void> _abrirHistorialAlumnos(AgendaDocenteItem item) async {
    await showDialog<void>(
      context: context,
      builder: (context) => _DialogHistorialAlumnos(
        cursoId: item.cursoId,
        tituloCurso: '${item.materia} (${item.etiquetaCurso})',
        fechaReferencia: _fecha,
      ),
    );
  }

  Future<void> _abrirAgrupamientoCurso(AgendaDocenteItem item) async {
    await showDialog<void>(
      context: context,
      builder: (context) => _DialogAgrupamientoCurso(
        cursoId: item.cursoId,
        tituloCurso: '${item.materia} (${item.etiquetaCurso})',
      ),
    );
  }

  Future<void> _abrirPlantillasCurso(AgendaDocenteItem item) async {
    final huboCambios = await showDialog<bool>(
      context: context,
      builder: (context) => _DialogPlantillasCurso(
        cursoId: item.cursoId,
        institucion: item.institucion,
        tituloCurso: '${item.materia} (${item.etiquetaCurso})',
      ),
    );
    if (huboCambios == true) {
      Proveedores.notificarDatosActualizados(
        mensaje: 'Plantillas actualizadas',
      );
      await _cargarAgenda();
    }
  }

  Future<void> _abrirRubricasCurso(AgendaDocenteItem item) async {
    final huboCambios = await showDialog<bool>(
      context: context,
      builder: (context) => _DialogRubricasCurso(
        cursoId: item.cursoId,
        institucion: item.institucion,
        tituloCurso: '${item.materia} (${item.etiquetaCurso})',
      ),
    );
    if (huboCambios == true) {
      Proveedores.notificarDatosActualizados(mensaje: 'Rubricas actualizadas');
      await _cargarAgenda();
    }
  }

  Future<void> _abrirEvaluacionesCurso(AgendaDocenteItem item) async {
    final huboCambios = await showDialog<bool>(
      context: context,
      builder: (context) => _DialogEvaluacionesCurso(
        cursoId: item.cursoId,
        institucion: item.institucion,
        tituloCurso: '${item.materia} (${item.etiquetaCurso})',
      ),
    );
    if (huboCambios == true) {
      Proveedores.notificarDatosActualizados(
        mensaje: 'Evaluaciones actualizadas',
      );
      await _cargarAgenda();
    }
  }

  Future<void> _abrirEvidenciasCurso(AgendaDocenteItem item) async {
    final huboCambios = await showDialog<bool>(
      context: context,
      builder: (context) => _DialogEvidenciasCurso(
        cursoId: item.cursoId,
        institucion: item.institucion,
        tituloCurso: '${item.materia} (${item.etiquetaCurso})',
        fechaReferencia: _fecha,
      ),
    );
    if (huboCambios == true) {
      Proveedores.notificarDatosActualizados(
        mensaje: 'Evidencias actualizadas',
      );
      await _cargarAgenda();
    }
  }

  Future<void> _abrirClaseActualRapida(AgendaDocenteItem item) async {
    final huboCambios = await showDialog<bool>(
      context: context,
      builder: (context) => _DialogClaseActualRapida(
        cursoId: item.cursoId,
        tituloCurso: '${item.materia} (${item.etiquetaCurso})',
        fecha: _fecha,
      ),
    );
    if (huboCambios == true) {
      Proveedores.notificarDatosActualizados(
        mensaje: 'Clase actual actualizada',
      );
      await _cargarAgenda();
    }
  }

  Future<void> _abrirFichaPedagogica(AgendaDocenteItem item) async {
    final huboCambios = await showDialog<bool>(
      context: context,
      builder: (context) => _DialogFichaPedagogica(
        cursoId: item.cursoId,
        tituloCurso: '${item.materia} (${item.etiquetaCurso})',
      ),
    );
    if (huboCambios == true) {
      Proveedores.notificarDatosActualizados(
        mensaje: 'Ficha pedagogica actualizada',
      );
      await _cargarAgenda();
    }
  }

  Future<void> _abrirPerfilEstableCurso(AgendaDocenteItem item) async {
    final huboCambios = await showDialog<bool>(
      context: context,
      builder: (context) => _DialogPerfilEstableCurso(
        cursoId: item.cursoId,
        tituloCurso: '${item.materia} (${item.etiquetaCurso})',
      ),
    );
    if (huboCambios == true) {
      Proveedores.notificarDatosActualizados(
        mensaje: 'Perfil estable del curso actualizado',
      );
      await _cargarAgenda();
    }
  }

  Future<void> _abrirCierreCurso(AgendaDocenteItem item) async {
    final resumen = await showDialog<ResumenCierreCurso>(
      context: context,
      builder: (context) => _DialogCierreCurso(
        cursoId: item.cursoId,
        cursoEtiqueta: '${item.materia} (${item.etiquetaCurso})',
        fechaReferencia: _fecha,
      ),
    );
    if (resumen == null || !mounted) return;
    final texto = resumen.generarTexto(
      '${item.materia} (${item.etiquetaCurso})',
    );
    await Clipboard.setData(ClipboardData(text: texto));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Resumen de cierre copiado al portapapeles'),
      ),
    );
  }

  Future<void> _abrirSintesisPeriodoCurso(AgendaDocenteItem item) async {
    await showDialog<void>(
      context: context,
      builder: (context) => _DialogSintesisPeriodoCurso(
        cursoId: item.cursoId,
        cursoEtiqueta: '${item.materia} (${item.etiquetaCurso})',
        fechaReferencia: _fecha,
      ),
    );
  }

  Future<void> _abrirPanelCierreInstitucional() async {
    final huboCambios = await showDialog<bool>(
      context: context,
      builder: (context) => _DialogCierreInstitucional(
        fechaReferencia: _fecha,
        institucionSugerida: _agenda.isEmpty ? null : _agenda.first.institucion,
      ),
    );
    if (huboCambios == true) {
      await _cargarAgenda();
    }
  }

  Future<void> _abrirCursoActualOProximo() async {
    if (_agenda.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay cursos disponibles hoy')),
      );
      return;
    }

    final ahora = DateTime.now();
    final referencia = _esMismoDia(_fecha, _soloFecha(ahora))
        ? ahora
        : DateTime(_fecha.year, _fecha.month, _fecha.day, 12, 0);

    _CandidatoCursoRapido? actual;
    _CandidatoCursoRapido? proximo;

    for (final item in _agenda) {
      final bloques = item.bloquesHorarios
          .map(_parsearBloqueHorario)
          .whereType<_BloqueHorarioParseado>()
          .toList(growable: false);
      for (final b in bloques) {
        final inicio = DateTime(
          _fecha.year,
          _fecha.month,
          _fecha.day,
          b.horaInicio,
          b.minutoInicio,
        );
        final fin =
            DateTime(
              _fecha.year,
              _fecha.month,
              _fecha.day,
              b.horaFin ?? b.horaInicio,
              b.minutoFin ?? (b.minutoInicio + 50) % 60,
            ).add(
              b.horaFin == null && b.minutoInicio + 50 >= 60
                  ? const Duration(hours: 1)
                  : Duration.zero,
            );

        if (!referencia.isBefore(inicio) && !referencia.isAfter(fin)) {
          final cand = _CandidatoCursoRapido(
            item: item,
            inicio: inicio,
            fin: fin,
          );
          if (actual == null || cand.inicio.isBefore(actual.inicio)) {
            actual = cand;
          }
        } else if (inicio.isAfter(referencia)) {
          final cand = _CandidatoCursoRapido(
            item: item,
            inicio: inicio,
            fin: fin,
          );
          if (proximo == null || cand.inicio.isBefore(proximo.inicio)) {
            proximo = cand;
          }
        }
      }
    }

    final elegido = actual ?? proximo;
    final item = elegido?.item ?? _agenda.first;
    await _abrirClaseActualRapida(item);
    if (!mounted) return;
    final etiqueta = actual != null
        ? 'Curso en curso'
        : (proximo != null ? 'Proximo curso' : 'Curso sugerido');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$etiqueta: ${item.materia} (${item.etiquetaCurso})'),
      ),
    );
  }

  Future<void> _abrirDashboardEjecutivo() async {
    await showDialog<void>(
      context: context,
      builder: (context) => _DialogDashboardEjecutivo(fechaReferencia: _fecha),
    );
  }

  Future<void> _abrirPanelPendientesAccionables() async {
    await showDialog<void>(
      context: context,
      builder: (context) =>
          _DialogPendientesAccionables(fechaReferencia: _fecha),
    );
  }

  Future<void> _abrirAuditoriaDocente() async {
    await showDialog<void>(
      context: context,
      builder: (context) =>
          _DialogAuditoriaDocente(fechaReferencia: _fecha, agenda: _agenda),
    );
  }

  void _normalizarFiltrosAlertas() {
    final instituciones = _institucionesAlertaDisponibles();
    if (_filtroInstitucion != 'todas' &&
        !instituciones.contains(_filtroInstitucion)) {
      _filtroInstitucion = 'todas';
    }

    final cursoIds = _cursoIdsAlertaDisponibles();
    if (_filtroCursoId != null && !cursoIds.contains(_filtroCursoId)) {
      _filtroCursoId = null;
    }

    const validos = {'todas', 'alta', 'media', 'baja'};
    if (!validos.contains(_filtroSeveridad)) {
      _filtroSeveridad = 'todas';
    }
  }

  List<String> _institucionesAlertaDisponibles() {
    final out = <String>{};
    for (final alerta in _alertas) {
      final i = (alerta.institucion ?? '').trim();
      if (i.isNotEmpty) out.add(i);
    }
    return out.toList()..sort();
  }

  List<int> _cursoIdsAlertaDisponibles() {
    return _alertas.map((a) => a.cursoId).whereType<int>().toSet().toList()
      ..sort();
  }

  List<AlertaAutomaticaDocente> _alertasFiltradas() {
    return _alertas
        .where((a) {
          if (_filtroSeveridad != 'todas' && a.severidad != _filtroSeveridad) {
            return false;
          }
          if (_filtroInstitucion != 'todas' &&
              (a.institucion ?? '').trim() != _filtroInstitucion) {
            return false;
          }
          if (_filtroCursoId != null && a.cursoId != _filtroCursoId) {
            return false;
          }
          return true;
        })
        .toList(growable: false);
  }

  void _normalizarFiltrosAgenda() {
    final instituciones = _institucionesAgendaDisponibles();
    if (_filtroInstitucionAgenda != 'todas' &&
        !instituciones.contains(_filtroInstitucionAgenda)) {
      _filtroInstitucionAgenda = 'todas';
    }
    const riesgosValidos = {'todos', 'alto', 'medio', 'bajo'};
    if (!riesgosValidos.contains(_filtroRiesgoAgenda)) {
      _filtroRiesgoAgenda = 'todos';
    }
  }

  List<String> _institucionesAgendaDisponibles() {
    final out = _agenda.map((a) => a.institucion.trim()).toSet().toList();
    out.removeWhere((x) => x.isEmpty);
    out.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return out;
  }

  List<AgendaDocenteItem> _agendaFiltrada() {
    return _agenda
        .where((item) {
          if (_filtroInstitucionAgenda != 'todas' &&
              item.institucion.trim() != _filtroInstitucionAgenda) {
            return false;
          }
          if (_filtroRiesgoAgenda != 'todos' &&
              _nivelRiesgoCurso(item) != _filtroRiesgoAgenda) {
            return false;
          }
          return true;
        })
        .toList(growable: false);
  }

  Widget _panelFiltrosAgenda() {
    final instituciones = _institucionesAgendaDisponibles();
    final visibles = _agendaFiltrada().length;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _bloqueDescripcionFuncion(context, 'filtros_agenda'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 250,
                  child: DropdownButtonFormField<String>(
                    initialValue: _filtroInstitucionAgenda,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Institucion'),
                    items: [
                      _itemMenuElidido('todas', 'Todas'),
                      ...instituciones.map((i) => _itemMenuElidido(i, i)),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => _filtroInstitucionAgenda = v);
                    },
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: DropdownButtonFormField<String>(
                    initialValue: _filtroRiesgoAgenda,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Riesgo'),
                    items: [
                      _itemMenuElidido('todos', 'Todos'),
                      _itemMenuElidido('alto', 'Alto'),
                      _itemMenuElidido('medio', 'Medio'),
                      _itemMenuElidido('bajo', 'Bajo'),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => _filtroRiesgoAgenda = v);
                    },
                  ),
                ),
                Chip(
                  label: Text('Cursos visibles: $visibles/${_agenda.length}'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _etiquetaCursoAlerta(int? cursoId) {
    if (cursoId == null) return 'Curso general';
    final fromAgenda = _agenda.where((x) => x.cursoId == cursoId).toList();
    if (fromAgenda.isNotEmpty) {
      final x = fromAgenda.first;
      return '${x.materia} (${x.etiquetaCurso})';
    }
    final fromAlerta = _alertas
        .where((a) => a.cursoId == cursoId)
        .map((a) {
          final mat = (a.materia ?? '').trim();
          final etiqueta = (a.etiquetaCurso ?? '').trim();
          if (mat.isEmpty && etiqueta.isEmpty) return '';
          if (etiqueta.isEmpty) return mat;
          return '$mat ($etiqueta)';
        })
        .firstWhere((s) => s.isNotEmpty, orElse: () => '');
    return fromAlerta.isEmpty ? 'Curso #$cursoId' : fromAlerta;
  }

  Future<void> _posponerAlerta(
    AlertaAutomaticaDocente alerta,
    Duration duracion,
  ) async {
    if (_alertasPosponiendo.contains(alerta.clave)) return;
    setState(() => _alertasPosponiendo.add(alerta.clave));
    try {
      await Proveedores.agendaDocenteRepositorio.posponerAlerta(
        clave: alerta.clave,
        duracion: duracion,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Alerta pospuesta por ${duracion.inDays == 0 ? '24 horas' : '${duracion.inDays} dias'}',
          ),
        ),
      );
      await _cargarAgenda();
    } finally {
      if (mounted) {
        setState(() => _alertasPosponiendo.remove(alerta.clave));
      }
    }
  }

  _BloqueHorarioParseado? _parsearBloqueHorario(String texto) {
    final base = texto.split('(').first.trim();
    if (base.isEmpty) return null;
    final m = RegExp(
      r'([01]\d|2[0-3]):([0-5]\d)(?:\s*-\s*([01]\d|2[0-3]):([0-5]\d))?',
    ).firstMatch(base);
    if (m == null) return null;
    final hi = int.tryParse(m.group(1)!);
    final mi = int.tryParse(m.group(2)!);
    final hf = m.group(3) == null ? null : int.tryParse(m.group(3)!);
    final mf = m.group(4) == null ? null : int.tryParse(m.group(4)!);
    if (hi == null || mi == null) return null;
    return _BloqueHorarioParseado(
      horaInicio: hi,
      minutoInicio: mi,
      horaFin: hf,
      minutoFin: mf,
    );
  }

  int _puntajeRiesgoCurso(AgendaDocenteItem item) {
    var puntaje = 0;
    if (item.alumnosPendientes >= 6) {
      puntaje += 2;
    } else if (item.alumnosPendientes >= 3) {
      puntaje += 1;
    }
    if (item.actividadesSinEntregar >= 8) {
      puntaje += 2;
    } else if (item.actividadesSinEntregar >= 4) {
      puntaje += 1;
    }
    if (item.trabajosSinCorregir >= 10) {
      puntaje += 2;
    } else if (item.trabajosSinCorregir >= 5) {
      puntaje += 1;
    }
    final alertasAltas = _alertas
        .where((a) => a.cursoId == item.cursoId && a.severidad == 'alta')
        .length;
    final alertasMedias = _alertas
        .where((a) => a.cursoId == item.cursoId && a.severidad == 'media')
        .length;
    puntaje += (alertasAltas * 2) + alertasMedias;
    return puntaje;
  }

  String _nivelRiesgoCurso(AgendaDocenteItem item) {
    final puntaje = _puntajeRiesgoCurso(item);
    if (puntaje >= 6) return 'alto';
    if (puntaje >= 3) return 'medio';
    return 'bajo';
  }

  Color _colorRiesgoCurso(BuildContext context, String nivel) {
    final riesgo = nivel.trim().toLowerCase();
    if (riesgo == 'alto') return Colors.red.shade700;
    if (riesgo == 'medio') return Colors.orange.shade700;
    return Theme.of(context).colorScheme.primary;
  }

  String _labelRiesgoCurso(String nivel) {
    final riesgo = nivel.trim().toLowerCase();
    if (riesgo == 'alto') return 'Riesgo alto';
    if (riesgo == 'medio') return 'Riesgo medio';
    return 'Riesgo bajo';
  }

  AgendaDocenteItem? _cursoPrioritarioHoy() {
    if (_agenda.isEmpty) return null;
    final orden = [..._agenda];
    orden.sort((a, b) {
      final riesgoCmp = _puntajeRiesgoCurso(
        b,
      ).compareTo(_puntajeRiesgoCurso(a));
      if (riesgoCmp != 0) return riesgoCmp;
      final pendientesA = a.alumnosPendientes + a.actividadesSinEntregar;
      final pendientesB = b.alumnosPendientes + b.actividadesSinEntregar;
      final pendCmp = pendientesB.compareTo(pendientesA);
      if (pendCmp != 0) return pendCmp;
      return a.materia.toLowerCase().compareTo(b.materia.toLowerCase());
    });
    return orden.first;
  }

  List<_SugerenciaDocenteAuto> _sugerenciasAutomaticas() {
    final out = <_SugerenciaDocenteAuto>[];
    final altas = _alertas.where((a) => a.severidad == 'alta').length;
    final hoySinAsistencia = _agenda
        .where((x) => x.tieneClaseHoy && !x.asistenciaInicializada)
        .toList(growable: false);
    final riesgoAlto = _agenda
        .where((x) => _nivelRiesgoCurso(x) == 'alto')
        .toList(growable: false);
    final conCorrecciones = _agenda
        .where((x) => x.trabajosSinCorregir >= 8)
        .toList(growable: false);
    final proximasEval = _agenda
        .where((x) {
          final fecha = x.proximaEvaluacionFecha;
          if (fecha == null) return false;
          final delta = _soloFecha(fecha).difference(_fecha).inDays;
          return delta >= 0 && delta <= 3;
        })
        .toList(growable: false);

    if (hoySinAsistencia.isNotEmpty) {
      final curso = hoySinAsistencia.first;
      out.add(
        _SugerenciaDocenteAuto(
          icono: Icons.fact_check_outlined,
          titulo: 'Completar asistencia de clase actual',
          detalle:
              '${curso.materia} (${curso.etiquetaCurso}) tiene clase hoy sin planilla inicializada.',
          accionTexto: 'Abrir clase actual',
          onTap: () {
            _abrirClaseActualRapida(curso);
          },
        ),
      );
    }

    if (riesgoAlto.isNotEmpty) {
      final curso = riesgoAlto.first;
      out.add(
        _SugerenciaDocenteAuto(
          icono: Icons.priority_high_outlined,
          titulo: 'Priorizar seguimiento de riesgo alto',
          detalle:
              '${riesgoAlto.length} curso(s) en riesgo alto. Empezar por ${curso.materia} (${curso.etiquetaCurso}).',
          accionTexto: 'Ver historial',
          onTap: () {
            _abrirHistorialAlumnos(curso);
          },
        ),
      );
    }

    if (conCorrecciones.isNotEmpty) {
      final curso = conCorrecciones.first;
      out.add(
        _SugerenciaDocenteAuto(
          icono: Icons.rule_folder_outlined,
          titulo: 'Cerrar evaluaciones o correcciones pendientes',
          detalle:
              '${curso.materia} (${curso.etiquetaCurso}) acumula ${curso.trabajosSinCorregir} trabajos sin corregir.',
          accionTexto: 'Abrir evaluaciones',
          onTap: () {
            _abrirEvaluacionesCurso(curso);
          },
        ),
      );
    }

    if (proximasEval.isNotEmpty) {
      final curso = proximasEval.first;
      final fecha = curso.proximaEvaluacionFecha!;
      out.add(
        _SugerenciaDocenteAuto(
          icono: Icons.event_available_outlined,
          titulo: 'Preparar evaluacion proxima',
          detalle:
              '${curso.materia} (${curso.etiquetaCurso}) tiene evaluacion el ${_fechaCorta(fecha)}.',
          accionTexto: 'Ir a evaluaciones',
          onTap: () {
            _abrirEvaluacionesCurso(curso);
          },
        ),
      );
    }

    if (altas >= 3) {
      out.add(
        _SugerenciaDocenteAuto(
          icono: Icons.warning_amber_outlined,
          titulo: 'Revisar alertas altas',
          detalle:
              'Hay $altas alertas de severidad alta. Conviene revisar pendientes accionables.',
          accionTexto: 'Abrir pendientes',
          onTap: () {
            _abrirPanelPendientesAccionables();
          },
        ),
      );
    }

    return out.take(3).toList(growable: false);
  }

  Widget _panelResumenInicio() {
    final totalCursos = _agenda.length;
    final clasesHoyPendientes = _agenda
        .where((x) => x.tieneClaseHoy && !x.asistenciaInicializada)
        .length;
    final alertasAltas = _alertas.where((a) => a.severidad == 'alta').length;
    final evaluacionesProximas = _agenda.where((x) {
      final fecha = x.proximaEvaluacionFecha;
      if (fecha == null) return false;
      final delta = _soloFecha(fecha).difference(_fecha).inDays;
      return delta >= 0 && delta <= 7;
    }).length;
    final cursosRiesgoAlto = _agenda
        .where((x) => _nivelRiesgoCurso(x) == 'alto')
        .length;
    final prioritario = _cursoPrioritarioHoy();
    final nivelPrioritario = prioritario == null
        ? 'bajo'
        : _nivelRiesgoCurso(prioritario);
    final colorPrioritario = _colorRiesgoCurso(context, nivelPrioritario);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tablero del dia',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            _bloqueDescripcionFuncion(context, 'tablero'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text('Cursos: $totalCursos')),
                Chip(label: Text('Asistencia pendiente: $clasesHoyPendientes')),
                Chip(label: Text('Alertas altas: $alertasAltas')),
                Chip(label: Text('Eval <= 7 dias: $evaluacionesProximas')),
                Chip(
                  label: Text('Cursos riesgo alto: $cursosRiesgoAlto'),
                  backgroundColor: coursesRiesgoColor(cursosRiesgoAlto),
                ),
              ],
            ),
            if (prioritario != null) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: _textoElidido(
                      'Curso que requiere atencion ahora: ${prioritario.materia} (${prioritario.etiquetaCurso})',
                      maxLines: 2,
                    ),
                  ),
                  Chip(
                    label: Text(_labelRiesgoCurso(nivelPrioritario)),
                    backgroundColor: colorPrioritario.withValues(alpha: 0.15),
                    labelStyle: TextStyle(
                      color: colorPrioritario,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () => _abrirClaseActualRapida(prioritario),
                    child: const Text('Abrir clase actual'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color coursesRiesgoColor(int cantidad) {
    if (cantidad >= 3) return Colors.red.shade50;
    if (cantidad >= 1) return Colors.orange.shade50;
    return Colors.green.shade50;
  }

  Widget _panelSugerenciasAutomaticas() {
    final sugerencias = _sugerenciasAutomaticas();
    if (sugerencias.isEmpty) return const SizedBox.shrink();
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Automatizaciones docentes sugeridas',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            _bloqueDescripcionFuncion(context, 'automatizaciones'),
            const SizedBox(height: 8),
            ListView.separated(
              itemCount: sugerencias.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final s = sugerencias[i];
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(s.icono),
                  title: Text(s.titulo),
                  subtitle: Text(s.detalle),
                  trailing: s.onTap == null
                      ? null
                      : TextButton(
                          onPressed: s.onTap,
                          child: Text(s.accionTexto ?? 'Abrir'),
                        ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _panelAccionesRapidas() {
    Widget boton({
      required IconData icono,
      required String texto,
      required VoidCallback onPressed,
    }) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(icono),
          label: Align(
            alignment: Alignment.centerLeft,
            child: _textoElidido(texto),
          ),
        ),
      );
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Acciones del dia',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            _bloqueDescripcionFuncion(context, 'acciones'),
            const SizedBox(height: 8),
            boton(
              icono: Icons.near_me_outlined,
              texto: 'Ir al curso actual/proximo',
              onPressed: _abrirCursoActualOProximo,
            ),
            const SizedBox(height: 6),
            boton(
              icono: Icons.pending_actions_outlined,
              texto: 'Pendientes accionables',
              onPressed: _abrirPanelPendientesAccionables,
            ),
            const SizedBox(height: 6),
            boton(
              icono: Icons.summarize_outlined,
              texto: 'Cierre institucional',
              onPressed: _abrirPanelCierreInstitucional,
            ),
            const SizedBox(height: 6),
            boton(
              icono: Icons.dashboard_outlined,
              texto: 'Dashboard ejecutivo',
              onPressed: _abrirDashboardEjecutivo,
            ),
            const SizedBox(height: 6),
            boton(
              icono: Icons.history_outlined,
              texto: 'Auditoria docente',
              onPressed: _abrirAuditoriaDocente,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const EstadoListaCargando(mensaje: 'Cargando agenda docente...');
    }
    if (_error != null) {
      return EstadoListaError(mensaje: _error!, alReintentar: _cargarAgenda);
    }

    return Padding(
      padding: LayoutApp.kPagePadding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final ancho = constraints.maxWidth;
          final tresColumnas = ancho >= 1500;
          final dosColumnas = !tresColumnas && ancho >= 1120;

          Widget contenido;
          if (tresColumnas) {
            contenido = Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 330,
                  child: Column(
                    children: [
                      _panelResumenInicio(),
                      const SizedBox(height: 10),
                      _panelSugerenciasAutomaticas(),
                      const SizedBox(height: 10),
                      _panelAccionesRapidas(),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    children: [
                      _panelFiltrosAgenda(),
                      const SizedBox(height: 10),
                      _listaCursos(expandidoCompleto: true),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 360,
                  child: _panelAlertas(expandidoCompleto: true),
                ),
              ],
            );
          } else if (dosColumnas) {
            contenido = Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _panelResumenInicio(),
                      const SizedBox(height: 10),
                      _panelSugerenciasAutomaticas(),
                      const SizedBox(height: 10),
                      _panelAccionesRapidas(),
                      const SizedBox(height: 10),
                      _panelFiltrosAgenda(),
                      const SizedBox(height: 10),
                      _listaCursos(expandidoCompleto: true),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 340,
                  child: _panelAlertas(expandidoCompleto: true),
                ),
              ],
            );
          } else {
            contenido = Column(
              children: [
                _panelResumenInicio(),
                const SizedBox(height: 10),
                _panelSugerenciasAutomaticas(),
                const SizedBox(height: 10),
                _panelAccionesRapidas(),
                const SizedBox(height: 10),
                _panelFiltrosAgenda(),
                const SizedBox(height: 10),
                if (_alertas.isNotEmpty) _panelAlertas(expandidoCompleto: true),
                const SizedBox(height: 10),
                _listaCursos(expandidoCompleto: true),
              ],
            );
          }

          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_sincronizando)
                    const LinearProgressIndicator(minHeight: 2),
                  PanelControlesModulo(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Agenda docente - ${_fechaLarga(_fecha)}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 560),
                          child: _bloqueDescripcionFuncion(
                            context,
                            'agenda',
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _cambiarDia(-1),
                          icon: const Icon(Icons.chevron_left),
                        ),
                        TextButton(
                          onPressed: _irAHoy,
                          child: const Text('Hoy'),
                        ),
                        IconButton(
                          onPressed: () => _cambiarDia(1),
                          icon: const Icon(Icons.chevron_right),
                        ),
                        OutlinedButton.icon(
                          onPressed: _abrirCursoActualOProximo,
                          icon: const Icon(Icons.near_me_outlined),
                          label: const Text('Curso actual'),
                        ),
                        IconButton(
                          onPressed: _cargarAgenda,
                          icon: const Icon(Icons.refresh),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  contenido,
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _panelAlertas({bool lateral = false, bool expandidoCompleto = false}) {
    final alertasFiltradas = _alertasFiltradas();
    final instituciones = _institucionesAlertaDisponibles();
    final cursoIds = _cursoIdsAlertaDisponibles();
    final listado = alertasFiltradas.isEmpty
        ? const Center(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Text('No hay alertas para esos filtros'),
            ),
          )
        : ListView.builder(
            shrinkWrap: expandidoCompleto || !lateral,
            physics: expandidoCompleto || !lateral
                ? const NeverScrollableScrollPhysics()
                : null,
            itemCount: alertasFiltradas.length,
            itemBuilder: (_, i) {
              final a = alertasFiltradas[i];
              final posponiendo = _alertasPosponiendo.contains(a.clave);
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text('[${a.severidad}] ${a.mensaje}'),
                subtitle: Text(
                  '${a.institucion ?? 'Sin institucion'} | ${_etiquetaCursoAlerta(a.cursoId)}',
                ),
                trailing: PopupMenuButton<int>(
                  enabled: !posponiendo,
                  tooltip: 'Posponer alerta',
                  onSelected: (value) {
                    if (value == 1) {
                      _posponerAlerta(a, const Duration(hours: 24));
                    } else if (value == 3) {
                      _posponerAlerta(a, const Duration(days: 3));
                    } else if (value == 7) {
                      _posponerAlerta(a, const Duration(days: 7));
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 1, child: Text('Posponer 24h')),
                    PopupMenuItem(value: 3, child: Text('Posponer 3 dias')),
                    PopupMenuItem(value: 7, child: Text('Posponer 7 dias')),
                  ],
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: posponiendo
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.snooze_outlined),
                  ),
                ),
              );
            },
          );

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Alertas automaticas (${alertasFiltradas.length}/${_alertas.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            _bloqueDescripcionFuncion(context, 'alertas'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                SizedBox(
                  width: 170,
                  child: DropdownButtonFormField<String>(
                    initialValue: _filtroSeveridad,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Severidad'),
                    items: [
                      _itemMenuElidido('todas', 'Todas'),
                      _itemMenuElidido('alta', 'Alta'),
                      _itemMenuElidido('media', 'Media'),
                      _itemMenuElidido('baja', 'Baja'),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => _filtroSeveridad = v);
                    },
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: DropdownButtonFormField<String>(
                    initialValue: _filtroInstitucion,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Institucion'),
                    items: [
                      _itemMenuElidido('todas', 'Todas'),
                      ...instituciones.map((i) => _itemMenuElidido(i, i)),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => _filtroInstitucion = v);
                    },
                  ),
                ),
                SizedBox(
                  width: 260,
                  child: DropdownButtonFormField<int?>(
                    initialValue: _filtroCursoId,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Curso'),
                    items: [
                      _itemMenuElidido<int?>(null, 'Todos'),
                      ...cursoIds.map(
                        (id) => DropdownMenuItem<int?>(
                          value: id,
                          child: _textoElidido(_etiquetaCursoAlerta(id)),
                        ),
                      ),
                    ],
                    onChanged: (v) => setState(() => _filtroCursoId = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (expandidoCompleto)
              listado
            else if (lateral)
              Expanded(child: listado)
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: listado,
              ),
          ],
        ),
      ),
    );
  }

  Widget _listaCursos({bool expandidoCompleto = false}) {
    final agendaVisible = _agendaFiltrada();
    if (_agenda.isEmpty) {
      return const EstadoListaVacia(
        titulo: 'No hay cursos para el dia seleccionado',
        icono: Icons.event_busy_outlined,
      );
    }
    if (agendaVisible.isEmpty) {
      return const EstadoListaVacia(
        titulo: 'No hay cursos para esos filtros',
        icono: Icons.event_busy_outlined,
      );
    }

    return ListView.separated(
      shrinkWrap: expandidoCompleto,
      physics: expandidoCompleto ? const NeverScrollableScrollPhysics() : null,
      itemCount: agendaVisible.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final item = agendaVisible[i];
        final creando = _cursosCreandoClase.contains(item.cursoId);
        final inicializando =
            item.claseHoyId != null &&
            _clasesInicializando.contains(item.claseHoyId!);
        return Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${item.materia} - ${item.etiquetaCurso}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Builder(
                      builder: (context) {
                        final nivel = _nivelRiesgoCurso(item);
                        final color = _colorRiesgoCurso(context, nivel);
                        return Chip(
                          label: Text(_labelRiesgoCurso(nivel)),
                          backgroundColor: color.withValues(alpha: 0.15),
                          labelStyle: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w700,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('${item.institucion} | ${item.carrera}'),
                const SizedBox(height: 6),
                Text(
                  item.bloquesHorarios.isEmpty
                      ? 'Horario semanal: sin configurar'
                      : 'Horario semanal: ${item.bloquesHorarios.join(' | ')}',
                ),
                const SizedBox(height: 4),
                Text('Clase pasada: ${item.temaClasePasada ?? 'Sin datos'}'),
                Text('Continuar hoy: ${item.continuarHoy}'),
                Text(
                  'Pendientes: ${item.alumnosPendientes} alumnos | Entregas: ${item.actividadesSinEntregar}',
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _abrirHorariosCurso(item),
                      icon: const Icon(Icons.schedule_outlined),
                      label: const Text('Horarios'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _abrirIntervencionesCurso(item),
                      icon: const Icon(Icons.record_voice_over_outlined),
                      label: const Text('Intervenciones'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _abrirAcuerdosCurso(item),
                      icon: const Icon(Icons.handshake_outlined),
                      label: const Text('Acuerdos'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _abrirReglasInstitucion(item),
                      icon: const Icon(Icons.apartment_outlined),
                      label: const Text('Reglas inst.'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _abrirHistorialAlumnos(item),
                      icon: const Icon(Icons.person_search_outlined),
                      label: const Text('Historial'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _abrirAgrupamientoCurso(item),
                      icon: const Icon(Icons.groups_outlined),
                      label: const Text('Agrupamiento'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _abrirPlantillasCurso(item),
                      icon: const Icon(Icons.text_snippet_outlined),
                      label: const Text('Plantillas'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _abrirRubricasCurso(item),
                      icon: const Icon(Icons.fact_check_outlined),
                      label: const Text('Rubricas'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _abrirEvaluacionesCurso(item),
                      icon: const Icon(Icons.rule_folder_outlined),
                      label: const Text('Evaluaciones'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _abrirEvidenciasCurso(item),
                      icon: const Icon(Icons.attach_file_outlined),
                      label: const Text('Evidencias'),
                    ),
                    FilledButton.icon(
                      onPressed: () => _abrirClaseActualRapida(item),
                      icon: const Icon(Icons.bolt_outlined),
                      label: const Text('Clase actual'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _abrirFichaPedagogica(item),
                      icon: const Icon(Icons.menu_book_outlined),
                      label: const Text('Ficha'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _abrirPerfilEstableCurso(item),
                      icon: const Icon(Icons.psychology_alt_outlined),
                      label: const Text('Perfil'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _abrirCierreCurso(item),
                      icon: const Icon(Icons.assignment_outlined),
                      label: const Text('Cierre'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _abrirSintesisPeriodoCurso(item),
                      icon: const Icon(Icons.summarize_outlined),
                      label: const Text('Sintesis'),
                    ),
                    if (!item.tieneClaseHoy)
                      FilledButton.icon(
                        onPressed: creando
                            ? null
                            : () => _crearClaseDelDia(item),
                        icon: const Icon(Icons.add_task_outlined),
                        label: Text(creando ? 'Creando...' : 'Crear clase'),
                      ),
                    if (item.tieneClaseHoy && !item.asistenciaInicializada)
                      OutlinedButton.icon(
                        onPressed: inicializando
                            ? null
                            : () => _inicializarAsistenciaHoy(item),
                        icon: const Icon(Icons.fact_check_outlined),
                        label: Text(
                          inicializando
                              ? 'Inicializando...'
                              : 'Inicializar asistencia',
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BloqueHorarioParseado {
  final int horaInicio;
  final int minutoInicio;
  final int? horaFin;
  final int? minutoFin;

  const _BloqueHorarioParseado({
    required this.horaInicio,
    required this.minutoInicio,
    required this.horaFin,
    required this.minutoFin,
  });
}

class _SugerenciaDocenteAuto {
  final IconData icono;
  final String titulo;
  final String detalle;
  final String? accionTexto;
  final VoidCallback? onTap;

  const _SugerenciaDocenteAuto({
    required this.icono,
    required this.titulo,
    required this.detalle,
    required this.accionTexto,
    required this.onTap,
  });
}

class _CandidatoCursoRapido {
  final AgendaDocenteItem item;
  final DateTime inicio;
  final DateTime fin;

  const _CandidatoCursoRapido({
    required this.item,
    required this.inicio,
    required this.fin,
  });
}
