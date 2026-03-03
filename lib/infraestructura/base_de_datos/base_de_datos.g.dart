// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_de_datos.dart';

// ignore_for_file: type=lint
class $TablaProductosTable extends TablaProductos
    with TableInfo<$TablaProductosTable, TablaProducto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TablaProductosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unidadMeta = const VerificationMeta('unidad');
  @override
  late final GeneratedColumn<String> unidad = GeneratedColumn<String>(
    'unidad',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 30,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _costoActualMeta = const VerificationMeta(
    'costoActual',
  );
  @override
  late final GeneratedColumn<double> costoActual = GeneratedColumn<double>(
    'costo_actual',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _precioSugeridoMeta = const VerificationMeta(
    'precioSugerido',
  );
  @override
  late final GeneratedColumn<double> precioSugerido = GeneratedColumn<double>(
    'precio_sugerido',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _stockMinimoMeta = const VerificationMeta(
    'stockMinimo',
  );
  @override
  late final GeneratedColumn<double> stockMinimo = GeneratedColumn<double>(
    'stock_minimo',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _proveedorMeta = const VerificationMeta(
    'proveedor',
  );
  @override
  late final GeneratedColumn<String> proveedor = GeneratedColumn<String>(
    'proveedor',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imagenMeta = const VerificationMeta('imagen');
  @override
  late final GeneratedColumn<String> imagen = GeneratedColumn<String>(
    'imagen',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activoMeta = const VerificationMeta('activo');
  @override
  late final GeneratedColumn<bool> activo = GeneratedColumn<bool>(
    'activo',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("activo" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _creadoEnMeta = const VerificationMeta(
    'creadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> creadoEn = GeneratedColumn<DateTime>(
    'creado_en',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nombre,
    unidad,
    costoActual,
    precioSugerido,
    stockMinimo,
    proveedor,
    imagen,
    activo,
    creadoEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tabla_productos';
  @override
  VerificationContext validateIntegrity(
    Insertable<TablaProducto> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('unidad')) {
      context.handle(
        _unidadMeta,
        unidad.isAcceptableOrUnknown(data['unidad']!, _unidadMeta),
      );
    } else if (isInserting) {
      context.missing(_unidadMeta);
    }
    if (data.containsKey('costo_actual')) {
      context.handle(
        _costoActualMeta,
        costoActual.isAcceptableOrUnknown(
          data['costo_actual']!,
          _costoActualMeta,
        ),
      );
    }
    if (data.containsKey('precio_sugerido')) {
      context.handle(
        _precioSugeridoMeta,
        precioSugerido.isAcceptableOrUnknown(
          data['precio_sugerido']!,
          _precioSugeridoMeta,
        ),
      );
    }
    if (data.containsKey('stock_minimo')) {
      context.handle(
        _stockMinimoMeta,
        stockMinimo.isAcceptableOrUnknown(
          data['stock_minimo']!,
          _stockMinimoMeta,
        ),
      );
    }
    if (data.containsKey('proveedor')) {
      context.handle(
        _proveedorMeta,
        proveedor.isAcceptableOrUnknown(data['proveedor']!, _proveedorMeta),
      );
    }
    if (data.containsKey('imagen')) {
      context.handle(
        _imagenMeta,
        imagen.isAcceptableOrUnknown(data['imagen']!, _imagenMeta),
      );
    }
    if (data.containsKey('activo')) {
      context.handle(
        _activoMeta,
        activo.isAcceptableOrUnknown(data['activo']!, _activoMeta),
      );
    }
    if (data.containsKey('creado_en')) {
      context.handle(
        _creadoEnMeta,
        creadoEn.isAcceptableOrUnknown(data['creado_en']!, _creadoEnMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TablaProducto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TablaProducto(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      unidad: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unidad'],
      )!,
      costoActual: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}costo_actual'],
      )!,
      precioSugerido: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}precio_sugerido'],
      )!,
      stockMinimo: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stock_minimo'],
      )!,
      proveedor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}proveedor'],
      ),
      imagen: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}imagen'],
      ),
      activo: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}activo'],
      )!,
      creadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}creado_en'],
      )!,
    );
  }

  @override
  $TablaProductosTable createAlias(String alias) {
    return $TablaProductosTable(attachedDatabase, alias);
  }
}

