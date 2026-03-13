import '/modulos/alumnos/modelos/alumno.dart';

import 'estado_asistencia.dart';

class RegistroAsistenciaAlumno {
  final Alumno alumno;
  final EstadoAsistencia estado;
  final String? observacion;
  final bool justificada;
  final String? detalleJustificacion;
  final bool actividadEntregada;
  final String? notaActividad;
  final String? detalleActividad;

  const RegistroAsistenciaAlumno({
    required this.alumno,
    required this.estado,
    required this.observacion,
    required this.justificada,
    required this.detalleJustificacion,
    required this.actividadEntregada,
    required this.notaActividad,
    required this.detalleActividad,
  });

  RegistroAsistenciaAlumno copyWith({
    EstadoAsistencia? estado,
    String? observacion,
    bool? justificada,
    String? detalleJustificacion,
    bool? actividadEntregada,
    String? notaActividad,
    String? detalleActividad,
  }) {
    return RegistroAsistenciaAlumno(
      alumno: alumno,
      estado: estado ?? this.estado,
      observacion: observacion ?? this.observacion,
      justificada: justificada ?? this.justificada,
      detalleJustificacion: detalleJustificacion ?? this.detalleJustificacion,
      actividadEntregada: actividadEntregada ?? this.actividadEntregada,
      notaActividad: notaActividad ?? this.notaActividad,
      detalleActividad: detalleActividad ?? this.detalleActividad,
    );
  }
}
