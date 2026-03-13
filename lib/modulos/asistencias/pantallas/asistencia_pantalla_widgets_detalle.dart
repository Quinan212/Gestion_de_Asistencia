part of 'asistencia_pantalla.dart';

extension _AsistenciaPantallaWidgetsDetalle on _AsistenciaPantallaState {
  static const List<String> _estadosContenidoClase = [
    'completado',
    'parcial',
    'reprogramado',
  ];
  static const List<String> _resultadosActividadClase = [
    'bien',
    'regular',
    'mal',
  ];

  String _labelEstadoContenidoClase(String valor) {
    switch (valor) {
      case 'completado':
        return 'Completado';
      case 'reprogramado':
        return 'Reprogramado';
      case 'parcial':
      default:
        return 'Parcial';
    }
  }

  String _labelResultadoActividadClase(String valor) {
    switch (valor) {
      case 'bien':
        return 'Bien';
      case 'mal':
        return 'Mal';
      case 'regular':
      default:
        return 'Regular';
    }
  }

  Widget _selectorMasivoAncho() {
    final deshabilitado = _guardando || _cargandoPlanilla || _planilla.isEmpty;
    return SizedBox(
      width: double.infinity,
      child: DropdownButtonFormField<EstadoAsistencia>(
        key: ValueKey('selector-masivo-$_selectorMasivoVersion-$_claseId'),
        initialValue: null,
        isExpanded: true,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.done_all_outlined),
        ),
        hint: const Text('Aplicar estado general a toda la clase'),
        items: EstadoAsistenciaX.valuesOrdenadas
            .map(
              (e) => DropdownMenuItem<EstadoAsistencia>(
                value: e,
                child: Text(e.label),
              ),
            )
            .toList(growable: false),
        onChanged: deshabilitado ? null : _aplicarSelectorMasivo,
      ),
    );
  }

  Widget _selectorCurso({
    bool deshabilitado = false,
    bool mostrarLabel = true,
  }) {
    final decoration = mostrarLabel
        ? const InputDecoration(labelText: 'Curso')
        : const InputDecoration(
            hintText: 'Seleccionar curso',
            prefixIcon: Icon(Icons.class_outlined),
          );

    return DropdownButtonFormField<int>(
      initialValue: _cursoId,
      isExpanded: true,
      decoration: decoration,
      items: _cursos
          .map(
            (c) => DropdownMenuItem<int>(
              value: c.id,
              child: Text(
                c.etiqueta,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      selectedItemBuilder: (context) {
        return _cursos
            .map(
              (c) => Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  c.etiqueta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
            .toList(growable: false);
      },
      onChanged: deshabilitado ? null : _cambiarCurso,
    );
  }

  ClaseAsistencia? _claseSeleccionadaActual() {
    final claseId = _claseDetalleId;
    if (claseId == null) return null;
    for (final clase in _clases) {
      if (clase.id == claseId) return clase;
    }
    return null;
  }

  Widget _bloqueDetalleLectura({
    required String titulo,
    required String valor,
    double minHeight = 56,
  }) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: t.labelMedium?.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: minHeight),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Text(
            valor.trim().isEmpty ? 'Sin datos cargados' : valor.trim(),
            style: t.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _panelDetalleClase() {
    final clase = _claseSeleccionadaActual();
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    if (clase == null) {
      return _panelDetalleVacio();
    }
    _sincronizarFormularioClase(clase);

    return Card(
      margin: EdgeInsets.zero,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Detalle de clase', style: textTheme.titleMedium),
                const Spacer(),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cs.surfaceContainerHighest,
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: IconButton(
                    onPressed: _guardandoDetalleClase
                        ? null
                        : () {
                            _actualizarEstado(() {
                              if (_editandoDetalleClase) {
                                _sincronizarFormularioClase(
                                  clase,
                                  forzar: true,
                                );
                              }
                              _editandoDetalleClase = !_editandoDetalleClase;
                            });
                          },
                    tooltip: _editandoDetalleClase
                        ? 'Cancelar edicion'
                        : 'Editar',
                    icon: Icon(
                      _editandoDetalleClase
                          ? Icons.close_rounded
                          : Icons.edit_outlined,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: cs.primary,
                ),
                const SizedBox(width: 8),
                Text(_fechaClase(clase.fecha), style: textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 14),
            if (_editandoDetalleClase) ...[
              TextField(
                controller: _temaClaseCtrl,
                decoration: const InputDecoration(
                  labelText: 'Tema de clase',
                  hintText: 'Ej: Fracciones equivalentes',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descripcionClaseCtrl,
                minLines: 4,
                maxLines: 8,
                decoration: const InputDecoration(
                  labelText: 'Descripcion del tema',
                  hintText: 'Contenido y objetivos de la clase',
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _actividadClaseCtrl,
                minLines: 3,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Actividad del dia',
                  hintText: 'Consigna o actividad solicitada',
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  SizedBox(
                    width: 220,
                    child: DropdownButtonFormField<String>(
                      initialValue: _estadoContenidoClase,
                      decoration: const InputDecoration(
                        labelText: 'Contenido de clase',
                      ),
                      items: _estadosContenidoClase
                          .map(
                            (e) => DropdownMenuItem<String>(
                              value: e,
                              child: Text(_labelEstadoContenidoClase(e)),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (v) {
                        if (v == null) return;
                        _actualizarEstado(() => _estadoContenidoClase = v);
                      },
                    ),
                  ),
                  SizedBox(
                    width: 220,
                    child: DropdownButtonFormField<String>(
                      initialValue: _resultadoActividadClase,
                      decoration: const InputDecoration(
                        labelText: 'Resultado de actividad',
                      ),
                      items: _resultadosActividadClase
                          .map(
                            (e) => DropdownMenuItem<String>(
                              value: e,
                              child: Text(_labelResultadoActividadClase(e)),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (v) {
                        if (v == null) return;
                        _actualizarEstado(() => _resultadoActividadClase = v);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _guardandoDetalleClase
                      ? null
                      : _guardarDetalleClase,
                  icon: const Icon(Icons.save_outlined),
                  label: Text(
                    _guardandoDetalleClase
                        ? 'Guardando detalle...'
                        : 'Guardar detalle de clase',
                  ),
                ),
              ),
            ] else ...[
              _bloqueDetalleLectura(
                titulo: 'Tema de clase',
                valor: _temaClaseCtrl.text,
                minHeight: 58,
              ),
              const SizedBox(height: 14),
              _bloqueDetalleLectura(
                titulo: 'Descripcion del tema',
                valor: _descripcionClaseCtrl.text,
                minHeight: 140,
              ),
              const SizedBox(height: 14),
              _bloqueDetalleLectura(
                titulo: 'Actividad del dia',
                valor: _actividadClaseCtrl.text,
                minHeight: 110,
              ),
              const SizedBox(height: 14),
              _bloqueDetalleLectura(
                titulo: 'Contenido de clase',
                valor: _labelEstadoContenidoClase(_estadoContenidoClase),
              ),
              const SizedBox(height: 14),
              _bloqueDetalleLectura(
                titulo: 'Resultado de actividad',
                valor: _labelResultadoActividadClase(_resultadoActividadClase),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _panelDetalleVacio() {
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Selecciona una clase o un alumno para ver detalle.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
        ),
      ),
    );
  }

  RegistroAsistenciaAlumno? _registroDetalleActual() {
    final alumnoId = _alumnoDetalleId;
    if (alumnoId == null) return null;
    for (final r in _planilla) {
      if (r.alumno.id == alumnoId) return r;
    }
    return null;
  }

  Widget _panelDetalleAlumno() {
    final registro = _registroDetalleActual();
    if (registro == null && _claseDetalleId != null) {
      return _panelDetalleClase();
    }
    if (registro == null) {
      return _panelDetalleVacio();
    }

    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final principalEsPresente =
        registro.estado == EstadoAsistencia.presente ||
        registro.estado == EstadoAsistencia.tarde;
    final clase = _claseSeleccionadaActual();
    _sincronizarFormularioAlumno(registro);

    final fotoPath = (registro.alumno.fotoPath ?? '').trim();
    final tieneFoto = fotoPath.isNotEmpty && File(fotoPath).existsSync();

    return Card(
      margin: EdgeInsets.zero,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Detalle de alumno', style: textTheme.titleMedium),
                const Spacer(),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cs.surfaceContainerHighest,
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: IconButton(
                    onPressed: _guardandoDetalleAlumno
                        ? null
                        : () {
                            _actualizarEstado(() {
                              if (_editandoDetalleAlumno) {
                                _sincronizarFormularioAlumno(
                                  registro,
                                  forzar: true,
                                );
                              }
                              _editandoDetalleAlumno = !_editandoDetalleAlumno;
                            });
                          },
                    tooltip: _editandoDetalleAlumno
                        ? 'Cancelar edicion'
                        : 'Editar',
                    icon: Icon(
                      _editandoDetalleAlumno
                          ? Icons.close_rounded
                          : Icons.edit_outlined,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(40),
                  onTap: _editandoDetalleAlumno
                      ? () => _cargarFotoAlumno(registro)
                      : null,
                  child: CircleAvatar(
                    radius: 34,
                    backgroundColor: cs.surfaceContainerHigh,
                    backgroundImage: tieneFoto
                        ? FileImage(File(fotoPath))
                        : null,
                    child: tieneFoto
                        ? null
                        : const Icon(Icons.add_a_photo_outlined, size: 28),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        registro.alumno.nombreCompleto,
                        style: textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _editandoDetalleAlumno
                            ? 'Click en la foto para cargar o cambiar imagen'
                            : 'Activa edicion para cambiar la foto',
                        style: textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Presente'),
              subtitle: Text(
                principalEsPresente
                    ? 'Marcado como presente'
                    : 'Marcado como ausente',
              ),
              value: principalEsPresente,
              onChanged: _guardando || !_editandoDetalleAlumno
                  ? null
                  : (v) {
                      _cambiarEstadoAlumno(
                        alumnoId: registro.alumno.id,
                        estado: v
                            ? EstadoAsistencia.presente
                            : EstadoAsistencia.ausente,
                      );
                    },
            ),
            const SizedBox(height: 8),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Ausencia justificada'),
              subtitle: const Text('Solo aplica si el alumno esta ausente'),
              value: _justificadaFormulario,
              onChanged: !_editandoDetalleAlumno || principalEsPresente
                  ? null
                  : (v) => _actualizarEstado(() => _justificadaFormulario = v),
            ),
            if (_editandoDetalleAlumno) ...[
              TextField(
                controller: _detalleJustificacionCtrl,
                minLines: 3,
                maxLines: 6,
                enabled: _justificadaFormulario && !principalEsPresente,
                decoration: const InputDecoration(
                  labelText: 'Detalle de justificacion',
                  hintText: 'Motivo, comprobante, contexto, etc.',
                ),
              ),
            ] else ...[
              _bloqueDetalleLectura(
                titulo: 'Detalle de justificacion',
                valor: (_justificadaFormulario && !principalEsPresente)
                    ? _detalleJustificacionCtrl.text
                    : '',
                minHeight: 92,
              ),
            ],
            const SizedBox(height: 12),
            Text('Actividad de la clase', style: textTheme.titleSmall),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Text(
                ((clase?.actividadDia ?? '').trim().isEmpty)
                    ? 'Todavia no se cargo la actividad del dia en detalle de clase.'
                    : clase!.actividadDia!.trim(),
                style: textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Entrego actividad'),
              value: _actividadEntregadaFormulario,
              onChanged: !_editandoDetalleAlumno
                  ? null
                  : (v) => _actualizarEstado(
                      () => _actividadEntregadaFormulario = v,
                    ),
            ),
            if (_editandoDetalleAlumno) ...[
              TextField(
                controller: _notaActividadCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nota de actividad',
                  hintText: 'Ej: 8/10 o Aprobado',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _detalleActividadCtrl,
                minLines: 3,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Detalle de desempeno',
                  hintText: 'Que le falto o que hizo bien en la actividad',
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _guardandoDetalleAlumno
                      ? null
                      : _guardarDetalleAlumno,
                  icon: const Icon(Icons.save_outlined),
                  label: Text(
                    _guardandoDetalleAlumno
                        ? 'Guardando detalle...'
                        : 'Guardar detalle del alumno',
                  ),
                ),
              ),
            ] else ...[
              _bloqueDetalleLectura(
                titulo: 'Nota de actividad',
                valor: _notaActividadCtrl.text,
                minHeight: 58,
              ),
              const SizedBox(height: 12),
              _bloqueDetalleLectura(
                titulo: 'Detalle de desempeno',
                valor: _detalleActividadCtrl.text,
                minHeight: 110,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
