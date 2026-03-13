import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_de_asistencias/modulos/asistencias/modelos/estado_asistencia.dart';

void main() {
  test('EstadoAsistenciaX.fromCode mapea correctamente', () {
    expect(EstadoAsistenciaX.fromCode('pendiente'), EstadoAsistencia.pendiente);
    expect(EstadoAsistenciaX.fromCode('presente'), EstadoAsistencia.presente);
    expect(EstadoAsistenciaX.fromCode('ausente'), EstadoAsistencia.ausente);
    expect(EstadoAsistenciaX.fromCode('tarde'), EstadoAsistencia.tarde);
    expect(
      EstadoAsistenciaX.fromCode('justificada'),
      EstadoAsistencia.justificada,
    );

    expect(
      EstadoAsistenciaX.fromCode('desconocido'),
      EstadoAsistencia.pendiente,
    );
    expect(EstadoAsistenciaX.fromCode('  TARDE  '), EstadoAsistencia.tarde);
  });
}
