part of 'asistencia_pantalla.dart';

extension _AsistenciaPantallaListaLayout on _AsistenciaPantallaState {
  bool _estadoCuentaComoPresente(EstadoAsistencia estado) {
    return estado == EstadoAsistencia.presente ||
        estado == EstadoAsistencia.tarde;
  }

  String _labelEstadoTarjetaAlumno(RegistroAsistenciaAlumno registro) {
    switch (registro.estado) {
      case EstadoAsistencia.presente:
        return 'Presente';
      case EstadoAsistencia.tarde:
        return 'Tarde';
      case EstadoAsistencia.justificada:
        return 'Justificada';
      case EstadoAsistencia.ausente:
        return 'Ausente';
      case EstadoAsistencia.pendiente:
        return 'Pendiente';
    }
  }

  Color _colorEstadoTarjetaAlumno(
    BuildContext context,
    RegistroAsistenciaAlumno registro,
  ) {
    switch (registro.estado) {
      case EstadoAsistencia.presente:
        return Colors.green.shade700;
      case EstadoAsistencia.tarde:
        return Colors.teal.shade700;
      case EstadoAsistencia.justificada:
        return Colors.amber.shade800;
      case EstadoAsistencia.ausente:
        return Colors.red.shade700;
      case EstadoAsistencia.pendiente:
        return Theme.of(context).colorScheme.primary;
    }
  }

  List<ClaseAsistencia> _clasesFiltradas() {
    final q = _filtroClase.trim().toLowerCase();
    if (q.isEmpty) return _clases;
    return _clases
        .where((clase) {
          final tema = (clase.tema ?? '').trim();
          final texto = '${_fechaClase(clase.fecha)} $tema'.toLowerCase();
          return texto.contains(q);
        })
        .toList(growable: false);
  }

  List<RegistroAsistenciaAlumno> _planillaFiltrada() {
    final q = _filtroAlumno.trim().toLowerCase();
    if (q.isEmpty) return _planilla;
    return _planilla
        .where((r) {
          final texto =
              '${r.alumno.nombreCompleto} '
                      '${r.alumno.documento ?? ''} '
                      '${r.alumno.contextoAcademico}'
                  .toLowerCase();
          return texto.contains(q);
        })
        .toList(growable: false);
  }

  Widget _contenidoListaClasesDesktop(List<ClaseAsistencia> clasesFiltradas) {
    if (_cargandoClases) {
      return const EstadoListaCargando(mensaje: 'Cargando clases...');
    }
    if (_clases.isEmpty) {
      return const EstadoListaVacia(
        titulo: 'No hay clases cargadas para este curso',
        icono: Icons.event_busy_outlined,
      );
    }
    if (clasesFiltradas.isEmpty) {
      return const EstadoListaVacia(
        titulo: 'No hay clases que coincidan con el filtro',
        icono: Icons.search_off_outlined,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(right: 12, bottom: 8),
      itemCount: clasesFiltradas.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final clase = clasesFiltradas[index];
        final tema = (clase.tema ?? '').trim();
        final label = tema.isEmpty
            ? _fechaClase(clase.fecha)
            : '${_fechaClase(clase.fecha)} - $tema';

        return ListTile(
          selected: _claseId == clase.id,
          leading: const Icon(Icons.event_note_outlined),
          title: Text(label, maxLines: 2, overflow: TextOverflow.ellipsis),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          trailing: IconButton(
            tooltip: 'Eliminar clase',
            onPressed: _guardando ? null : () => _eliminarClase(clase.id),
            icon: const Icon(Icons.delete_outline),
          ),
          onTap: _guardando ? null : () => _seleccionarClase(clase.id),
        );
      },
    );
  }

