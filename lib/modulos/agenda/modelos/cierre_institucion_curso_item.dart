import 'resumen_cierre_curso.dart';

class CierreInstitucionCursoItem {
  final int cursoId;
  final String institucion;
  final String carrera;
  final String materia;
  final String etiquetaCurso;
  final ResumenCierreCurso resumen;

  const CierreInstitucionCursoItem({
    required this.cursoId,
    required this.institucion,
    required this.carrera,
    required this.materia,
    required this.etiquetaCurso,
    required this.resumen,
  });

  String get etiquetaCompleta => '$materia ($etiquetaCurso)';
}