class TablaProducto extends DataClass implements Insertable<TablaProducto> {
  final int id;
  final String nombre;
  final String unidad;
  final double costoActual;
  final double precioSugerido;
  final double stockMinimo;
  final String? proveedor;
  final String? imagen;
  final bool activo;
  final DateTime creadoEn;
  const TablaProducto({
    required this.id,
    required this.nombre,
    required this.unidad,
    required this.costoActual,
    required this.precioSugerido,
    required this.stockMinimo,
    this.proveedor,
    this.imagen,
    required this.activo,
    required this.creadoEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nombre'] = Variable<String>(nombre);
    map['unidad'] = Variable<String>(unidad);
    map['costo_actual'] = Variable<double>(costoActual);
    map['precio_sugerido'] = Variable<double>(precioSugerido);
    map['stock_minimo'] = Variable<double>(stockMinimo);
    if (!nullToAbsent || proveedor != null) {
      map['proveedor'] = Variable<String>(proveedor);
    }
    if (!nullToAbsent || imagen != null) {
      map['imagen'] = Variable<String>(imagen);
    }
    map['activo'] = Variable<bool>(activo);
    map['creado_en'] = Variable<DateTime>(creadoEn);
    return map;
  }

  TablaProductosCompanion toCompanion(bool nullToAbsent) {
    return TablaProductosCompanion(
      id: Value(id),
      nombre: Value(nombre),
      unidad: Value(unidad),
      costoActual: Value(costoActual),
      precioSugerido: Value(precioSugerido),
      stockMinimo: Value(stockMinimo),
      proveedor: proveedor == null && nullToAbsent
          ? const Value.absent()
          : Value(proveedor),
      imagen: imagen == null && nullToAbsent
          ? const Value.absent()
          : Value(imagen),
      activo: Value(activo),
      creadoEn: Value(creadoEn),
    );
  }

  factory TablaProducto.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TablaProducto(
      id: serializer.fromJson<int>(json['id']),
      nombre: serializer.fromJson<String>(json['nombre']),
      unidad: serializer.fromJson<String>(json['unidad']),
      costoActual: serializer.fromJson<double>(json['costoActual']),
      precioSugerido: serializer.fromJson<double>(json['precioSugerido']),
      stockMinimo: serializer.fromJson<double>(json['stockMinimo']),
      proveedor: serializer.fromJson<String?>(json['proveedor']),
      imagen: serializer.fromJson<String?>(json['imagen']),
      activo: serializer.fromJson<bool>(json['activo']),
      creadoEn: serializer.fromJson<DateTime>(json['creadoEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nombre': serializer.toJson<String>(nombre),
      'unidad': serializer.toJson<String>(unidad),
      'costoActual': serializer.toJson<double>(costoActual),
      'precioSugerido': serializer.toJson<double>(precioSugerido),
      'stockMinimo': serializer.toJson<double>(stockMinimo),
      'proveedor': serializer.toJson<String?>(proveedor),
      'imagen': serializer.toJson<String?>(imagen),
      'activo': serializer.toJson<bool>(activo),
      'creadoEn': serializer.toJson<DateTime>(creadoEn),
    };
  }

  TablaProducto copyWith({
    int? id,
    String? nombre,
    String? unidad,
    double? costoActual,
    double? precioSugerido,
    double? stockMinimo,
    Value<String?> proveedor = const Value.absent(),
    Value<String?> imagen = const Value.absent(),
    bool? activo,
    DateTime? creadoEn,
  }) => TablaProducto(
    id: id ?? this.id,
    nombre: nombre ?? this.nombre,
    unidad: unidad ?? this.unidad,
    costoActual: costoActual ?? this.costoActual,
    precioSugerido: precioSugerido ?? this.precioSugerido,
    stockMinimo: stockMinimo ?? this.stockMinimo,
    proveedor: proveedor.present ? proveedor.value : this.proveedor,
    imagen: imagen.present ? imagen.value : this.imagen,
    activo: activo ?? this.activo,
    creadoEn: creadoEn ?? this.creadoEn,
  );
  TablaProducto copyWithCompanion(TablaProductosCompanion data) {
    return TablaProducto(
      id: data.id.present ? data.id.value : this.id,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      unidad: data.unidad.present ? data.unidad.value : this.unidad,
      costoActual: data.costoActual.present
          ? data.costoActual.value
          : this.costoActual,
      precioSugerido: data.precioSugerido.present
          ? data.precioSugerido.value
          : this.precioSugerido,
      stockMinimo: data.stockMinimo.present
          ? data.stockMinimo.value
          : this.stockMinimo,
      proveedor: data.proveedor.present ? data.proveedor.value : this.proveedor,
      imagen: data.imagen.present ? data.imagen.value : this.imagen,
      activo: data.activo.present ? data.activo.value : this.activo,
      creadoEn: data.creadoEn.present ? data.creadoEn.value : this.creadoEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TablaProducto(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('unidad: $unidad, ')
          ..write('costoActual: $costoActual, ')
          ..write('precioSugerido: $precioSugerido, ')
          ..write('stockMinimo: $stockMinimo, ')
          ..write('proveedor: $proveedor, ')
          ..write('imagen: $imagen, ')
          ..write('activo: $activo, ')
          ..write('creadoEn: $creadoEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nombre,
    unidad,
    costoActual,
    precioSugerido,
    stockMinimo,
    proveedor,
    imagen,
    activo,
    creadoEn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TablaProducto &&
          other.id == this.id &&
          other.nombre == this.nombre &&
          other.unidad == this.unidad &&
          other.costoActual == this.costoActual &&
          other.precioSugerido == this.precioSugerido &&
          other.stockMinimo == this.stockMinimo &&
          other.proveedor == this.proveedor &&
          other.imagen == this.imagen &&
          other.activo == this.activo &&
          other.creadoEn == this.creadoEn);
}

class TablaProductosCompanion extends UpdateCompanion<TablaProducto> {
  final Value<int> id;
  final Value<String> nombre;
  final Value<String> unidad;
  final Value<double> costoActual;
  final Value<double> precioSugerido;
  final Value<double> stockMinimo;
  final Value<String?> proveedor;
  final Value<String?> imagen;
  final Value<bool> activo;
  final Value<DateTime> creadoEn;
  const TablaProductosCompanion({
    this.id = const Value.absent(),
    this.nombre = const Value.absent(),
    this.unidad = const Value.absent(),
    this.costoActual = const Value.absent(),
    this.precioSugerido = const Value.absent(),
    this.stockMinimo = const Value.absent(),
    this.proveedor = const Value.absent(),
    this.imagen = const Value.absent(),
    this.activo = const Value.absent(),
    this.creadoEn = const Value.absent(),
  });
  TablaProductosCompanion.insert({
    this.id = const Value.absent(),
    required String nombre,
    required String unidad,
    this.costoActual = const Value.absent(),
    this.precioSugerido = const Value.absent(),
    this.stockMinimo = const Value.absent(),
    this.proveedor = const Value.absent(),
    this.imagen = const Value.absent(),
    this.activo = const Value.absent(),
    this.creadoEn = const Value.absent(),
  }) : nombre = Value(nombre),
       unidad = Value(unidad);
  static Insertable<TablaProducto> custom({
    Expression<int>? id,
    Expression<String>? nombre,
    Expression<String>? unidad,
    Expression<double>? costoActual,
    Expression<double>? precioSugerido,
    Expression<double>? stockMinimo,
    Expression<String>? proveedor,
    Expression<String>? imagen,
    Expression<bool>? activo,
    Expression<DateTime>? creadoEn,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombre != null) 'nombre': nombre,
      if (unidad != null) 'unidad': unidad,
      if (costoActual != null) 'costo_actual': costoActual,
      if (precioSugerido != null) 'precio_sugerido': precioSugerido,
      if (stockMinimo != null) 'stock_minimo': stockMinimo,
      if (proveedor != null) 'proveedor': proveedor,
      if (imagen != null) 'imagen': imagen,
      if (activo != null) 'activo': activo,
      if (creadoEn != null) 'creado_en': creadoEn,
    });
  }

  TablaProductosCompanion copyWith({
    Value<int>? id,
    Value<String>? nombre,
    Value<String>? unidad,
    Value<double>? costoActual,
    Value<double>? precioSugerido,
    Value<double>? stockMinimo,
    Value<String?>? proveedor,
    Value<String?>? imagen,
    Value<bool>? activo,
    Value<DateTime>? creadoEn,
  }) {
    return TablaProductosCompanion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      unidad: unidad ?? this.unidad,
      costoActual: costoActual ?? this.costoActual,
      precioSugerido: precioSugerido ?? this.precioSugerido,
      stockMinimo: stockMinimo ?? this.stockMinimo,
      proveedor: proveedor ?? this.proveedor,
      imagen: imagen ?? this.imagen,
      activo: activo ?? this.activo,
      creadoEn: creadoEn ?? this.creadoEn,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (unidad.present) {
      map['unidad'] = Variable<String>(unidad.value);
    }
    if (costoActual.present) {
      map['costo_actual'] = Variable<double>(costoActual.value);
    }
    if (precioSugerido.present) {
      map['precio_sugerido'] = Variable<double>(precioSugerido.value);
    }
    if (stockMinimo.present) {
      map['stock_minimo'] = Variable<double>(stockMinimo.value);
    }
    if (proveedor.present) {
      map['proveedor'] = Variable<String>(proveedor.value);
    }
    if (imagen.present) {
      map['imagen'] = Variable<String>(imagen.value);
    }
    if (activo.present) {
      map['activo'] = Variable<bool>(activo.value);
    }
    if (creadoEn.present) {
      map['creado_en'] = Variable<DateTime>(creadoEn.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TablaProductosCompanion(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('unidad: $unidad, ')
          ..write('costoActual: $costoActual, ')
          ..write('precioSugerido: $precioSugerido, ')
          ..write('stockMinimo: $stockMinimo, ')
          ..write('proveedor: $proveedor, ')
          ..write('imagen: $imagen, ')
          ..write('activo: $activo, ')
          ..write('creadoEn: $creadoEn')
          ..write(')'))
        .toString();
  }
}

class $TablaMovimientosTable extends TablaMovimientos
    with TableInfo<$TablaMovimientosTable, TablaMovimiento> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TablaMovimientosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _productoIdMeta = const VerificationMeta(
    'productoId',
  );
  @override
  late final GeneratedColumn<int> productoId = GeneratedColumn<int>(
    'producto_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tabla_productos (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
    'tipo',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 20,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cantidadMeta = const VerificationMeta(
    'cantidad',
  );
  @override
  late final GeneratedColumn<double> cantidad = GeneratedColumn<double>(
    'cantidad',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<DateTime> fecha = GeneratedColumn<DateTime>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _notaMeta = const VerificationMeta('nota');
  @override
  late final GeneratedColumn<String> nota = GeneratedColumn<String>(
    'nota',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _referenciaMeta = const VerificationMeta(
    'referencia',
  );
  @override
  late final GeneratedColumn<String> referencia = GeneratedColumn<String>(
    'referencia',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 40,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    productoId,
    tipo,
    cantidad,
    fecha,
    nota,
    referencia,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tabla_movimientos';
  @override
  VerificationContext validateIntegrity(
    Insertable<TablaMovimiento> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('producto_id')) {
      context.handle(
        _productoIdMeta,
        productoId.isAcceptableOrUnknown(data['producto_id']!, _productoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productoIdMeta);
    }
    if (data.containsKey('tipo')) {
      context.handle(
        _tipoMeta,
        tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta),
      );
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('cantidad')) {
      context.handle(
        _cantidadMeta,
        cantidad.isAcceptableOrUnknown(data['cantidad']!, _cantidadMeta),
      );
    } else if (isInserting) {
      context.missing(_cantidadMeta);
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    }
    if (data.containsKey('nota')) {
      context.handle(
        _notaMeta,
        nota.isAcceptableOrUnknown(data['nota']!, _notaMeta),
      );
    }
    if (data.containsKey('referencia')) {
      context.handle(
        _referenciaMeta,
        referencia.isAcceptableOrUnknown(data['referencia']!, _referenciaMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TablaMovimiento map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TablaMovimiento(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      productoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}producto_id'],
      )!,
      tipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo'],
      )!,
      cantidad: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cantidad'],
      )!,
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha'],
      )!,
      nota: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nota'],
      ),
      referencia: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}referencia'],
      ),
    );
  }

  @override
  $TablaMovimientosTable createAlias(String alias) {
    return $TablaMovimientosTable(attachedDatabase, alias);
  }
}

class TablaMovimiento extends DataClass implements Insertable<TablaMovimiento> {
  final int id;
  final int productoId;
  final String tipo;
  final double cantidad;
  final DateTime fecha;
  final String? nota;
  final String? referencia;
  const TablaMovimiento({
    required this.id,
    required this.productoId,
    required this.tipo,
    required this.cantidad,
    required this.fecha,
    this.nota,
    this.referencia,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['producto_id'] = Variable<int>(productoId);
    map['tipo'] = Variable<String>(tipo);
    map['cantidad'] = Variable<double>(cantidad);
    map['fecha'] = Variable<DateTime>(fecha);
    if (!nullToAbsent || nota != null) {
      map['nota'] = Variable<String>(nota);
    }
    if (!nullToAbsent || referencia != null) {
      map['referencia'] = Variable<String>(referencia);
    }
    return map;
  }

  TablaMovimientosCompanion toCompanion(bool nullToAbsent) {
    return TablaMovimientosCompanion(
      id: Value(id),
      productoId: Value(productoId),
      tipo: Value(tipo),
      cantidad: Value(cantidad),
      fecha: Value(fecha),
      nota: nota == null && nullToAbsent ? const Value.absent() : Value(nota),
      referencia: referencia == null && nullToAbsent
          ? const Value.absent()
          : Value(referencia),
    );
  }

  factory TablaMovimiento.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TablaMovimiento(
      id: serializer.fromJson<int>(json['id']),
      productoId: serializer.fromJson<int>(json['productoId']),
      tipo: serializer.fromJson<String>(json['tipo']),
      cantidad: serializer.fromJson<double>(json['cantidad']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
      nota: serializer.fromJson<String?>(json['nota']),
      referencia: serializer.fromJson<String?>(json['referencia']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'productoId': serializer.toJson<int>(productoId),
      'tipo': serializer.toJson<String>(tipo),
      'cantidad': serializer.toJson<double>(cantidad),
      'fecha': serializer.toJson<DateTime>(fecha),
      'nota': serializer.toJson<String?>(nota),
      'referencia': serializer.toJson<String?>(referencia),
    };
  }

  TablaMovimiento copyWith({
    int? id,
    int? productoId,
    String? tipo,
    double? cantidad,
    DateTime? fecha,
    Value<String?> nota = const Value.absent(),
    Value<String?> referencia = const Value.absent(),
  }) => TablaMovimiento(
    id: id ?? this.id,
    productoId: productoId ?? this.productoId,
    tipo: tipo ?? this.tipo,
    cantidad: cantidad ?? this.cantidad,
    fecha: fecha ?? this.fecha,
    nota: nota.present ? nota.value : this.nota,
    referencia: referencia.present ? referencia.value : this.referencia,
  );
  TablaMovimiento copyWithCompanion(TablaMovimientosCompanion data) {
    return TablaMovimiento(
      id: data.id.present ? data.id.value : this.id,
      productoId: data.productoId.present
          ? data.productoId.value
          : this.productoId,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      cantidad: data.cantidad.present ? data.cantidad.value : this.cantidad,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      nota: data.nota.present ? data.nota.value : this.nota,
      referencia: data.referencia.present
          ? data.referencia.value
          : this.referencia,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TablaMovimiento(')
          ..write('id: $id, ')
          ..write('productoId: $productoId, ')
          ..write('tipo: $tipo, ')
          ..write('cantidad: $cantidad, ')
          ..write('fecha: $fecha, ')
          ..write('nota: $nota, ')
          ..write('referencia: $referencia')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, productoId, tipo, cantidad, fecha, nota, referencia);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TablaMovimiento &&
          other.id == this.id &&
          other.productoId == this.productoId &&
          other.tipo == this.tipo &&
          other.cantidad == this.cantidad &&
          other.fecha == this.fecha &&
          other.nota == this.nota &&
          other.referencia == this.referencia);
}

class TablaMovimientosCompanion extends UpdateCompanion<TablaMovimiento> {
  final Value<int> id;
  final Value<int> productoId;
  final Value<String> tipo;
  final Value<double> cantidad;
  final Value<DateTime> fecha;
  final Value<String?> nota;
  final Value<String?> referencia;
  const TablaMovimientosCompanion({
    this.id = const Value.absent(),
    this.productoId = const Value.absent(),
    this.tipo = const Value.absent(),
    this.cantidad = const Value.absent(),
    this.fecha = const Value.absent(),
    this.nota = const Value.absent(),
    this.referencia = const Value.absent(),
  });
  TablaMovimientosCompanion.insert({
    this.id = const Value.absent(),
    required int productoId,
    required String tipo,
    required double cantidad,
    this.fecha = const Value.absent(),
    this.nota = const Value.absent(),
    this.referencia = const Value.absent(),
  }) : productoId = Value(productoId),
       tipo = Value(tipo),
       cantidad = Value(cantidad);
  static Insertable<TablaMovimiento> custom({
    Expression<int>? id,
    Expression<int>? productoId,
    Expression<String>? tipo,
    Expression<double>? cantidad,
    Expression<DateTime>? fecha,
    Expression<String>? nota,
    Expression<String>? referencia,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productoId != null) 'producto_id': productoId,
      if (tipo != null) 'tipo': tipo,
      if (cantidad != null) 'cantidad': cantidad,
      if (fecha != null) 'fecha': fecha,
      if (nota != null) 'nota': nota,
      if (referencia != null) 'referencia': referencia,
    });
  }

  TablaMovimientosCompanion copyWith({
    Value<int>? id,
    Value<int>? productoId,
    Value<String>? tipo,
    Value<double>? cantidad,
    Value<DateTime>? fecha,
    Value<String?>? nota,
    Value<String?>? referencia,
  }) {
    return TablaMovimientosCompanion(
      id: id ?? this.id,
      productoId: productoId ?? this.productoId,
      tipo: tipo ?? this.tipo,
      cantidad: cantidad ?? this.cantidad,
      fecha: fecha ?? this.fecha,
      nota: nota ?? this.nota,
      referencia: referencia ?? this.referencia,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (productoId.present) {
      map['producto_id'] = Variable<int>(productoId.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (cantidad.present) {
      map['cantidad'] = Variable<double>(cantidad.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (nota.present) {
      map['nota'] = Variable<String>(nota.value);
    }
    if (referencia.present) {
      map['referencia'] = Variable<String>(referencia.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TablaMovimientosCompanion(')
          ..write('id: $id, ')
          ..write('productoId: $productoId, ')
          ..write('tipo: $tipo, ')
          ..write('cantidad: $cantidad, ')
          ..write('fecha: $fecha, ')
          ..write('nota: $nota, ')
          ..write('referencia: $referencia')
          ..write(')'))
        .toString();
  }
}

class $TablaCombosTable extends TablaCombos
    with TableInfo<$TablaCombosTable, TablaCombo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TablaCombosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _precioVentaMeta = const VerificationMeta(
    'precioVenta',
  );
  @override
  late final GeneratedColumn<double> precioVenta = GeneratedColumn<double>(
    'precio_venta',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _activoMeta = const VerificationMeta('activo');
  @override
  late final GeneratedColumn<bool> activo = GeneratedColumn<bool>(
    'activo',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("activo" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _creadoEnMeta = const VerificationMeta(
    'creadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> creadoEn = GeneratedColumn<DateTime>(
    'creado_en',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nombre,
    precioVenta,
    activo,
    creadoEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tabla_combos';
  @override
  VerificationContext validateIntegrity(
    Insertable<TablaCombo> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('precio_venta')) {
      context.handle(
        _precioVentaMeta,
        precioVenta.isAcceptableOrUnknown(
          data['precio_venta']!,
          _precioVentaMeta,
        ),
      );
    }
    if (data.containsKey('activo')) {
      context.handle(
        _activoMeta,
        activo.isAcceptableOrUnknown(data['activo']!, _activoMeta),
      );
    }
    if (data.containsKey('creado_en')) {
      context.handle(
        _creadoEnMeta,
        creadoEn.isAcceptableOrUnknown(data['creado_en']!, _creadoEnMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TablaCombo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TablaCombo(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      precioVenta: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}precio_venta'],
      )!,
      activo: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}activo'],
      )!,
      creadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}creado_en'],
      )!,
    );
  }

  @override
  $TablaCombosTable createAlias(String alias) {
    return $TablaCombosTable(attachedDatabase, alias);
  }
}

class TablaCombo extends DataClass implements Insertable<TablaCombo> {
  final int id;
  final String nombre;
  final double precioVenta;
  final bool activo;
  final DateTime creadoEn;
  const TablaCombo({
    required this.id,
    required this.nombre,
    required this.precioVenta,
    required this.activo,
    required this.creadoEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nombre'] = Variable<String>(nombre);
    map['precio_venta'] = Variable<double>(precioVenta);
    map['activo'] = Variable<bool>(activo);
    map['creado_en'] = Variable<DateTime>(creadoEn);
    return map;
  }

  TablaCombosCompanion toCompanion(bool nullToAbsent) {
    return TablaCombosCompanion(
      id: Value(id),
      nombre: Value(nombre),
      precioVenta: Value(precioVenta),
      activo: Value(activo),
      creadoEn: Value(creadoEn),
    );
  }

  factory TablaCombo.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TablaCombo(
      id: serializer.fromJson<int>(json['id']),
      nombre: serializer.fromJson<String>(json['nombre']),
      precioVenta: serializer.fromJson<double>(json['precioVenta']),
      activo: serializer.fromJson<bool>(json['activo']),
      creadoEn: serializer.fromJson<DateTime>(json['creadoEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nombre': serializer.toJson<String>(nombre),
      'precioVenta': serializer.toJson<double>(precioVenta),
      'activo': serializer.toJson<bool>(activo),
      'creadoEn': serializer.toJson<DateTime>(creadoEn),
    };
  }

  TablaCombo copyWith({
    int? id,
    String? nombre,
    double? precioVenta,
    bool? activo,
    DateTime? creadoEn,
  }) => TablaCombo(
    id: id ?? this.id,
    nombre: nombre ?? this.nombre,
    precioVenta: precioVenta ?? this.precioVenta,
    activo: activo ?? this.activo,
    creadoEn: creadoEn ?? this.creadoEn,
  );
  TablaCombo copyWithCompanion(TablaCombosCompanion data) {
    return TablaCombo(
      id: data.id.present ? data.id.value : this.id,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      precioVenta: data.precioVenta.present
          ? data.precioVenta.value
          : this.precioVenta,
      activo: data.activo.present ? data.activo.value : this.activo,
      creadoEn: data.creadoEn.present ? data.creadoEn.value : this.creadoEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TablaCombo(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('precioVenta: $precioVenta, ')
          ..write('activo: $activo, ')
          ..write('creadoEn: $creadoEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nombre, precioVenta, activo, creadoEn);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TablaCombo &&
          other.id == this.id &&
          other.nombre == this.nombre &&
          other.precioVenta == this.precioVenta &&
          other.activo == this.activo &&
          other.creadoEn == this.creadoEn);
}

class TablaCombosCompanion extends UpdateCompanion<TablaCombo> {
  final Value<int> id;
  final Value<String> nombre;
  final Value<double> precioVenta;
  final Value<bool> activo;
  final Value<DateTime> creadoEn;
  const TablaCombosCompanion({
    this.id = const Value.absent(),
    this.nombre = const Value.absent(),
    this.precioVenta = const Value.absent(),
    this.activo = const Value.absent(),
    this.creadoEn = const Value.absent(),
  });
  TablaCombosCompanion.insert({
    this.id = const Value.absent(),
    required String nombre,
    this.precioVenta = const Value.absent(),
    this.activo = const Value.absent(),
    this.creadoEn = const Value.absent(),
  }) : nombre = Value(nombre);
  static Insertable<TablaCombo> custom({
    Expression<int>? id,
    Expression<String>? nombre,
    Expression<double>? precioVenta,
    Expression<bool>? activo,
    Expression<DateTime>? creadoEn,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombre != null) 'nombre': nombre,
      if (precioVenta != null) 'precio_venta': precioVenta,
      if (activo != null) 'activo': activo,
      if (creadoEn != null) 'creado_en': creadoEn,
    });
  }

  TablaCombosCompanion copyWith({
    Value<int>? id,
    Value<String>? nombre,
    Value<double>? precioVenta,
    Value<bool>? activo,
    Value<DateTime>? creadoEn,
  }) {
    return TablaCombosCompanion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      precioVenta: precioVenta ?? this.precioVenta,
      activo: activo ?? this.activo,
      creadoEn: creadoEn ?? this.creadoEn,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (precioVenta.present) {
      map['precio_venta'] = Variable<double>(precioVenta.value);
    }
    if (activo.present) {
      map['activo'] = Variable<bool>(activo.value);
    }
    if (creadoEn.present) {
      map['creado_en'] = Variable<DateTime>(creadoEn.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TablaCombosCompanion(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('precioVenta: $precioVenta, ')
          ..write('activo: $activo, ')
          ..write('creadoEn: $creadoEn')
          ..write(')'))
        .toString();
  }
}

class $TablaComponentesTable extends TablaComponentes
    with TableInfo<$TablaComponentesTable, TablaComponente> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TablaComponentesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _comboIdMeta = const VerificationMeta(
    'comboId',
  );
  @override
  late final GeneratedColumn<int> comboId = GeneratedColumn<int>(
    'combo_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tabla_combos (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _productoIdMeta = const VerificationMeta(
    'productoId',
  );
  @override
  late final GeneratedColumn<int> productoId = GeneratedColumn<int>(
    'producto_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tabla_productos (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _cantidadMeta = const VerificationMeta(
    'cantidad',
  );
  @override
  late final GeneratedColumn<double> cantidad = GeneratedColumn<double>(
    'cantidad',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, comboId, productoId, cantidad];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tabla_componentes';
  @override
  VerificationContext validateIntegrity(
    Insertable<TablaComponente> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('combo_id')) {
      context.handle(
        _comboIdMeta,
        comboId.isAcceptableOrUnknown(data['combo_id']!, _comboIdMeta),
      );
    } else if (isInserting) {
      context.missing(_comboIdMeta);
    }
    if (data.containsKey('producto_id')) {
      context.handle(
        _productoIdMeta,
        productoId.isAcceptableOrUnknown(data['producto_id']!, _productoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productoIdMeta);
    }
    if (data.containsKey('cantidad')) {
      context.handle(
        _cantidadMeta,
        cantidad.isAcceptableOrUnknown(data['cantidad']!, _cantidadMeta),
      );
    } else if (isInserting) {
      context.missing(_cantidadMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TablaComponente map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TablaComponente(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      comboId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}combo_id'],
      )!,
      productoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}producto_id'],
      )!,
      cantidad: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cantidad'],
      )!,
    );
  }

  @override
  $TablaComponentesTable createAlias(String alias) {
    return $TablaComponentesTable(attachedDatabase, alias);
  }
}

class TablaComponente extends DataClass implements Insertable<TablaComponente> {
  final int id;
  final int comboId;
  final int productoId;
  final double cantidad;
  const TablaComponente({
    required this.id,
    required this.comboId,
    required this.productoId,
    required this.cantidad,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['combo_id'] = Variable<int>(comboId);
    map['producto_id'] = Variable<int>(productoId);
    map['cantidad'] = Variable<double>(cantidad);
    return map;
  }

  TablaComponentesCompanion toCompanion(bool nullToAbsent) {
    return TablaComponentesCompanion(
      id: Value(id),
      comboId: Value(comboId),
      productoId: Value(productoId),
      cantidad: Value(cantidad),
    );
  }

  factory TablaComponente.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TablaComponente(
      id: serializer.fromJson<int>(json['id']),
      comboId: serializer.fromJson<int>(json['comboId']),
      productoId: serializer.fromJson<int>(json['productoId']),
      cantidad: serializer.fromJson<double>(json['cantidad']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'comboId': serializer.toJson<int>(comboId),
      'productoId': serializer.toJson<int>(productoId),
      'cantidad': serializer.toJson<double>(cantidad),
    };
  }

  TablaComponente copyWith({
    int? id,
    int? comboId,
    int? productoId,
    double? cantidad,
  }) => TablaComponente(
    id: id ?? this.id,
    comboId: comboId ?? this.comboId,
    productoId: productoId ?? this.productoId,
    cantidad: cantidad ?? this.cantidad,
  );
  TablaComponente copyWithCompanion(TablaComponentesCompanion data) {
    return TablaComponente(
      id: data.id.present ? data.id.value : this.id,
      comboId: data.comboId.present ? data.comboId.value : this.comboId,
      productoId: data.productoId.present
          ? data.productoId.value
          : this.productoId,
      cantidad: data.cantidad.present ? data.cantidad.value : this.cantidad,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TablaComponente(')
          ..write('id: $id, ')
          ..write('comboId: $comboId, ')
          ..write('productoId: $productoId, ')
          ..write('cantidad: $cantidad')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, comboId, productoId, cantidad);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TablaComponente &&
          other.id == this.id &&
          other.comboId == this.comboId &&
          other.productoId == this.productoId &&
          other.cantidad == this.cantidad);
}

class TablaComponentesCompanion extends UpdateCompanion<TablaComponente> {
  final Value<int> id;
  final Value<int> comboId;
  final Value<int> productoId;
  final Value<double> cantidad;
  const TablaComponentesCompanion({
    this.id = const Value.absent(),
    this.comboId = const Value.absent(),
    this.productoId = const Value.absent(),
    this.cantidad = const Value.absent(),
  });
  TablaComponentesCompanion.insert({
    this.id = const Value.absent(),
    required int comboId,
    required int productoId,
    required double cantidad,
  }) : comboId = Value(comboId),
       productoId = Value(productoId),
       cantidad = Value(cantidad);
  static Insertable<TablaComponente> custom({
    Expression<int>? id,
    Expression<int>? comboId,
    Expression<int>? productoId,
    Expression<double>? cantidad,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (comboId != null) 'combo_id': comboId,
      if (productoId != null) 'producto_id': productoId,
      if (cantidad != null) 'cantidad': cantidad,
    });
  }

  TablaComponentesCompanion copyWith({
    Value<int>? id,
    Value<int>? comboId,
    Value<int>? productoId,
    Value<double>? cantidad,
  }) {
    return TablaComponentesCompanion(
      id: id ?? this.id,
      comboId: comboId ?? this.comboId,
      productoId: productoId ?? this.productoId,
      cantidad: cantidad ?? this.cantidad,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (comboId.present) {
      map['combo_id'] = Variable<int>(comboId.value);
    }
    if (productoId.present) {
      map['producto_id'] = Variable<int>(productoId.value);
    }
    if (cantidad.present) {
      map['cantidad'] = Variable<double>(cantidad.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TablaComponentesCompanion(')
          ..write('id: $id, ')
          ..write('comboId: $comboId, ')
          ..write('productoId: $productoId, ')
          ..write('cantidad: $cantidad')
          ..write(')'))
        .toString();
  }
}

class $TablaVentasTable extends TablaVentas
    with TableInfo<$TablaVentasTable, TablaVenta> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TablaVentasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<DateTime> fecha = GeneratedColumn<DateTime>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<double> total = GeneratedColumn<double>(
    'total',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _notaMeta = const VerificationMeta('nota');
  @override
  late final GeneratedColumn<String> nota = GeneratedColumn<String>(
    'nota',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, fecha, total, nota];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tabla_ventas';
  @override
  VerificationContext validateIntegrity(
    Insertable<TablaVenta> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    }
    if (data.containsKey('total')) {
      context.handle(
        _totalMeta,
        total.isAcceptableOrUnknown(data['total']!, _totalMeta),
      );
    }
    if (data.containsKey('nota')) {
      context.handle(
        _notaMeta,
        nota.isAcceptableOrUnknown(data['nota']!, _notaMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TablaVenta map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TablaVenta(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha'],
      )!,
      total: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total'],
      )!,
      nota: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nota'],
      ),
    );
  }

  @override
  $TablaVentasTable createAlias(String alias) {
    return $TablaVentasTable(attachedDatabase, alias);
  }
}

class TablaVenta extends DataClass implements Insertable<TablaVenta> {
  final int id;
  final DateTime fecha;
  final double total;
  final String? nota;
  const TablaVenta({
    required this.id,
    required this.fecha,
    required this.total,
    this.nota,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['fecha'] = Variable<DateTime>(fecha);
    map['total'] = Variable<double>(total);
    if (!nullToAbsent || nota != null) {
      map['nota'] = Variable<String>(nota);
    }
    return map;
  }

  TablaVentasCompanion toCompanion(bool nullToAbsent) {
    return TablaVentasCompanion(
      id: Value(id),
      fecha: Value(fecha),
      total: Value(total),
      nota: nota == null && nullToAbsent ? const Value.absent() : Value(nota),
    );
  }

  factory TablaVenta.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TablaVenta(
      id: serializer.fromJson<int>(json['id']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
      total: serializer.fromJson<double>(json['total']),
      nota: serializer.fromJson<String?>(json['nota']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'fecha': serializer.toJson<DateTime>(fecha),
      'total': serializer.toJson<double>(total),
      'nota': serializer.toJson<String?>(nota),
    };
  }

  TablaVenta copyWith({
    int? id,
    DateTime? fecha,
    double? total,
    Value<String?> nota = const Value.absent(),
  }) => TablaVenta(
    id: id ?? this.id,
    fecha: fecha ?? this.fecha,
    total: total ?? this.total,
    nota: nota.present ? nota.value : this.nota,
  );
  TablaVenta copyWithCompanion(TablaVentasCompanion data) {
    return TablaVenta(
      id: data.id.present ? data.id.value : this.id,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      total: data.total.present ? data.total.value : this.total,
      nota: data.nota.present ? data.nota.value : this.nota,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TablaVenta(')
          ..write('id: $id, ')
          ..write('fecha: $fecha, ')
          ..write('total: $total, ')
          ..write('nota: $nota')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, fecha, total, nota);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TablaVenta &&
          other.id == this.id &&
          other.fecha == this.fecha &&
          other.total == this.total &&
          other.nota == this.nota);
}

class TablaVentasCompanion extends UpdateCompanion<TablaVenta> {
  final Value<int> id;
  final Value<DateTime> fecha;
  final Value<double> total;
  final Value<String?> nota;
  const TablaVentasCompanion({
    this.id = const Value.absent(),
    this.fecha = const Value.absent(),
    this.total = const Value.absent(),
    this.nota = const Value.absent(),
  });
  TablaVentasCompanion.insert({
    this.id = const Value.absent(),
    this.fecha = const Value.absent(),
    this.total = const Value.absent(),
    this.nota = const Value.absent(),
  });
  static Insertable<TablaVenta> custom({
    Expression<int>? id,
    Expression<DateTime>? fecha,
    Expression<double>? total,
    Expression<String>? nota,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fecha != null) 'fecha': fecha,
      if (total != null) 'total': total,
      if (nota != null) 'nota': nota,
    });
  }

  TablaVentasCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? fecha,
    Value<double>? total,
    Value<String?>? nota,
  }) {
    return TablaVentasCompanion(
      id: id ?? this.id,
      fecha: fecha ?? this.fecha,
      total: total ?? this.total,
      nota: nota ?? this.nota,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (total.present) {
      map['total'] = Variable<double>(total.value);
    }
    if (nota.present) {
      map['nota'] = Variable<String>(nota.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TablaVentasCompanion(')
          ..write('id: $id, ')
          ..write('fecha: $fecha, ')
          ..write('total: $total, ')
          ..write('nota: $nota')
          ..write(')'))
        .toString();
  }
}

class $TablaLineasVentaTable extends TablaLineasVenta
    with TableInfo<$TablaLineasVentaTable, TablaLineasVentaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TablaLineasVentaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _ventaIdMeta = const VerificationMeta(
    'ventaId',
  );
  @override
  late final GeneratedColumn<int> ventaId = GeneratedColumn<int>(
    'venta_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tabla_ventas (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _comboIdMeta = const VerificationMeta(
    'comboId',
  );
  @override
  late final GeneratedColumn<int> comboId = GeneratedColumn<int>(
    'combo_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tabla_combos (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _cantidadMeta = const VerificationMeta(
    'cantidad',
  );
  @override
  late final GeneratedColumn<double> cantidad = GeneratedColumn<double>(
    'cantidad',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _precioUnitarioMeta = const VerificationMeta(
    'precioUnitario',
  );
  @override
  late final GeneratedColumn<double> precioUnitario = GeneratedColumn<double>(
    'precio_unitario',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _subtotalMeta = const VerificationMeta(
    'subtotal',
  );
  @override
  late final GeneratedColumn<double> subtotal = GeneratedColumn<double>(
    'subtotal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ventaId,
    comboId,
    cantidad,
    precioUnitario,
    subtotal,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tabla_lineas_venta';
  @override
  VerificationContext validateIntegrity(
    Insertable<TablaLineasVentaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('venta_id')) {
      context.handle(
        _ventaIdMeta,
        ventaId.isAcceptableOrUnknown(data['venta_id']!, _ventaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ventaIdMeta);
    }
    if (data.containsKey('combo_id')) {
      context.handle(
        _comboIdMeta,
        comboId.isAcceptableOrUnknown(data['combo_id']!, _comboIdMeta),
      );
    } else if (isInserting) {
      context.missing(_comboIdMeta);
    }
    if (data.containsKey('cantidad')) {
      context.handle(
        _cantidadMeta,
        cantidad.isAcceptableOrUnknown(data['cantidad']!, _cantidadMeta),
      );
    } else if (isInserting) {
      context.missing(_cantidadMeta);
    }
    if (data.containsKey('precio_unitario')) {
      context.handle(
        _precioUnitarioMeta,
        precioUnitario.isAcceptableOrUnknown(
          data['precio_unitario']!,
          _precioUnitarioMeta,
        ),
      );
    }
    if (data.containsKey('subtotal')) {
      context.handle(
        _subtotalMeta,
        subtotal.isAcceptableOrUnknown(data['subtotal']!, _subtotalMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TablaLineasVentaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TablaLineasVentaData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      ventaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}venta_id'],
      )!,
      comboId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}combo_id'],
      )!,
      cantidad: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cantidad'],
      )!,
      precioUnitario: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}precio_unitario'],
      )!,
      subtotal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}subtotal'],
      )!,
    );
  }

  @override
  $TablaLineasVentaTable createAlias(String alias) {
    return $TablaLineasVentaTable(attachedDatabase, alias);
  }
}

class TablaLineasVentaData extends DataClass
    implements Insertable<TablaLineasVentaData> {
  final int id;
  final int ventaId;
  final int comboId;
  final double cantidad;
  final double precioUnitario;
  final double subtotal;
  const TablaLineasVentaData({
    required this.id,
    required this.ventaId,
    required this.comboId,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['venta_id'] = Variable<int>(ventaId);
    map['combo_id'] = Variable<int>(comboId);
    map['cantidad'] = Variable<double>(cantidad);
    map['precio_unitario'] = Variable<double>(precioUnitario);
    map['subtotal'] = Variable<double>(subtotal);
    return map;
  }

  TablaLineasVentaCompanion toCompanion(bool nullToAbsent) {
    return TablaLineasVentaCompanion(
      id: Value(id),
      ventaId: Value(ventaId),
      comboId: Value(comboId),
      cantidad: Value(cantidad),
      precioUnitario: Value(precioUnitario),
      subtotal: Value(subtotal),
    );
  }

  factory TablaLineasVentaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TablaLineasVentaData(
      id: serializer.fromJson<int>(json['id']),
      ventaId: serializer.fromJson<int>(json['ventaId']),
      comboId: serializer.fromJson<int>(json['comboId']),
      cantidad: serializer.fromJson<double>(json['cantidad']),
      precioUnitario: serializer.fromJson<double>(json['precioUnitario']),
      subtotal: serializer.fromJson<double>(json['subtotal']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ventaId': serializer.toJson<int>(ventaId),
      'comboId': serializer.toJson<int>(comboId),
      'cantidad': serializer.toJson<double>(cantidad),
      'precioUnitario': serializer.toJson<double>(precioUnitario),
      'subtotal': serializer.toJson<double>(subtotal),
    };
  }

  TablaLineasVentaData copyWith({
    int? id,
    int? ventaId,
    int? comboId,
    double? cantidad,
    double? precioUnitario,
    double? subtotal,
  }) => TablaLineasVentaData(
    id: id ?? this.id,
    ventaId: ventaId ?? this.ventaId,
    comboId: comboId ?? this.comboId,
    cantidad: cantidad ?? this.cantidad,
    precioUnitario: precioUnitario ?? this.precioUnitario,
    subtotal: subtotal ?? this.subtotal,
  );
  TablaLineasVentaData copyWithCompanion(TablaLineasVentaCompanion data) {
    return TablaLineasVentaData(
      id: data.id.present ? data.id.value : this.id,
      ventaId: data.ventaId.present ? data.ventaId.value : this.ventaId,
      comboId: data.comboId.present ? data.comboId.value : this.comboId,
      cantidad: data.cantidad.present ? data.cantidad.value : this.cantidad,
      precioUnitario: data.precioUnitario.present
          ? data.precioUnitario.value
          : this.precioUnitario,
      subtotal: data.subtotal.present ? data.subtotal.value : this.subtotal,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TablaLineasVentaData(')
          ..write('id: $id, ')
          ..write('ventaId: $ventaId, ')
          ..write('comboId: $comboId, ')
          ..write('cantidad: $cantidad, ')
          ..write('precioUnitario: $precioUnitario, ')
          ..write('subtotal: $subtotal')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, ventaId, comboId, cantidad, precioUnitario, subtotal);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TablaLineasVentaData &&
          other.id == this.id &&
          other.ventaId == this.ventaId &&
          other.comboId == this.comboId &&
          other.cantidad == this.cantidad &&
          other.precioUnitario == this.precioUnitario &&
          other.subtotal == this.subtotal);
}

class TablaLineasVentaCompanion extends UpdateCompanion<TablaLineasVentaData> {
  final Value<int> id;
  final Value<int> ventaId;
  final Value<int> comboId;
  final Value<double> cantidad;
  final Value<double> precioUnitario;
  final Value<double> subtotal;
  const TablaLineasVentaCompanion({
    this.id = const Value.absent(),
    this.ventaId = const Value.absent(),
    this.comboId = const Value.absent(),
    this.cantidad = const Value.absent(),
    this.precioUnitario = const Value.absent(),
    this.subtotal = const Value.absent(),
  });
  TablaLineasVentaCompanion.insert({
    this.id = const Value.absent(),
    required int ventaId,
    required int comboId,
    required double cantidad,
    this.precioUnitario = const Value.absent(),
    this.subtotal = const Value.absent(),
  }) : ventaId = Value(ventaId),
       comboId = Value(comboId),
       cantidad = Value(cantidad);
  static Insertable<TablaLineasVentaData> custom({
    Expression<int>? id,
    Expression<int>? ventaId,
    Expression<int>? comboId,
    Expression<double>? cantidad,
    Expression<double>? precioUnitario,
    Expression<double>? subtotal,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ventaId != null) 'venta_id': ventaId,
      if (comboId != null) 'combo_id': comboId,
      if (cantidad != null) 'cantidad': cantidad,
      if (precioUnitario != null) 'precio_unitario': precioUnitario,
      if (subtotal != null) 'subtotal': subtotal,
    });
  }

  TablaLineasVentaCompanion copyWith({
    Value<int>? id,
    Value<int>? ventaId,
    Value<int>? comboId,
    Value<double>? cantidad,
    Value<double>? precioUnitario,
    Value<double>? subtotal,
  }) {
    return TablaLineasVentaCompanion(
      id: id ?? this.id,
      ventaId: ventaId ?? this.ventaId,
      comboId: comboId ?? this.comboId,
      cantidad: cantidad ?? this.cantidad,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      subtotal: subtotal ?? this.subtotal,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ventaId.present) {
      map['venta_id'] = Variable<int>(ventaId.value);
    }
    if (comboId.present) {
      map['combo_id'] = Variable<int>(comboId.value);
    }
    if (cantidad.present) {
      map['cantidad'] = Variable<double>(cantidad.value);
    }
    if (precioUnitario.present) {
      map['precio_unitario'] = Variable<double>(precioUnitario.value);
    }
    if (subtotal.present) {
      map['subtotal'] = Variable<double>(subtotal.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TablaLineasVentaCompanion(')
          ..write('id: $id, ')
          ..write('ventaId: $ventaId, ')
          ..write('comboId: $comboId, ')
          ..write('cantidad: $cantidad, ')
          ..write('precioUnitario: $precioUnitario, ')
          ..write('subtotal: $subtotal')
          ..write(')'))
        .toString();
  }
}

class $TablaComprasTable extends TablaCompras
    with TableInfo<$TablaComprasTable, TablaCompra> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TablaComprasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<DateTime> fecha = GeneratedColumn<DateTime>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _proveedorMeta = const VerificationMeta(
    'proveedor',
  );
  @override
  late final GeneratedColumn<String> proveedor = GeneratedColumn<String>(
    'proveedor',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<double> total = GeneratedColumn<double>(
    'total',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _notaMeta = const VerificationMeta('nota');
  @override
  late final GeneratedColumn<String> nota = GeneratedColumn<String>(
    'nota',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, fecha, proveedor, total, nota];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tabla_compras';
  @override
  VerificationContext validateIntegrity(
    Insertable<TablaCompra> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    }
    if (data.containsKey('proveedor')) {
      context.handle(
        _proveedorMeta,
        proveedor.isAcceptableOrUnknown(data['proveedor']!, _proveedorMeta),
      );
    }
    if (data.containsKey('total')) {
      context.handle(
        _totalMeta,
        total.isAcceptableOrUnknown(data['total']!, _totalMeta),
      );
    }
    if (data.containsKey('nota')) {
      context.handle(
        _notaMeta,
        nota.isAcceptableOrUnknown(data['nota']!, _notaMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TablaCompra map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TablaCompra(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha'],
      )!,
      proveedor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}proveedor'],
      ),
      total: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total'],
      )!,
      nota: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nota'],
      ),
    );
  }

  @override
  $TablaComprasTable createAlias(String alias) {
    return $TablaComprasTable(attachedDatabase, alias);
  }
}

class TablaCompra extends DataClass implements Insertable<TablaCompra> {
  final int id;
  final DateTime fecha;
  final String? proveedor;
  final double total;
  final String? nota;
  const TablaCompra({
    required this.id,
    required this.fecha,
    this.proveedor,
    required this.total,
    this.nota,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['fecha'] = Variable<DateTime>(fecha);
    if (!nullToAbsent || proveedor != null) {
      map['proveedor'] = Variable<String>(proveedor);
    }
    map['total'] = Variable<double>(total);
    if (!nullToAbsent || nota != null) {
      map['nota'] = Variable<String>(nota);
    }
    return map;
  }

  TablaComprasCompanion toCompanion(bool nullToAbsent) {
    return TablaComprasCompanion(
      id: Value(id),
      fecha: Value(fecha),
      proveedor: proveedor == null && nullToAbsent
          ? const Value.absent()
          : Value(proveedor),
      total: Value(total),
      nota: nota == null && nullToAbsent ? const Value.absent() : Value(nota),
    );
  }

  factory TablaCompra.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TablaCompra(
      id: serializer.fromJson<int>(json['id']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
      proveedor: serializer.fromJson<String?>(json['proveedor']),
      total: serializer.fromJson<double>(json['total']),
      nota: serializer.fromJson<String?>(json['nota']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'fecha': serializer.toJson<DateTime>(fecha),
      'proveedor': serializer.toJson<String?>(proveedor),
      'total': serializer.toJson<double>(total),
      'nota': serializer.toJson<String?>(nota),
    };
  }

  TablaCompra copyWith({
    int? id,
    DateTime? fecha,
    Value<String?> proveedor = const Value.absent(),
    double? total,
    Value<String?> nota = const Value.absent(),
  }) => TablaCompra(
    id: id ?? this.id,
    fecha: fecha ?? this.fecha,
    proveedor: proveedor.present ? proveedor.value : this.proveedor,
    total: total ?? this.total,
    nota: nota.present ? nota.value : this.nota,
  );
  TablaCompra copyWithCompanion(TablaComprasCompanion data) {
    return TablaCompra(
      id: data.id.present ? data.id.value : this.id,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      proveedor: data.proveedor.present ? data.proveedor.value : this.proveedor,
      total: data.total.present ? data.total.value : this.total,
      nota: data.nota.present ? data.nota.value : this.nota,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TablaCompra(')
          ..write('id: $id, ')
          ..write('fecha: $fecha, ')
          ..write('proveedor: $proveedor, ')
          ..write('total: $total, ')
          ..write('nota: $nota')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, fecha, proveedor, total, nota);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TablaCompra &&
          other.id == this.id &&
          other.fecha == this.fecha &&
          other.proveedor == this.proveedor &&
          other.total == this.total &&
          other.nota == this.nota);
}

class TablaComprasCompanion extends UpdateCompanion<TablaCompra> {
  final Value<int> id;
  final Value<DateTime> fecha;
  final Value<String?> proveedor;
  final Value<double> total;
  final Value<String?> nota;
  const TablaComprasCompanion({
    this.id = const Value.absent(),
    this.fecha = const Value.absent(),
    this.proveedor = const Value.absent(),
    this.total = const Value.absent(),
    this.nota = const Value.absent(),
  });
  TablaComprasCompanion.insert({
    this.id = const Value.absent(),
    this.fecha = const Value.absent(),
    this.proveedor = const Value.absent(),
    this.total = const Value.absent(),
    this.nota = const Value.absent(),
  });
  static Insertable<TablaCompra> custom({
    Expression<int>? id,
    Expression<DateTime>? fecha,
    Expression<String>? proveedor,
    Expression<double>? total,
    Expression<String>? nota,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fecha != null) 'fecha': fecha,
      if (proveedor != null) 'proveedor': proveedor,
      if (total != null) 'total': total,
      if (nota != null) 'nota': nota,
    });
  }

  TablaComprasCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? fecha,
    Value<String?>? proveedor,
    Value<double>? total,
    Value<String?>? nota,
  }) {
    return TablaComprasCompanion(
      id: id ?? this.id,
      fecha: fecha ?? this.fecha,
      proveedor: proveedor ?? this.proveedor,
      total: total ?? this.total,
      nota: nota ?? this.nota,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (proveedor.present) {
      map['proveedor'] = Variable<String>(proveedor.value);
    }
    if (total.present) {
      map['total'] = Variable<double>(total.value);
    }
    if (nota.present) {
      map['nota'] = Variable<String>(nota.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TablaComprasCompanion(')
          ..write('id: $id, ')
          ..write('fecha: $fecha, ')
          ..write('proveedor: $proveedor, ')
          ..write('total: $total, ')
          ..write('nota: $nota')
          ..write(')'))
        .toString();
  }
}

class $TablaLineasCompraTable extends TablaLineasCompra
    with TableInfo<$TablaLineasCompraTable, TablaLineasCompraData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TablaLineasCompraTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _compraIdMeta = const VerificationMeta(
    'compraId',
  );
  @override
  late final GeneratedColumn<int> compraId = GeneratedColumn<int>(
    'compra_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tabla_compras (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _productoIdMeta = const VerificationMeta(
    'productoId',
  );
  @override
  late final GeneratedColumn<int> productoId = GeneratedColumn<int>(
    'producto_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tabla_productos (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _cantidadMeta = const VerificationMeta(
    'cantidad',
  );
  @override
  late final GeneratedColumn<double> cantidad = GeneratedColumn<double>(
    'cantidad',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _costoUnitarioMeta = const VerificationMeta(
    'costoUnitario',
  );
  @override
  late final GeneratedColumn<double> costoUnitario = GeneratedColumn<double>(
    'costo_unitario',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _subtotalMeta = const VerificationMeta(
    'subtotal',
  );
  @override
  late final GeneratedColumn<double> subtotal = GeneratedColumn<double>(
    'subtotal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    compraId,
    productoId,
    cantidad,
    costoUnitario,
    subtotal,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tabla_lineas_compra';
  @override
  VerificationContext validateIntegrity(
    Insertable<TablaLineasCompraData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('compra_id')) {
      context.handle(
        _compraIdMeta,
        compraId.isAcceptableOrUnknown(data['compra_id']!, _compraIdMeta),
      );
    } else if (isInserting) {
      context.missing(_compraIdMeta);
    }
    if (data.containsKey('producto_id')) {
      context.handle(
        _productoIdMeta,
        productoId.isAcceptableOrUnknown(data['producto_id']!, _productoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productoIdMeta);
    }
    if (data.containsKey('cantidad')) {
      context.handle(
        _cantidadMeta,
        cantidad.isAcceptableOrUnknown(data['cantidad']!, _cantidadMeta),
      );
    } else if (isInserting) {
      context.missing(_cantidadMeta);
    }
    if (data.containsKey('costo_unitario')) {
      context.handle(
        _costoUnitarioMeta,
        costoUnitario.isAcceptableOrUnknown(
          data['costo_unitario']!,
          _costoUnitarioMeta,
        ),
      );
    }
    if (data.containsKey('subtotal')) {
      context.handle(
        _subtotalMeta,
        subtotal.isAcceptableOrUnknown(data['subtotal']!, _subtotalMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TablaLineasCompraData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TablaLineasCompraData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      compraId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}compra_id'],
      )!,
      productoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}producto_id'],
      )!,
      cantidad: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cantidad'],
      )!,
      costoUnitario: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}costo_unitario'],
      )!,
      subtotal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}subtotal'],
      )!,
    );
  }

  @override
  $TablaLineasCompraTable createAlias(String alias) {
    return $TablaLineasCompraTable(attachedDatabase, alias);
  }
}

class TablaLineasCompraData extends DataClass
    implements Insertable<TablaLineasCompraData> {
  final int id;
  final int compraId;
  final int productoId;
  final double cantidad;
  final double costoUnitario;
  final double subtotal;
  const TablaLineasCompraData({
    required this.id,
    required this.compraId,
    required this.productoId,
    required this.cantidad,
    required this.costoUnitario,
    required this.subtotal,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['compra_id'] = Variable<int>(compraId);
    map['producto_id'] = Variable<int>(productoId);
    map['cantidad'] = Variable<double>(cantidad);
    map['costo_unitario'] = Variable<double>(costoUnitario);
    map['subtotal'] = Variable<double>(subtotal);
    return map;
  }

  TablaLineasCompraCompanion toCompanion(bool nullToAbsent) {
    return TablaLineasCompraCompanion(
      id: Value(id),
      compraId: Value(compraId),
      productoId: Value(productoId),
      cantidad: Value(cantidad),
      costoUnitario: Value(costoUnitario),
      subtotal: Value(subtotal),
    );
  }

  factory TablaLineasCompraData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TablaLineasCompraData(
      id: serializer.fromJson<int>(json['id']),
      compraId: serializer.fromJson<int>(json['compraId']),
      productoId: serializer.fromJson<int>(json['productoId']),
      cantidad: serializer.fromJson<double>(json['cantidad']),
      costoUnitario: serializer.fromJson<double>(json['costoUnitario']),
      subtotal: serializer.fromJson<double>(json['subtotal']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'compraId': serializer.toJson<int>(compraId),
      'productoId': serializer.toJson<int>(productoId),
      'cantidad': serializer.toJson<double>(cantidad),
      'costoUnitario': serializer.toJson<double>(costoUnitario),
      'subtotal': serializer.toJson<double>(subtotal),
    };
  }

  TablaLineasCompraData copyWith({
    int? id,
    int? compraId,
    int? productoId,
    double? cantidad,
    double? costoUnitario,
    double? subtotal,
  }) => TablaLineasCompraData(
    id: id ?? this.id,
    compraId: compraId ?? this.compraId,
    productoId: productoId ?? this.productoId,
    cantidad: cantidad ?? this.cantidad,
    costoUnitario: costoUnitario ?? this.costoUnitario,
    subtotal: subtotal ?? this.subtotal,
  );
  TablaLineasCompraData copyWithCompanion(TablaLineasCompraCompanion data) {
    return TablaLineasCompraData(
      id: data.id.present ? data.id.value : this.id,
      compraId: data.compraId.present ? data.compraId.value : this.compraId,
      productoId: data.productoId.present
          ? data.productoId.value
          : this.productoId,
      cantidad: data.cantidad.present ? data.cantidad.value : this.cantidad,
      costoUnitario: data.costoUnitario.present
          ? data.costoUnitario.value
          : this.costoUnitario,
      subtotal: data.subtotal.present ? data.subtotal.value : this.subtotal,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TablaLineasCompraData(')
          ..write('id: $id, ')
          ..write('compraId: $compraId, ')
          ..write('productoId: $productoId, ')
          ..write('cantidad: $cantidad, ')
          ..write('costoUnitario: $costoUnitario, ')
          ..write('subtotal: $subtotal')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, compraId, productoId, cantidad, costoUnitario, subtotal);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TablaLineasCompraData &&
          other.id == this.id &&
          other.compraId == this.compraId &&
          other.productoId == this.productoId &&
          other.cantidad == this.cantidad &&
          other.costoUnitario == this.costoUnitario &&
          other.subtotal == this.subtotal);
}

class TablaLineasCompraCompanion
    extends UpdateCompanion<TablaLineasCompraData> {
  final Value<int> id;
  final Value<int> compraId;
  final Value<int> productoId;
  final Value<double> cantidad;
  final Value<double> costoUnitario;
  final Value<double> subtotal;
  const TablaLineasCompraCompanion({
    this.id = const Value.absent(),
    this.compraId = const Value.absent(),
    this.productoId = const Value.absent(),
    this.cantidad = const Value.absent(),
    this.costoUnitario = const Value.absent(),
    this.subtotal = const Value.absent(),
  });
  TablaLineasCompraCompanion.insert({
    this.id = const Value.absent(),
    required int compraId,
    required int productoId,
    required double cantidad,
    this.costoUnitario = const Value.absent(),
    this.subtotal = const Value.absent(),
  }) : compraId = Value(compraId),
       productoId = Value(productoId),
       cantidad = Value(cantidad);
  static Insertable<TablaLineasCompraData> custom({
    Expression<int>? id,
    Expression<int>? compraId,
    Expression<int>? productoId,
    Expression<double>? cantidad,
    Expression<double>? costoUnitario,
    Expression<double>? subtotal,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (compraId != null) 'compra_id': compraId,
      if (productoId != null) 'producto_id': productoId,
      if (cantidad != null) 'cantidad': cantidad,
      if (costoUnitario != null) 'costo_unitario': costoUnitario,
      if (subtotal != null) 'subtotal': subtotal,
    });
  }

  TablaLineasCompraCompanion copyWith({
    Value<int>? id,
    Value<int>? compraId,
    Value<int>? productoId,
    Value<double>? cantidad,
    Value<double>? costoUnitario,
    Value<double>? subtotal,
  }) {
    return TablaLineasCompraCompanion(
      id: id ?? this.id,
      compraId: compraId ?? this.compraId,
      productoId: productoId ?? this.productoId,
      cantidad: cantidad ?? this.cantidad,
      costoUnitario: costoUnitario ?? this.costoUnitario,
      subtotal: subtotal ?? this.subtotal,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (compraId.present) {
      map['compra_id'] = Variable<int>(compraId.value);
    }
    if (productoId.present) {
      map['producto_id'] = Variable<int>(productoId.value);
    }
    if (cantidad.present) {
      map['cantidad'] = Variable<double>(cantidad.value);
    }
    if (costoUnitario.present) {
      map['costo_unitario'] = Variable<double>(costoUnitario.value);
    }
    if (subtotal.present) {
      map['subtotal'] = Variable<double>(subtotal.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TablaLineasCompraCompanion(')
          ..write('id: $id, ')
          ..write('compraId: $compraId, ')
          ..write('productoId: $productoId, ')
          ..write('cantidad: $cantidad, ')
          ..write('costoUnitario: $costoUnitario, ')
          ..write('subtotal: $subtotal')
          ..write(')'))
        .toString();
  }
}

abstract class _$BaseDeDatos extends GeneratedDatabase {
  _$BaseDeDatos(QueryExecutor e) : super(e);
  $BaseDeDatosManager get managers => $BaseDeDatosManager(this);
  late final $TablaProductosTable tablaProductos = $TablaProductosTable(this);
  late final $TablaMovimientosTable tablaMovimientos = $TablaMovimientosTable(
    this,
  );
  late final $TablaCombosTable tablaCombos = $TablaCombosTable(this);
  late final $TablaComponentesTable tablaComponentes = $TablaComponentesTable(
    this,
  );
  late final $TablaVentasTable tablaVentas = $TablaVentasTable(this);
  late final $TablaLineasVentaTable tablaLineasVenta = $TablaLineasVentaTable(
    this,
  );
  late final $TablaComprasTable tablaCompras = $TablaComprasTable(this);
  late final $TablaLineasCompraTable tablaLineasCompra =
      $TablaLineasCompraTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    tablaProductos,
    tablaMovimientos,
    tablaCombos,
    tablaComponentes,
    tablaVentas,
    tablaLineasVenta,
    tablaCompras,
    tablaLineasCompra,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tabla_productos',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('tabla_movimientos', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tabla_combos',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('tabla_componentes', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tabla_ventas',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('tabla_lineas_venta', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tabla_compras',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('tabla_lineas_compra', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$TablaProductosTableCreateCompanionBuilder =
    TablaProductosCompanion Function({
      Value<int> id,
      required String nombre,
      required String unidad,
      Value<double> costoActual,
      Value<double> precioSugerido,
      Value<double> stockMinimo,
      Value<String?> proveedor,
      Value<String?> imagen,
      Value<bool> activo,
      Value<DateTime> creadoEn,
    });
typedef $$TablaProductosTableUpdateCompanionBuilder =
    TablaProductosCompanion Function({
      Value<int> id,
      Value<String> nombre,
      Value<String> unidad,
      Value<double> costoActual,
      Value<double> precioSugerido,
      Value<double> stockMinimo,
      Value<String?> proveedor,
      Value<String?> imagen,
      Value<bool> activo,
      Value<DateTime> creadoEn,
    });

final class $$TablaProductosTableReferences
    extends BaseReferences<_$BaseDeDatos, $TablaProductosTable, TablaProducto> {
  $$TablaProductosTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$TablaMovimientosTable, List<TablaMovimiento>>
  _tablaMovimientosRefsTable(_$BaseDeDatos db) => MultiTypedResultKey.fromTable(
    db.tablaMovimientos,
    aliasName: $_aliasNameGenerator(
      db.tablaProductos.id,
      db.tablaMovimientos.productoId,
    ),
  );

  $$TablaMovimientosTableProcessedTableManager get tablaMovimientosRefs {
    final manager = $$TablaMovimientosTableTableManager(
      $_db,
      $_db.tablaMovimientos,
    ).filter((f) => f.productoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _tablaMovimientosRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TablaComponentesTable, List<TablaComponente>>
  _tablaComponentesRefsTable(_$BaseDeDatos db) => MultiTypedResultKey.fromTable(
    db.tablaComponentes,
    aliasName: $_aliasNameGenerator(
      db.tablaProductos.id,
      db.tablaComponentes.productoId,
    ),
  );

  $$TablaComponentesTableProcessedTableManager get tablaComponentesRefs {
    final manager = $$TablaComponentesTableTableManager(
      $_db,
      $_db.tablaComponentes,
    ).filter((f) => f.productoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _tablaComponentesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $TablaLineasCompraTable,
    List<TablaLineasCompraData>
  >
  _tablaLineasCompraRefsTable(_$BaseDeDatos db) =>
      MultiTypedResultKey.fromTable(
        db.tablaLineasCompra,
        aliasName: $_aliasNameGenerator(
          db.tablaProductos.id,
          db.tablaLineasCompra.productoId,
        ),
      );

  $$TablaLineasCompraTableProcessedTableManager get tablaLineasCompraRefs {
    final manager = $$TablaLineasCompraTableTableManager(
      $_db,
      $_db.tablaLineasCompra,
    ).filter((f) => f.productoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _tablaLineasCompraRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TablaProductosTableFilterComposer
    extends Composer<_$BaseDeDatos, $TablaProductosTable> {
  $$TablaProductosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unidad => $composableBuilder(
    column: $table.unidad,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get costoActual => $composableBuilder(
    column: $table.costoActual,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get precioSugerido => $composableBuilder(
    column: $table.precioSugerido,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get stockMinimo => $composableBuilder(
    column: $table.stockMinimo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get proveedor => $composableBuilder(
    column: $table.proveedor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagen => $composableBuilder(
    column: $table.imagen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get activo => $composableBuilder(
    column: $table.activo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> tablaMovimientosRefs(
    Expression<bool> Function($$TablaMovimientosTableFilterComposer f) f,
  ) {
    final $$TablaMovimientosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tablaMovimientos,
      getReferencedColumn: (t) => t.productoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaMovimientosTableFilterComposer(
            $db: $db,
            $table: $db.tablaMovimientos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> tablaComponentesRefs(
    Expression<bool> Function($$TablaComponentesTableFilterComposer f) f,
  ) {
    final $$TablaComponentesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tablaComponentes,
      getReferencedColumn: (t) => t.productoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaComponentesTableFilterComposer(
            $db: $db,
            $table: $db.tablaComponentes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> tablaLineasCompraRefs(
    Expression<bool> Function($$TablaLineasCompraTableFilterComposer f) f,
  ) {
    final $$TablaLineasCompraTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tablaLineasCompra,
      getReferencedColumn: (t) => t.productoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaLineasCompraTableFilterComposer(
            $db: $db,
            $table: $db.tablaLineasCompra,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TablaProductosTableOrderingComposer
    extends Composer<_$BaseDeDatos, $TablaProductosTable> {
  $$TablaProductosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unidad => $composableBuilder(
    column: $table.unidad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get costoActual => $composableBuilder(
    column: $table.costoActual,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get precioSugerido => $composableBuilder(
    column: $table.precioSugerido,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stockMinimo => $composableBuilder(
    column: $table.stockMinimo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get proveedor => $composableBuilder(
    column: $table.proveedor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagen => $composableBuilder(
    column: $table.imagen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get activo => $composableBuilder(
    column: $table.activo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TablaProductosTableAnnotationComposer
    extends Composer<_$BaseDeDatos, $TablaProductosTable> {
  $$TablaProductosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get unidad =>
      $composableBuilder(column: $table.unidad, builder: (column) => column);

  GeneratedColumn<double> get costoActual => $composableBuilder(
    column: $table.costoActual,
    builder: (column) => column,
  );

  GeneratedColumn<double> get precioSugerido => $composableBuilder(
    column: $table.precioSugerido,
    builder: (column) => column,
  );

  GeneratedColumn<double> get stockMinimo => $composableBuilder(
    column: $table.stockMinimo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get proveedor =>
      $composableBuilder(column: $table.proveedor, builder: (column) => column);

  GeneratedColumn<String> get imagen =>
      $composableBuilder(column: $table.imagen, builder: (column) => column);

  GeneratedColumn<bool> get activo =>
      $composableBuilder(column: $table.activo, builder: (column) => column);

  GeneratedColumn<DateTime> get creadoEn =>
      $composableBuilder(column: $table.creadoEn, builder: (column) => column);

  Expression<T> tablaMovimientosRefs<T extends Object>(
    Expression<T> Function($$TablaMovimientosTableAnnotationComposer a) f,
  ) {
    final $$TablaMovimientosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tablaMovimientos,
      getReferencedColumn: (t) => t.productoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaMovimientosTableAnnotationComposer(
            $db: $db,
            $table: $db.tablaMovimientos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> tablaComponentesRefs<T extends Object>(
    Expression<T> Function($$TablaComponentesTableAnnotationComposer a) f,
  ) {
    final $$TablaComponentesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tablaComponentes,
      getReferencedColumn: (t) => t.productoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaComponentesTableAnnotationComposer(
            $db: $db,
            $table: $db.tablaComponentes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> tablaLineasCompraRefs<T extends Object>(
    Expression<T> Function($$TablaLineasCompraTableAnnotationComposer a) f,
  ) {
    final $$TablaLineasCompraTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.tablaLineasCompra,
          getReferencedColumn: (t) => t.productoId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TablaLineasCompraTableAnnotationComposer(
                $db: $db,
                $table: $db.tablaLineasCompra,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$TablaProductosTableTableManager
    extends
        RootTableManager<
          _$BaseDeDatos,
          $TablaProductosTable,
          TablaProducto,
          $$TablaProductosTableFilterComposer,
          $$TablaProductosTableOrderingComposer,
          $$TablaProductosTableAnnotationComposer,
          $$TablaProductosTableCreateCompanionBuilder,
          $$TablaProductosTableUpdateCompanionBuilder,
          (TablaProducto, $$TablaProductosTableReferences),
          TablaProducto,
          PrefetchHooks Function({
            bool tablaMovimientosRefs,
            bool tablaComponentesRefs,
            bool tablaLineasCompraRefs,
          })
        > {
  $$TablaProductosTableTableManager(
    _$BaseDeDatos db,
    $TablaProductosTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TablaProductosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TablaProductosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TablaProductosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<String> unidad = const Value.absent(),
                Value<double> costoActual = const Value.absent(),
                Value<double> precioSugerido = const Value.absent(),
                Value<double> stockMinimo = const Value.absent(),
                Value<String?> proveedor = const Value.absent(),
                Value<String?> imagen = const Value.absent(),
                Value<bool> activo = const Value.absent(),
                Value<DateTime> creadoEn = const Value.absent(),
              }) => TablaProductosCompanion(
                id: id,
                nombre: nombre,
                unidad: unidad,
                costoActual: costoActual,
                precioSugerido: precioSugerido,
                stockMinimo: stockMinimo,
                proveedor: proveedor,
                imagen: imagen,
                activo: activo,
                creadoEn: creadoEn,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nombre,
                required String unidad,
                Value<double> costoActual = const Value.absent(),
                Value<double> precioSugerido = const Value.absent(),
                Value<double> stockMinimo = const Value.absent(),
                Value<String?> proveedor = const Value.absent(),
                Value<String?> imagen = const Value.absent(),
                Value<bool> activo = const Value.absent(),
                Value<DateTime> creadoEn = const Value.absent(),
              }) => TablaProductosCompanion.insert(
                id: id,
                nombre: nombre,
                unidad: unidad,
                costoActual: costoActual,
                precioSugerido: precioSugerido,
                stockMinimo: stockMinimo,
                proveedor: proveedor,
                imagen: imagen,
                activo: activo,
                creadoEn: creadoEn,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TablaProductosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                tablaMovimientosRefs = false,
                tablaComponentesRefs = false,
                tablaLineasCompraRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (tablaMovimientosRefs) db.tablaMovimientos,
                    if (tablaComponentesRefs) db.tablaComponentes,
                    if (tablaLineasCompraRefs) db.tablaLineasCompra,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (tablaMovimientosRefs)
                        await $_getPrefetchedData<
                          TablaProducto,
                          $TablaProductosTable,
                          TablaMovimiento
                        >(
                          currentTable: table,
                          referencedTable: $$TablaProductosTableReferences
                              ._tablaMovimientosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TablaProductosTableReferences(
                                db,
                                table,
                                p0,
                              ).tablaMovimientosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.productoId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (tablaComponentesRefs)
                        await $_getPrefetchedData<
                          TablaProducto,
                          $TablaProductosTable,
                          TablaComponente
                        >(
                          currentTable: table,
                          referencedTable: $$TablaProductosTableReferences
                              ._tablaComponentesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TablaProductosTableReferences(
                                db,
                                table,
                                p0,
                              ).tablaComponentesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.productoId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (tablaLineasCompraRefs)
                        await $_getPrefetchedData<
                          TablaProducto,
                          $TablaProductosTable,
                          TablaLineasCompraData
                        >(
                          currentTable: table,
                          referencedTable: $$TablaProductosTableReferences
                              ._tablaLineasCompraRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TablaProductosTableReferences(
                                db,
                                table,
                                p0,
                              ).tablaLineasCompraRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.productoId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TablaProductosTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDeDatos,
      $TablaProductosTable,
      TablaProducto,
      $$TablaProductosTableFilterComposer,
      $$TablaProductosTableOrderingComposer,
      $$TablaProductosTableAnnotationComposer,
      $$TablaProductosTableCreateCompanionBuilder,
      $$TablaProductosTableUpdateCompanionBuilder,
      (TablaProducto, $$TablaProductosTableReferences),
      TablaProducto,
      PrefetchHooks Function({
        bool tablaMovimientosRefs,
        bool tablaComponentesRefs,
        bool tablaLineasCompraRefs,
      })
    >;
typedef $$TablaMovimientosTableCreateCompanionBuilder =
    TablaMovimientosCompanion Function({
      Value<int> id,
      required int productoId,
      required String tipo,
      required double cantidad,
      Value<DateTime> fecha,
      Value<String?> nota,
      Value<String?> referencia,
    });
typedef $$TablaMovimientosTableUpdateCompanionBuilder =
    TablaMovimientosCompanion Function({
      Value<int> id,
      Value<int> productoId,
      Value<String> tipo,
      Value<double> cantidad,
      Value<DateTime> fecha,
      Value<String?> nota,
      Value<String?> referencia,
    });

final class $$TablaMovimientosTableReferences
    extends
        BaseReferences<_$BaseDeDatos, $TablaMovimientosTable, TablaMovimiento> {
  $$TablaMovimientosTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TablaProductosTable _productoIdTable(_$BaseDeDatos db) =>
      db.tablaProductos.createAlias(
        $_aliasNameGenerator(
          db.tablaMovimientos.productoId,
          db.tablaProductos.id,
        ),
      );

  $$TablaProductosTableProcessedTableManager get productoId {
    final $_column = $_itemColumn<int>('producto_id')!;

    final manager = $$TablaProductosTableTableManager(
      $_db,
      $_db.tablaProductos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TablaMovimientosTableFilterComposer
    extends Composer<_$BaseDeDatos, $TablaMovimientosTable> {
  $$TablaMovimientosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cantidad => $composableBuilder(
    column: $table.cantidad,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nota => $composableBuilder(
    column: $table.nota,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referencia => $composableBuilder(
    column: $table.referencia,
    builder: (column) => ColumnFilters(column),
  );

  $$TablaProductosTableFilterComposer get productoId {
    final $$TablaProductosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productoId,
      referencedTable: $db.tablaProductos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaProductosTableFilterComposer(
            $db: $db,
            $table: $db.tablaProductos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TablaMovimientosTableOrderingComposer
    extends Composer<_$BaseDeDatos, $TablaMovimientosTable> {
  $$TablaMovimientosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cantidad => $composableBuilder(
    column: $table.cantidad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nota => $composableBuilder(
    column: $table.nota,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referencia => $composableBuilder(
    column: $table.referencia,
    builder: (column) => ColumnOrderings(column),
  );

  $$TablaProductosTableOrderingComposer get productoId {
    final $$TablaProductosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productoId,
      referencedTable: $db.tablaProductos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaProductosTableOrderingComposer(
            $db: $db,
            $table: $db.tablaProductos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TablaMovimientosTableAnnotationComposer
    extends Composer<_$BaseDeDatos, $TablaMovimientosTable> {
  $$TablaMovimientosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<double> get cantidad =>
      $composableBuilder(column: $table.cantidad, builder: (column) => column);

  GeneratedColumn<DateTime> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<String> get nota =>
      $composableBuilder(column: $table.nota, builder: (column) => column);

  GeneratedColumn<String> get referencia => $composableBuilder(
    column: $table.referencia,
    builder: (column) => column,
  );

  $$TablaProductosTableAnnotationComposer get productoId {
    final $$TablaProductosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productoId,
      referencedTable: $db.tablaProductos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaProductosTableAnnotationComposer(
            $db: $db,
            $table: $db.tablaProductos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TablaMovimientosTableTableManager
    extends
        RootTableManager<
          _$BaseDeDatos,
          $TablaMovimientosTable,
          TablaMovimiento,
          $$TablaMovimientosTableFilterComposer,
          $$TablaMovimientosTableOrderingComposer,
          $$TablaMovimientosTableAnnotationComposer,
          $$TablaMovimientosTableCreateCompanionBuilder,
          $$TablaMovimientosTableUpdateCompanionBuilder,
          (TablaMovimiento, $$TablaMovimientosTableReferences),
          TablaMovimiento,
          PrefetchHooks Function({bool productoId})
        > {
  $$TablaMovimientosTableTableManager(
    _$BaseDeDatos db,
    $TablaMovimientosTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TablaMovimientosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TablaMovimientosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TablaMovimientosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> productoId = const Value.absent(),
                Value<String> tipo = const Value.absent(),
                Value<double> cantidad = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
                Value<String?> nota = const Value.absent(),
                Value<String?> referencia = const Value.absent(),
              }) => TablaMovimientosCompanion(
                id: id,
                productoId: productoId,
                tipo: tipo,
                cantidad: cantidad,
                fecha: fecha,
                nota: nota,
                referencia: referencia,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int productoId,
                required String tipo,
                required double cantidad,
                Value<DateTime> fecha = const Value.absent(),
                Value<String?> nota = const Value.absent(),
                Value<String?> referencia = const Value.absent(),
              }) => TablaMovimientosCompanion.insert(
                id: id,
                productoId: productoId,
                tipo: tipo,
                cantidad: cantidad,
                fecha: fecha,
                nota: nota,
                referencia: referencia,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TablaMovimientosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({productoId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (productoId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.productoId,
                                referencedTable:
                                    $$TablaMovimientosTableReferences
                                        ._productoIdTable(db),
                                referencedColumn:
                                    $$TablaMovimientosTableReferences
                                        ._productoIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TablaMovimientosTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDeDatos,
      $TablaMovimientosTable,
      TablaMovimiento,
      $$TablaMovimientosTableFilterComposer,
      $$TablaMovimientosTableOrderingComposer,
      $$TablaMovimientosTableAnnotationComposer,
      $$TablaMovimientosTableCreateCompanionBuilder,
      $$TablaMovimientosTableUpdateCompanionBuilder,
      (TablaMovimiento, $$TablaMovimientosTableReferences),
      TablaMovimiento,
      PrefetchHooks Function({bool productoId})
    >;
typedef $$TablaCombosTableCreateCompanionBuilder =
    TablaCombosCompanion Function({
      Value<int> id,
      required String nombre,
      Value<double> precioVenta,
      Value<bool> activo,
      Value<DateTime> creadoEn,
    });
typedef $$TablaCombosTableUpdateCompanionBuilder =
    TablaCombosCompanion Function({
      Value<int> id,
      Value<String> nombre,
      Value<double> precioVenta,
      Value<bool> activo,
      Value<DateTime> creadoEn,
    });

final class $$TablaCombosTableReferences
    extends BaseReferences<_$BaseDeDatos, $TablaCombosTable, TablaCombo> {
  $$TablaCombosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TablaComponentesTable, List<TablaComponente>>
  _tablaComponentesRefsTable(_$BaseDeDatos db) => MultiTypedResultKey.fromTable(
    db.tablaComponentes,
    aliasName: $_aliasNameGenerator(
      db.tablaCombos.id,
      db.tablaComponentes.comboId,
    ),
  );

  $$TablaComponentesTableProcessedTableManager get tablaComponentesRefs {
    final manager = $$TablaComponentesTableTableManager(
      $_db,
      $_db.tablaComponentes,
    ).filter((f) => f.comboId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _tablaComponentesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TablaLineasVentaTable, List<TablaLineasVentaData>>
  _tablaLineasVentaRefsTable(_$BaseDeDatos db) => MultiTypedResultKey.fromTable(
    db.tablaLineasVenta,
    aliasName: $_aliasNameGenerator(
      db.tablaCombos.id,
      db.tablaLineasVenta.comboId,
    ),
  );

  $$TablaLineasVentaTableProcessedTableManager get tablaLineasVentaRefs {
    final manager = $$TablaLineasVentaTableTableManager(
      $_db,
      $_db.tablaLineasVenta,
    ).filter((f) => f.comboId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _tablaLineasVentaRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TablaCombosTableFilterComposer
    extends Composer<_$BaseDeDatos, $TablaCombosTable> {
  $$TablaCombosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get precioVenta => $composableBuilder(
    column: $table.precioVenta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get activo => $composableBuilder(
    column: $table.activo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> tablaComponentesRefs(
    Expression<bool> Function($$TablaComponentesTableFilterComposer f) f,
  ) {
    final $$TablaComponentesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tablaComponentes,
      getReferencedColumn: (t) => t.comboId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaComponentesTableFilterComposer(
            $db: $db,
            $table: $db.tablaComponentes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> tablaLineasVentaRefs(
    Expression<bool> Function($$TablaLineasVentaTableFilterComposer f) f,
  ) {
    final $$TablaLineasVentaTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tablaLineasVenta,
      getReferencedColumn: (t) => t.comboId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaLineasVentaTableFilterComposer(
            $db: $db,
            $table: $db.tablaLineasVenta,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TablaCombosTableOrderingComposer
    extends Composer<_$BaseDeDatos, $TablaCombosTable> {
  $$TablaCombosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get precioVenta => $composableBuilder(
    column: $table.precioVenta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get activo => $composableBuilder(
    column: $table.activo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TablaCombosTableAnnotationComposer
    extends Composer<_$BaseDeDatos, $TablaCombosTable> {
  $$TablaCombosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<double> get precioVenta => $composableBuilder(
    column: $table.precioVenta,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get activo =>
      $composableBuilder(column: $table.activo, builder: (column) => column);

  GeneratedColumn<DateTime> get creadoEn =>
      $composableBuilder(column: $table.creadoEn, builder: (column) => column);

  Expression<T> tablaComponentesRefs<T extends Object>(
    Expression<T> Function($$TablaComponentesTableAnnotationComposer a) f,
  ) {
    final $$TablaComponentesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tablaComponentes,
      getReferencedColumn: (t) => t.comboId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaComponentesTableAnnotationComposer(
            $db: $db,
            $table: $db.tablaComponentes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> tablaLineasVentaRefs<T extends Object>(
    Expression<T> Function($$TablaLineasVentaTableAnnotationComposer a) f,
  ) {
    final $$TablaLineasVentaTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tablaLineasVenta,
      getReferencedColumn: (t) => t.comboId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaLineasVentaTableAnnotationComposer(
            $db: $db,
            $table: $db.tablaLineasVenta,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TablaCombosTableTableManager
    extends
        RootTableManager<
          _$BaseDeDatos,
          $TablaCombosTable,
          TablaCombo,
          $$TablaCombosTableFilterComposer,
          $$TablaCombosTableOrderingComposer,
          $$TablaCombosTableAnnotationComposer,
          $$TablaCombosTableCreateCompanionBuilder,
          $$TablaCombosTableUpdateCompanionBuilder,
          (TablaCombo, $$TablaCombosTableReferences),
          TablaCombo,
          PrefetchHooks Function({
            bool tablaComponentesRefs,
            bool tablaLineasVentaRefs,
          })
        > {
  $$TablaCombosTableTableManager(_$BaseDeDatos db, $TablaCombosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TablaCombosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TablaCombosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TablaCombosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<double> precioVenta = const Value.absent(),
                Value<bool> activo = const Value.absent(),
                Value<DateTime> creadoEn = const Value.absent(),
              }) => TablaCombosCompanion(
                id: id,
                nombre: nombre,
                precioVenta: precioVenta,
                activo: activo,
                creadoEn: creadoEn,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nombre,
                Value<double> precioVenta = const Value.absent(),
                Value<bool> activo = const Value.absent(),
                Value<DateTime> creadoEn = const Value.absent(),
              }) => TablaCombosCompanion.insert(
                id: id,
                nombre: nombre,
                precioVenta: precioVenta,
                activo: activo,
                creadoEn: creadoEn,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TablaCombosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({tablaComponentesRefs = false, tablaLineasVentaRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (tablaComponentesRefs) db.tablaComponentes,
                    if (tablaLineasVentaRefs) db.tablaLineasVenta,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (tablaComponentesRefs)
                        await $_getPrefetchedData<
                          TablaCombo,
                          $TablaCombosTable,
                          TablaComponente
                        >(
                          currentTable: table,
                          referencedTable: $$TablaCombosTableReferences
                              ._tablaComponentesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TablaCombosTableReferences(
                                db,
                                table,
                                p0,
                              ).tablaComponentesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.comboId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (tablaLineasVentaRefs)
                        await $_getPrefetchedData<
                          TablaCombo,
                          $TablaCombosTable,
                          TablaLineasVentaData
                        >(
                          currentTable: table,
                          referencedTable: $$TablaCombosTableReferences
                              ._tablaLineasVentaRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TablaCombosTableReferences(
                                db,
                                table,
                                p0,
                              ).tablaLineasVentaRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.comboId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TablaCombosTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDeDatos,
      $TablaCombosTable,
      TablaCombo,
      $$TablaCombosTableFilterComposer,
      $$TablaCombosTableOrderingComposer,
      $$TablaCombosTableAnnotationComposer,
      $$TablaCombosTableCreateCompanionBuilder,
      $$TablaCombosTableUpdateCompanionBuilder,
      (TablaCombo, $$TablaCombosTableReferences),
      TablaCombo,
      PrefetchHooks Function({
        bool tablaComponentesRefs,
        bool tablaLineasVentaRefs,
      })
    >;
typedef $$TablaComponentesTableCreateCompanionBuilder =
    TablaComponentesCompanion Function({
      Value<int> id,
      required int comboId,
      required int productoId,
      required double cantidad,
    });
typedef $$TablaComponentesTableUpdateCompanionBuilder =
    TablaComponentesCompanion Function({
      Value<int> id,
      Value<int> comboId,
      Value<int> productoId,
      Value<double> cantidad,
    });

final class $$TablaComponentesTableReferences
    extends
        BaseReferences<_$BaseDeDatos, $TablaComponentesTable, TablaComponente> {
  $$TablaComponentesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TablaCombosTable _comboIdTable(_$BaseDeDatos db) =>
      db.tablaCombos.createAlias(
        $_aliasNameGenerator(db.tablaComponentes.comboId, db.tablaCombos.id),
      );

  $$TablaCombosTableProcessedTableManager get comboId {
    final $_column = $_itemColumn<int>('combo_id')!;

    final manager = $$TablaCombosTableTableManager(
      $_db,
      $_db.tablaCombos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_comboIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TablaProductosTable _productoIdTable(_$BaseDeDatos db) =>
      db.tablaProductos.createAlias(
        $_aliasNameGenerator(
          db.tablaComponentes.productoId,
          db.tablaProductos.id,
        ),
      );

  $$TablaProductosTableProcessedTableManager get productoId {
    final $_column = $_itemColumn<int>('producto_id')!;

    final manager = $$TablaProductosTableTableManager(
      $_db,
      $_db.tablaProductos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TablaComponentesTableFilterComposer
    extends Composer<_$BaseDeDatos, $TablaComponentesTable> {
  $$TablaComponentesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cantidad => $composableBuilder(
    column: $table.cantidad,
    builder: (column) => ColumnFilters(column),
  );

  $$TablaCombosTableFilterComposer get comboId {
    final $$TablaCombosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.comboId,
      referencedTable: $db.tablaCombos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaCombosTableFilterComposer(
            $db: $db,
            $table: $db.tablaCombos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TablaProductosTableFilterComposer get productoId {
    final $$TablaProductosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productoId,
      referencedTable: $db.tablaProductos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaProductosTableFilterComposer(
            $db: $db,
            $table: $db.tablaProductos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TablaComponentesTableOrderingComposer
    extends Composer<_$BaseDeDatos, $TablaComponentesTable> {
  $$TablaComponentesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cantidad => $composableBuilder(
    column: $table.cantidad,
    builder: (column) => ColumnOrderings(column),
  );

  $$TablaCombosTableOrderingComposer get comboId {
    final $$TablaCombosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.comboId,
      referencedTable: $db.tablaCombos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaCombosTableOrderingComposer(
            $db: $db,
            $table: $db.tablaCombos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TablaProductosTableOrderingComposer get productoId {
    final $$TablaProductosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productoId,
      referencedTable: $db.tablaProductos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaProductosTableOrderingComposer(
            $db: $db,
            $table: $db.tablaProductos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TablaComponentesTableAnnotationComposer
    extends Composer<_$BaseDeDatos, $TablaComponentesTable> {
  $$TablaComponentesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get cantidad =>
      $composableBuilder(column: $table.cantidad, builder: (column) => column);

  $$TablaCombosTableAnnotationComposer get comboId {
    final $$TablaCombosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.comboId,
      referencedTable: $db.tablaCombos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaCombosTableAnnotationComposer(
            $db: $db,
            $table: $db.tablaCombos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TablaProductosTableAnnotationComposer get productoId {
    final $$TablaProductosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productoId,
      referencedTable: $db.tablaProductos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaProductosTableAnnotationComposer(
            $db: $db,
            $table: $db.tablaProductos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TablaComponentesTableTableManager
    extends
        RootTableManager<
          _$BaseDeDatos,
          $TablaComponentesTable,
          TablaComponente,
          $$TablaComponentesTableFilterComposer,
          $$TablaComponentesTableOrderingComposer,
          $$TablaComponentesTableAnnotationComposer,
          $$TablaComponentesTableCreateCompanionBuilder,
          $$TablaComponentesTableUpdateCompanionBuilder,
          (TablaComponente, $$TablaComponentesTableReferences),
          TablaComponente,
          PrefetchHooks Function({bool comboId, bool productoId})
        > {
  $$TablaComponentesTableTableManager(
    _$BaseDeDatos db,
    $TablaComponentesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TablaComponentesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TablaComponentesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TablaComponentesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> comboId = const Value.absent(),
                Value<int> productoId = const Value.absent(),
                Value<double> cantidad = const Value.absent(),
              }) => TablaComponentesCompanion(
                id: id,
                comboId: comboId,
                productoId: productoId,
                cantidad: cantidad,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int comboId,
                required int productoId,
                required double cantidad,
              }) => TablaComponentesCompanion.insert(
                id: id,
                comboId: comboId,
                productoId: productoId,
                cantidad: cantidad,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TablaComponentesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({comboId = false, productoId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (comboId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.comboId,
                                referencedTable:
                                    $$TablaComponentesTableReferences
                                        ._comboIdTable(db),
                                referencedColumn:
                                    $$TablaComponentesTableReferences
                                        ._comboIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (productoId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.productoId,
                                referencedTable:
                                    $$TablaComponentesTableReferences
                                        ._productoIdTable(db),
                                referencedColumn:
                                    $$TablaComponentesTableReferences
                                        ._productoIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TablaComponentesTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDeDatos,
      $TablaComponentesTable,
      TablaComponente,
      $$TablaComponentesTableFilterComposer,
      $$TablaComponentesTableOrderingComposer,
      $$TablaComponentesTableAnnotationComposer,
      $$TablaComponentesTableCreateCompanionBuilder,
      $$TablaComponentesTableUpdateCompanionBuilder,
      (TablaComponente, $$TablaComponentesTableReferences),
      TablaComponente,
      PrefetchHooks Function({bool comboId, bool productoId})
    >;
typedef $$TablaVentasTableCreateCompanionBuilder =
    TablaVentasCompanion Function({
      Value<int> id,
      Value<DateTime> fecha,
      Value<double> total,
      Value<String?> nota,
    });
typedef $$TablaVentasTableUpdateCompanionBuilder =
    TablaVentasCompanion Function({
      Value<int> id,
      Value<DateTime> fecha,
      Value<double> total,
      Value<String?> nota,
    });

final class $$TablaVentasTableReferences
    extends BaseReferences<_$BaseDeDatos, $TablaVentasTable, TablaVenta> {
  $$TablaVentasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TablaLineasVentaTable, List<TablaLineasVentaData>>
  _tablaLineasVentaRefsTable(_$BaseDeDatos db) => MultiTypedResultKey.fromTable(
    db.tablaLineasVenta,
    aliasName: $_aliasNameGenerator(
      db.tablaVentas.id,
      db.tablaLineasVenta.ventaId,
    ),
  );

  $$TablaLineasVentaTableProcessedTableManager get tablaLineasVentaRefs {
    final manager = $$TablaLineasVentaTableTableManager(
      $_db,
      $_db.tablaLineasVenta,
    ).filter((f) => f.ventaId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _tablaLineasVentaRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TablaVentasTableFilterComposer
    extends Composer<_$BaseDeDatos, $TablaVentasTable> {
  $$TablaVentasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nota => $composableBuilder(
    column: $table.nota,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> tablaLineasVentaRefs(
    Expression<bool> Function($$TablaLineasVentaTableFilterComposer f) f,
  ) {
    final $$TablaLineasVentaTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tablaLineasVenta,
      getReferencedColumn: (t) => t.ventaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaLineasVentaTableFilterComposer(
            $db: $db,
            $table: $db.tablaLineasVenta,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TablaVentasTableOrderingComposer
    extends Composer<_$BaseDeDatos, $TablaVentasTable> {
  $$TablaVentasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nota => $composableBuilder(
    column: $table.nota,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TablaVentasTableAnnotationComposer
    extends Composer<_$BaseDeDatos, $TablaVentasTable> {
  $$TablaVentasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<double> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<String> get nota =>
      $composableBuilder(column: $table.nota, builder: (column) => column);

  Expression<T> tablaLineasVentaRefs<T extends Object>(
    Expression<T> Function($$TablaLineasVentaTableAnnotationComposer a) f,
  ) {
    final $$TablaLineasVentaTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tablaLineasVenta,
      getReferencedColumn: (t) => t.ventaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaLineasVentaTableAnnotationComposer(
            $db: $db,
            $table: $db.tablaLineasVenta,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TablaVentasTableTableManager
    extends
        RootTableManager<
          _$BaseDeDatos,
          $TablaVentasTable,
          TablaVenta,
          $$TablaVentasTableFilterComposer,
          $$TablaVentasTableOrderingComposer,
          $$TablaVentasTableAnnotationComposer,
          $$TablaVentasTableCreateCompanionBuilder,
          $$TablaVentasTableUpdateCompanionBuilder,
          (TablaVenta, $$TablaVentasTableReferences),
          TablaVenta,
          PrefetchHooks Function({bool tablaLineasVentaRefs})
        > {
  $$TablaVentasTableTableManager(_$BaseDeDatos db, $TablaVentasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TablaVentasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TablaVentasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TablaVentasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
                Value<double> total = const Value.absent(),
                Value<String?> nota = const Value.absent(),
              }) => TablaVentasCompanion(
                id: id,
                fecha: fecha,
                total: total,
                nota: nota,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
                Value<double> total = const Value.absent(),
                Value<String?> nota = const Value.absent(),
              }) => TablaVentasCompanion.insert(
                id: id,
                fecha: fecha,
                total: total,
                nota: nota,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TablaVentasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({tablaLineasVentaRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (tablaLineasVentaRefs) db.tablaLineasVenta,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tablaLineasVentaRefs)
                    await $_getPrefetchedData<
                      TablaVenta,
                      $TablaVentasTable,
                      TablaLineasVentaData
                    >(
                      currentTable: table,
                      referencedTable: $$TablaVentasTableReferences
                          ._tablaLineasVentaRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TablaVentasTableReferences(
                            db,
                            table,
                            p0,
                          ).tablaLineasVentaRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.ventaId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TablaVentasTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDeDatos,
      $TablaVentasTable,
      TablaVenta,
      $$TablaVentasTableFilterComposer,
      $$TablaVentasTableOrderingComposer,
      $$TablaVentasTableAnnotationComposer,
      $$TablaVentasTableCreateCompanionBuilder,
      $$TablaVentasTableUpdateCompanionBuilder,
      (TablaVenta, $$TablaVentasTableReferences),
      TablaVenta,
      PrefetchHooks Function({bool tablaLineasVentaRefs})
    >;
typedef $$TablaLineasVentaTableCreateCompanionBuilder =
    TablaLineasVentaCompanion Function({
      Value<int> id,
      required int ventaId,
      required int comboId,
      required double cantidad,
      Value<double> precioUnitario,
      Value<double> subtotal,
    });
typedef $$TablaLineasVentaTableUpdateCompanionBuilder =
    TablaLineasVentaCompanion Function({
      Value<int> id,
      Value<int> ventaId,
      Value<int> comboId,
      Value<double> cantidad,
      Value<double> precioUnitario,
      Value<double> subtotal,
    });

final class $$TablaLineasVentaTableReferences
    extends
        BaseReferences<
          _$BaseDeDatos,
          $TablaLineasVentaTable,
          TablaLineasVentaData
        > {
  $$TablaLineasVentaTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TablaVentasTable _ventaIdTable(_$BaseDeDatos db) =>
      db.tablaVentas.createAlias(
        $_aliasNameGenerator(db.tablaLineasVenta.ventaId, db.tablaVentas.id),
      );

  $$TablaVentasTableProcessedTableManager get ventaId {
    final $_column = $_itemColumn<int>('venta_id')!;

    final manager = $$TablaVentasTableTableManager(
      $_db,
      $_db.tablaVentas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ventaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TablaCombosTable _comboIdTable(_$BaseDeDatos db) =>
      db.tablaCombos.createAlias(
        $_aliasNameGenerator(db.tablaLineasVenta.comboId, db.tablaCombos.id),
      );

  $$TablaCombosTableProcessedTableManager get comboId {
    final $_column = $_itemColumn<int>('combo_id')!;

    final manager = $$TablaCombosTableTableManager(
      $_db,
      $_db.tablaCombos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_comboIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TablaLineasVentaTableFilterComposer
    extends Composer<_$BaseDeDatos, $TablaLineasVentaTable> {
  $$TablaLineasVentaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cantidad => $composableBuilder(
    column: $table.cantidad,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get precioUnitario => $composableBuilder(
    column: $table.precioUnitario,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnFilters(column),
  );

  $$TablaVentasTableFilterComposer get ventaId {
    final $$TablaVentasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ventaId,
      referencedTable: $db.tablaVentas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaVentasTableFilterComposer(
            $db: $db,
            $table: $db.tablaVentas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TablaCombosTableFilterComposer get comboId {
    final $$TablaCombosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.comboId,
      referencedTable: $db.tablaCombos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaCombosTableFilterComposer(
            $db: $db,
            $table: $db.tablaCombos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TablaLineasVentaTableOrderingComposer
    extends Composer<_$BaseDeDatos, $TablaLineasVentaTable> {
  $$TablaLineasVentaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cantidad => $composableBuilder(
    column: $table.cantidad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get precioUnitario => $composableBuilder(
    column: $table.precioUnitario,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnOrderings(column),
  );

  $$TablaVentasTableOrderingComposer get ventaId {
    final $$TablaVentasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ventaId,
      referencedTable: $db.tablaVentas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaVentasTableOrderingComposer(
            $db: $db,
            $table: $db.tablaVentas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TablaCombosTableOrderingComposer get comboId {
    final $$TablaCombosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.comboId,
      referencedTable: $db.tablaCombos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaCombosTableOrderingComposer(
            $db: $db,
            $table: $db.tablaCombos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TablaLineasVentaTableAnnotationComposer
    extends Composer<_$BaseDeDatos, $TablaLineasVentaTable> {
  $$TablaLineasVentaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get cantidad =>
      $composableBuilder(column: $table.cantidad, builder: (column) => column);

  GeneratedColumn<double> get precioUnitario => $composableBuilder(
    column: $table.precioUnitario,
    builder: (column) => column,
  );

  GeneratedColumn<double> get subtotal =>
      $composableBuilder(column: $table.subtotal, builder: (column) => column);

  $$TablaVentasTableAnnotationComposer get ventaId {
    final $$TablaVentasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ventaId,
      referencedTable: $db.tablaVentas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaVentasTableAnnotationComposer(
            $db: $db,
            $table: $db.tablaVentas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TablaCombosTableAnnotationComposer get comboId {
    final $$TablaCombosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.comboId,
      referencedTable: $db.tablaCombos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaCombosTableAnnotationComposer(
            $db: $db,
            $table: $db.tablaCombos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TablaLineasVentaTableTableManager
    extends
        RootTableManager<
          _$BaseDeDatos,
          $TablaLineasVentaTable,
          TablaLineasVentaData,
          $$TablaLineasVentaTableFilterComposer,
          $$TablaLineasVentaTableOrderingComposer,
          $$TablaLineasVentaTableAnnotationComposer,
          $$TablaLineasVentaTableCreateCompanionBuilder,
          $$TablaLineasVentaTableUpdateCompanionBuilder,
          (TablaLineasVentaData, $$TablaLineasVentaTableReferences),
          TablaLineasVentaData,
          PrefetchHooks Function({bool ventaId, bool comboId})
        > {
  $$TablaLineasVentaTableTableManager(
    _$BaseDeDatos db,
    $TablaLineasVentaTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TablaLineasVentaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TablaLineasVentaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TablaLineasVentaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> ventaId = const Value.absent(),
                Value<int> comboId = const Value.absent(),
                Value<double> cantidad = const Value.absent(),
                Value<double> precioUnitario = const Value.absent(),
                Value<double> subtotal = const Value.absent(),
              }) => TablaLineasVentaCompanion(
                id: id,
                ventaId: ventaId,
                comboId: comboId,
                cantidad: cantidad,
                precioUnitario: precioUnitario,
                subtotal: subtotal,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int ventaId,
                required int comboId,
                required double cantidad,
                Value<double> precioUnitario = const Value.absent(),
                Value<double> subtotal = const Value.absent(),
              }) => TablaLineasVentaCompanion.insert(
                id: id,
                ventaId: ventaId,
                comboId: comboId,
                cantidad: cantidad,
                precioUnitario: precioUnitario,
                subtotal: subtotal,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TablaLineasVentaTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({ventaId = false, comboId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (ventaId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.ventaId,
                                referencedTable:
                                    $$TablaLineasVentaTableReferences
                                        ._ventaIdTable(db),
                                referencedColumn:
                                    $$TablaLineasVentaTableReferences
                                        ._ventaIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (comboId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.comboId,
                                referencedTable:
                                    $$TablaLineasVentaTableReferences
                                        ._comboIdTable(db),
                                referencedColumn:
                                    $$TablaLineasVentaTableReferences
                                        ._comboIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TablaLineasVentaTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDeDatos,
      $TablaLineasVentaTable,
      TablaLineasVentaData,
      $$TablaLineasVentaTableFilterComposer,
      $$TablaLineasVentaTableOrderingComposer,
      $$TablaLineasVentaTableAnnotationComposer,
      $$TablaLineasVentaTableCreateCompanionBuilder,
      $$TablaLineasVentaTableUpdateCompanionBuilder,
      (TablaLineasVentaData, $$TablaLineasVentaTableReferences),
      TablaLineasVentaData,
      PrefetchHooks Function({bool ventaId, bool comboId})
    >;
typedef $$TablaComprasTableCreateCompanionBuilder =
    TablaComprasCompanion Function({
      Value<int> id,
      Value<DateTime> fecha,
      Value<String?> proveedor,
      Value<double> total,
      Value<String?> nota,
    });
typedef $$TablaComprasTableUpdateCompanionBuilder =
    TablaComprasCompanion Function({
      Value<int> id,
      Value<DateTime> fecha,
      Value<String?> proveedor,
      Value<double> total,
      Value<String?> nota,
    });

final class $$TablaComprasTableReferences
    extends BaseReferences<_$BaseDeDatos, $TablaComprasTable, TablaCompra> {
  $$TablaComprasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $TablaLineasCompraTable,
    List<TablaLineasCompraData>
  >
  _tablaLineasCompraRefsTable(_$BaseDeDatos db) =>
      MultiTypedResultKey.fromTable(
        db.tablaLineasCompra,
        aliasName: $_aliasNameGenerator(
          db.tablaCompras.id,
          db.tablaLineasCompra.compraId,
        ),
      );

  $$TablaLineasCompraTableProcessedTableManager get tablaLineasCompraRefs {
    final manager = $$TablaLineasCompraTableTableManager(
      $_db,
      $_db.tablaLineasCompra,
    ).filter((f) => f.compraId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _tablaLineasCompraRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TablaComprasTableFilterComposer
    extends Composer<_$BaseDeDatos, $TablaComprasTable> {
  $$TablaComprasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get proveedor => $composableBuilder(
    column: $table.proveedor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nota => $composableBuilder(
    column: $table.nota,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> tablaLineasCompraRefs(
    Expression<bool> Function($$TablaLineasCompraTableFilterComposer f) f,
  ) {
    final $$TablaLineasCompraTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tablaLineasCompra,
      getReferencedColumn: (t) => t.compraId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaLineasCompraTableFilterComposer(
            $db: $db,
            $table: $db.tablaLineasCompra,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TablaComprasTableOrderingComposer
    extends Composer<_$BaseDeDatos, $TablaComprasTable> {
  $$TablaComprasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get proveedor => $composableBuilder(
    column: $table.proveedor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nota => $composableBuilder(
    column: $table.nota,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TablaComprasTableAnnotationComposer
    extends Composer<_$BaseDeDatos, $TablaComprasTable> {
  $$TablaComprasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<String> get proveedor =>
      $composableBuilder(column: $table.proveedor, builder: (column) => column);

  GeneratedColumn<double> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<String> get nota =>
      $composableBuilder(column: $table.nota, builder: (column) => column);

  Expression<T> tablaLineasCompraRefs<T extends Object>(
    Expression<T> Function($$TablaLineasCompraTableAnnotationComposer a) f,
  ) {
    final $$TablaLineasCompraTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.tablaLineasCompra,
          getReferencedColumn: (t) => t.compraId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TablaLineasCompraTableAnnotationComposer(
                $db: $db,
                $table: $db.tablaLineasCompra,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$TablaComprasTableTableManager
    extends
        RootTableManager<
          _$BaseDeDatos,
          $TablaComprasTable,
          TablaCompra,
          $$TablaComprasTableFilterComposer,
          $$TablaComprasTableOrderingComposer,
          $$TablaComprasTableAnnotationComposer,
          $$TablaComprasTableCreateCompanionBuilder,
          $$TablaComprasTableUpdateCompanionBuilder,
          (TablaCompra, $$TablaComprasTableReferences),
          TablaCompra,
          PrefetchHooks Function({bool tablaLineasCompraRefs})
        > {
  $$TablaComprasTableTableManager(_$BaseDeDatos db, $TablaComprasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TablaComprasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TablaComprasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TablaComprasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
                Value<String?> proveedor = const Value.absent(),
                Value<double> total = const Value.absent(),
                Value<String?> nota = const Value.absent(),
              }) => TablaComprasCompanion(
                id: id,
                fecha: fecha,
                proveedor: proveedor,
                total: total,
                nota: nota,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
                Value<String?> proveedor = const Value.absent(),
                Value<double> total = const Value.absent(),
                Value<String?> nota = const Value.absent(),
              }) => TablaComprasCompanion.insert(
                id: id,
                fecha: fecha,
                proveedor: proveedor,
                total: total,
                nota: nota,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TablaComprasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({tablaLineasCompraRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (tablaLineasCompraRefs) db.tablaLineasCompra,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tablaLineasCompraRefs)
                    await $_getPrefetchedData<
                      TablaCompra,
                      $TablaComprasTable,
                      TablaLineasCompraData
                    >(
                      currentTable: table,
                      referencedTable: $$TablaComprasTableReferences
                          ._tablaLineasCompraRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TablaComprasTableReferences(
                            db,
                            table,
                            p0,
                          ).tablaLineasCompraRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.compraId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TablaComprasTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDeDatos,
      $TablaComprasTable,
      TablaCompra,
      $$TablaComprasTableFilterComposer,
      $$TablaComprasTableOrderingComposer,
      $$TablaComprasTableAnnotationComposer,
      $$TablaComprasTableCreateCompanionBuilder,
      $$TablaComprasTableUpdateCompanionBuilder,
      (TablaCompra, $$TablaComprasTableReferences),
      TablaCompra,
      PrefetchHooks Function({bool tablaLineasCompraRefs})
    >;
typedef $$TablaLineasCompraTableCreateCompanionBuilder =
    TablaLineasCompraCompanion Function({
      Value<int> id,
      required int compraId,
      required int productoId,
      required double cantidad,
      Value<double> costoUnitario,
      Value<double> subtotal,
    });
typedef $$TablaLineasCompraTableUpdateCompanionBuilder =
    TablaLineasCompraCompanion Function({
      Value<int> id,
      Value<int> compraId,
      Value<int> productoId,
      Value<double> cantidad,
      Value<double> costoUnitario,
      Value<double> subtotal,
    });

final class $$TablaLineasCompraTableReferences
    extends
        BaseReferences<
          _$BaseDeDatos,
          $TablaLineasCompraTable,
          TablaLineasCompraData
        > {
  $$TablaLineasCompraTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TablaComprasTable _compraIdTable(_$BaseDeDatos db) =>
      db.tablaCompras.createAlias(
        $_aliasNameGenerator(db.tablaLineasCompra.compraId, db.tablaCompras.id),
      );

  $$TablaComprasTableProcessedTableManager get compraId {
    final $_column = $_itemColumn<int>('compra_id')!;

    final manager = $$TablaComprasTableTableManager(
      $_db,
      $_db.tablaCompras,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_compraIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TablaProductosTable _productoIdTable(_$BaseDeDatos db) =>
      db.tablaProductos.createAlias(
        $_aliasNameGenerator(
          db.tablaLineasCompra.productoId,
          db.tablaProductos.id,
        ),
      );

  $$TablaProductosTableProcessedTableManager get productoId {
    final $_column = $_itemColumn<int>('producto_id')!;

    final manager = $$TablaProductosTableTableManager(
      $_db,
      $_db.tablaProductos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TablaLineasCompraTableFilterComposer
    extends Composer<_$BaseDeDatos, $TablaLineasCompraTable> {
  $$TablaLineasCompraTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cantidad => $composableBuilder(
    column: $table.cantidad,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get costoUnitario => $composableBuilder(
    column: $table.costoUnitario,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnFilters(column),
  );

  $$TablaComprasTableFilterComposer get compraId {
    final $$TablaComprasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.compraId,
      referencedTable: $db.tablaCompras,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaComprasTableFilterComposer(
            $db: $db,
            $table: $db.tablaCompras,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TablaProductosTableFilterComposer get productoId {
    final $$TablaProductosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productoId,
      referencedTable: $db.tablaProductos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaProductosTableFilterComposer(
            $db: $db,
            $table: $db.tablaProductos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TablaLineasCompraTableOrderingComposer
    extends Composer<_$BaseDeDatos, $TablaLineasCompraTable> {
  $$TablaLineasCompraTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cantidad => $composableBuilder(
    column: $table.cantidad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get costoUnitario => $composableBuilder(
    column: $table.costoUnitario,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnOrderings(column),
  );

  $$TablaComprasTableOrderingComposer get compraId {
    final $$TablaComprasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.compraId,
      referencedTable: $db.tablaCompras,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaComprasTableOrderingComposer(
            $db: $db,
            $table: $db.tablaCompras,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TablaProductosTableOrderingComposer get productoId {
    final $$TablaProductosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productoId,
      referencedTable: $db.tablaProductos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaProductosTableOrderingComposer(
            $db: $db,
            $table: $db.tablaProductos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TablaLineasCompraTableAnnotationComposer
    extends Composer<_$BaseDeDatos, $TablaLineasCompraTable> {
  $$TablaLineasCompraTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get cantidad =>
      $composableBuilder(column: $table.cantidad, builder: (column) => column);

  GeneratedColumn<double> get costoUnitario => $composableBuilder(
    column: $table.costoUnitario,
    builder: (column) => column,
  );

  GeneratedColumn<double> get subtotal =>
      $composableBuilder(column: $table.subtotal, builder: (column) => column);

  $$TablaComprasTableAnnotationComposer get compraId {
    final $$TablaComprasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.compraId,
      referencedTable: $db.tablaCompras,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaComprasTableAnnotationComposer(
            $db: $db,
            $table: $db.tablaCompras,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TablaProductosTableAnnotationComposer get productoId {
    final $$TablaProductosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productoId,
      referencedTable: $db.tablaProductos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaProductosTableAnnotationComposer(
            $db: $db,
            $table: $db.tablaProductos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TablaLineasCompraTableTableManager
    extends
        RootTableManager<
          _$BaseDeDatos,
          $TablaLineasCompraTable,
          TablaLineasCompraData,
          $$TablaLineasCompraTableFilterComposer,
          $$TablaLineasCompraTableOrderingComposer,
          $$TablaLineasCompraTableAnnotationComposer,
          $$TablaLineasCompraTableCreateCompanionBuilder,
          $$TablaLineasCompraTableUpdateCompanionBuilder,
          (TablaLineasCompraData, $$TablaLineasCompraTableReferences),
          TablaLineasCompraData,
          PrefetchHooks Function({bool compraId, bool productoId})
        > {
  $$TablaLineasCompraTableTableManager(
    _$BaseDeDatos db,
    $TablaLineasCompraTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TablaLineasCompraTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TablaLineasCompraTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TablaLineasCompraTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> compraId = const Value.absent(),
                Value<int> productoId = const Value.absent(),
                Value<double> cantidad = const Value.absent(),
                Value<double> costoUnitario = const Value.absent(),
                Value<double> subtotal = const Value.absent(),
              }) => TablaLineasCompraCompanion(
                id: id,
                compraId: compraId,
                productoId: productoId,
                cantidad: cantidad,
                costoUnitario: costoUnitario,
                subtotal: subtotal,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int compraId,
                required int productoId,
                required double cantidad,
                Value<double> costoUnitario = const Value.absent(),
                Value<double> subtotal = const Value.absent(),
              }) => TablaLineasCompraCompanion.insert(
                id: id,
                compraId: compraId,
                productoId: productoId,
                cantidad: cantidad,
                costoUnitario: costoUnitario,
                subtotal: subtotal,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TablaLineasCompraTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({compraId = false, productoId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (compraId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.compraId,
                                referencedTable:
                                    $$TablaLineasCompraTableReferences
                                        ._compraIdTable(db),
                                referencedColumn:
                                    $$TablaLineasCompraTableReferences
                                        ._compraIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (productoId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.productoId,
                                referencedTable:
                                    $$TablaLineasCompraTableReferences
                                        ._productoIdTable(db),
                                referencedColumn:
                                    $$TablaLineasCompraTableReferences
                                        ._productoIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TablaLineasCompraTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDeDatos,
      $TablaLineasCompraTable,
      TablaLineasCompraData,
      $$TablaLineasCompraTableFilterComposer,
      $$TablaLineasCompraTableOrderingComposer,
      $$TablaLineasCompraTableAnnotationComposer,
      $$TablaLineasCompraTableCreateCompanionBuilder,
      $$TablaLineasCompraTableUpdateCompanionBuilder,
      (TablaLineasCompraData, $$TablaLineasCompraTableReferences),
      TablaLineasCompraData,
      PrefetchHooks Function({bool compraId, bool productoId})
    >;

class $BaseDeDatosManager {
  final _$BaseDeDatos _db;
  $BaseDeDatosManager(this._db);
  $$TablaProductosTableTableManager get tablaProductos =>
      $$TablaProductosTableTableManager(_db, _db.tablaProductos);
  $$TablaMovimientosTableTableManager get tablaMovimientos =>
      $$TablaMovimientosTableTableManager(_db, _db.tablaMovimientos);
  $$TablaCombosTableTableManager get tablaCombos =>
      $$TablaCombosTableTableManager(_db, _db.tablaCombos);
  $$TablaComponentesTableTableManager get tablaComponentes =>
      $$TablaComponentesTableTableManager(_db, _db.tablaComponentes);
  $$TablaVentasTableTableManager get tablaVentas =>
      $$TablaVentasTableTableManager(_db, _db.tablaVentas);
  $$TablaLineasVentaTableTableManager get tablaLineasVenta =>
      $$TablaLineasVentaTableTableManager(_db, _db.tablaLineasVenta);
  $$TablaComprasTableTableManager get tablaCompras =>
      $$TablaComprasTableTableManager(_db, _db.tablaCompras);
  $$TablaLineasCompraTableTableManager get tablaLineasCompra =>
      $$TablaLineasCompraTableTableManager(_db, _db.tablaLineasCompra);
}
