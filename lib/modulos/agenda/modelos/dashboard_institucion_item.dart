class DashboardInstitucionItem {
  final String institucion;
  final int cursosActivos;
  final int alertasAltas;
  final int alertasMedias;
  final int alertasBajas;
  final int estudiantesEnRiesgo;
  final int evaluacionesAbiertas;
  final int contenidosPendientes;
  final String semaforo;
  final String resumen;

  const DashboardInstitucionItem({
    required this.institucion,
    required this.cursosActivos,
    required this.alertasAltas,
    required this.alertasMedias,
    required this.alertasBajas,
    required this.estudiantesEnRiesgo,
    required this.evaluacionesAbiertas,
    required this.contenidosPendientes,
    required this.semaforo,
    required this.resumen,
  });
}