  Widget _buildPantalla(BuildContext context) {
    if (_cargandoInicial) {
      return const EstadoListaCargando(mensaje: 'Cargando asistencia...');
    }

    if (_error != null) {
      return EstadoListaError(mensaje: _error!, alReintentar: _cargarInicial);
    }

    if (_cursos.isEmpty) {
      return const EstadoListaVacia(
        titulo: 'Primero crea al menos un curso',
        icono: Icons.class_outlined,
      );
    }

    final clasesFiltradas = _clasesFiltradas();
    final planillaFiltrada = _planillaFiltrada();

    final panelControlesContenido = LayoutBuilder(
      builder: (context, c) {
        final esTabletPanoramico =
            c.maxWidth >= LayoutApp.kTablet && c.maxWidth < LayoutApp.kDesktop;
        final compacto = c.maxWidth < 700;
        final botonNuevaClase = FilledButton.icon(
          onPressed: _guardando ? null : _crearClase,
          icon: const Icon(Icons.add_task_outlined),
          label: Text(_guardando ? 'Guardando...' : 'Nueva clase'),
        );

        if (esTabletPanoramico) {
          return Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 320,
                child: _selectorCurso(deshabilitado: _guardando),
              ),
              SizedBox(width: 190, height: 42, child: botonNuevaClase),
              SizedBox(
                width: 320,
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Buscar clase por fecha o tema',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (v) => _actualizarEstado(() => _filtroClase = v),
                ),
              ),
              SizedBox(
                width: 320,
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Buscar alumno en planilla',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (v) => _actualizarEstado(() => _filtroAlumno = v),
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            _selectorCurso(deshabilitado: _guardando),
            const SizedBox(height: 10),
            if (compacto) ...[
              Row(
                children: [
                  Expanded(child: SizedBox(height: 42, child: botonNuevaClase)),
                ],
              ),
            ] else ...[
              Row(
                children: [
                  SizedBox(width: 180, height: 42, child: botonNuevaClase),
                ],
              ),
            ],
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar clase por fecha o tema',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => _actualizarEstado(() => _filtroClase = v),
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar alumno en planilla',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => _actualizarEstado(() => _filtroAlumno = v),
            ),
          ],
        );
      },
    );

    final panelControles = Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.settings_outlined),
              title: Text('Configuracion'),
            ),
            const SizedBox(height: 6),
            panelControlesContenido,
          ],
        ),
      ),
    );

    Widget planillaContenido;
    if (_cargandoPlanilla) {
      planillaContenido = const EstadoListaCargando(
        mensaje: 'Cargando planilla...',
      );
    } else if (_planilla.isEmpty) {
      planillaContenido = const EstadoListaVacia(
        titulo:
            'No hay alumnos inscriptos en este curso.\nVe a "Cursos" para inscribir alumnos.',
        icono: Icons.group_off_outlined,
      );
    } else if (planillaFiltrada.isEmpty) {
      planillaContenido = const EstadoListaVacia(
        titulo: 'No hay alumnos que coincidan con el filtro',
        icono: Icons.search_off_outlined,
      );
    } else {
      planillaContenido = LayoutBuilder(
        builder: (context, c) {
          final columnas = c.maxWidth >= 760
              ? 4
              : c.maxWidth >= 560
              ? 3
              : c.maxWidth >= 320
              ? 2
              : 1;
          return GridView.builder(
            padding: const EdgeInsets.only(right: 4, bottom: 8, top: 4),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columnas,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.28,
            ),
            itemCount: planillaFiltrada.length,
            itemBuilder: (context, index) {
              final r = planillaFiltrada[index];
              final seleccionado = _alumnoDetalleId == r.alumno.id;
              final color = _colorEstadoTarjetaAlumno(context, r);
              final principalEsPresente = _estadoCuentaComoPresente(r.estado);
              final contexto = [
                (r.alumno.documento ?? '').trim(),
                r.alumno.contextoAcademico.trim(),
              ].where((x) => x.isNotEmpty).join(' · ');

              return Material(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _seleccionarAlumnoDetalle(r.alumno.id),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: seleccionado
                            ? color
                            : Theme.of(context).colorScheme.outlineVariant,
                        width: seleccionado ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.person_outline,
                                size: 16,
                                color: color,
                              ),
                            ),
                            const Spacer(),
                            InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: _guardando
                                  ? null
                                  : () {
                                      _seleccionarAlumnoDetalle(r.alumno.id);
                                      _cambiarEstadoAlumno(
                                        alumnoId: r.alumno.id,
                                        estado: principalEsPresente
                                            ? EstadoAsistencia.ausente
                                            : EstadoAsistencia.presente,
                                      );
                                    },
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: principalEsPresente
                                      ? color.withValues(alpha: 0.14)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: color),
                                ),
                                child: Icon(
                                  principalEsPresente
                                      ? Icons.check_rounded
                                      : Icons.crop_square_rounded,
                                  size: 16,
                                  color: color,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          r.alumno.nombreCompleto,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          contexto.isEmpty
                              ? 'Sin contexto adicional'
                              : contexto,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _labelEstadoTarjetaAlumno(r),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(
                                      color: color,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                    ),
                              ),
                            ),
                            if (r.actividadEntregada)
                              Icon(
                                Icons.assignment_turned_in_outlined,
                                size: 18,
                                color: Colors.green.shade700,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    }

    return Padding(
      padding: LayoutApp.kPagePadding,
      child: Column(
        children: [
          if (_sincronizando) const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: LayoutBuilder(
              builder: (context, c) {
                final esDesktop = LayoutApp.esDesktop(c.maxWidth);
                final esTablet = LayoutApp.esTablet(c.maxWidth);

                if (!esTablet) {
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 260,
                          child: Card(
                            margin: EdgeInsets.zero,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: Icon(
                                      Icons.calendar_month_outlined,
                                    ),
                                    title: Text('Clases'),
                                  ),
                                  const SizedBox(height: 6),
                                  Expanded(
                                    child: _contenidoListaClasesDesktop(
                                      clasesFiltradas,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        panelControles,
                        const SizedBox(height: 10),
                        Card(
                          margin: EdgeInsets.zero,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_agendaCursoSeleccionado() != null) ...[
                                  _panelContextoAgendaCursoActual(),
                                  const SizedBox(height: 12),
                                ],
                                _selectorMasivoAncho(),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 360,
                          child: Card(
                            margin: EdgeInsets.zero,
                            child: planillaContenido,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(height: 420, child: _panelDetalleAlumno()),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 260,
                          child: _panelAlertasAgendaAsistencias(),
                        ),
                      ],
                    ),
                  );
                }

                final anchoDetalleBase = esDesktop ? 400.0 : 340.0;
                final anchoIzquierdaBase = esDesktop ? 320.0 : 280.0;
                final anchoAlertasBase = esDesktop ? 300.0 : 250.0;
                final anchoDetalleMin = esDesktop ? 340.0 : 300.0;
                final anchoIzquierdaMin = esDesktop ? 280.0 : 240.0;
                final anchoAlertasMin = esDesktop ? 250.0 : 220.0;
                const separaciones = 36.0;
                const anchoCentroMinimo = 320.0;

                var anchoIzquierda = anchoIzquierdaBase;
                var anchoDetalle = anchoDetalleBase;
                var anchoAlertas = anchoAlertasBase;
                final totalActual = c.maxWidth;
                final minimoNecesario =
                    anchoIzquierda +
                    anchoDetalle +
                    anchoAlertas +
                    anchoCentroMinimo +
                    separaciones;
                if (totalActual < minimoNecesario) {
                  var deficit = minimoNecesario - totalActual;

                  final recorteDetalleMax = anchoDetalle - anchoDetalleMin;
                  if (recorteDetalleMax > 0) {
                    final recorteDetalle = deficit < recorteDetalleMax
                        ? deficit
                        : recorteDetalleMax;
                    anchoDetalle -= recorteDetalle;
                    deficit -= recorteDetalle;
                  }

                  final recorteIzquierdaMax =
                      anchoIzquierda - anchoIzquierdaMin;
                  if (deficit > 0 && recorteIzquierdaMax > 0) {
                    final recorteIzquierda = deficit < recorteIzquierdaMax
                        ? deficit
                        : recorteIzquierdaMax;
                    anchoIzquierda -= recorteIzquierda;
                    deficit -= recorteIzquierda;
                  }

                  final recorteAlertasMax = anchoAlertas - anchoAlertasMin;
                  if (deficit > 0 && recorteAlertasMax > 0) {
                    final recorteAlertas = deficit < recorteAlertasMax
                        ? deficit
                        : recorteAlertasMax;
                    anchoAlertas -= recorteAlertas;
                  }
                }
                final botonNuevaClase = FilledButton.icon(
                  onPressed: _guardando ? null : _crearClase,
                  icon: const Icon(Icons.add_task_outlined),
                  label: Text(_guardando ? 'Guardando...' : 'Nueva clase'),
                );

                return Row(
                  children: [
                    SizedBox(
                      width: anchoIzquierda,
                      child: Column(
                        children: [
                          Card(
                            margin: EdgeInsets.zero,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: Icon(Icons.tune_outlined),
                                    title: Text('Curso'),
                                  ),
                                  const SizedBox(height: 6),
                                  _selectorCurso(
                                    deshabilitado: _guardando,
                                    mostrarLabel: false,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: Card(
                              margin: EdgeInsets.zero,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: Icon(
                                        Icons.calendar_month_outlined,
                                      ),
                                      title: Text('Clases'),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: SizedBox(
                                            height: 42,
                                            child: botonNuevaClase,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    TextField(
                                      decoration: const InputDecoration(
                                        hintText:
                                            'Buscar clase por fecha o tema',
                                        prefixIcon: Icon(Icons.search),
                                      ),
                                      onChanged: (v) => _actualizarEstado(
                                        () => _filtroClase = v,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Expanded(
                                      child: _contenidoListaClasesDesktop(
                                        clasesFiltradas,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: Card(
                              margin: EdgeInsets.zero,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: Icon(Icons.group_outlined),
                                      title: Text('Estudiantes'),
                                    ),
                                    if (_agendaCursoSeleccionado() != null) ...[
                                      _panelContextoAgendaCursoActual(),
                                      const SizedBox(height: 12),
                                    ],
                                    TextField(
                                      decoration: const InputDecoration(
                                        hintText: 'Buscar alumno en planilla',
                                        prefixIcon: Icon(Icons.search),
                                      ),
                                      onChanged: (v) => _actualizarEstado(
                                        () => _filtroAlumno = v,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    _selectorMasivoAncho(),
                                    const SizedBox(height: 12),
                                    Expanded(child: planillaContenido),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: anchoDetalle,
                      child: Column(
                        children: [Expanded(child: _panelDetalleAlumno())],
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: anchoAlertas,
                      child: Column(
                        children: [
                          Expanded(child: _panelAlertasAgendaAsistencias()),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
