// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_de_datos.dart';

// ignore_for_file: type=lint
class $TablaInstitucionesTable extends TablaInstituciones
    with TableInfo<$TablaInstitucionesTable, TablaInstitucione> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TablaInstitucionesTable(this.attachedDatabase, [this._alias]);
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
      maxTextLength: 180,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  List<GeneratedColumn> get $columns => [id, nombre, activo, creadoEn];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tabla_instituciones';
  @override
  VerificationContext validateIntegrity(
    Insertable<TablaInstitucione> instance, {
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
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {nombre},
  ];
  @override
  TablaInstitucione map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TablaInstitucione(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
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
  $TablaInstitucionesTable createAlias(String alias) {
    return $TablaInstitucionesTable(attachedDatabase, alias);
  }
}

class TablaInstitucione extends DataClass
    implements Insertable<TablaInstitucione> {
  final int id;
  final String nombre;
  final bool activo;
  final DateTime creadoEn;
  const TablaInstitucione({
    required this.id,
    required this.nombre,
    required this.activo,
    required this.creadoEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nombre'] = Variable<String>(nombre);
    map['activo'] = Variable<bool>(activo);
    map['creado_en'] = Variable<DateTime>(creadoEn);
    return map;
  }

  TablaInstitucionesCompanion toCompanion(bool nullToAbsent) {
    return TablaInstitucionesCompanion(
      id: Value(id),
      nombre: Value(nombre),
      activo: Value(activo),
      creadoEn: Value(creadoEn),
    );
  }

  factory TablaInstitucione.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TablaInstitucione(
      id: serializer.fromJson<int>(json['id']),
      nombre: serializer.fromJson<String>(json['nombre']),
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
      'activo': serializer.toJson<bool>(activo),
      'creadoEn': serializer.toJson<DateTime>(creadoEn),
    };
  }

  TablaInstitucione copyWith({
    int? id,
    String? nombre,
    bool? activo,
    DateTime? creadoEn,
  }) => TablaInstitucione(
    id: id ?? this.id,
    nombre: nombre ?? this.nombre,
    activo: activo ?? this.activo,
    creadoEn: creadoEn ?? this.creadoEn,
  );
  TablaInstitucione copyWithCompanion(TablaInstitucionesCompanion data) {
    return TablaInstitucione(
      id: data.id.present ? data.id.value : this.id,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      activo: data.activo.present ? data.activo.value : this.activo,
      creadoEn: data.creadoEn.present ? data.creadoEn.value : this.creadoEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TablaInstitucione(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('activo: $activo, ')
          ..write('creadoEn: $creadoEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nombre, activo, creadoEn);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TablaInstitucione &&
          other.id == this.id &&
          other.nombre == this.nombre &&
          other.activo == this.activo &&
          other.creadoEn == this.creadoEn);
}

class TablaInstitucionesCompanion extends UpdateCompanion<TablaInstitucione> {
  final Value<int> id;
  final Value<String> nombre;
  final Value<bool> activo;
  final Value<DateTime> creadoEn;
  const TablaInstitucionesCompanion({
    this.id = const Value.absent(),
    this.nombre = const Value.absent(),
    this.activo = const Value.absent(),
    this.creadoEn = const Value.absent(),
  });
  TablaInstitucionesCompanion.insert({
    this.id = const Value.absent(),
    required String nombre,
    this.activo = const Value.absent(),
    this.creadoEn = const Value.absent(),
  }) : nombre = Value(nombre);
  static Insertable<TablaInstitucione> custom({
    Expression<int>? id,
    Expression<String>? nombre,
    Expression<bool>? activo,
    Expression<DateTime>? creadoEn,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombre != null) 'nombre': nombre,
      if (activo != null) 'activo': activo,
      if (creadoEn != null) 'creado_en': creadoEn,
    });
  }

  TablaInstitucionesCompanion copyWith({
    Value<int>? id,
    Value<String>? nombre,
    Value<bool>? activo,
    Value<DateTime>? creadoEn,
  }) {
    return TablaInstitucionesCompanion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
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
    return (StringBuffer('TablaInstitucionesCompanion(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('activo: $activo, ')
          ..write('creadoEn: $creadoEn')
          ..write(')'))
        .toString();
  }
}

class $TablaCarrerasTable extends TablaCarreras
    with TableInfo<$TablaCarrerasTable, TablaCarrera> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TablaCarrerasTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _institucionIdMeta = const VerificationMeta(
    'institucionId',
  );
  @override
  late final GeneratedColumn<int> institucionId = GeneratedColumn<int>(
    'institucion_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tabla_instituciones (id) ON DELETE CASCADE',
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
      maxTextLength: 160,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    institucionId,
    nombre,
    activo,
    creadoEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tabla_carreras';
  @override
  VerificationContext validateIntegrity(
    Insertable<TablaCarrera> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('institucion_id')) {
      context.handle(
        _institucionIdMeta,
        institucionId.isAcceptableOrUnknown(
          data['institucion_id']!,
          _institucionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_institucionIdMeta);
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
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
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {institucionId, nombre},
  ];
  @override
  TablaCarrera map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TablaCarrera(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      institucionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}institucion_id'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
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
  $TablaCarrerasTable createAlias(String alias) {
    return $TablaCarrerasTable(attachedDatabase, alias);
  }
}

class TablaCarrera extends DataClass implements Insertable<TablaCarrera> {
  final int id;
  final int institucionId;
  final String nombre;
  final bool activo;
  final DateTime creadoEn;
  const TablaCarrera({
    required this.id,
    required this.institucionId,
    required this.nombre,
    required this.activo,
    required this.creadoEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['institucion_id'] = Variable<int>(institucionId);
    map['nombre'] = Variable<String>(nombre);
    map['activo'] = Variable<bool>(activo);
    map['creado_en'] = Variable<DateTime>(creadoEn);
    return map;
  }

  TablaCarrerasCompanion toCompanion(bool nullToAbsent) {
    return TablaCarrerasCompanion(
      id: Value(id),
      institucionId: Value(institucionId),
      nombre: Value(nombre),
      activo: Value(activo),
      creadoEn: Value(creadoEn),
    );
  }

  factory TablaCarrera.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TablaCarrera(
      id: serializer.fromJson<int>(json['id']),
      institucionId: serializer.fromJson<int>(json['institucionId']),
      nombre: serializer.fromJson<String>(json['nombre']),
      activo: serializer.fromJson<bool>(json['activo']),
      creadoEn: serializer.fromJson<DateTime>(json['creadoEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'institucionId': serializer.toJson<int>(institucionId),
      'nombre': serializer.toJson<String>(nombre),
      'activo': serializer.toJson<bool>(activo),
      'creadoEn': serializer.toJson<DateTime>(creadoEn),
    };
  }

  TablaCarrera copyWith({
    int? id,
    int? institucionId,
    String? nombre,
    bool? activo,
    DateTime? creadoEn,
  }) => TablaCarrera(
    id: id ?? this.id,
    institucionId: institucionId ?? this.institucionId,
    nombre: nombre ?? this.nombre,
    activo: activo ?? this.activo,
    creadoEn: creadoEn ?? this.creadoEn,
  );
  TablaCarrera copyWithCompanion(TablaCarrerasCompanion data) {
    return TablaCarrera(
      id: data.id.present ? data.id.value : this.id,
      institucionId: data.institucionId.present
          ? data.institucionId.value
          : this.institucionId,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      activo: data.activo.present ? data.activo.value : this.activo,
      creadoEn: data.creadoEn.present ? data.creadoEn.value : this.creadoEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TablaCarrera(')
          ..write('id: $id, ')
          ..write('institucionId: $institucionId, ')
          ..write('nombre: $nombre, ')
          ..write('activo: $activo, ')
          ..write('creadoEn: $creadoEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, institucionId, nombre, activo, creadoEn);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TablaCarrera &&
          other.id == this.id &&
          other.institucionId == this.institucionId &&
          other.nombre == this.nombre &&
          other.activo == this.activo &&
          other.creadoEn == this.creadoEn);
}

class TablaCarrerasCompanion extends UpdateCompanion<TablaCarrera> {
  final Value<int> id;
  final Value<int> institucionId;
  final Value<String> nombre;
  final Value<bool> activo;
  final Value<DateTime> creadoEn;
  const TablaCarrerasCompanion({
    this.id = const Value.absent(),
    this.institucionId = const Value.absent(),
    this.nombre = const Value.absent(),
    this.activo = const Value.absent(),
    this.creadoEn = const Value.absent(),
  });
  TablaCarrerasCompanion.insert({
    this.id = const Value.absent(),
    required int institucionId,
    required String nombre,
    this.activo = const Value.absent(),
    this.creadoEn = const Value.absent(),
  }) : institucionId = Value(institucionId),
       nombre = Value(nombre);
  static Insertable<TablaCarrera> custom({
    Expression<int>? id,
    Expression<int>? institucionId,
    Expression<String>? nombre,
    Expression<bool>? activo,
    Expression<DateTime>? creadoEn,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (institucionId != null) 'institucion_id': institucionId,
      if (nombre != null) 'nombre': nombre,
      if (activo != null) 'activo': activo,
      if (creadoEn != null) 'creado_en': creadoEn,
    });
  }

  TablaCarrerasCompanion copyWith({
    Value<int>? id,
    Value<int>? institucionId,
    Value<String>? nombre,
    Value<bool>? activo,
    Value<DateTime>? creadoEn,
  }) {
    return TablaCarrerasCompanion(
      id: id ?? this.id,
      institucionId: institucionId ?? this.institucionId,
      nombre: nombre ?? this.nombre,
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
    if (institucionId.present) {
      map['institucion_id'] = Variable<int>(institucionId.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
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
    return (StringBuffer('TablaCarrerasCompanion(')
          ..write('id: $id, ')
          ..write('institucionId: $institucionId, ')
          ..write('nombre: $nombre, ')
          ..write('activo: $activo, ')
          ..write('creadoEn: $creadoEn')
          ..write(')'))
        .toString();
  }
}

class $TablaAlumnosTable extends TablaAlumnos
    with TableInfo<$TablaAlumnosTable, TablaAlumno> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TablaAlumnosTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _apellidoMeta = const VerificationMeta(
    'apellido',
  );
  @override
  late final GeneratedColumn<String> apellido = GeneratedColumn<String>(
    'apellido',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _edadMeta = const VerificationMeta('edad');
  @override
  late final GeneratedColumn<int> edad = GeneratedColumn<int>(
    'edad',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _documentoMeta = const VerificationMeta(
    'documento',
  );
  @override
  late final GeneratedColumn<String> documento = GeneratedColumn<String>(
    'documento',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 30,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _telefonoMeta = const VerificationMeta(
    'telefono',
  );
  @override
  late final GeneratedColumn<String> telefono = GeneratedColumn<String>(
    'telefono',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 40,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fotoPathMeta = const VerificationMeta(
    'fotoPath',
  );
  @override
  late final GeneratedColumn<String> fotoPath = GeneratedColumn<String>(
    'foto_path',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 500,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _institucionIdMeta = const VerificationMeta(
    'institucionId',
  );
  @override
  late final GeneratedColumn<int> institucionId = GeneratedColumn<int>(
    'institucion_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tabla_instituciones (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _carreraIdMeta = const VerificationMeta(
    'carreraId',
  );
  @override
  late final GeneratedColumn<int> carreraId = GeneratedColumn<int>(
    'carrera_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tabla_carreras (id) ON DELETE SET NULL',
    ),
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
    apellido,
    nombre,
    edad,
    documento,
    email,
    telefono,
    fotoPath,
    institucionId,
    carreraId,
    activo,
    creadoEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tabla_alumnos';
  @override
  VerificationContext validateIntegrity(
    Insertable<TablaAlumno> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('apellido')) {
      context.handle(
        _apellidoMeta,
        apellido.isAcceptableOrUnknown(data['apellido']!, _apellidoMeta),
      );
    } else if (isInserting) {
      context.missing(_apellidoMeta);
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('edad')) {
      context.handle(
        _edadMeta,
        edad.isAcceptableOrUnknown(data['edad']!, _edadMeta),
      );
    }
    if (data.containsKey('documento')) {
      context.handle(
        _documentoMeta,
        documento.isAcceptableOrUnknown(data['documento']!, _documentoMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('telefono')) {
      context.handle(
        _telefonoMeta,
        telefono.isAcceptableOrUnknown(data['telefono']!, _telefonoMeta),
      );
    }
    if (data.containsKey('foto_path')) {
      context.handle(
        _fotoPathMeta,
        fotoPath.isAcceptableOrUnknown(data['foto_path']!, _fotoPathMeta),
      );
    }
    if (data.containsKey('institucion_id')) {
      context.handle(
        _institucionIdMeta,
        institucionId.isAcceptableOrUnknown(
          data['institucion_id']!,
          _institucionIdMeta,
        ),
      );
    }
    if (data.containsKey('carrera_id')) {
      context.handle(
        _carreraIdMeta,
        carreraId.isAcceptableOrUnknown(data['carrera_id']!, _carreraIdMeta),
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
  TablaAlumno map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TablaAlumno(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      apellido: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}apellido'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      edad: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}edad'],
      ),
      documento: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}documento'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      telefono: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}telefono'],
      ),
      fotoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}foto_path'],
      ),
      institucionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}institucion_id'],
      ),
      carreraId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}carrera_id'],
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
  $TablaAlumnosTable createAlias(String alias) {
    return $TablaAlumnosTable(attachedDatabase, alias);
  }
}

class TablaAlumno extends DataClass implements Insertable<TablaAlumno> {
  final int id;
  final String apellido;
  final String nombre;
  final int? edad;
  final String? documento;
  final String? email;
  final String? telefono;
  final String? fotoPath;
  final int? institucionId;
  final int? carreraId;
  final bool activo;
  final DateTime creadoEn;
  const TablaAlumno({
    required this.id,
    required this.apellido,
    required this.nombre,
    this.edad,
    this.documento,
    this.email,
    this.telefono,
    this.fotoPath,
    this.institucionId,
    this.carreraId,
    required this.activo,
    required this.creadoEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['apellido'] = Variable<String>(apellido);
    map['nombre'] = Variable<String>(nombre);
    if (!nullToAbsent || edad != null) {
      map['edad'] = Variable<int>(edad);
    }
    if (!nullToAbsent || documento != null) {
      map['documento'] = Variable<String>(documento);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || telefono != null) {
      map['telefono'] = Variable<String>(telefono);
    }
    if (!nullToAbsent || fotoPath != null) {
      map['foto_path'] = Variable<String>(fotoPath);
    }
    if (!nullToAbsent || institucionId != null) {
      map['institucion_id'] = Variable<int>(institucionId);
    }
    if (!nullToAbsent || carreraId != null) {
      map['carrera_id'] = Variable<int>(carreraId);
    }
    map['activo'] = Variable<bool>(activo);
    map['creado_en'] = Variable<DateTime>(creadoEn);
    return map;
  }

  TablaAlumnosCompanion toCompanion(bool nullToAbsent) {
    return TablaAlumnosCompanion(
      id: Value(id),
      apellido: Value(apellido),
      nombre: Value(nombre),
      edad: edad == null && nullToAbsent ? const Value.absent() : Value(edad),
      documento: documento == null && nullToAbsent
          ? const Value.absent()
          : Value(documento),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      telefono: telefono == null && nullToAbsent
          ? const Value.absent()
          : Value(telefono),
      fotoPath: fotoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(fotoPath),
      institucionId: institucionId == null && nullToAbsent
          ? const Value.absent()
          : Value(institucionId),
      carreraId: carreraId == null && nullToAbsent
          ? const Value.absent()
          : Value(carreraId),
      activo: Value(activo),
      creadoEn: Value(creadoEn),
    );
  }

  factory TablaAlumno.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TablaAlumno(
      id: serializer.fromJson<int>(json['id']),
      apellido: serializer.fromJson<String>(json['apellido']),
      nombre: serializer.fromJson<String>(json['nombre']),
      edad: serializer.fromJson<int?>(json['edad']),
      documento: serializer.fromJson<String?>(json['documento']),
      email: serializer.fromJson<String?>(json['email']),
      telefono: serializer.fromJson<String?>(json['telefono']),
      fotoPath: serializer.fromJson<String?>(json['fotoPath']),
      institucionId: serializer.fromJson<int?>(json['institucionId']),
      carreraId: serializer.fromJson<int?>(json['carreraId']),
      activo: serializer.fromJson<bool>(json['activo']),
      creadoEn: serializer.fromJson<DateTime>(json['creadoEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'apellido': serializer.toJson<String>(apellido),
      'nombre': serializer.toJson<String>(nombre),
      'edad': serializer.toJson<int?>(edad),
      'documento': serializer.toJson<String?>(documento),
      'email': serializer.toJson<String?>(email),
      'telefono': serializer.toJson<String?>(telefono),
      'fotoPath': serializer.toJson<String?>(fotoPath),
      'institucionId': serializer.toJson<int?>(institucionId),
      'carreraId': serializer.toJson<int?>(carreraId),
      'activo': serializer.toJson<bool>(activo),
      'creadoEn': serializer.toJson<DateTime>(creadoEn),
    };
  }

  TablaAlumno copyWith({
    int? id,
    String? apellido,
    String? nombre,
    Value<int?> edad = const Value.absent(),
    Value<String?> documento = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> telefono = const Value.absent(),
    Value<String?> fotoPath = const Value.absent(),
    Value<int?> institucionId = const Value.absent(),
    Value<int?> carreraId = const Value.absent(),
    bool? activo,
    DateTime? creadoEn,
  }) => TablaAlumno(
    id: id ?? this.id,
    apellido: apellido ?? this.apellido,
    nombre: nombre ?? this.nombre,
    edad: edad.present ? edad.value : this.edad,
    documento: documento.present ? documento.value : this.documento,
    email: email.present ? email.value : this.email,
    telefono: telefono.present ? telefono.value : this.telefono,
    fotoPath: fotoPath.present ? fotoPath.value : this.fotoPath,
    institucionId: institucionId.present
        ? institucionId.value
        : this.institucionId,
    carreraId: carreraId.present ? carreraId.value : this.carreraId,
    activo: activo ?? this.activo,
    creadoEn: creadoEn ?? this.creadoEn,
  );
  TablaAlumno copyWithCompanion(TablaAlumnosCompanion data) {
    return TablaAlumno(
      id: data.id.present ? data.id.value : this.id,
      apellido: data.apellido.present ? data.apellido.value : this.apellido,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      edad: data.edad.present ? data.edad.value : this.edad,
      documento: data.documento.present ? data.documento.value : this.documento,
      email: data.email.present ? data.email.value : this.email,
      telefono: data.telefono.present ? data.telefono.value : this.telefono,
      fotoPath: data.fotoPath.present ? data.fotoPath.value : this.fotoPath,
      institucionId: data.institucionId.present
          ? data.institucionId.value
          : this.institucionId,
      carreraId: data.carreraId.present ? data.carreraId.value : this.carreraId,
      activo: data.activo.present ? data.activo.value : this.activo,
      creadoEn: data.creadoEn.present ? data.creadoEn.value : this.creadoEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TablaAlumno(')
          ..write('id: $id, ')
          ..write('apellido: $apellido, ')
          ..write('nombre: $nombre, ')
          ..write('edad: $edad, ')
          ..write('documento: $documento, ')
          ..write('email: $email, ')
          ..write('telefono: $telefono, ')
          ..write('fotoPath: $fotoPath, ')
          ..write('institucionId: $institucionId, ')
          ..write('carreraId: $carreraId, ')
          ..write('activo: $activo, ')
          ..write('creadoEn: $creadoEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    apellido,
    nombre,
    edad,
    documento,
    email,
    telefono,
    fotoPath,
    institucionId,
    carreraId,
    activo,
    creadoEn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TablaAlumno &&
          other.id == this.id &&
          other.apellido == this.apellido &&
          other.nombre == this.nombre &&
          other.edad == this.edad &&
          other.documento == this.documento &&
          other.email == this.email &&
          other.telefono == this.telefono &&
          other.fotoPath == this.fotoPath &&
          other.institucionId == this.institucionId &&
          other.carreraId == this.carreraId &&
          other.activo == this.activo &&
          other.creadoEn == this.creadoEn);
}

class TablaAlumnosCompanion extends UpdateCompanion<TablaAlumno> {
  final Value<int> id;
  final Value<String> apellido;
  final Value<String> nombre;
  final Value<int?> edad;
  final Value<String?> documento;
  final Value<String?> email;
  final Value<String?> telefono;
  final Value<String?> fotoPath;
  final Value<int?> institucionId;
  final Value<int?> carreraId;
  final Value<bool> activo;
  final Value<DateTime> creadoEn;
  const TablaAlumnosCompanion({
    this.id = const Value.absent(),
    this.apellido = const Value.absent(),
    this.nombre = const Value.absent(),
    this.edad = const Value.absent(),
    this.documento = const Value.absent(),
    this.email = const Value.absent(),
    this.telefono = const Value.absent(),
    this.fotoPath = const Value.absent(),
    this.institucionId = const Value.absent(),
    this.carreraId = const Value.absent(),
    this.activo = const Value.absent(),
    this.creadoEn = const Value.absent(),
  });
  TablaAlumnosCompanion.insert({
    this.id = const Value.absent(),
    required String apellido,
    required String nombre,
    this.edad = const Value.absent(),
    this.documento = const Value.absent(),
    this.email = const Value.absent(),
    this.telefono = const Value.absent(),
    this.fotoPath = const Value.absent(),
    this.institucionId = const Value.absent(),
    this.carreraId = const Value.absent(),
    this.activo = const Value.absent(),
    this.creadoEn = const Value.absent(),
  }) : apellido = Value(apellido),
       nombre = Value(nombre);
  static Insertable<TablaAlumno> custom({
    Expression<int>? id,
    Expression<String>? apellido,
    Expression<String>? nombre,
    Expression<int>? edad,
    Expression<String>? documento,
    Expression<String>? email,
    Expression<String>? telefono,
    Expression<String>? fotoPath,
    Expression<int>? institucionId,
    Expression<int>? carreraId,
    Expression<bool>? activo,
    Expression<DateTime>? creadoEn,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (apellido != null) 'apellido': apellido,
      if (nombre != null) 'nombre': nombre,
      if (edad != null) 'edad': edad,
      if (documento != null) 'documento': documento,
      if (email != null) 'email': email,
      if (telefono != null) 'telefono': telefono,
      if (fotoPath != null) 'foto_path': fotoPath,
      if (institucionId != null) 'institucion_id': institucionId,
      if (carreraId != null) 'carrera_id': carreraId,
      if (activo != null) 'activo': activo,
      if (creadoEn != null) 'creado_en': creadoEn,
    });
  }

  TablaAlumnosCompanion copyWith({
    Value<int>? id,
    Value<String>? apellido,
    Value<String>? nombre,
    Value<int?>? edad,
    Value<String?>? documento,
    Value<String?>? email,
    Value<String?>? telefono,
    Value<String?>? fotoPath,
    Value<int?>? institucionId,
    Value<int?>? carreraId,
    Value<bool>? activo,
    Value<DateTime>? creadoEn,
  }) {
    return TablaAlumnosCompanion(
      id: id ?? this.id,
      apellido: apellido ?? this.apellido,
      nombre: nombre ?? this.nombre,
      edad: edad ?? this.edad,
      documento: documento ?? this.documento,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      fotoPath: fotoPath ?? this.fotoPath,
      institucionId: institucionId ?? this.institucionId,
      carreraId: carreraId ?? this.carreraId,
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
    if (apellido.present) {
      map['apellido'] = Variable<String>(apellido.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (edad.present) {
      map['edad'] = Variable<int>(edad.value);
    }
    if (documento.present) {
      map['documento'] = Variable<String>(documento.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (telefono.present) {
      map['telefono'] = Variable<String>(telefono.value);
    }
    if (fotoPath.present) {
      map['foto_path'] = Variable<String>(fotoPath.value);
    }
    if (institucionId.present) {
      map['institucion_id'] = Variable<int>(institucionId.value);
    }
    if (carreraId.present) {
      map['carrera_id'] = Variable<int>(carreraId.value);
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
    return (StringBuffer('TablaAlumnosCompanion(')
          ..write('id: $id, ')
          ..write('apellido: $apellido, ')
          ..write('nombre: $nombre, ')
          ..write('edad: $edad, ')
          ..write('documento: $documento, ')
          ..write('email: $email, ')
          ..write('telefono: $telefono, ')
          ..write('fotoPath: $fotoPath, ')
          ..write('institucionId: $institucionId, ')
          ..write('carreraId: $carreraId, ')
          ..write('activo: $activo, ')
          ..write('creadoEn: $creadoEn')
          ..write(')'))
        .toString();
  }
}

class $TablaMateriasTable extends TablaMaterias
    with TableInfo<$TablaMateriasTable, TablaMateria> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TablaMateriasTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _carreraIdMeta = const VerificationMeta(
    'carreraId',
  );
  @override
  late final GeneratedColumn<int> carreraId = GeneratedColumn<int>(
    'carrera_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tabla_carreras (id) ON DELETE CASCADE',
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
      maxTextLength: 140,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _anioCursadaMeta = const VerificationMeta(
    'anioCursada',
  );
  @override
  late final GeneratedColumn<int> anioCursada = GeneratedColumn<int>(
    'anio_cursada',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cursoMeta = const VerificationMeta('curso');
  @override
  late final GeneratedColumn<String> curso = GeneratedColumn<String>(
    'curso',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 4,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    carreraId,
    nombre,
    anioCursada,
    curso,
    activo,
    creadoEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tabla_materias';
  @override
  VerificationContext validateIntegrity(
    Insertable<TablaMateria> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('carrera_id')) {
      context.handle(
        _carreraIdMeta,
        carreraId.isAcceptableOrUnknown(data['carrera_id']!, _carreraIdMeta),
      );
    } else if (isInserting) {
      context.missing(_carreraIdMeta);
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('anio_cursada')) {
      context.handle(
        _anioCursadaMeta,
        anioCursada.isAcceptableOrUnknown(
          data['anio_cursada']!,
          _anioCursadaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_anioCursadaMeta);
    }
    if (data.containsKey('curso')) {
      context.handle(
        _cursoMeta,
        curso.isAcceptableOrUnknown(data['curso']!, _cursoMeta),
      );
    } else if (isInserting) {
      context.missing(_cursoMeta);
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
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {carreraId, nombre, anioCursada, curso},
  ];
  @override
  TablaMateria map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TablaMateria(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      carreraId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}carrera_id'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      anioCursada: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}anio_cursada'],
      )!,
      curso: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}curso'],
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
  $TablaMateriasTable createAlias(String alias) {
    return $TablaMateriasTable(attachedDatabase, alias);
  }
}

class TablaMateria extends DataClass implements Insertable<TablaMateria> {
  final int id;
  final int carreraId;
  final String nombre;
  final int anioCursada;
  final String curso;
  final bool activo;
  final DateTime creadoEn;
  const TablaMateria({
    required this.id,
    required this.carreraId,
    required this.nombre,
    required this.anioCursada,
    required this.curso,
    required this.activo,
    required this.creadoEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['carrera_id'] = Variable<int>(carreraId);
    map['nombre'] = Variable<String>(nombre);
    map['anio_cursada'] = Variable<int>(anioCursada);
    map['curso'] = Variable<String>(curso);
    map['activo'] = Variable<bool>(activo);
    map['creado_en'] = Variable<DateTime>(creadoEn);
    return map;
  }

  TablaMateriasCompanion toCompanion(bool nullToAbsent) {
    return TablaMateriasCompanion(
      id: Value(id),
      carreraId: Value(carreraId),
      nombre: Value(nombre),
      anioCursada: Value(anioCursada),
      curso: Value(curso),
      activo: Value(activo),
      creadoEn: Value(creadoEn),
    );
  }

  factory TablaMateria.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TablaMateria(
      id: serializer.fromJson<int>(json['id']),
      carreraId: serializer.fromJson<int>(json['carreraId']),
      nombre: serializer.fromJson<String>(json['nombre']),
      anioCursada: serializer.fromJson<int>(json['anioCursada']),
      curso: serializer.fromJson<String>(json['curso']),
      activo: serializer.fromJson<bool>(json['activo']),
      creadoEn: serializer.fromJson<DateTime>(json['creadoEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'carreraId': serializer.toJson<int>(carreraId),
      'nombre': serializer.toJson<String>(nombre),
      'anioCursada': serializer.toJson<int>(anioCursada),
      'curso': serializer.toJson<String>(curso),
      'activo': serializer.toJson<bool>(activo),
      'creadoEn': serializer.toJson<DateTime>(creadoEn),
    };
  }

  TablaMateria copyWith({
    int? id,
    int? carreraId,
    String? nombre,
    int? anioCursada,
    String? curso,
    bool? activo,
    DateTime? creadoEn,
  }) => TablaMateria(
    id: id ?? this.id,
    carreraId: carreraId ?? this.carreraId,
    nombre: nombre ?? this.nombre,
    anioCursada: anioCursada ?? this.anioCursada,
    curso: curso ?? this.curso,
    activo: activo ?? this.activo,
    creadoEn: creadoEn ?? this.creadoEn,
  );
  TablaMateria copyWithCompanion(TablaMateriasCompanion data) {
    return TablaMateria(
      id: data.id.present ? data.id.value : this.id,
      carreraId: data.carreraId.present ? data.carreraId.value : this.carreraId,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      anioCursada: data.anioCursada.present
          ? data.anioCursada.value
          : this.anioCursada,
      curso: data.curso.present ? data.curso.value : this.curso,
      activo: data.activo.present ? data.activo.value : this.activo,
      creadoEn: data.creadoEn.present ? data.creadoEn.value : this.creadoEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TablaMateria(')
          ..write('id: $id, ')
          ..write('carreraId: $carreraId, ')
          ..write('nombre: $nombre, ')
          ..write('anioCursada: $anioCursada, ')
          ..write('curso: $curso, ')
          ..write('activo: $activo, ')
          ..write('creadoEn: $creadoEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, carreraId, nombre, anioCursada, curso, activo, creadoEn);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TablaMateria &&
          other.id == this.id &&
          other.carreraId == this.carreraId &&
          other.nombre == this.nombre &&
          other.anioCursada == this.anioCursada &&
          other.curso == this.curso &&
          other.activo == this.activo &&
          other.creadoEn == this.creadoEn);
}

class TablaMateriasCompanion extends UpdateCompanion<TablaMateria> {
  final Value<int> id;
  final Value<int> carreraId;
  final Value<String> nombre;
  final Value<int> anioCursada;
  final Value<String> curso;
  final Value<bool> activo;
  final Value<DateTime> creadoEn;
  const TablaMateriasCompanion({
    this.id = const Value.absent(),
    this.carreraId = const Value.absent(),
    this.nombre = const Value.absent(),
    this.anioCursada = const Value.absent(),
    this.curso = const Value.absent(),
    this.activo = const Value.absent(),
    this.creadoEn = const Value.absent(),
  });
  TablaMateriasCompanion.insert({
    this.id = const Value.absent(),
    required int carreraId,
    required String nombre,
    required int anioCursada,
    required String curso,
    this.activo = const Value.absent(),
    this.creadoEn = const Value.absent(),
  }) : carreraId = Value(carreraId),
       nombre = Value(nombre),
       anioCursada = Value(anioCursada),
       curso = Value(curso);
  static Insertable<TablaMateria> custom({
    Expression<int>? id,
    Expression<int>? carreraId,
    Expression<String>? nombre,
    Expression<int>? anioCursada,
    Expression<String>? curso,
    Expression<bool>? activo,
    Expression<DateTime>? creadoEn,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (carreraId != null) 'carrera_id': carreraId,
      if (nombre != null) 'nombre': nombre,
      if (anioCursada != null) 'anio_cursada': anioCursada,
      if (curso != null) 'curso': curso,
      if (activo != null) 'activo': activo,
      if (creadoEn != null) 'creado_en': creadoEn,
    });
  }

  TablaMateriasCompanion copyWith({
    Value<int>? id,
    Value<int>? carreraId,
    Value<String>? nombre,
    Value<int>? anioCursada,
    Value<String>? curso,
    Value<bool>? activo,
    Value<DateTime>? creadoEn,
  }) {
    return TablaMateriasCompanion(
      id: id ?? this.id,
      carreraId: carreraId ?? this.carreraId,
      nombre: nombre ?? this.nombre,
      anioCursada: anioCursada ?? this.anioCursada,
      curso: curso ?? this.curso,
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
    if (carreraId.present) {
      map['carrera_id'] = Variable<int>(carreraId.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (anioCursada.present) {
      map['anio_cursada'] = Variable<int>(anioCursada.value);
    }
    if (curso.present) {
      map['curso'] = Variable<String>(curso.value);
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
    return (StringBuffer('TablaMateriasCompanion(')
          ..write('id: $id, ')
          ..write('carreraId: $carreraId, ')
          ..write('nombre: $nombre, ')
          ..write('anioCursada: $anioCursada, ')
          ..write('curso: $curso, ')
          ..write('activo: $activo, ')
          ..write('creadoEn: $creadoEn')
          ..write(')'))
        .toString();
  }
}

class $TablaCursosTable extends TablaCursos
    with TableInfo<$TablaCursosTable, TablaCurso> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TablaCursosTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _divisionMeta = const VerificationMeta(
    'division',
  );
  @override
  late final GeneratedColumn<String> division = GeneratedColumn<String>(
    'division',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 40,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _materiaMeta = const VerificationMeta(
    'materia',
  );
  @override
  late final GeneratedColumn<String> materia = GeneratedColumn<String>(
    'materia',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _turnoMeta = const VerificationMeta('turno');
  @override
  late final GeneratedColumn<String> turno = GeneratedColumn<String>(
    'turno',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 40,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _anioMeta = const VerificationMeta('anio');
  @override
  late final GeneratedColumn<int> anio = GeneratedColumn<int>(
    'anio',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _institucionIdMeta = const VerificationMeta(
    'institucionId',
  );
  @override
  late final GeneratedColumn<int> institucionId = GeneratedColumn<int>(
    'institucion_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tabla_instituciones (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _carreraIdMeta = const VerificationMeta(
    'carreraId',
  );
  @override
  late final GeneratedColumn<int> carreraId = GeneratedColumn<int>(
    'carrera_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tabla_carreras (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _materiaIdMeta = const VerificationMeta(
    'materiaId',
  );
  @override
  late final GeneratedColumn<int> materiaId = GeneratedColumn<int>(
    'materia_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tabla_materias (id) ON DELETE SET NULL',
    ),
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
    division,
    materia,
    turno,
    anio,
    institucionId,
    carreraId,
    materiaId,
    activo,
    creadoEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tabla_cursos';
  @override
  VerificationContext validateIntegrity(
    Insertable<TablaCurso> instance, {
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
    if (data.containsKey('division')) {
      context.handle(
        _divisionMeta,
        division.isAcceptableOrUnknown(data['division']!, _divisionMeta),
      );
    }
    if (data.containsKey('materia')) {
      context.handle(
        _materiaMeta,
        materia.isAcceptableOrUnknown(data['materia']!, _materiaMeta),
      );
    }
    if (data.containsKey('turno')) {
      context.handle(
        _turnoMeta,
        turno.isAcceptableOrUnknown(data['turno']!, _turnoMeta),
      );
    }
    if (data.containsKey('anio')) {
      context.handle(
        _anioMeta,
        anio.isAcceptableOrUnknown(data['anio']!, _anioMeta),
      );
    }
    if (data.containsKey('institucion_id')) {
      context.handle(
        _institucionIdMeta,
        institucionId.isAcceptableOrUnknown(
          data['institucion_id']!,
          _institucionIdMeta,
        ),
      );
    }
    if (data.containsKey('carrera_id')) {
      context.handle(
        _carreraIdMeta,
        carreraId.isAcceptableOrUnknown(data['carrera_id']!, _carreraIdMeta),
      );
    }
    if (data.containsKey('materia_id')) {
      context.handle(
        _materiaIdMeta,
        materiaId.isAcceptableOrUnknown(data['materia_id']!, _materiaIdMeta),
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
  TablaCurso map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TablaCurso(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      division: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}division'],
      ),
      materia: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}materia'],
      ),
      turno: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}turno'],
      ),
      anio: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}anio'],
      ),
      institucionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}institucion_id'],
      ),
      carreraId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}carrera_id'],
      ),
      materiaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}materia_id'],
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
  $TablaCursosTable createAlias(String alias) {
    return $TablaCursosTable(attachedDatabase, alias);
  }
}

class TablaCurso extends DataClass implements Insertable<TablaCurso> {
  final int id;
  final String nombre;
  final String? division;
  final String? materia;
  final String? turno;
  final int? anio;
  final int? institucionId;
  final int? carreraId;
  final int? materiaId;
  final bool activo;
  final DateTime creadoEn;
  const TablaCurso({
    required this.id,
    required this.nombre,
    this.division,
    this.materia,
    this.turno,
    this.anio,
    this.institucionId,
    this.carreraId,
    this.materiaId,
    required this.activo,
    required this.creadoEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nombre'] = Variable<String>(nombre);
    if (!nullToAbsent || division != null) {
      map['division'] = Variable<String>(division);
    }
    if (!nullToAbsent || materia != null) {
      map['materia'] = Variable<String>(materia);
    }
    if (!nullToAbsent || turno != null) {
      map['turno'] = Variable<String>(turno);
    }
    if (!nullToAbsent || anio != null) {
      map['anio'] = Variable<int>(anio);
    }
    if (!nullToAbsent || institucionId != null) {
      map['institucion_id'] = Variable<int>(institucionId);
    }
    if (!nullToAbsent || carreraId != null) {
      map['carrera_id'] = Variable<int>(carreraId);
    }
    if (!nullToAbsent || materiaId != null) {
      map['materia_id'] = Variable<int>(materiaId);
    }
    map['activo'] = Variable<bool>(activo);
    map['creado_en'] = Variable<DateTime>(creadoEn);
    return map;
  }

  TablaCursosCompanion toCompanion(bool nullToAbsent) {
    return TablaCursosCompanion(
      id: Value(id),
      nombre: Value(nombre),
      division: division == null && nullToAbsent
          ? const Value.absent()
          : Value(division),
      materia: materia == null && nullToAbsent
          ? const Value.absent()
          : Value(materia),
      turno: turno == null && nullToAbsent
          ? const Value.absent()
          : Value(turno),
      anio: anio == null && nullToAbsent ? const Value.absent() : Value(anio),
      institucionId: institucionId == null && nullToAbsent
          ? const Value.absent()
          : Value(institucionId),
      carreraId: carreraId == null && nullToAbsent
          ? const Value.absent()
          : Value(carreraId),
      materiaId: materiaId == null && nullToAbsent
          ? const Value.absent()
          : Value(materiaId),
      activo: Value(activo),
      creadoEn: Value(creadoEn),
    );
  }

  factory TablaCurso.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TablaCurso(
      id: serializer.fromJson<int>(json['id']),
      nombre: serializer.fromJson<String>(json['nombre']),
      division: serializer.fromJson<String?>(json['division']),
      materia: serializer.fromJson<String?>(json['materia']),
      turno: serializer.fromJson<String?>(json['turno']),
      anio: serializer.fromJson<int?>(json['anio']),
      institucionId: serializer.fromJson<int?>(json['institucionId']),
      carreraId: serializer.fromJson<int?>(json['carreraId']),
      materiaId: serializer.fromJson<int?>(json['materiaId']),
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
      'division': serializer.toJson<String?>(division),
      'materia': serializer.toJson<String?>(materia),
      'turno': serializer.toJson<String?>(turno),
      'anio': serializer.toJson<int?>(anio),
      'institucionId': serializer.toJson<int?>(institucionId),
      'carreraId': serializer.toJson<int?>(carreraId),
      'materiaId': serializer.toJson<int?>(materiaId),
      'activo': serializer.toJson<bool>(activo),
      'creadoEn': serializer.toJson<DateTime>(creadoEn),
    };
  }

  TablaCurso copyWith({
    int? id,
    String? nombre,
    Value<String?> division = const Value.absent(),
    Value<String?> materia = const Value.absent(),
    Value<String?> turno = const Value.absent(),
    Value<int?> anio = const Value.absent(),
    Value<int?> institucionId = const Value.absent(),
    Value<int?> carreraId = const Value.absent(),
    Value<int?> materiaId = const Value.absent(),
    bool? activo,
    DateTime? creadoEn,
  }) => TablaCurso(
    id: id ?? this.id,
    nombre: nombre ?? this.nombre,
    division: division.present ? division.value : this.division,
    materia: materia.present ? materia.value : this.materia,
    turno: turno.present ? turno.value : this.turno,
    anio: anio.present ? anio.value : this.anio,
    institucionId: institucionId.present
        ? institucionId.value
        : this.institucionId,
    carreraId: carreraId.present ? carreraId.value : this.carreraId,
    materiaId: materiaId.present ? materiaId.value : this.materiaId,
    activo: activo ?? this.activo,
    creadoEn: creadoEn ?? this.creadoEn,
  );
  TablaCurso copyWithCompanion(TablaCursosCompanion data) {
    return TablaCurso(
      id: data.id.present ? data.id.value : this.id,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      division: data.division.present ? data.division.value : this.division,
      materia: data.materia.present ? data.materia.value : this.materia,
      turno: data.turno.present ? data.turno.value : this.turno,
      anio: data.anio.present ? data.anio.value : this.anio,
      institucionId: data.institucionId.present
          ? data.institucionId.value
          : this.institucionId,
      carreraId: data.carreraId.present ? data.carreraId.value : this.carreraId,
      materiaId: data.materiaId.present ? data.materiaId.value : this.materiaId,
      activo: data.activo.present ? data.activo.value : this.activo,
      creadoEn: data.creadoEn.present ? data.creadoEn.value : this.creadoEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TablaCurso(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('division: $division, ')
          ..write('materia: $materia, ')
          ..write('turno: $turno, ')
          ..write('anio: $anio, ')
          ..write('institucionId: $institucionId, ')
          ..write('carreraId: $carreraId, ')
          ..write('materiaId: $materiaId, ')
          ..write('activo: $activo, ')
          ..write('creadoEn: $creadoEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nombre,
    division,
    materia,
    turno,
    anio,
    institucionId,
    carreraId,
    materiaId,
    activo,
    creadoEn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TablaCurso &&
          other.id == this.id &&
          other.nombre == this.nombre &&
          other.division == this.division &&
          other.materia == this.materia &&
          other.turno == this.turno &&
          other.anio == this.anio &&
          other.institucionId == this.institucionId &&
          other.carreraId == this.carreraId &&
          other.materiaId == this.materiaId &&
          other.activo == this.activo &&
          other.creadoEn == this.creadoEn);
}

class TablaCursosCompanion extends UpdateCompanion<TablaCurso> {
  final Value<int> id;
  final Value<String> nombre;
  final Value<String?> division;
  final Value<String?> materia;
  final Value<String?> turno;
  final Value<int?> anio;
  final Value<int?> institucionId;
  final Value<int?> carreraId;
  final Value<int?> materiaId;
  final Value<bool> activo;
  final Value<DateTime> creadoEn;
  const TablaCursosCompanion({
    this.id = const Value.absent(),
    this.nombre = const Value.absent(),
    this.division = const Value.absent(),
    this.materia = const Value.absent(),
    this.turno = const Value.absent(),
    this.anio = const Value.absent(),
    this.institucionId = const Value.absent(),
    this.carreraId = const Value.absent(),
    this.materiaId = const Value.absent(),
    this.activo = const Value.absent(),
    this.creadoEn = const Value.absent(),
  });
  TablaCursosCompanion.insert({
    this.id = const Value.absent(),
    required String nombre,
    this.division = const Value.absent(),
    this.materia = const Value.absent(),
    this.turno = const Value.absent(),
    this.anio = const Value.absent(),
    this.institucionId = const Value.absent(),
    this.carreraId = const Value.absent(),
    this.materiaId = const Value.absent(),
    this.activo = const Value.absent(),
    this.creadoEn = const Value.absent(),
  }) : nombre = Value(nombre);
  static Insertable<TablaCurso> custom({
    Expression<int>? id,
    Expression<String>? nombre,
    Expression<String>? division,
    Expression<String>? materia,
    Expression<String>? turno,
    Expression<int>? anio,
    Expression<int>? institucionId,
    Expression<int>? carreraId,
    Expression<int>? materiaId,
    Expression<bool>? activo,
    Expression<DateTime>? creadoEn,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombre != null) 'nombre': nombre,
      if (division != null) 'division': division,
      if (materia != null) 'materia': materia,
      if (turno != null) 'turno': turno,
      if (anio != null) 'anio': anio,
      if (institucionId != null) 'institucion_id': institucionId,
      if (carreraId != null) 'carrera_id': carreraId,
      if (materiaId != null) 'materia_id': materiaId,
      if (activo != null) 'activo': activo,
      if (creadoEn != null) 'creado_en': creadoEn,
    });
  }

  TablaCursosCompanion copyWith({
    Value<int>? id,
    Value<String>? nombre,
    Value<String?>? division,
    Value<String?>? materia,
    Value<String?>? turno,
    Value<int?>? anio,
    Value<int?>? institucionId,
    Value<int?>? carreraId,
    Value<int?>? materiaId,
    Value<bool>? activo,
    Value<DateTime>? creadoEn,
  }) {
    return TablaCursosCompanion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      division: division ?? this.division,
      materia: materia ?? this.materia,
      turno: turno ?? this.turno,
      anio: anio ?? this.anio,
      institucionId: institucionId ?? this.institucionId,
      carreraId: carreraId ?? this.carreraId,
      materiaId: materiaId ?? this.materiaId,
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
    if (division.present) {
      map['division'] = Variable<String>(division.value);
    }
    if (materia.present) {
      map['materia'] = Variable<String>(materia.value);
    }
    if (turno.present) {
      map['turno'] = Variable<String>(turno.value);
    }
    if (anio.present) {
      map['anio'] = Variable<int>(anio.value);
    }
    if (institucionId.present) {
      map['institucion_id'] = Variable<int>(institucionId.value);
    }
    if (carreraId.present) {
      map['carrera_id'] = Variable<int>(carreraId.value);
    }
    if (materiaId.present) {
      map['materia_id'] = Variable<int>(materiaId.value);
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
    return (StringBuffer('TablaCursosCompanion(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('division: $division, ')
          ..write('materia: $materia, ')
          ..write('turno: $turno, ')
          ..write('anio: $anio, ')
          ..write('institucionId: $institucionId, ')
          ..write('carreraId: $carreraId, ')
          ..write('materiaId: $materiaId, ')
          ..write('activo: $activo, ')
          ..write('creadoEn: $creadoEn')
          ..write(')'))
        .toString();
  }
}

class $TablaInscripcionesTable extends TablaInscripciones
    with TableInfo<$TablaInscripcionesTable, TablaInscripcione> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TablaInscripcionesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _alumnoIdMeta = const VerificationMeta(
    'alumnoId',
  );
  @override
  late final GeneratedColumn<int> alumnoId = GeneratedColumn<int>(
    'alumno_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tabla_alumnos (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _cursoIdMeta = const VerificationMeta(
    'cursoId',
  );
  @override
  late final GeneratedColumn<int> cursoId = GeneratedColumn<int>(
    'curso_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tabla_cursos (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _fechaAltaMeta = const VerificationMeta(
    'fechaAlta',
  );
  @override
  late final GeneratedColumn<DateTime> fechaAlta = GeneratedColumn<DateTime>(
    'fecha_alta',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    alumnoId,
    cursoId,
    fechaAlta,
    activo,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tabla_inscripciones';
  @override
  VerificationContext validateIntegrity(
    Insertable<TablaInscripcione> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('alumno_id')) {
      context.handle(
        _alumnoIdMeta,
        alumnoId.isAcceptableOrUnknown(data['alumno_id']!, _alumnoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_alumnoIdMeta);
    }
    if (data.containsKey('curso_id')) {
      context.handle(
        _cursoIdMeta,
        cursoId.isAcceptableOrUnknown(data['curso_id']!, _cursoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cursoIdMeta);
    }
    if (data.containsKey('fecha_alta')) {
      context.handle(
        _fechaAltaMeta,
        fechaAlta.isAcceptableOrUnknown(data['fecha_alta']!, _fechaAltaMeta),
      );
    }
    if (data.containsKey('activo')) {
      context.handle(
        _activoMeta,
        activo.isAcceptableOrUnknown(data['activo']!, _activoMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {alumnoId, cursoId},
  ];
  @override
  TablaInscripcione map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TablaInscripcione(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      alumnoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}alumno_id'],
      )!,
      cursoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}curso_id'],
      )!,
      fechaAlta: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha_alta'],
      )!,
      activo: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}activo'],
      )!,
    );
  }

  @override
  $TablaInscripcionesTable createAlias(String alias) {
    return $TablaInscripcionesTable(attachedDatabase, alias);
  }
}

class TablaInscripcione extends DataClass
    implements Insertable<TablaInscripcione> {
  final int id;
  final int alumnoId;
  final int cursoId;
  final DateTime fechaAlta;
  final bool activo;
  const TablaInscripcione({
    required this.id,
    required this.alumnoId,
    required this.cursoId,
    required this.fechaAlta,
    required this.activo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['alumno_id'] = Variable<int>(alumnoId);
    map['curso_id'] = Variable<int>(cursoId);
    map['fecha_alta'] = Variable<DateTime>(fechaAlta);
    map['activo'] = Variable<bool>(activo);
    return map;
  }

  TablaInscripcionesCompanion toCompanion(bool nullToAbsent) {
    return TablaInscripcionesCompanion(
      id: Value(id),
      alumnoId: Value(alumnoId),
      cursoId: Value(cursoId),
      fechaAlta: Value(fechaAlta),
      activo: Value(activo),
    );
  }

  factory TablaInscripcione.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TablaInscripcione(
      id: serializer.fromJson<int>(json['id']),
      alumnoId: serializer.fromJson<int>(json['alumnoId']),
      cursoId: serializer.fromJson<int>(json['cursoId']),
      fechaAlta: serializer.fromJson<DateTime>(json['fechaAlta']),
      activo: serializer.fromJson<bool>(json['activo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'alumnoId': serializer.toJson<int>(alumnoId),
      'cursoId': serializer.toJson<int>(cursoId),
      'fechaAlta': serializer.toJson<DateTime>(fechaAlta),
      'activo': serializer.toJson<bool>(activo),
    };
  }

  TablaInscripcione copyWith({
    int? id,
    int? alumnoId,
    int? cursoId,
    DateTime? fechaAlta,
    bool? activo,
  }) => TablaInscripcione(
    id: id ?? this.id,
    alumnoId: alumnoId ?? this.alumnoId,
    cursoId: cursoId ?? this.cursoId,
    fechaAlta: fechaAlta ?? this.fechaAlta,
    activo: activo ?? this.activo,
  );
  TablaInscripcione copyWithCompanion(TablaInscripcionesCompanion data) {
    return TablaInscripcione(
      id: data.id.present ? data.id.value : this.id,
      alumnoId: data.alumnoId.present ? data.alumnoId.value : this.alumnoId,
      cursoId: data.cursoId.present ? data.cursoId.value : this.cursoId,
      fechaAlta: data.fechaAlta.present ? data.fechaAlta.value : this.fechaAlta,
      activo: data.activo.present ? data.activo.value : this.activo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TablaInscripcione(')
          ..write('id: $id, ')
          ..write('alumnoId: $alumnoId, ')
          ..write('cursoId: $cursoId, ')
          ..write('fechaAlta: $fechaAlta, ')
          ..write('activo: $activo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, alumnoId, cursoId, fechaAlta, activo);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TablaInscripcione &&
          other.id == this.id &&
          other.alumnoId == this.alumnoId &&
          other.cursoId == this.cursoId &&
          other.fechaAlta == this.fechaAlta &&
          other.activo == this.activo);
}

class TablaInscripcionesCompanion extends UpdateCompanion<TablaInscripcione> {
  final Value<int> id;
  final Value<int> alumnoId;
  final Value<int> cursoId;
  final Value<DateTime> fechaAlta;
  final Value<bool> activo;
  const TablaInscripcionesCompanion({
    this.id = const Value.absent(),
    this.alumnoId = const Value.absent(),
    this.cursoId = const Value.absent(),
    this.fechaAlta = const Value.absent(),
    this.activo = const Value.absent(),
  });
  TablaInscripcionesCompanion.insert({
    this.id = const Value.absent(),
    required int alumnoId,
    required int cursoId,
    this.fechaAlta = const Value.absent(),
    this.activo = const Value.absent(),
  }) : alumnoId = Value(alumnoId),
       cursoId = Value(cursoId);
  static Insertable<TablaInscripcione> custom({
    Expression<int>? id,
    Expression<int>? alumnoId,
    Expression<int>? cursoId,
    Expression<DateTime>? fechaAlta,
    Expression<bool>? activo,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (alumnoId != null) 'alumno_id': alumnoId,
      if (cursoId != null) 'curso_id': cursoId,
      if (fechaAlta != null) 'fecha_alta': fechaAlta,
      if (activo != null) 'activo': activo,
    });
  }

  TablaInscripcionesCompanion copyWith({
    Value<int>? id,
    Value<int>? alumnoId,
    Value<int>? cursoId,
    Value<DateTime>? fechaAlta,
    Value<bool>? activo,
  }) {
    return TablaInscripcionesCompanion(
      id: id ?? this.id,
      alumnoId: alumnoId ?? this.alumnoId,
      cursoId: cursoId ?? this.cursoId,
      fechaAlta: fechaAlta ?? this.fechaAlta,
      activo: activo ?? this.activo,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (alumnoId.present) {
      map['alumno_id'] = Variable<int>(alumnoId.value);
    }
    if (cursoId.present) {
      map['curso_id'] = Variable<int>(cursoId.value);
    }
    if (fechaAlta.present) {
      map['fecha_alta'] = Variable<DateTime>(fechaAlta.value);
    }
    if (activo.present) {
      map['activo'] = Variable<bool>(activo.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TablaInscripcionesCompanion(')
          ..write('id: $id, ')
          ..write('alumnoId: $alumnoId, ')
          ..write('cursoId: $cursoId, ')
          ..write('fechaAlta: $fechaAlta, ')
          ..write('activo: $activo')
          ..write(')'))
        .toString();
  }
}

class $TablaClasesTable extends TablaClases
    with TableInfo<$TablaClasesTable, TablaClase> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TablaClasesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _cursoIdMeta = const VerificationMeta(
    'cursoId',
  );
  @override
  late final GeneratedColumn<int> cursoId = GeneratedColumn<int>(
    'curso_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tabla_cursos (id) ON DELETE CASCADE',
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
  static const VerificationMeta _temaMeta = const VerificationMeta('tema');
  @override
  late final GeneratedColumn<String> tema = GeneratedColumn<String>(
    'tema',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _observacionMeta = const VerificationMeta(
    'observacion',
  );
  @override
  late final GeneratedColumn<String> observacion = GeneratedColumn<String>(
    'observacion',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 250,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actividadDiaMeta = const VerificationMeta(
    'actividadDia',
  );
  @override
  late final GeneratedColumn<String> actividadDia = GeneratedColumn<String>(
    'actividad_dia',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 400,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cursoId,
    fecha,
    tema,
    observacion,
    actividadDia,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tabla_clases';
  @override
  VerificationContext validateIntegrity(
    Insertable<TablaClase> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('curso_id')) {
      context.handle(
        _cursoIdMeta,
        cursoId.isAcceptableOrUnknown(data['curso_id']!, _cursoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cursoIdMeta);
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    }
    if (data.containsKey('tema')) {
      context.handle(
        _temaMeta,
        tema.isAcceptableOrUnknown(data['tema']!, _temaMeta),
      );
    }
    if (data.containsKey('observacion')) {
      context.handle(
        _observacionMeta,
        observacion.isAcceptableOrUnknown(
          data['observacion']!,
          _observacionMeta,
        ),
      );
    }
    if (data.containsKey('actividad_dia')) {
      context.handle(
        _actividadDiaMeta,
        actividadDia.isAcceptableOrUnknown(
          data['actividad_dia']!,
          _actividadDiaMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TablaClase map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TablaClase(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cursoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}curso_id'],
      )!,
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha'],
      )!,
      tema: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tema'],
      ),
      observacion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observacion'],
      ),
      actividadDia: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actividad_dia'],
      ),
    );
  }

  @override
  $TablaClasesTable createAlias(String alias) {
    return $TablaClasesTable(attachedDatabase, alias);
  }
}

class TablaClase extends DataClass implements Insertable<TablaClase> {
  final int id;
  final int cursoId;
  final DateTime fecha;
  final String? tema;
  final String? observacion;
  final String? actividadDia;
  const TablaClase({
    required this.id,
    required this.cursoId,
    required this.fecha,
    this.tema,
    this.observacion,
    this.actividadDia,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['curso_id'] = Variable<int>(cursoId);
    map['fecha'] = Variable<DateTime>(fecha);
    if (!nullToAbsent || tema != null) {
      map['tema'] = Variable<String>(tema);
    }
    if (!nullToAbsent || observacion != null) {
      map['observacion'] = Variable<String>(observacion);
    }
    if (!nullToAbsent || actividadDia != null) {
      map['actividad_dia'] = Variable<String>(actividadDia);
    }
    return map;
  }

  TablaClasesCompanion toCompanion(bool nullToAbsent) {
    return TablaClasesCompanion(
      id: Value(id),
      cursoId: Value(cursoId),
      fecha: Value(fecha),
      tema: tema == null && nullToAbsent ? const Value.absent() : Value(tema),
      observacion: observacion == null && nullToAbsent
          ? const Value.absent()
          : Value(observacion),
      actividadDia: actividadDia == null && nullToAbsent
          ? const Value.absent()
          : Value(actividadDia),
    );
  }

  factory TablaClase.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TablaClase(
      id: serializer.fromJson<int>(json['id']),
      cursoId: serializer.fromJson<int>(json['cursoId']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
      tema: serializer.fromJson<String?>(json['tema']),
      observacion: serializer.fromJson<String?>(json['observacion']),
      actividadDia: serializer.fromJson<String?>(json['actividadDia']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cursoId': serializer.toJson<int>(cursoId),
      'fecha': serializer.toJson<DateTime>(fecha),
      'tema': serializer.toJson<String?>(tema),
      'observacion': serializer.toJson<String?>(observacion),
      'actividadDia': serializer.toJson<String?>(actividadDia),
    };
  }

  TablaClase copyWith({
    int? id,
    int? cursoId,
    DateTime? fecha,
    Value<String?> tema = const Value.absent(),
    Value<String?> observacion = const Value.absent(),
    Value<String?> actividadDia = const Value.absent(),
  }) => TablaClase(
    id: id ?? this.id,
    cursoId: cursoId ?? this.cursoId,
    fecha: fecha ?? this.fecha,
    tema: tema.present ? tema.value : this.tema,
    observacion: observacion.present ? observacion.value : this.observacion,
    actividadDia: actividadDia.present ? actividadDia.value : this.actividadDia,
  );
  TablaClase copyWithCompanion(TablaClasesCompanion data) {
    return TablaClase(
      id: data.id.present ? data.id.value : this.id,
      cursoId: data.cursoId.present ? data.cursoId.value : this.cursoId,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      tema: data.tema.present ? data.tema.value : this.tema,
      observacion: data.observacion.present
          ? data.observacion.value
          : this.observacion,
      actividadDia: data.actividadDia.present
          ? data.actividadDia.value
          : this.actividadDia,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TablaClase(')
          ..write('id: $id, ')
          ..write('cursoId: $cursoId, ')
          ..write('fecha: $fecha, ')
          ..write('tema: $tema, ')
          ..write('observacion: $observacion, ')
          ..write('actividadDia: $actividadDia')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, cursoId, fecha, tema, observacion, actividadDia);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TablaClase &&
          other.id == this.id &&
          other.cursoId == this.cursoId &&
          other.fecha == this.fecha &&
          other.tema == this.tema &&
          other.observacion == this.observacion &&
          other.actividadDia == this.actividadDia);
}

class TablaClasesCompanion extends UpdateCompanion<TablaClase> {
  final Value<int> id;
  final Value<int> cursoId;
  final Value<DateTime> fecha;
  final Value<String?> tema;
  final Value<String?> observacion;
  final Value<String?> actividadDia;
  const TablaClasesCompanion({
    this.id = const Value.absent(),
    this.cursoId = const Value.absent(),
    this.fecha = const Value.absent(),
    this.tema = const Value.absent(),
    this.observacion = const Value.absent(),
    this.actividadDia = const Value.absent(),
  });
  TablaClasesCompanion.insert({
    this.id = const Value.absent(),
    required int cursoId,
    this.fecha = const Value.absent(),
    this.tema = const Value.absent(),
    this.observacion = const Value.absent(),
    this.actividadDia = const Value.absent(),
  }) : cursoId = Value(cursoId);
  static Insertable<TablaClase> custom({
    Expression<int>? id,
    Expression<int>? cursoId,
    Expression<DateTime>? fecha,
    Expression<String>? tema,
    Expression<String>? observacion,
    Expression<String>? actividadDia,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cursoId != null) 'curso_id': cursoId,
      if (fecha != null) 'fecha': fecha,
      if (tema != null) 'tema': tema,
      if (observacion != null) 'observacion': observacion,
      if (actividadDia != null) 'actividad_dia': actividadDia,
    });
  }

  TablaClasesCompanion copyWith({
    Value<int>? id,
    Value<int>? cursoId,
    Value<DateTime>? fecha,
    Value<String?>? tema,
    Value<String?>? observacion,
    Value<String?>? actividadDia,
  }) {
    return TablaClasesCompanion(
      id: id ?? this.id,
      cursoId: cursoId ?? this.cursoId,
      fecha: fecha ?? this.fecha,
      tema: tema ?? this.tema,
      observacion: observacion ?? this.observacion,
      actividadDia: actividadDia ?? this.actividadDia,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cursoId.present) {
      map['curso_id'] = Variable<int>(cursoId.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (tema.present) {
      map['tema'] = Variable<String>(tema.value);
    }
    if (observacion.present) {
      map['observacion'] = Variable<String>(observacion.value);
    }
    if (actividadDia.present) {
      map['actividad_dia'] = Variable<String>(actividadDia.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TablaClasesCompanion(')
          ..write('id: $id, ')
          ..write('cursoId: $cursoId, ')
          ..write('fecha: $fecha, ')
          ..write('tema: $tema, ')
          ..write('observacion: $observacion, ')
          ..write('actividadDia: $actividadDia')
          ..write(')'))
        .toString();
  }
}

class $TablaAsistenciasTable extends TablaAsistencias
    with TableInfo<$TablaAsistenciasTable, TablaAsistencia> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TablaAsistenciasTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _claseIdMeta = const VerificationMeta(
    'claseId',
  );
  @override
  late final GeneratedColumn<int> claseId = GeneratedColumn<int>(
    'clase_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tabla_clases (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _alumnoIdMeta = const VerificationMeta(
    'alumnoId',
  );
  @override
  late final GeneratedColumn<int> alumnoId = GeneratedColumn<int>(
    'alumno_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tabla_alumnos (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
    'estado',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('presente'),
  );
  static const VerificationMeta _observacionMeta = const VerificationMeta(
    'observacion',
  );
  @override
  late final GeneratedColumn<String> observacion = GeneratedColumn<String>(
    'observacion',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 250,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _justificadaMeta = const VerificationMeta(
    'justificada',
  );
  @override
  late final GeneratedColumn<bool> justificada = GeneratedColumn<bool>(
    'justificada',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("justificada" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _detalleJustificacionMeta =
      const VerificationMeta('detalleJustificacion');
  @override
  late final GeneratedColumn<String> detalleJustificacion =
      GeneratedColumn<String>(
        'detalle_justificacion',
        aliasedName,
        true,
        additionalChecks: GeneratedColumn.checkTextLength(
          minTextLength: 0,
          maxTextLength: 500,
        ),
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _actividadEntregadaMeta =
      const VerificationMeta('actividadEntregada');
  @override
  late final GeneratedColumn<bool> actividadEntregada = GeneratedColumn<bool>(
    'actividad_entregada',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("actividad_entregada" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notaActividadMeta = const VerificationMeta(
    'notaActividad',
  );
  @override
  late final GeneratedColumn<String> notaActividad = GeneratedColumn<String>(
    'nota_actividad',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _detalleActividadMeta = const VerificationMeta(
    'detalleActividad',
  );
  @override
  late final GeneratedColumn<String> detalleActividad = GeneratedColumn<String>(
    'detalle_actividad',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 500,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _registradoEnMeta = const VerificationMeta(
    'registradoEn',
  );
  @override
  late final GeneratedColumn<DateTime> registradoEn = GeneratedColumn<DateTime>(
    'registrado_en',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    claseId,
    alumnoId,
    estado,
    observacion,
    justificada,
    detalleJustificacion,
    actividadEntregada,
    notaActividad,
    detalleActividad,
    registradoEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tabla_asistencias';
  @override
  VerificationContext validateIntegrity(
    Insertable<TablaAsistencia> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('clase_id')) {
      context.handle(
        _claseIdMeta,
        claseId.isAcceptableOrUnknown(data['clase_id']!, _claseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_claseIdMeta);
    }
    if (data.containsKey('alumno_id')) {
      context.handle(
        _alumnoIdMeta,
        alumnoId.isAcceptableOrUnknown(data['alumno_id']!, _alumnoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_alumnoIdMeta);
    }
    if (data.containsKey('estado')) {
      context.handle(
        _estadoMeta,
        estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta),
      );
    }
    if (data.containsKey('observacion')) {
      context.handle(
        _observacionMeta,
        observacion.isAcceptableOrUnknown(
          data['observacion']!,
          _observacionMeta,
        ),
      );
    }
    if (data.containsKey('justificada')) {
      context.handle(
        _justificadaMeta,
        justificada.isAcceptableOrUnknown(
          data['justificada']!,
          _justificadaMeta,
        ),
      );
    }
    if (data.containsKey('detalle_justificacion')) {
      context.handle(
        _detalleJustificacionMeta,
        detalleJustificacion.isAcceptableOrUnknown(
          data['detalle_justificacion']!,
          _detalleJustificacionMeta,
        ),
      );
    }
    if (data.containsKey('actividad_entregada')) {
      context.handle(
        _actividadEntregadaMeta,
        actividadEntregada.isAcceptableOrUnknown(
          data['actividad_entregada']!,
          _actividadEntregadaMeta,
        ),
      );
    }
    if (data.containsKey('nota_actividad')) {
      context.handle(
        _notaActividadMeta,
        notaActividad.isAcceptableOrUnknown(
          data['nota_actividad']!,
          _notaActividadMeta,
        ),
      );
    }
    if (data.containsKey('detalle_actividad')) {
      context.handle(
        _detalleActividadMeta,
        detalleActividad.isAcceptableOrUnknown(
          data['detalle_actividad']!,
          _detalleActividadMeta,
        ),
      );
    }
    if (data.containsKey('registrado_en')) {
      context.handle(
        _registradoEnMeta,
        registradoEn.isAcceptableOrUnknown(
          data['registrado_en']!,
          _registradoEnMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {claseId, alumnoId},
  ];
  @override
  TablaAsistencia map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TablaAsistencia(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      claseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}clase_id'],
      )!,
      alumnoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}alumno_id'],
      )!,
      estado: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado'],
      )!,
      observacion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observacion'],
      ),
      justificada: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}justificada'],
      )!,
      detalleJustificacion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}detalle_justificacion'],
      ),
      actividadEntregada: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}actividad_entregada'],
      )!,
      notaActividad: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nota_actividad'],
      ),
      detalleActividad: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}detalle_actividad'],
      ),
      registradoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}registrado_en'],
      )!,
    );
  }

  @override
  $TablaAsistenciasTable createAlias(String alias) {
    return $TablaAsistenciasTable(attachedDatabase, alias);
  }
}

class TablaAsistencia extends DataClass implements Insertable<TablaAsistencia> {
  final int id;
  final int claseId;
  final int alumnoId;
  final String estado;
  final String? observacion;
  final bool justificada;
  final String? detalleJustificacion;
  final bool actividadEntregada;
  final String? notaActividad;
  final String? detalleActividad;
  final DateTime registradoEn;
  const TablaAsistencia({
    required this.id,
    required this.claseId,
    required this.alumnoId,
    required this.estado,
    this.observacion,
    required this.justificada,
    this.detalleJustificacion,
    required this.actividadEntregada,
    this.notaActividad,
    this.detalleActividad,
    required this.registradoEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['clase_id'] = Variable<int>(claseId);
    map['alumno_id'] = Variable<int>(alumnoId);
    map['estado'] = Variable<String>(estado);
    if (!nullToAbsent || observacion != null) {
      map['observacion'] = Variable<String>(observacion);
    }
    map['justificada'] = Variable<bool>(justificada);
    if (!nullToAbsent || detalleJustificacion != null) {
      map['detalle_justificacion'] = Variable<String>(detalleJustificacion);
    }
    map['actividad_entregada'] = Variable<bool>(actividadEntregada);
    if (!nullToAbsent || notaActividad != null) {
      map['nota_actividad'] = Variable<String>(notaActividad);
    }
    if (!nullToAbsent || detalleActividad != null) {
      map['detalle_actividad'] = Variable<String>(detalleActividad);
    }
    map['registrado_en'] = Variable<DateTime>(registradoEn);
    return map;
  }

  TablaAsistenciasCompanion toCompanion(bool nullToAbsent) {
    return TablaAsistenciasCompanion(
      id: Value(id),
      claseId: Value(claseId),
      alumnoId: Value(alumnoId),
      estado: Value(estado),
      observacion: observacion == null && nullToAbsent
          ? const Value.absent()
          : Value(observacion),
      justificada: Value(justificada),
      detalleJustificacion: detalleJustificacion == null && nullToAbsent
          ? const Value.absent()
          : Value(detalleJustificacion),
      actividadEntregada: Value(actividadEntregada),
      notaActividad: notaActividad == null && nullToAbsent
          ? const Value.absent()
          : Value(notaActividad),
      detalleActividad: detalleActividad == null && nullToAbsent
          ? const Value.absent()
          : Value(detalleActividad),
      registradoEn: Value(registradoEn),
    );
  }

  factory TablaAsistencia.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TablaAsistencia(
      id: serializer.fromJson<int>(json['id']),
      claseId: serializer.fromJson<int>(json['claseId']),
      alumnoId: serializer.fromJson<int>(json['alumnoId']),
      estado: serializer.fromJson<String>(json['estado']),
      observacion: serializer.fromJson<String?>(json['observacion']),
      justificada: serializer.fromJson<bool>(json['justificada']),
      detalleJustificacion: serializer.fromJson<String?>(
        json['detalleJustificacion'],
      ),
      actividadEntregada: serializer.fromJson<bool>(json['actividadEntregada']),
      notaActividad: serializer.fromJson<String?>(json['notaActividad']),
      detalleActividad: serializer.fromJson<String?>(json['detalleActividad']),
      registradoEn: serializer.fromJson<DateTime>(json['registradoEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'claseId': serializer.toJson<int>(claseId),
      'alumnoId': serializer.toJson<int>(alumnoId),
      'estado': serializer.toJson<String>(estado),
      'observacion': serializer.toJson<String?>(observacion),
      'justificada': serializer.toJson<bool>(justificada),
      'detalleJustificacion': serializer.toJson<String?>(detalleJustificacion),
      'actividadEntregada': serializer.toJson<bool>(actividadEntregada),
      'notaActividad': serializer.toJson<String?>(notaActividad),
      'detalleActividad': serializer.toJson<String?>(detalleActividad),
      'registradoEn': serializer.toJson<DateTime>(registradoEn),
    };
  }

  TablaAsistencia copyWith({
    int? id,
    int? claseId,
    int? alumnoId,
    String? estado,
    Value<String?> observacion = const Value.absent(),
    bool? justificada,
    Value<String?> detalleJustificacion = const Value.absent(),
    bool? actividadEntregada,
    Value<String?> notaActividad = const Value.absent(),
    Value<String?> detalleActividad = const Value.absent(),
    DateTime? registradoEn,
  }) => TablaAsistencia(
    id: id ?? this.id,
    claseId: claseId ?? this.claseId,
    alumnoId: alumnoId ?? this.alumnoId,
    estado: estado ?? this.estado,
    observacion: observacion.present ? observacion.value : this.observacion,
    justificada: justificada ?? this.justificada,
    detalleJustificacion: detalleJustificacion.present
        ? detalleJustificacion.value
        : this.detalleJustificacion,
    actividadEntregada: actividadEntregada ?? this.actividadEntregada,
    notaActividad: notaActividad.present
        ? notaActividad.value
        : this.notaActividad,
    detalleActividad: detalleActividad.present
        ? detalleActividad.value
        : this.detalleActividad,
    registradoEn: registradoEn ?? this.registradoEn,
  );
  TablaAsistencia copyWithCompanion(TablaAsistenciasCompanion data) {
    return TablaAsistencia(
      id: data.id.present ? data.id.value : this.id,
      claseId: data.claseId.present ? data.claseId.value : this.claseId,
      alumnoId: data.alumnoId.present ? data.alumnoId.value : this.alumnoId,
      estado: data.estado.present ? data.estado.value : this.estado,
      observacion: data.observacion.present
          ? data.observacion.value
          : this.observacion,
      justificada: data.justificada.present
          ? data.justificada.value
          : this.justificada,
      detalleJustificacion: data.detalleJustificacion.present
          ? data.detalleJustificacion.value
          : this.detalleJustificacion,
      actividadEntregada: data.actividadEntregada.present
          ? data.actividadEntregada.value
          : this.actividadEntregada,
      notaActividad: data.notaActividad.present
          ? data.notaActividad.value
          : this.notaActividad,
      detalleActividad: data.detalleActividad.present
          ? data.detalleActividad.value
          : this.detalleActividad,
      registradoEn: data.registradoEn.present
          ? data.registradoEn.value
          : this.registradoEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TablaAsistencia(')
          ..write('id: $id, ')
          ..write('claseId: $claseId, ')
          ..write('alumnoId: $alumnoId, ')
          ..write('estado: $estado, ')
          ..write('observacion: $observacion, ')
          ..write('justificada: $justificada, ')
          ..write('detalleJustificacion: $detalleJustificacion, ')
          ..write('actividadEntregada: $actividadEntregada, ')
          ..write('notaActividad: $notaActividad, ')
          ..write('detalleActividad: $detalleActividad, ')
          ..write('registradoEn: $registradoEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    claseId,
    alumnoId,
    estado,
    observacion,
    justificada,
    detalleJustificacion,
    actividadEntregada,
    notaActividad,
    detalleActividad,
    registradoEn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TablaAsistencia &&
          other.id == this.id &&
          other.claseId == this.claseId &&
          other.alumnoId == this.alumnoId &&
          other.estado == this.estado &&
          other.observacion == this.observacion &&
          other.justificada == this.justificada &&
          other.detalleJustificacion == this.detalleJustificacion &&
          other.actividadEntregada == this.actividadEntregada &&
          other.notaActividad == this.notaActividad &&
          other.detalleActividad == this.detalleActividad &&
          other.registradoEn == this.registradoEn);
}

class TablaAsistenciasCompanion extends UpdateCompanion<TablaAsistencia> {
  final Value<int> id;
  final Value<int> claseId;
  final Value<int> alumnoId;
  final Value<String> estado;
  final Value<String?> observacion;
  final Value<bool> justificada;
  final Value<String?> detalleJustificacion;
  final Value<bool> actividadEntregada;
  final Value<String?> notaActividad;
  final Value<String?> detalleActividad;
  final Value<DateTime> registradoEn;
  const TablaAsistenciasCompanion({
    this.id = const Value.absent(),
    this.claseId = const Value.absent(),
    this.alumnoId = const Value.absent(),
    this.estado = const Value.absent(),
    this.observacion = const Value.absent(),
    this.justificada = const Value.absent(),
    this.detalleJustificacion = const Value.absent(),
    this.actividadEntregada = const Value.absent(),
    this.notaActividad = const Value.absent(),
    this.detalleActividad = const Value.absent(),
    this.registradoEn = const Value.absent(),
  });
  TablaAsistenciasCompanion.insert({
    this.id = const Value.absent(),
    required int claseId,
    required int alumnoId,
    this.estado = const Value.absent(),
    this.observacion = const Value.absent(),
    this.justificada = const Value.absent(),
    this.detalleJustificacion = const Value.absent(),
    this.actividadEntregada = const Value.absent(),
    this.notaActividad = const Value.absent(),
    this.detalleActividad = const Value.absent(),
    this.registradoEn = const Value.absent(),
  }) : claseId = Value(claseId),
       alumnoId = Value(alumnoId);
  static Insertable<TablaAsistencia> custom({
    Expression<int>? id,
    Expression<int>? claseId,
    Expression<int>? alumnoId,
    Expression<String>? estado,
    Expression<String>? observacion,
    Expression<bool>? justificada,
    Expression<String>? detalleJustificacion,
    Expression<bool>? actividadEntregada,
    Expression<String>? notaActividad,
    Expression<String>? detalleActividad,
    Expression<DateTime>? registradoEn,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (claseId != null) 'clase_id': claseId,
      if (alumnoId != null) 'alumno_id': alumnoId,
      if (estado != null) 'estado': estado,
      if (observacion != null) 'observacion': observacion,
      if (justificada != null) 'justificada': justificada,
      if (detalleJustificacion != null)
        'detalle_justificacion': detalleJustificacion,
      if (actividadEntregada != null) 'actividad_entregada': actividadEntregada,
      if (notaActividad != null) 'nota_actividad': notaActividad,
      if (detalleActividad != null) 'detalle_actividad': detalleActividad,
      if (registradoEn != null) 'registrado_en': registradoEn,
    });
  }

  TablaAsistenciasCompanion copyWith({
    Value<int>? id,
    Value<int>? claseId,
    Value<int>? alumnoId,
    Value<String>? estado,
    Value<String?>? observacion,
    Value<bool>? justificada,
    Value<String?>? detalleJustificacion,
    Value<bool>? actividadEntregada,
    Value<String?>? notaActividad,
    Value<String?>? detalleActividad,
    Value<DateTime>? registradoEn,
  }) {
    return TablaAsistenciasCompanion(
      id: id ?? this.id,
      claseId: claseId ?? this.claseId,
      alumnoId: alumnoId ?? this.alumnoId,
      estado: estado ?? this.estado,
      observacion: observacion ?? this.observacion,
      justificada: justificada ?? this.justificada,
      detalleJustificacion: detalleJustificacion ?? this.detalleJustificacion,
      actividadEntregada: actividadEntregada ?? this.actividadEntregada,
      notaActividad: notaActividad ?? this.notaActividad,
      detalleActividad: detalleActividad ?? this.detalleActividad,
      registradoEn: registradoEn ?? this.registradoEn,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (claseId.present) {
      map['clase_id'] = Variable<int>(claseId.value);
    }
    if (alumnoId.present) {
      map['alumno_id'] = Variable<int>(alumnoId.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    if (observacion.present) {
      map['observacion'] = Variable<String>(observacion.value);
    }
    if (justificada.present) {
      map['justificada'] = Variable<bool>(justificada.value);
    }
    if (detalleJustificacion.present) {
      map['detalle_justificacion'] = Variable<String>(
        detalleJustificacion.value,
      );
    }
    if (actividadEntregada.present) {
      map['actividad_entregada'] = Variable<bool>(actividadEntregada.value);
    }
    if (notaActividad.present) {
      map['nota_actividad'] = Variable<String>(notaActividad.value);
    }
    if (detalleActividad.present) {
      map['detalle_actividad'] = Variable<String>(detalleActividad.value);
    }
    if (registradoEn.present) {
      map['registrado_en'] = Variable<DateTime>(registradoEn.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TablaAsistenciasCompanion(')
          ..write('id: $id, ')
          ..write('claseId: $claseId, ')
          ..write('alumnoId: $alumnoId, ')
          ..write('estado: $estado, ')
          ..write('observacion: $observacion, ')
          ..write('justificada: $justificada, ')
          ..write('detalleJustificacion: $detalleJustificacion, ')
          ..write('actividadEntregada: $actividadEntregada, ')
          ..write('notaActividad: $notaActividad, ')
          ..write('detalleActividad: $detalleActividad, ')
          ..write('registradoEn: $registradoEn')
          ..write(')'))
        .toString();
  }
}

class $TablaAlertasGestionHistorialTable extends TablaAlertasGestionHistorial
    with
        TableInfo<
          $TablaAlertasGestionHistorialTable,
          TablaAlertasGestionHistorialData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TablaAlertasGestionHistorialTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _claveMeta = const VerificationMeta('clave');
  @override
  late final GeneratedColumn<String> clave = GeneratedColumn<String>(
    'clave',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 180,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accionMeta = const VerificationMeta('accion');
  @override
  late final GeneratedColumn<String> accion = GeneratedColumn<String>(
    'accion',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 40,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _estadoAnteriorMeta = const VerificationMeta(
    'estadoAnterior',
  );
  @override
  late final GeneratedColumn<String> estadoAnterior = GeneratedColumn<String>(
    'estado_anterior',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 30,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _estadoNuevoMeta = const VerificationMeta(
    'estadoNuevo',
  );
  @override
  late final GeneratedColumn<String> estadoNuevo = GeneratedColumn<String>(
    'estado_nuevo',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 30,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _derivadaAMeta = const VerificationMeta(
    'derivadaA',
  );
  @override
  late final GeneratedColumn<String> derivadaA = GeneratedColumn<String>(
    'derivada_a',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _comentarioMeta = const VerificationMeta(
    'comentario',
  );
  @override
  late final GeneratedColumn<String> comentario = GeneratedColumn<String>(
    'comentario',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 300,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    clave,
    accion,
    estadoAnterior,
    estadoNuevo,
    derivadaA,
    comentario,
    creadoEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tabla_alertas_gestion_historial';
  @override
  VerificationContext validateIntegrity(
    Insertable<TablaAlertasGestionHistorialData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('clave')) {
      context.handle(
        _claveMeta,
        clave.isAcceptableOrUnknown(data['clave']!, _claveMeta),
      );
    } else if (isInserting) {
      context.missing(_claveMeta);
    }
    if (data.containsKey('accion')) {
      context.handle(
        _accionMeta,
        accion.isAcceptableOrUnknown(data['accion']!, _accionMeta),
      );
    } else if (isInserting) {
      context.missing(_accionMeta);
    }
    if (data.containsKey('estado_anterior')) {
      context.handle(
        _estadoAnteriorMeta,
        estadoAnterior.isAcceptableOrUnknown(
          data['estado_anterior']!,
          _estadoAnteriorMeta,
        ),
      );
    }
    if (data.containsKey('estado_nuevo')) {
      context.handle(
        _estadoNuevoMeta,
        estadoNuevo.isAcceptableOrUnknown(
          data['estado_nuevo']!,
          _estadoNuevoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_estadoNuevoMeta);
    }
    if (data.containsKey('derivada_a')) {
      context.handle(
        _derivadaAMeta,
        derivadaA.isAcceptableOrUnknown(data['derivada_a']!, _derivadaAMeta),
      );
    }
    if (data.containsKey('comentario')) {
      context.handle(
        _comentarioMeta,
        comentario.isAcceptableOrUnknown(data['comentario']!, _comentarioMeta),
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
  TablaAlertasGestionHistorialData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TablaAlertasGestionHistorialData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      clave: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}clave'],
      )!,
      accion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}accion'],
      )!,
      estadoAnterior: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado_anterior'],
      ),
      estadoNuevo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado_nuevo'],
      )!,
      derivadaA: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}derivada_a'],
      ),
      comentario: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}comentario'],
      ),
      creadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}creado_en'],
      )!,
    );
  }

  @override
  $TablaAlertasGestionHistorialTable createAlias(String alias) {
    return $TablaAlertasGestionHistorialTable(attachedDatabase, alias);
  }
}

class TablaAlertasGestionHistorialData extends DataClass
    implements Insertable<TablaAlertasGestionHistorialData> {
  final int id;
  final String clave;
  final String accion;
  final String? estadoAnterior;
  final String estadoNuevo;
  final String? derivadaA;
  final String? comentario;
  final DateTime creadoEn;
  const TablaAlertasGestionHistorialData({
    required this.id,
    required this.clave,
    required this.accion,
    this.estadoAnterior,
    required this.estadoNuevo,
    this.derivadaA,
    this.comentario,
    required this.creadoEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['clave'] = Variable<String>(clave);
    map['accion'] = Variable<String>(accion);
    if (!nullToAbsent || estadoAnterior != null) {
      map['estado_anterior'] = Variable<String>(estadoAnterior);
    }
    map['estado_nuevo'] = Variable<String>(estadoNuevo);
    if (!nullToAbsent || derivadaA != null) {
      map['derivada_a'] = Variable<String>(derivadaA);
    }
    if (!nullToAbsent || comentario != null) {
      map['comentario'] = Variable<String>(comentario);
    }
    map['creado_en'] = Variable<DateTime>(creadoEn);
    return map;
  }

  TablaAlertasGestionHistorialCompanion toCompanion(bool nullToAbsent) {
    return TablaAlertasGestionHistorialCompanion(
      id: Value(id),
      clave: Value(clave),
      accion: Value(accion),
      estadoAnterior: estadoAnterior == null && nullToAbsent
          ? const Value.absent()
          : Value(estadoAnterior),
      estadoNuevo: Value(estadoNuevo),
      derivadaA: derivadaA == null && nullToAbsent
          ? const Value.absent()
          : Value(derivadaA),
      comentario: comentario == null && nullToAbsent
          ? const Value.absent()
          : Value(comentario),
      creadoEn: Value(creadoEn),
    );
  }

  factory TablaAlertasGestionHistorialData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TablaAlertasGestionHistorialData(
      id: serializer.fromJson<int>(json['id']),
      clave: serializer.fromJson<String>(json['clave']),
      accion: serializer.fromJson<String>(json['accion']),
      estadoAnterior: serializer.fromJson<String?>(json['estadoAnterior']),
      estadoNuevo: serializer.fromJson<String>(json['estadoNuevo']),
      derivadaA: serializer.fromJson<String?>(json['derivadaA']),
      comentario: serializer.fromJson<String?>(json['comentario']),
      creadoEn: serializer.fromJson<DateTime>(json['creadoEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'clave': serializer.toJson<String>(clave),
      'accion': serializer.toJson<String>(accion),
      'estadoAnterior': serializer.toJson<String?>(estadoAnterior),
      'estadoNuevo': serializer.toJson<String>(estadoNuevo),
      'derivadaA': serializer.toJson<String?>(derivadaA),
      'comentario': serializer.toJson<String?>(comentario),
      'creadoEn': serializer.toJson<DateTime>(creadoEn),
    };
  }

  TablaAlertasGestionHistorialData copyWith({
    int? id,
    String? clave,
    String? accion,
    Value<String?> estadoAnterior = const Value.absent(),
    String? estadoNuevo,
    Value<String?> derivadaA = const Value.absent(),
    Value<String?> comentario = const Value.absent(),
    DateTime? creadoEn,
  }) => TablaAlertasGestionHistorialData(
    id: id ?? this.id,
    clave: clave ?? this.clave,
    accion: accion ?? this.accion,
    estadoAnterior: estadoAnterior.present
        ? estadoAnterior.value
        : this.estadoAnterior,
    estadoNuevo: estadoNuevo ?? this.estadoNuevo,
    derivadaA: derivadaA.present ? derivadaA.value : this.derivadaA,
    comentario: comentario.present ? comentario.value : this.comentario,
    creadoEn: creadoEn ?? this.creadoEn,
  );
  TablaAlertasGestionHistorialData copyWithCompanion(
    TablaAlertasGestionHistorialCompanion data,
  ) {
    return TablaAlertasGestionHistorialData(
      id: data.id.present ? data.id.value : this.id,
      clave: data.clave.present ? data.clave.value : this.clave,
      accion: data.accion.present ? data.accion.value : this.accion,
      estadoAnterior: data.estadoAnterior.present
          ? data.estadoAnterior.value
          : this.estadoAnterior,
      estadoNuevo: data.estadoNuevo.present
          ? data.estadoNuevo.value
          : this.estadoNuevo,
      derivadaA: data.derivadaA.present ? data.derivadaA.value : this.derivadaA,
      comentario: data.comentario.present
          ? data.comentario.value
          : this.comentario,
      creadoEn: data.creadoEn.present ? data.creadoEn.value : this.creadoEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TablaAlertasGestionHistorialData(')
          ..write('id: $id, ')
          ..write('clave: $clave, ')
          ..write('accion: $accion, ')
          ..write('estadoAnterior: $estadoAnterior, ')
          ..write('estadoNuevo: $estadoNuevo, ')
          ..write('derivadaA: $derivadaA, ')
          ..write('comentario: $comentario, ')
          ..write('creadoEn: $creadoEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    clave,
    accion,
    estadoAnterior,
    estadoNuevo,
    derivadaA,
    comentario,
    creadoEn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TablaAlertasGestionHistorialData &&
          other.id == this.id &&
          other.clave == this.clave &&
          other.accion == this.accion &&
          other.estadoAnterior == this.estadoAnterior &&
          other.estadoNuevo == this.estadoNuevo &&
          other.derivadaA == this.derivadaA &&
          other.comentario == this.comentario &&
          other.creadoEn == this.creadoEn);
}

class TablaAlertasGestionHistorialCompanion
    extends UpdateCompanion<TablaAlertasGestionHistorialData> {
  final Value<int> id;
  final Value<String> clave;
  final Value<String> accion;
  final Value<String?> estadoAnterior;
  final Value<String> estadoNuevo;
  final Value<String?> derivadaA;
  final Value<String?> comentario;
  final Value<DateTime> creadoEn;
  const TablaAlertasGestionHistorialCompanion({
    this.id = const Value.absent(),
    this.clave = const Value.absent(),
    this.accion = const Value.absent(),
    this.estadoAnterior = const Value.absent(),
    this.estadoNuevo = const Value.absent(),
    this.derivadaA = const Value.absent(),
    this.comentario = const Value.absent(),
    this.creadoEn = const Value.absent(),
  });
  TablaAlertasGestionHistorialCompanion.insert({
    this.id = const Value.absent(),
    required String clave,
    required String accion,
    this.estadoAnterior = const Value.absent(),
    required String estadoNuevo,
    this.derivadaA = const Value.absent(),
    this.comentario = const Value.absent(),
    this.creadoEn = const Value.absent(),
  }) : clave = Value(clave),
       accion = Value(accion),
       estadoNuevo = Value(estadoNuevo);
  static Insertable<TablaAlertasGestionHistorialData> custom({
    Expression<int>? id,
    Expression<String>? clave,
    Expression<String>? accion,
    Expression<String>? estadoAnterior,
    Expression<String>? estadoNuevo,
    Expression<String>? derivadaA,
    Expression<String>? comentario,
    Expression<DateTime>? creadoEn,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clave != null) 'clave': clave,
      if (accion != null) 'accion': accion,
      if (estadoAnterior != null) 'estado_anterior': estadoAnterior,
      if (estadoNuevo != null) 'estado_nuevo': estadoNuevo,
      if (derivadaA != null) 'derivada_a': derivadaA,
      if (comentario != null) 'comentario': comentario,
      if (creadoEn != null) 'creado_en': creadoEn,
    });
  }

  TablaAlertasGestionHistorialCompanion copyWith({
    Value<int>? id,
    Value<String>? clave,
    Value<String>? accion,
    Value<String?>? estadoAnterior,
    Value<String>? estadoNuevo,
    Value<String?>? derivadaA,
    Value<String?>? comentario,
    Value<DateTime>? creadoEn,
  }) {
    return TablaAlertasGestionHistorialCompanion(
      id: id ?? this.id,
      clave: clave ?? this.clave,
      accion: accion ?? this.accion,
      estadoAnterior: estadoAnterior ?? this.estadoAnterior,
      estadoNuevo: estadoNuevo ?? this.estadoNuevo,
      derivadaA: derivadaA ?? this.derivadaA,
      comentario: comentario ?? this.comentario,
      creadoEn: creadoEn ?? this.creadoEn,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (clave.present) {
      map['clave'] = Variable<String>(clave.value);
    }
    if (accion.present) {
      map['accion'] = Variable<String>(accion.value);
    }
    if (estadoAnterior.present) {
      map['estado_anterior'] = Variable<String>(estadoAnterior.value);
    }
    if (estadoNuevo.present) {
      map['estado_nuevo'] = Variable<String>(estadoNuevo.value);
    }
    if (derivadaA.present) {
      map['derivada_a'] = Variable<String>(derivadaA.value);
    }
    if (comentario.present) {
      map['comentario'] = Variable<String>(comentario.value);
    }
    if (creadoEn.present) {
      map['creado_en'] = Variable<DateTime>(creadoEn.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TablaAlertasGestionHistorialCompanion(')
          ..write('id: $id, ')
          ..write('clave: $clave, ')
          ..write('accion: $accion, ')
          ..write('estadoAnterior: $estadoAnterior, ')
          ..write('estadoNuevo: $estadoNuevo, ')
          ..write('derivadaA: $derivadaA, ')
          ..write('comentario: $comentario, ')
          ..write('creadoEn: $creadoEn')
          ..write(')'))
        .toString();
  }
}

class $TablaAlertasGestionEstadoTable extends TablaAlertasGestionEstado
    with
        TableInfo<
          $TablaAlertasGestionEstadoTable,
          TablaAlertasGestionEstadoData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TablaAlertasGestionEstadoTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _claveMeta = const VerificationMeta('clave');
  @override
  late final GeneratedColumn<String> clave = GeneratedColumn<String>(
    'clave',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 180,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
    'estado',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 30,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pospuestaHastaMeta = const VerificationMeta(
    'pospuestaHasta',
  );
  @override
  late final GeneratedColumn<DateTime> pospuestaHasta =
      GeneratedColumn<DateTime>(
        'pospuesta_hasta',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _derivadaAMeta = const VerificationMeta(
    'derivadaA',
  );
  @override
  late final GeneratedColumn<String> derivadaA = GeneratedColumn<String>(
    'derivada_a',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _comentarioMeta = const VerificationMeta(
    'comentario',
  );
  @override
  late final GeneratedColumn<String> comentario = GeneratedColumn<String>(
    'comentario',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 300,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actualizadoEnMeta = const VerificationMeta(
    'actualizadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> actualizadoEn =
      GeneratedColumn<DateTime>(
        'actualizado_en',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    clave,
    estado,
    pospuestaHasta,
    derivadaA,
    comentario,
    actualizadoEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tabla_alertas_gestion_estado';
  @override
  VerificationContext validateIntegrity(
    Insertable<TablaAlertasGestionEstadoData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('clave')) {
      context.handle(
        _claveMeta,
        clave.isAcceptableOrUnknown(data['clave']!, _claveMeta),
      );
    } else if (isInserting) {
      context.missing(_claveMeta);
    }
    if (data.containsKey('estado')) {
      context.handle(
        _estadoMeta,
        estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta),
      );
    } else if (isInserting) {
      context.missing(_estadoMeta);
    }
    if (data.containsKey('pospuesta_hasta')) {
      context.handle(
        _pospuestaHastaMeta,
        pospuestaHasta.isAcceptableOrUnknown(
          data['pospuesta_hasta']!,
          _pospuestaHastaMeta,
        ),
      );
    }
    if (data.containsKey('derivada_a')) {
      context.handle(
        _derivadaAMeta,
        derivadaA.isAcceptableOrUnknown(data['derivada_a']!, _derivadaAMeta),
      );
    }
    if (data.containsKey('comentario')) {
      context.handle(
        _comentarioMeta,
        comentario.isAcceptableOrUnknown(data['comentario']!, _comentarioMeta),
      );
    }
    if (data.containsKey('actualizado_en')) {
      context.handle(
        _actualizadoEnMeta,
        actualizadoEn.isAcceptableOrUnknown(
          data['actualizado_en']!,
          _actualizadoEnMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {clave},
  ];
  @override
  TablaAlertasGestionEstadoData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TablaAlertasGestionEstadoData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      clave: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}clave'],
      )!,
      estado: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado'],
      )!,
      pospuestaHasta: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}pospuesta_hasta'],
      ),
      derivadaA: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}derivada_a'],
      ),
      comentario: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}comentario'],
      ),
      actualizadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}actualizado_en'],
      )!,
    );
  }

  @override
  $TablaAlertasGestionEstadoTable createAlias(String alias) {
    return $TablaAlertasGestionEstadoTable(attachedDatabase, alias);
  }
}

class TablaAlertasGestionEstadoData extends DataClass
    implements Insertable<TablaAlertasGestionEstadoData> {
  final int id;
  final String clave;
  final String estado;
  final DateTime? pospuestaHasta;
  final String? derivadaA;
  final String? comentario;
  final DateTime actualizadoEn;
  const TablaAlertasGestionEstadoData({
    required this.id,
    required this.clave,
    required this.estado,
    this.pospuestaHasta,
    this.derivadaA,
    this.comentario,
    required this.actualizadoEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['clave'] = Variable<String>(clave);
    map['estado'] = Variable<String>(estado);
    if (!nullToAbsent || pospuestaHasta != null) {
      map['pospuesta_hasta'] = Variable<DateTime>(pospuestaHasta);
    }
    if (!nullToAbsent || derivadaA != null) {
      map['derivada_a'] = Variable<String>(derivadaA);
    }
    if (!nullToAbsent || comentario != null) {
      map['comentario'] = Variable<String>(comentario);
    }
    map['actualizado_en'] = Variable<DateTime>(actualizadoEn);
    return map;
  }

  TablaAlertasGestionEstadoCompanion toCompanion(bool nullToAbsent) {
    return TablaAlertasGestionEstadoCompanion(
      id: Value(id),
      clave: Value(clave),
      estado: Value(estado),
      pospuestaHasta: pospuestaHasta == null && nullToAbsent
          ? const Value.absent()
          : Value(pospuestaHasta),
      derivadaA: derivadaA == null && nullToAbsent
          ? const Value.absent()
          : Value(derivadaA),
      comentario: comentario == null && nullToAbsent
          ? const Value.absent()
          : Value(comentario),
      actualizadoEn: Value(actualizadoEn),
    );
  }

  factory TablaAlertasGestionEstadoData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TablaAlertasGestionEstadoData(
      id: serializer.fromJson<int>(json['id']),
      clave: serializer.fromJson<String>(json['clave']),
      estado: serializer.fromJson<String>(json['estado']),
      pospuestaHasta: serializer.fromJson<DateTime?>(json['pospuestaHasta']),
      derivadaA: serializer.fromJson<String?>(json['derivadaA']),
      comentario: serializer.fromJson<String?>(json['comentario']),
      actualizadoEn: serializer.fromJson<DateTime>(json['actualizadoEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'clave': serializer.toJson<String>(clave),
      'estado': serializer.toJson<String>(estado),
      'pospuestaHasta': serializer.toJson<DateTime?>(pospuestaHasta),
      'derivadaA': serializer.toJson<String?>(derivadaA),
      'comentario': serializer.toJson<String?>(comentario),
      'actualizadoEn': serializer.toJson<DateTime>(actualizadoEn),
    };
  }

  TablaAlertasGestionEstadoData copyWith({
    int? id,
    String? clave,
    String? estado,
    Value<DateTime?> pospuestaHasta = const Value.absent(),
    Value<String?> derivadaA = const Value.absent(),
    Value<String?> comentario = const Value.absent(),
    DateTime? actualizadoEn,
  }) => TablaAlertasGestionEstadoData(
    id: id ?? this.id,
    clave: clave ?? this.clave,
    estado: estado ?? this.estado,
    pospuestaHasta: pospuestaHasta.present
        ? pospuestaHasta.value
        : this.pospuestaHasta,
    derivadaA: derivadaA.present ? derivadaA.value : this.derivadaA,
    comentario: comentario.present ? comentario.value : this.comentario,
    actualizadoEn: actualizadoEn ?? this.actualizadoEn,
  );
  TablaAlertasGestionEstadoData copyWithCompanion(
    TablaAlertasGestionEstadoCompanion data,
  ) {
    return TablaAlertasGestionEstadoData(
      id: data.id.present ? data.id.value : this.id,
      clave: data.clave.present ? data.clave.value : this.clave,
      estado: data.estado.present ? data.estado.value : this.estado,
      pospuestaHasta: data.pospuestaHasta.present
          ? data.pospuestaHasta.value
          : this.pospuestaHasta,
      derivadaA: data.derivadaA.present ? data.derivadaA.value : this.derivadaA,
      comentario: data.comentario.present
          ? data.comentario.value
          : this.comentario,
      actualizadoEn: data.actualizadoEn.present
          ? data.actualizadoEn.value
          : this.actualizadoEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TablaAlertasGestionEstadoData(')
          ..write('id: $id, ')
          ..write('clave: $clave, ')
          ..write('estado: $estado, ')
          ..write('pospuestaHasta: $pospuestaHasta, ')
          ..write('derivadaA: $derivadaA, ')
          ..write('comentario: $comentario, ')
          ..write('actualizadoEn: $actualizadoEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    clave,
    estado,
    pospuestaHasta,
    derivadaA,
    comentario,
    actualizadoEn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TablaAlertasGestionEstadoData &&
          other.id == this.id &&
          other.clave == this.clave &&
          other.estado == this.estado &&
          other.pospuestaHasta == this.pospuestaHasta &&
          other.derivadaA == this.derivadaA &&
          other.comentario == this.comentario &&
          other.actualizadoEn == this.actualizadoEn);
}

class TablaAlertasGestionEstadoCompanion
    extends UpdateCompanion<TablaAlertasGestionEstadoData> {
  final Value<int> id;
  final Value<String> clave;
  final Value<String> estado;
  final Value<DateTime?> pospuestaHasta;
  final Value<String?> derivadaA;
  final Value<String?> comentario;
  final Value<DateTime> actualizadoEn;
  const TablaAlertasGestionEstadoCompanion({
    this.id = const Value.absent(),
    this.clave = const Value.absent(),
    this.estado = const Value.absent(),
    this.pospuestaHasta = const Value.absent(),
    this.derivadaA = const Value.absent(),
    this.comentario = const Value.absent(),
    this.actualizadoEn = const Value.absent(),
  });
  TablaAlertasGestionEstadoCompanion.insert({
    this.id = const Value.absent(),
    required String clave,
    required String estado,
    this.pospuestaHasta = const Value.absent(),
    this.derivadaA = const Value.absent(),
    this.comentario = const Value.absent(),
    this.actualizadoEn = const Value.absent(),
  }) : clave = Value(clave),
       estado = Value(estado);
  static Insertable<TablaAlertasGestionEstadoData> custom({
    Expression<int>? id,
    Expression<String>? clave,
    Expression<String>? estado,
    Expression<DateTime>? pospuestaHasta,
    Expression<String>? derivadaA,
    Expression<String>? comentario,
    Expression<DateTime>? actualizadoEn,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clave != null) 'clave': clave,
      if (estado != null) 'estado': estado,
      if (pospuestaHasta != null) 'pospuesta_hasta': pospuestaHasta,
      if (derivadaA != null) 'derivada_a': derivadaA,
      if (comentario != null) 'comentario': comentario,
      if (actualizadoEn != null) 'actualizado_en': actualizadoEn,
    });
  }

  TablaAlertasGestionEstadoCompanion copyWith({
    Value<int>? id,
    Value<String>? clave,
    Value<String>? estado,
    Value<DateTime?>? pospuestaHasta,
    Value<String?>? derivadaA,
    Value<String?>? comentario,
    Value<DateTime>? actualizadoEn,
  }) {
    return TablaAlertasGestionEstadoCompanion(
      id: id ?? this.id,
      clave: clave ?? this.clave,
      estado: estado ?? this.estado,
      pospuestaHasta: pospuestaHasta ?? this.pospuestaHasta,
      derivadaA: derivadaA ?? this.derivadaA,
      comentario: comentario ?? this.comentario,
      actualizadoEn: actualizadoEn ?? this.actualizadoEn,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (clave.present) {
      map['clave'] = Variable<String>(clave.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    if (pospuestaHasta.present) {
      map['pospuesta_hasta'] = Variable<DateTime>(pospuestaHasta.value);
    }
    if (derivadaA.present) {
      map['derivada_a'] = Variable<String>(derivadaA.value);
    }
    if (comentario.present) {
      map['comentario'] = Variable<String>(comentario.value);
    }
    if (actualizadoEn.present) {
      map['actualizado_en'] = Variable<DateTime>(actualizadoEn.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TablaAlertasGestionEstadoCompanion(')
          ..write('id: $id, ')
          ..write('clave: $clave, ')
          ..write('estado: $estado, ')
          ..write('pospuestaHasta: $pospuestaHasta, ')
          ..write('derivadaA: $derivadaA, ')
          ..write('comentario: $comentario, ')
          ..write('actualizadoEn: $actualizadoEn')
          ..write(')'))
        .toString();
  }
}

class $TablaIncidenciasTransversalesHistorialTable
    extends TablaIncidenciasTransversalesHistorial
    with
        TableInfo<
          $TablaIncidenciasTransversalesHistorialTable,
          TablaIncidenciasTransversalesHistorialData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TablaIncidenciasTransversalesHistorialTable(
    this.attachedDatabase, [
    this._alias,
  ]);
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
  static const VerificationMeta _origenMeta = const VerificationMeta('origen');
  @override
  late final GeneratedColumn<String> origen = GeneratedColumn<String>(
    'origen',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 40,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _referenciaMeta = const VerificationMeta(
    'referencia',
  );
  @override
  late final GeneratedColumn<String> referencia = GeneratedColumn<String>(
    'referencia',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 180,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accionMeta = const VerificationMeta('accion');
  @override
  late final GeneratedColumn<String> accion = GeneratedColumn<String>(
    'accion',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 40,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _estadoOperativoMeta = const VerificationMeta(
    'estadoOperativo',
  );
  @override
  late final GeneratedColumn<String> estadoOperativo = GeneratedColumn<String>(
    'estado_operativo',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _estadoDocumentalMeta = const VerificationMeta(
    'estadoDocumental',
  );
  @override
  late final GeneratedColumn<String> estadoDocumental = GeneratedColumn<String>(
    'estado_documental',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _detalleMeta = const VerificationMeta(
    'detalle',
  );
  @override
  late final GeneratedColumn<String> detalle = GeneratedColumn<String>(
    'detalle',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 500,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    origen,
    referencia,
    accion,
    estadoOperativo,
    estadoDocumental,
    detalle,
    creadoEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tabla_incidencias_transversales_historial';
  @override
  VerificationContext validateIntegrity(
    Insertable<TablaIncidenciasTransversalesHistorialData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('origen')) {
      context.handle(
        _origenMeta,
        origen.isAcceptableOrUnknown(data['origen']!, _origenMeta),
      );
    } else if (isInserting) {
      context.missing(_origenMeta);
    }
    if (data.containsKey('referencia')) {
      context.handle(
        _referenciaMeta,
        referencia.isAcceptableOrUnknown(data['referencia']!, _referenciaMeta),
      );
    } else if (isInserting) {
      context.missing(_referenciaMeta);
    }
    if (data.containsKey('accion')) {
      context.handle(
        _accionMeta,
        accion.isAcceptableOrUnknown(data['accion']!, _accionMeta),
      );
    } else if (isInserting) {
      context.missing(_accionMeta);
    }
    if (data.containsKey('estado_operativo')) {
      context.handle(
        _estadoOperativoMeta,
        estadoOperativo.isAcceptableOrUnknown(
          data['estado_operativo']!,
          _estadoOperativoMeta,
        ),
      );
    }
    if (data.containsKey('estado_documental')) {
      context.handle(
        _estadoDocumentalMeta,
        estadoDocumental.isAcceptableOrUnknown(
          data['estado_documental']!,
          _estadoDocumentalMeta,
        ),
      );
    }
    if (data.containsKey('detalle')) {
      context.handle(
        _detalleMeta,
        detalle.isAcceptableOrUnknown(data['detalle']!, _detalleMeta),
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
  TablaIncidenciasTransversalesHistorialData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TablaIncidenciasTransversalesHistorialData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      origen: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origen'],
      )!,
      referencia: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}referencia'],
      )!,
      accion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}accion'],
      )!,
      estadoOperativo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado_operativo'],
      ),
      estadoDocumental: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado_documental'],
      ),
      detalle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}detalle'],
      ),
      creadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}creado_en'],
      )!,
    );
  }

  @override
  $TablaIncidenciasTransversalesHistorialTable createAlias(String alias) {
    return $TablaIncidenciasTransversalesHistorialTable(
      attachedDatabase,
      alias,
    );
  }
}

class TablaIncidenciasTransversalesHistorialData extends DataClass
    implements Insertable<TablaIncidenciasTransversalesHistorialData> {
  final int id;
  final String origen;
  final String referencia;
  final String accion;
  final String? estadoOperativo;
  final String? estadoDocumental;
  final String? detalle;
  final DateTime creadoEn;
  const TablaIncidenciasTransversalesHistorialData({
    required this.id,
    required this.origen,
    required this.referencia,
    required this.accion,
    this.estadoOperativo,
    this.estadoDocumental,
    this.detalle,
    required this.creadoEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['origen'] = Variable<String>(origen);
    map['referencia'] = Variable<String>(referencia);
    map['accion'] = Variable<String>(accion);
    if (!nullToAbsent || estadoOperativo != null) {
      map['estado_operativo'] = Variable<String>(estadoOperativo);
    }
    if (!nullToAbsent || estadoDocumental != null) {
      map['estado_documental'] = Variable<String>(estadoDocumental);
    }
    if (!nullToAbsent || detalle != null) {
      map['detalle'] = Variable<String>(detalle);
    }
    map['creado_en'] = Variable<DateTime>(creadoEn);
    return map;
  }

  TablaIncidenciasTransversalesHistorialCompanion toCompanion(
    bool nullToAbsent,
  ) {
    return TablaIncidenciasTransversalesHistorialCompanion(
      id: Value(id),
      origen: Value(origen),
      referencia: Value(referencia),
      accion: Value(accion),
      estadoOperativo: estadoOperativo == null && nullToAbsent
          ? const Value.absent()
          : Value(estadoOperativo),
      estadoDocumental: estadoDocumental == null && nullToAbsent
          ? const Value.absent()
          : Value(estadoDocumental),
      detalle: detalle == null && nullToAbsent
          ? const Value.absent()
          : Value(detalle),
      creadoEn: Value(creadoEn),
    );
  }

  factory TablaIncidenciasTransversalesHistorialData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TablaIncidenciasTransversalesHistorialData(
      id: serializer.fromJson<int>(json['id']),
      origen: serializer.fromJson<String>(json['origen']),
      referencia: serializer.fromJson<String>(json['referencia']),
      accion: serializer.fromJson<String>(json['accion']),
      estadoOperativo: serializer.fromJson<String?>(json['estadoOperativo']),
      estadoDocumental: serializer.fromJson<String?>(json['estadoDocumental']),
      detalle: serializer.fromJson<String?>(json['detalle']),
      creadoEn: serializer.fromJson<DateTime>(json['creadoEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'origen': serializer.toJson<String>(origen),
      'referencia': serializer.toJson<String>(referencia),
      'accion': serializer.toJson<String>(accion),
      'estadoOperativo': serializer.toJson<String?>(estadoOperativo),
      'estadoDocumental': serializer.toJson<String?>(estadoDocumental),
      'detalle': serializer.toJson<String?>(detalle),
      'creadoEn': serializer.toJson<DateTime>(creadoEn),
    };
  }

  TablaIncidenciasTransversalesHistorialData copyWith({
    int? id,
    String? origen,
    String? referencia,
    String? accion,
    Value<String?> estadoOperativo = const Value.absent(),
    Value<String?> estadoDocumental = const Value.absent(),
    Value<String?> detalle = const Value.absent(),
    DateTime? creadoEn,
  }) => TablaIncidenciasTransversalesHistorialData(
    id: id ?? this.id,
    origen: origen ?? this.origen,
    referencia: referencia ?? this.referencia,
    accion: accion ?? this.accion,
    estadoOperativo: estadoOperativo.present
        ? estadoOperativo.value
        : this.estadoOperativo,
    estadoDocumental: estadoDocumental.present
        ? estadoDocumental.value
        : this.estadoDocumental,
    detalle: detalle.present ? detalle.value : this.detalle,
    creadoEn: creadoEn ?? this.creadoEn,
  );
  TablaIncidenciasTransversalesHistorialData copyWithCompanion(
    TablaIncidenciasTransversalesHistorialCompanion data,
  ) {
    return TablaIncidenciasTransversalesHistorialData(
      id: data.id.present ? data.id.value : this.id,
      origen: data.origen.present ? data.origen.value : this.origen,
      referencia: data.referencia.present
          ? data.referencia.value
          : this.referencia,
      accion: data.accion.present ? data.accion.value : this.accion,
      estadoOperativo: data.estadoOperativo.present
          ? data.estadoOperativo.value
          : this.estadoOperativo,
      estadoDocumental: data.estadoDocumental.present
          ? data.estadoDocumental.value
          : this.estadoDocumental,
      detalle: data.detalle.present ? data.detalle.value : this.detalle,
      creadoEn: data.creadoEn.present ? data.creadoEn.value : this.creadoEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TablaIncidenciasTransversalesHistorialData(')
          ..write('id: $id, ')
          ..write('origen: $origen, ')
          ..write('referencia: $referencia, ')
          ..write('accion: $accion, ')
          ..write('estadoOperativo: $estadoOperativo, ')
          ..write('estadoDocumental: $estadoDocumental, ')
          ..write('detalle: $detalle, ')
          ..write('creadoEn: $creadoEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    origen,
    referencia,
    accion,
    estadoOperativo,
    estadoDocumental,
    detalle,
    creadoEn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TablaIncidenciasTransversalesHistorialData &&
          other.id == this.id &&
          other.origen == this.origen &&
          other.referencia == this.referencia &&
          other.accion == this.accion &&
          other.estadoOperativo == this.estadoOperativo &&
          other.estadoDocumental == this.estadoDocumental &&
          other.detalle == this.detalle &&
          other.creadoEn == this.creadoEn);
}

class TablaIncidenciasTransversalesHistorialCompanion
    extends UpdateCompanion<TablaIncidenciasTransversalesHistorialData> {
  final Value<int> id;
  final Value<String> origen;
  final Value<String> referencia;
  final Value<String> accion;
  final Value<String?> estadoOperativo;
  final Value<String?> estadoDocumental;
  final Value<String?> detalle;
  final Value<DateTime> creadoEn;
  const TablaIncidenciasTransversalesHistorialCompanion({
    this.id = const Value.absent(),
    this.origen = const Value.absent(),
    this.referencia = const Value.absent(),
    this.accion = const Value.absent(),
    this.estadoOperativo = const Value.absent(),
    this.estadoDocumental = const Value.absent(),
    this.detalle = const Value.absent(),
    this.creadoEn = const Value.absent(),
  });
  TablaIncidenciasTransversalesHistorialCompanion.insert({
    this.id = const Value.absent(),
    required String origen,
    required String referencia,
    required String accion,
    this.estadoOperativo = const Value.absent(),
    this.estadoDocumental = const Value.absent(),
    this.detalle = const Value.absent(),
    this.creadoEn = const Value.absent(),
  }) : origen = Value(origen),
       referencia = Value(referencia),
       accion = Value(accion);
  static Insertable<TablaIncidenciasTransversalesHistorialData> custom({
    Expression<int>? id,
    Expression<String>? origen,
    Expression<String>? referencia,
    Expression<String>? accion,
    Expression<String>? estadoOperativo,
    Expression<String>? estadoDocumental,
    Expression<String>? detalle,
    Expression<DateTime>? creadoEn,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (origen != null) 'origen': origen,
      if (referencia != null) 'referencia': referencia,
      if (accion != null) 'accion': accion,
      if (estadoOperativo != null) 'estado_operativo': estadoOperativo,
      if (estadoDocumental != null) 'estado_documental': estadoDocumental,
      if (detalle != null) 'detalle': detalle,
      if (creadoEn != null) 'creado_en': creadoEn,
    });
  }

  TablaIncidenciasTransversalesHistorialCompanion copyWith({
    Value<int>? id,
    Value<String>? origen,
    Value<String>? referencia,
    Value<String>? accion,
    Value<String?>? estadoOperativo,
    Value<String?>? estadoDocumental,
    Value<String?>? detalle,
    Value<DateTime>? creadoEn,
  }) {
    return TablaIncidenciasTransversalesHistorialCompanion(
      id: id ?? this.id,
      origen: origen ?? this.origen,
      referencia: referencia ?? this.referencia,
      accion: accion ?? this.accion,
      estadoOperativo: estadoOperativo ?? this.estadoOperativo,
      estadoDocumental: estadoDocumental ?? this.estadoDocumental,
      detalle: detalle ?? this.detalle,
      creadoEn: creadoEn ?? this.creadoEn,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (origen.present) {
      map['origen'] = Variable<String>(origen.value);
    }
    if (referencia.present) {
      map['referencia'] = Variable<String>(referencia.value);
    }
    if (accion.present) {
      map['accion'] = Variable<String>(accion.value);
    }
    if (estadoOperativo.present) {
      map['estado_operativo'] = Variable<String>(estadoOperativo.value);
    }
    if (estadoDocumental.present) {
      map['estado_documental'] = Variable<String>(estadoDocumental.value);
    }
    if (detalle.present) {
      map['detalle'] = Variable<String>(detalle.value);
    }
    if (creadoEn.present) {
      map['creado_en'] = Variable<DateTime>(creadoEn.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TablaIncidenciasTransversalesHistorialCompanion(')
          ..write('id: $id, ')
          ..write('origen: $origen, ')
          ..write('referencia: $referencia, ')
          ..write('accion: $accion, ')
          ..write('estadoOperativo: $estadoOperativo, ')
          ..write('estadoDocumental: $estadoDocumental, ')
          ..write('detalle: $detalle, ')
          ..write('creadoEn: $creadoEn')
          ..write(')'))
        .toString();
  }
}

class $TablaLegajosDocumentalesTable extends TablaLegajosDocumentales
    with TableInfo<$TablaLegajosDocumentalesTable, TablaLegajosDocumentale> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TablaLegajosDocumentalesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _tipoRegistroMeta = const VerificationMeta(
    'tipoRegistro',
  );
  @override
  late final GeneratedColumn<String> tipoRegistro = GeneratedColumn<String>(
    'tipo_registro',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 30,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoriaMeta = const VerificationMeta(
    'categoria',
  );
  @override
  late final GeneratedColumn<String> categoria = GeneratedColumn<String>(
    'categoria',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 30,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codigoMeta = const VerificationMeta('codigo');
  @override
  late final GeneratedColumn<String> codigo = GeneratedColumn<String>(
    'codigo',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 40,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tituloMeta = const VerificationMeta('titulo');
  @override
  late final GeneratedColumn<String> titulo = GeneratedColumn<String>(
    'titulo',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 160,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _detalleMeta = const VerificationMeta(
    'detalle',
  );
  @override
  late final GeneratedColumn<String> detalle = GeneratedColumn<String>(
    'detalle',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 600,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _responsableMeta = const VerificationMeta(
    'responsable',
  );
  @override
  late final GeneratedColumn<String> responsable = GeneratedColumn<String>(
    'responsable',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
    'estado',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _severidadMeta = const VerificationMeta(
    'severidad',
  );
  @override
  late final GeneratedColumn<String> severidad = GeneratedColumn<String>(
    'severidad',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 20,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rolDestinoMeta = const VerificationMeta(
    'rolDestino',
  );
  @override
  late final GeneratedColumn<String> rolDestino = GeneratedColumn<String>(
    'rol_destino',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 40,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nivelDestinoMeta = const VerificationMeta(
    'nivelDestino',
  );
  @override
  late final GeneratedColumn<String> nivelDestino = GeneratedColumn<String>(
    'nivel_destino',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 30,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dependenciaDestinoMeta =
      const VerificationMeta('dependenciaDestino');
  @override
  late final GeneratedColumn<String> dependenciaDestino =
      GeneratedColumn<String>(
        'dependencia_destino',
        aliasedName,
        false,
        additionalChecks: GeneratedColumn.checkTextLength(
          minTextLength: 1,
          maxTextLength: 30,
        ),
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _horasHastaVencimientoMeta =
      const VerificationMeta('horasHastaVencimiento');
  @override
  late final GeneratedColumn<int> horasHastaVencimiento = GeneratedColumn<int>(
    'horas_hasta_vencimiento',
    aliasedName,
    true,
    type: DriftSqlType.int,
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
  static const VerificationMeta _actualizadoEnMeta = const VerificationMeta(
    'actualizadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> actualizadoEn =
      GeneratedColumn<DateTime>(
        'actualizado_en',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tipoRegistro,
    categoria,
    codigo,
    titulo,
    detalle,
    responsable,
    estado,
    severidad,
    rolDestino,
    nivelDestino,
    dependenciaDestino,
    horasHastaVencimiento,
    activo,
    creadoEn,
    actualizadoEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tabla_legajos_documentales';
  @override
  VerificationContext validateIntegrity(
    Insertable<TablaLegajosDocumentale> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('tipo_registro')) {
      context.handle(
        _tipoRegistroMeta,
        tipoRegistro.isAcceptableOrUnknown(
          data['tipo_registro']!,
          _tipoRegistroMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tipoRegistroMeta);
    }
    if (data.containsKey('categoria')) {
      context.handle(
        _categoriaMeta,
        categoria.isAcceptableOrUnknown(data['categoria']!, _categoriaMeta),
      );
    } else if (isInserting) {
      context.missing(_categoriaMeta);
    }
    if (data.containsKey('codigo')) {
      context.handle(
        _codigoMeta,
        codigo.isAcceptableOrUnknown(data['codigo']!, _codigoMeta),
      );
    } else if (isInserting) {
      context.missing(_codigoMeta);
    }
    if (data.containsKey('titulo')) {
      context.handle(
        _tituloMeta,
        titulo.isAcceptableOrUnknown(data['titulo']!, _tituloMeta),
      );
    } else if (isInserting) {
      context.missing(_tituloMeta);
    }
    if (data.containsKey('detalle')) {
      context.handle(
        _detalleMeta,
        detalle.isAcceptableOrUnknown(data['detalle']!, _detalleMeta),
      );
    } else if (isInserting) {
      context.missing(_detalleMeta);
    }
    if (data.containsKey('responsable')) {
      context.handle(
        _responsableMeta,
        responsable.isAcceptableOrUnknown(
          data['responsable']!,
          _responsableMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_responsableMeta);
    }
    if (data.containsKey('estado')) {
      context.handle(
        _estadoMeta,
        estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta),
      );
    } else if (isInserting) {
      context.missing(_estadoMeta);
    }
    if (data.containsKey('severidad')) {
      context.handle(
        _severidadMeta,
        severidad.isAcceptableOrUnknown(data['severidad']!, _severidadMeta),
      );
    } else if (isInserting) {
      context.missing(_severidadMeta);
    }
    if (data.containsKey('rol_destino')) {
      context.handle(
        _rolDestinoMeta,
        rolDestino.isAcceptableOrUnknown(data['rol_destino']!, _rolDestinoMeta),
      );
    } else if (isInserting) {
      context.missing(_rolDestinoMeta);
    }
    if (data.containsKey('nivel_destino')) {
      context.handle(
        _nivelDestinoMeta,
        nivelDestino.isAcceptableOrUnknown(
          data['nivel_destino']!,
          _nivelDestinoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nivelDestinoMeta);
    }
    if (data.containsKey('dependencia_destino')) {
      context.handle(
        _dependenciaDestinoMeta,
        dependenciaDestino.isAcceptableOrUnknown(
          data['dependencia_destino']!,
          _dependenciaDestinoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dependenciaDestinoMeta);
    }
    if (data.containsKey('horas_hasta_vencimiento')) {
      context.handle(
        _horasHastaVencimientoMeta,
        horasHastaVencimiento.isAcceptableOrUnknown(
          data['horas_hasta_vencimiento']!,
          _horasHastaVencimientoMeta,
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
    if (data.containsKey('actualizado_en')) {
      context.handle(
        _actualizadoEnMeta,
        actualizadoEn.isAcceptableOrUnknown(
          data['actualizado_en']!,
          _actualizadoEnMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TablaLegajosDocumentale map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TablaLegajosDocumentale(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      tipoRegistro: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo_registro'],
      )!,
      categoria: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}categoria'],
      )!,
      codigo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}codigo'],
      )!,
      titulo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}titulo'],
      )!,
      detalle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}detalle'],
      )!,
      responsable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}responsable'],
      )!,
      estado: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado'],
      )!,
      severidad: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}severidad'],
      )!,
      rolDestino: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rol_destino'],
      )!,
      nivelDestino: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nivel_destino'],
      )!,
      dependenciaDestino: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dependencia_destino'],
      )!,
      horasHastaVencimiento: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}horas_hasta_vencimiento'],
      ),
      activo: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}activo'],
      )!,
      creadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}creado_en'],
      )!,
      actualizadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}actualizado_en'],
      )!,
    );
  }

  @override
  $TablaLegajosDocumentalesTable createAlias(String alias) {
    return $TablaLegajosDocumentalesTable(attachedDatabase, alias);
  }
}

class TablaLegajosDocumentale extends DataClass
    implements Insertable<TablaLegajosDocumentale> {
  final int id;
  final String tipoRegistro;
  final String categoria;
  final String codigo;
  final String titulo;
  final String detalle;
  final String responsable;
  final String estado;
  final String severidad;
  final String rolDestino;
  final String nivelDestino;
  final String dependenciaDestino;
  final int? horasHastaVencimiento;
  final bool activo;
  final DateTime creadoEn;
  final DateTime actualizadoEn;
  const TablaLegajosDocumentale({
    required this.id,
    required this.tipoRegistro,
    required this.categoria,
    required this.codigo,
    required this.titulo,
    required this.detalle,
    required this.responsable,
    required this.estado,
    required this.severidad,
    required this.rolDestino,
    required this.nivelDestino,
    required this.dependenciaDestino,
    this.horasHastaVencimiento,
    required this.activo,
    required this.creadoEn,
    required this.actualizadoEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['tipo_registro'] = Variable<String>(tipoRegistro);
    map['categoria'] = Variable<String>(categoria);
    map['codigo'] = Variable<String>(codigo);
    map['titulo'] = Variable<String>(titulo);
    map['detalle'] = Variable<String>(detalle);
    map['responsable'] = Variable<String>(responsable);
    map['estado'] = Variable<String>(estado);
    map['severidad'] = Variable<String>(severidad);
    map['rol_destino'] = Variable<String>(rolDestino);
    map['nivel_destino'] = Variable<String>(nivelDestino);
    map['dependencia_destino'] = Variable<String>(dependenciaDestino);
    if (!nullToAbsent || horasHastaVencimiento != null) {
      map['horas_hasta_vencimiento'] = Variable<int>(horasHastaVencimiento);
    }
    map['activo'] = Variable<bool>(activo);
    map['creado_en'] = Variable<DateTime>(creadoEn);
    map['actualizado_en'] = Variable<DateTime>(actualizadoEn);
    return map;
  }

  TablaLegajosDocumentalesCompanion toCompanion(bool nullToAbsent) {
    return TablaLegajosDocumentalesCompanion(
      id: Value(id),
      tipoRegistro: Value(tipoRegistro),
      categoria: Value(categoria),
      codigo: Value(codigo),
      titulo: Value(titulo),
      detalle: Value(detalle),
      responsable: Value(responsable),
      estado: Value(estado),
      severidad: Value(severidad),
      rolDestino: Value(rolDestino),
      nivelDestino: Value(nivelDestino),
      dependenciaDestino: Value(dependenciaDestino),
      horasHastaVencimiento: horasHastaVencimiento == null && nullToAbsent
          ? const Value.absent()
          : Value(horasHastaVencimiento),
      activo: Value(activo),
      creadoEn: Value(creadoEn),
      actualizadoEn: Value(actualizadoEn),
    );
  }

  factory TablaLegajosDocumentale.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TablaLegajosDocumentale(
      id: serializer.fromJson<int>(json['id']),
      tipoRegistro: serializer.fromJson<String>(json['tipoRegistro']),
      categoria: serializer.fromJson<String>(json['categoria']),
      codigo: serializer.fromJson<String>(json['codigo']),
      titulo: serializer.fromJson<String>(json['titulo']),
      detalle: serializer.fromJson<String>(json['detalle']),
      responsable: serializer.fromJson<String>(json['responsable']),
      estado: serializer.fromJson<String>(json['estado']),
      severidad: serializer.fromJson<String>(json['severidad']),
      rolDestino: serializer.fromJson<String>(json['rolDestino']),
      nivelDestino: serializer.fromJson<String>(json['nivelDestino']),
      dependenciaDestino: serializer.fromJson<String>(
        json['dependenciaDestino'],
      ),
      horasHastaVencimiento: serializer.fromJson<int?>(
        json['horasHastaVencimiento'],
      ),
      activo: serializer.fromJson<bool>(json['activo']),
      creadoEn: serializer.fromJson<DateTime>(json['creadoEn']),
      actualizadoEn: serializer.fromJson<DateTime>(json['actualizadoEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'tipoRegistro': serializer.toJson<String>(tipoRegistro),
      'categoria': serializer.toJson<String>(categoria),
      'codigo': serializer.toJson<String>(codigo),
      'titulo': serializer.toJson<String>(titulo),
      'detalle': serializer.toJson<String>(detalle),
      'responsable': serializer.toJson<String>(responsable),
      'estado': serializer.toJson<String>(estado),
      'severidad': serializer.toJson<String>(severidad),
      'rolDestino': serializer.toJson<String>(rolDestino),
      'nivelDestino': serializer.toJson<String>(nivelDestino),
      'dependenciaDestino': serializer.toJson<String>(dependenciaDestino),
      'horasHastaVencimiento': serializer.toJson<int?>(horasHastaVencimiento),
      'activo': serializer.toJson<bool>(activo),
      'creadoEn': serializer.toJson<DateTime>(creadoEn),
      'actualizadoEn': serializer.toJson<DateTime>(actualizadoEn),
    };
  }

  TablaLegajosDocumentale copyWith({
    int? id,
    String? tipoRegistro,
    String? categoria,
    String? codigo,
    String? titulo,
    String? detalle,
    String? responsable,
    String? estado,
    String? severidad,
    String? rolDestino,
    String? nivelDestino,
    String? dependenciaDestino,
    Value<int?> horasHastaVencimiento = const Value.absent(),
    bool? activo,
    DateTime? creadoEn,
    DateTime? actualizadoEn,
  }) => TablaLegajosDocumentale(
    id: id ?? this.id,
    tipoRegistro: tipoRegistro ?? this.tipoRegistro,
    categoria: categoria ?? this.categoria,
    codigo: codigo ?? this.codigo,
    titulo: titulo ?? this.titulo,
    detalle: detalle ?? this.detalle,
    responsable: responsable ?? this.responsable,
    estado: estado ?? this.estado,
    severidad: severidad ?? this.severidad,
    rolDestino: rolDestino ?? this.rolDestino,
    nivelDestino: nivelDestino ?? this.nivelDestino,
    dependenciaDestino: dependenciaDestino ?? this.dependenciaDestino,
    horasHastaVencimiento: horasHastaVencimiento.present
        ? horasHastaVencimiento.value
        : this.horasHastaVencimiento,
    activo: activo ?? this.activo,
    creadoEn: creadoEn ?? this.creadoEn,
    actualizadoEn: actualizadoEn ?? this.actualizadoEn,
  );
  TablaLegajosDocumentale copyWithCompanion(
    TablaLegajosDocumentalesCompanion data,
  ) {
    return TablaLegajosDocumentale(
      id: data.id.present ? data.id.value : this.id,
      tipoRegistro: data.tipoRegistro.present
          ? data.tipoRegistro.value
          : this.tipoRegistro,
      categoria: data.categoria.present ? data.categoria.value : this.categoria,
      codigo: data.codigo.present ? data.codigo.value : this.codigo,
      titulo: data.titulo.present ? data.titulo.value : this.titulo,
      detalle: data.detalle.present ? data.detalle.value : this.detalle,
      responsable: data.responsable.present
          ? data.responsable.value
          : this.responsable,
      estado: data.estado.present ? data.estado.value : this.estado,
      severidad: data.severidad.present ? data.severidad.value : this.severidad,
      rolDestino: data.rolDestino.present
          ? data.rolDestino.value
          : this.rolDestino,
      nivelDestino: data.nivelDestino.present
          ? data.nivelDestino.value
          : this.nivelDestino,
      dependenciaDestino: data.dependenciaDestino.present
          ? data.dependenciaDestino.value
          : this.dependenciaDestino,
      horasHastaVencimiento: data.horasHastaVencimiento.present
          ? data.horasHastaVencimiento.value
          : this.horasHastaVencimiento,
      activo: data.activo.present ? data.activo.value : this.activo,
      creadoEn: data.creadoEn.present ? data.creadoEn.value : this.creadoEn,
      actualizadoEn: data.actualizadoEn.present
          ? data.actualizadoEn.value
          : this.actualizadoEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TablaLegajosDocumentale(')
          ..write('id: $id, ')
          ..write('tipoRegistro: $tipoRegistro, ')
          ..write('categoria: $categoria, ')
          ..write('codigo: $codigo, ')
          ..write('titulo: $titulo, ')
          ..write('detalle: $detalle, ')
          ..write('responsable: $responsable, ')
          ..write('estado: $estado, ')
          ..write('severidad: $severidad, ')
          ..write('rolDestino: $rolDestino, ')
          ..write('nivelDestino: $nivelDestino, ')
          ..write('dependenciaDestino: $dependenciaDestino, ')
          ..write('horasHastaVencimiento: $horasHastaVencimiento, ')
          ..write('activo: $activo, ')
          ..write('creadoEn: $creadoEn, ')
          ..write('actualizadoEn: $actualizadoEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tipoRegistro,
    categoria,
    codigo,
    titulo,
    detalle,
    responsable,
    estado,
    severidad,
    rolDestino,
    nivelDestino,
    dependenciaDestino,
    horasHastaVencimiento,
    activo,
    creadoEn,
    actualizadoEn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TablaLegajosDocumentale &&
          other.id == this.id &&
          other.tipoRegistro == this.tipoRegistro &&
          other.categoria == this.categoria &&
          other.codigo == this.codigo &&
          other.titulo == this.titulo &&
          other.detalle == this.detalle &&
          other.responsable == this.responsable &&
          other.estado == this.estado &&
          other.severidad == this.severidad &&
          other.rolDestino == this.rolDestino &&
          other.nivelDestino == this.nivelDestino &&
          other.dependenciaDestino == this.dependenciaDestino &&
          other.horasHastaVencimiento == this.horasHastaVencimiento &&
          other.activo == this.activo &&
          other.creadoEn == this.creadoEn &&
          other.actualizadoEn == this.actualizadoEn);
}

class TablaLegajosDocumentalesCompanion
    extends UpdateCompanion<TablaLegajosDocumentale> {
  final Value<int> id;
  final Value<String> tipoRegistro;
  final Value<String> categoria;
  final Value<String> codigo;
  final Value<String> titulo;
  final Value<String> detalle;
  final Value<String> responsable;
  final Value<String> estado;
  final Value<String> severidad;
  final Value<String> rolDestino;
  final Value<String> nivelDestino;
  final Value<String> dependenciaDestino;
  final Value<int?> horasHastaVencimiento;
  final Value<bool> activo;
  final Value<DateTime> creadoEn;
  final Value<DateTime> actualizadoEn;
  const TablaLegajosDocumentalesCompanion({
    this.id = const Value.absent(),
    this.tipoRegistro = const Value.absent(),
    this.categoria = const Value.absent(),
    this.codigo = const Value.absent(),
    this.titulo = const Value.absent(),
    this.detalle = const Value.absent(),
    this.responsable = const Value.absent(),
    this.estado = const Value.absent(),
    this.severidad = const Value.absent(),
    this.rolDestino = const Value.absent(),
    this.nivelDestino = const Value.absent(),
    this.dependenciaDestino = const Value.absent(),
    this.horasHastaVencimiento = const Value.absent(),
    this.activo = const Value.absent(),
    this.creadoEn = const Value.absent(),
    this.actualizadoEn = const Value.absent(),
  });
  TablaLegajosDocumentalesCompanion.insert({
    this.id = const Value.absent(),
    required String tipoRegistro,
    required String categoria,
    required String codigo,
    required String titulo,
    required String detalle,
    required String responsable,
    required String estado,
    required String severidad,
    required String rolDestino,
    required String nivelDestino,
    required String dependenciaDestino,
    this.horasHastaVencimiento = const Value.absent(),
    this.activo = const Value.absent(),
    this.creadoEn = const Value.absent(),
    this.actualizadoEn = const Value.absent(),
  }) : tipoRegistro = Value(tipoRegistro),
       categoria = Value(categoria),
       codigo = Value(codigo),
       titulo = Value(titulo),
       detalle = Value(detalle),
       responsable = Value(responsable),
       estado = Value(estado),
       severidad = Value(severidad),
       rolDestino = Value(rolDestino),
       nivelDestino = Value(nivelDestino),
       dependenciaDestino = Value(dependenciaDestino);
  static Insertable<TablaLegajosDocumentale> custom({
    Expression<int>? id,
    Expression<String>? tipoRegistro,
    Expression<String>? categoria,
    Expression<String>? codigo,
    Expression<String>? titulo,
    Expression<String>? detalle,
    Expression<String>? responsable,
    Expression<String>? estado,
    Expression<String>? severidad,
    Expression<String>? rolDestino,
    Expression<String>? nivelDestino,
    Expression<String>? dependenciaDestino,
    Expression<int>? horasHastaVencimiento,
    Expression<bool>? activo,
    Expression<DateTime>? creadoEn,
    Expression<DateTime>? actualizadoEn,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tipoRegistro != null) 'tipo_registro': tipoRegistro,
      if (categoria != null) 'categoria': categoria,
      if (codigo != null) 'codigo': codigo,
      if (titulo != null) 'titulo': titulo,
      if (detalle != null) 'detalle': detalle,
      if (responsable != null) 'responsable': responsable,
      if (estado != null) 'estado': estado,
      if (severidad != null) 'severidad': severidad,
      if (rolDestino != null) 'rol_destino': rolDestino,
      if (nivelDestino != null) 'nivel_destino': nivelDestino,
      if (dependenciaDestino != null) 'dependencia_destino': dependenciaDestino,
      if (horasHastaVencimiento != null)
        'horas_hasta_vencimiento': horasHastaVencimiento,
      if (activo != null) 'activo': activo,
      if (creadoEn != null) 'creado_en': creadoEn,
      if (actualizadoEn != null) 'actualizado_en': actualizadoEn,
    });
  }

  TablaLegajosDocumentalesCompanion copyWith({
    Value<int>? id,
    Value<String>? tipoRegistro,
    Value<String>? categoria,
    Value<String>? codigo,
    Value<String>? titulo,
    Value<String>? detalle,
    Value<String>? responsable,
    Value<String>? estado,
    Value<String>? severidad,
    Value<String>? rolDestino,
    Value<String>? nivelDestino,
    Value<String>? dependenciaDestino,
    Value<int?>? horasHastaVencimiento,
    Value<bool>? activo,
    Value<DateTime>? creadoEn,
    Value<DateTime>? actualizadoEn,
  }) {
    return TablaLegajosDocumentalesCompanion(
      id: id ?? this.id,
      tipoRegistro: tipoRegistro ?? this.tipoRegistro,
      categoria: categoria ?? this.categoria,
      codigo: codigo ?? this.codigo,
      titulo: titulo ?? this.titulo,
      detalle: detalle ?? this.detalle,
      responsable: responsable ?? this.responsable,
      estado: estado ?? this.estado,
      severidad: severidad ?? this.severidad,
      rolDestino: rolDestino ?? this.rolDestino,
      nivelDestino: nivelDestino ?? this.nivelDestino,
      dependenciaDestino: dependenciaDestino ?? this.dependenciaDestino,
      horasHastaVencimiento:
          horasHastaVencimiento ?? this.horasHastaVencimiento,
      activo: activo ?? this.activo,
      creadoEn: creadoEn ?? this.creadoEn,
      actualizadoEn: actualizadoEn ?? this.actualizadoEn,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (tipoRegistro.present) {
      map['tipo_registro'] = Variable<String>(tipoRegistro.value);
    }
    if (categoria.present) {
      map['categoria'] = Variable<String>(categoria.value);
    }
    if (codigo.present) {
      map['codigo'] = Variable<String>(codigo.value);
    }
    if (titulo.present) {
      map['titulo'] = Variable<String>(titulo.value);
    }
    if (detalle.present) {
      map['detalle'] = Variable<String>(detalle.value);
    }
    if (responsable.present) {
      map['responsable'] = Variable<String>(responsable.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    if (severidad.present) {
      map['severidad'] = Variable<String>(severidad.value);
    }
    if (rolDestino.present) {
      map['rol_destino'] = Variable<String>(rolDestino.value);
    }
    if (nivelDestino.present) {
      map['nivel_destino'] = Variable<String>(nivelDestino.value);
    }
    if (dependenciaDestino.present) {
      map['dependencia_destino'] = Variable<String>(dependenciaDestino.value);
    }
    if (horasHastaVencimiento.present) {
      map['horas_hasta_vencimiento'] = Variable<int>(
        horasHastaVencimiento.value,
      );
    }
    if (activo.present) {
      map['activo'] = Variable<bool>(activo.value);
    }
    if (creadoEn.present) {
      map['creado_en'] = Variable<DateTime>(creadoEn.value);
    }
    if (actualizadoEn.present) {
      map['actualizado_en'] = Variable<DateTime>(actualizadoEn.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TablaLegajosDocumentalesCompanion(')
          ..write('id: $id, ')
          ..write('tipoRegistro: $tipoRegistro, ')
          ..write('categoria: $categoria, ')
          ..write('codigo: $codigo, ')
          ..write('titulo: $titulo, ')
          ..write('detalle: $detalle, ')
          ..write('responsable: $responsable, ')
          ..write('estado: $estado, ')
          ..write('severidad: $severidad, ')
          ..write('rolDestino: $rolDestino, ')
          ..write('nivelDestino: $nivelDestino, ')
          ..write('dependenciaDestino: $dependenciaDestino, ')
          ..write('horasHastaVencimiento: $horasHastaVencimiento, ')
          ..write('activo: $activo, ')
          ..write('creadoEn: $creadoEn, ')
          ..write('actualizadoEn: $actualizadoEn')
          ..write(')'))
        .toString();
  }
}

class $TablaNotasManualesTable extends TablaNotasManuales
    with TableInfo<$TablaNotasManualesTable, TablaNotasManuale> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TablaNotasManualesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _alumnoIdMeta = const VerificationMeta(
    'alumnoId',
  );
  @override
  late final GeneratedColumn<int> alumnoId = GeneratedColumn<int>(
    'alumno_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tabla_alumnos (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _cursoIdMeta = const VerificationMeta(
    'cursoId',
  );
  @override
  late final GeneratedColumn<int> cursoId = GeneratedColumn<int>(
    'curso_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _claveContextoMeta = const VerificationMeta(
    'claveContexto',
  );
  @override
  late final GeneratedColumn<String> claveContexto = GeneratedColumn<String>(
    'clave_contexto',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notaMeta = const VerificationMeta('nota');
  @override
  late final GeneratedColumn<String> nota = GeneratedColumn<String>(
    'nota',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actualizadoEnMeta = const VerificationMeta(
    'actualizadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> actualizadoEn =
      GeneratedColumn<DateTime>(
        'actualizado_en',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    alumnoId,
    cursoId,
    claveContexto,
    nota,
    actualizadoEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tabla_notas_manuales';
  @override
  VerificationContext validateIntegrity(
    Insertable<TablaNotasManuale> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('alumno_id')) {
      context.handle(
        _alumnoIdMeta,
        alumnoId.isAcceptableOrUnknown(data['alumno_id']!, _alumnoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_alumnoIdMeta);
    }
    if (data.containsKey('curso_id')) {
      context.handle(
        _cursoIdMeta,
        cursoId.isAcceptableOrUnknown(data['curso_id']!, _cursoIdMeta),
      );
    }
    if (data.containsKey('clave_contexto')) {
      context.handle(
        _claveContextoMeta,
        claveContexto.isAcceptableOrUnknown(
          data['clave_contexto']!,
          _claveContextoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_claveContextoMeta);
    }
    if (data.containsKey('nota')) {
      context.handle(
        _notaMeta,
        nota.isAcceptableOrUnknown(data['nota']!, _notaMeta),
      );
    } else if (isInserting) {
      context.missing(_notaMeta);
    }
    if (data.containsKey('actualizado_en')) {
      context.handle(
        _actualizadoEnMeta,
        actualizadoEn.isAcceptableOrUnknown(
          data['actualizado_en']!,
          _actualizadoEnMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {alumnoId, claveContexto},
  ];
  @override
  TablaNotasManuale map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TablaNotasManuale(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      alumnoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}alumno_id'],
      )!,
      cursoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}curso_id'],
      ),
      claveContexto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}clave_contexto'],
      )!,
      nota: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nota'],
      )!,
      actualizadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}actualizado_en'],
      )!,
    );
  }

  @override
  $TablaNotasManualesTable createAlias(String alias) {
    return $TablaNotasManualesTable(attachedDatabase, alias);
  }
}

class TablaNotasManuale extends DataClass
    implements Insertable<TablaNotasManuale> {
  final int id;
  final int alumnoId;
  final int? cursoId;
  final String claveContexto;
  final String nota;
  final DateTime actualizadoEn;
  const TablaNotasManuale({
    required this.id,
    required this.alumnoId,
    this.cursoId,
    required this.claveContexto,
    required this.nota,
    required this.actualizadoEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['alumno_id'] = Variable<int>(alumnoId);
    if (!nullToAbsent || cursoId != null) {
      map['curso_id'] = Variable<int>(cursoId);
    }
    map['clave_contexto'] = Variable<String>(claveContexto);
    map['nota'] = Variable<String>(nota);
    map['actualizado_en'] = Variable<DateTime>(actualizadoEn);
    return map;
  }

  TablaNotasManualesCompanion toCompanion(bool nullToAbsent) {
    return TablaNotasManualesCompanion(
      id: Value(id),
      alumnoId: Value(alumnoId),
      cursoId: cursoId == null && nullToAbsent
          ? const Value.absent()
          : Value(cursoId),
      claveContexto: Value(claveContexto),
      nota: Value(nota),
      actualizadoEn: Value(actualizadoEn),
    );
  }

  factory TablaNotasManuale.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TablaNotasManuale(
      id: serializer.fromJson<int>(json['id']),
      alumnoId: serializer.fromJson<int>(json['alumnoId']),
      cursoId: serializer.fromJson<int?>(json['cursoId']),
      claveContexto: serializer.fromJson<String>(json['claveContexto']),
      nota: serializer.fromJson<String>(json['nota']),
      actualizadoEn: serializer.fromJson<DateTime>(json['actualizadoEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'alumnoId': serializer.toJson<int>(alumnoId),
      'cursoId': serializer.toJson<int?>(cursoId),
      'claveContexto': serializer.toJson<String>(claveContexto),
      'nota': serializer.toJson<String>(nota),
      'actualizadoEn': serializer.toJson<DateTime>(actualizadoEn),
    };
  }

  TablaNotasManuale copyWith({
    int? id,
    int? alumnoId,
    Value<int?> cursoId = const Value.absent(),
    String? claveContexto,
    String? nota,
    DateTime? actualizadoEn,
  }) => TablaNotasManuale(
    id: id ?? this.id,
    alumnoId: alumnoId ?? this.alumnoId,
    cursoId: cursoId.present ? cursoId.value : this.cursoId,
    claveContexto: claveContexto ?? this.claveContexto,
    nota: nota ?? this.nota,
    actualizadoEn: actualizadoEn ?? this.actualizadoEn,
  );
  TablaNotasManuale copyWithCompanion(TablaNotasManualesCompanion data) {
    return TablaNotasManuale(
      id: data.id.present ? data.id.value : this.id,
      alumnoId: data.alumnoId.present ? data.alumnoId.value : this.alumnoId,
      cursoId: data.cursoId.present ? data.cursoId.value : this.cursoId,
      claveContexto: data.claveContexto.present
          ? data.claveContexto.value
          : this.claveContexto,
      nota: data.nota.present ? data.nota.value : this.nota,
      actualizadoEn: data.actualizadoEn.present
          ? data.actualizadoEn.value
          : this.actualizadoEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TablaNotasManuale(')
          ..write('id: $id, ')
          ..write('alumnoId: $alumnoId, ')
          ..write('cursoId: $cursoId, ')
          ..write('claveContexto: $claveContexto, ')
          ..write('nota: $nota, ')
          ..write('actualizadoEn: $actualizadoEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, alumnoId, cursoId, claveContexto, nota, actualizadoEn);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TablaNotasManuale &&
          other.id == this.id &&
          other.alumnoId == this.alumnoId &&
          other.cursoId == this.cursoId &&
          other.claveContexto == this.claveContexto &&
          other.nota == this.nota &&
          other.actualizadoEn == this.actualizadoEn);
}

class TablaNotasManualesCompanion extends UpdateCompanion<TablaNotasManuale> {
  final Value<int> id;
  final Value<int> alumnoId;
  final Value<int?> cursoId;
  final Value<String> claveContexto;
  final Value<String> nota;
  final Value<DateTime> actualizadoEn;
  const TablaNotasManualesCompanion({
    this.id = const Value.absent(),
    this.alumnoId = const Value.absent(),
    this.cursoId = const Value.absent(),
    this.claveContexto = const Value.absent(),
    this.nota = const Value.absent(),
    this.actualizadoEn = const Value.absent(),
  });
  TablaNotasManualesCompanion.insert({
    this.id = const Value.absent(),
    required int alumnoId,
    this.cursoId = const Value.absent(),
    required String claveContexto,
    required String nota,
    this.actualizadoEn = const Value.absent(),
  }) : alumnoId = Value(alumnoId),
       claveContexto = Value(claveContexto),
       nota = Value(nota);
  static Insertable<TablaNotasManuale> custom({
    Expression<int>? id,
    Expression<int>? alumnoId,
    Expression<int>? cursoId,
    Expression<String>? claveContexto,
    Expression<String>? nota,
    Expression<DateTime>? actualizadoEn,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (alumnoId != null) 'alumno_id': alumnoId,
      if (cursoId != null) 'curso_id': cursoId,
      if (claveContexto != null) 'clave_contexto': claveContexto,
      if (nota != null) 'nota': nota,
      if (actualizadoEn != null) 'actualizado_en': actualizadoEn,
    });
  }

  TablaNotasManualesCompanion copyWith({
    Value<int>? id,
    Value<int>? alumnoId,
    Value<int?>? cursoId,
    Value<String>? claveContexto,
    Value<String>? nota,
    Value<DateTime>? actualizadoEn,
  }) {
    return TablaNotasManualesCompanion(
      id: id ?? this.id,
      alumnoId: alumnoId ?? this.alumnoId,
      cursoId: cursoId ?? this.cursoId,
      claveContexto: claveContexto ?? this.claveContexto,
      nota: nota ?? this.nota,
      actualizadoEn: actualizadoEn ?? this.actualizadoEn,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (alumnoId.present) {
      map['alumno_id'] = Variable<int>(alumnoId.value);
    }
    if (cursoId.present) {
      map['curso_id'] = Variable<int>(cursoId.value);
    }
    if (claveContexto.present) {
      map['clave_contexto'] = Variable<String>(claveContexto.value);
    }
    if (nota.present) {
      map['nota'] = Variable<String>(nota.value);
    }
    if (actualizadoEn.present) {
      map['actualizado_en'] = Variable<DateTime>(actualizadoEn.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TablaNotasManualesCompanion(')
          ..write('id: $id, ')
          ..write('alumnoId: $alumnoId, ')
          ..write('cursoId: $cursoId, ')
          ..write('claveContexto: $claveContexto, ')
          ..write('nota: $nota, ')
          ..write('actualizadoEn: $actualizadoEn')
          ..write(')'))
        .toString();
  }
}

class $TablaNovedadesPreceptoriaTable extends TablaNovedadesPreceptoria
    with
        TableInfo<
          $TablaNovedadesPreceptoriaTable,
          TablaNovedadesPreceptoriaData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TablaNovedadesPreceptoriaTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _tipoNovedadMeta = const VerificationMeta(
    'tipoNovedad',
  );
  @override
  late final GeneratedColumn<String> tipoNovedad = GeneratedColumn<String>(
    'tipo_novedad',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 40,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoriaMeta = const VerificationMeta(
    'categoria',
  );
  @override
  late final GeneratedColumn<String> categoria = GeneratedColumn<String>(
    'categoria',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 30,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cursoReferenciaMeta = const VerificationMeta(
    'cursoReferencia',
  );
  @override
  late final GeneratedColumn<String> cursoReferencia = GeneratedColumn<String>(
    'curso_referencia',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _alumnoReferenciaMeta = const VerificationMeta(
    'alumnoReferencia',
  );
  @override
  late final GeneratedColumn<String> alumnoReferencia = GeneratedColumn<String>(
    'alumno_referencia',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
    'estado',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 40,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _prioridadMeta = const VerificationMeta(
    'prioridad',
  );
  @override
  late final GeneratedColumn<String> prioridad = GeneratedColumn<String>(
    'prioridad',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 20,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _responsableMeta = const VerificationMeta(
    'responsable',
  );
  @override
  late final GeneratedColumn<String> responsable = GeneratedColumn<String>(
    'responsable',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _observacionesMeta = const VerificationMeta(
    'observaciones',
  );
  @override
  late final GeneratedColumn<String> observaciones = GeneratedColumn<String>(
    'observaciones',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 800,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fechaSeguimientoMeta = const VerificationMeta(
    'fechaSeguimiento',
  );
  @override
  late final GeneratedColumn<DateTime> fechaSeguimiento =
      GeneratedColumn<DateTime>(
        'fecha_seguimiento',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _rolDestinoMeta = const VerificationMeta(
    'rolDestino',
  );
  @override
  late final GeneratedColumn<String> rolDestino = GeneratedColumn<String>(
    'rol_destino',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 40,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nivelDestinoMeta = const VerificationMeta(
    'nivelDestino',
  );
  @override
  late final GeneratedColumn<String> nivelDestino = GeneratedColumn<String>(
    'nivel_destino',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 30,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dependenciaDestinoMeta =
      const VerificationMeta('dependenciaDestino');
  @override
  late final GeneratedColumn<String> dependenciaDestino =
      GeneratedColumn<String>(
        'dependencia_destino',
        aliasedName,
        false,
        additionalChecks: GeneratedColumn.checkTextLength(
          minTextLength: 1,
          maxTextLength: 30,
        ),
        type: DriftSqlType.string,
        requiredDuringInsert: true,
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
  static const VerificationMeta _actualizadoEnMeta = const VerificationMeta(
    'actualizadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> actualizadoEn =
      GeneratedColumn<DateTime>(
        'actualizado_en',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tipoNovedad,
    categoria,
    cursoReferencia,
    alumnoReferencia,
    estado,
    prioridad,
    responsable,
    observaciones,
    fechaSeguimiento,
    rolDestino,
    nivelDestino,
    dependenciaDestino,
    activo,
    creadoEn,
    actualizadoEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tabla_novedades_preceptoria';
  @override
  VerificationContext validateIntegrity(
    Insertable<TablaNovedadesPreceptoriaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('tipo_novedad')) {
      context.handle(
        _tipoNovedadMeta,
        tipoNovedad.isAcceptableOrUnknown(
          data['tipo_novedad']!,
          _tipoNovedadMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tipoNovedadMeta);
    }
    if (data.containsKey('categoria')) {
      context.handle(
        _categoriaMeta,
        categoria.isAcceptableOrUnknown(data['categoria']!, _categoriaMeta),
      );
    } else if (isInserting) {
      context.missing(_categoriaMeta);
    }
    if (data.containsKey('curso_referencia')) {
      context.handle(
        _cursoReferenciaMeta,
        cursoReferencia.isAcceptableOrUnknown(
          data['curso_referencia']!,
          _cursoReferenciaMeta,
        ),
      );
    }
    if (data.containsKey('alumno_referencia')) {
      context.handle(
        _alumnoReferenciaMeta,
        alumnoReferencia.isAcceptableOrUnknown(
          data['alumno_referencia']!,
          _alumnoReferenciaMeta,
        ),
      );
    }
    if (data.containsKey('estado')) {
      context.handle(
        _estadoMeta,
        estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta),
      );
    } else if (isInserting) {
      context.missing(_estadoMeta);
    }
    if (data.containsKey('prioridad')) {
      context.handle(
        _prioridadMeta,
        prioridad.isAcceptableOrUnknown(data['prioridad']!, _prioridadMeta),
      );
    } else if (isInserting) {
      context.missing(_prioridadMeta);
    }
    if (data.containsKey('responsable')) {
      context.handle(
        _responsableMeta,
        responsable.isAcceptableOrUnknown(
          data['responsable']!,
          _responsableMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_responsableMeta);
    }
    if (data.containsKey('observaciones')) {
      context.handle(
        _observacionesMeta,
        observaciones.isAcceptableOrUnknown(
          data['observaciones']!,
          _observacionesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_observacionesMeta);
    }
    if (data.containsKey('fecha_seguimiento')) {
      context.handle(
        _fechaSeguimientoMeta,
        fechaSeguimiento.isAcceptableOrUnknown(
          data['fecha_seguimiento']!,
          _fechaSeguimientoMeta,
        ),
      );
    }
    if (data.containsKey('rol_destino')) {
      context.handle(
        _rolDestinoMeta,
        rolDestino.isAcceptableOrUnknown(data['rol_destino']!, _rolDestinoMeta),
      );
    } else if (isInserting) {
      context.missing(_rolDestinoMeta);
    }
    if (data.containsKey('nivel_destino')) {
      context.handle(
        _nivelDestinoMeta,
        nivelDestino.isAcceptableOrUnknown(
          data['nivel_destino']!,
          _nivelDestinoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nivelDestinoMeta);
    }
    if (data.containsKey('dependencia_destino')) {
      context.handle(
        _dependenciaDestinoMeta,
        dependenciaDestino.isAcceptableOrUnknown(
          data['dependencia_destino']!,
          _dependenciaDestinoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dependenciaDestinoMeta);
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
    if (data.containsKey('actualizado_en')) {
      context.handle(
        _actualizadoEnMeta,
        actualizadoEn.isAcceptableOrUnknown(
          data['actualizado_en']!,
          _actualizadoEnMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TablaNovedadesPreceptoriaData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TablaNovedadesPreceptoriaData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      tipoNovedad: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo_novedad'],
      )!,
      categoria: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}categoria'],
      )!,
      cursoReferencia: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}curso_referencia'],
      ),
      alumnoReferencia: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alumno_referencia'],
      ),
      estado: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado'],
      )!,
      prioridad: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prioridad'],
      )!,
      responsable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}responsable'],
      )!,
      observaciones: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observaciones'],
      )!,
      fechaSeguimiento: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha_seguimiento'],
      ),
      rolDestino: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rol_destino'],
      )!,
      nivelDestino: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nivel_destino'],
      )!,
      dependenciaDestino: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dependencia_destino'],
      )!,
      activo: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}activo'],
      )!,
      creadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}creado_en'],
      )!,
      actualizadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}actualizado_en'],
      )!,
    );
  }

  @override
  $TablaNovedadesPreceptoriaTable createAlias(String alias) {
    return $TablaNovedadesPreceptoriaTable(attachedDatabase, alias);
  }
}

class TablaNovedadesPreceptoriaData extends DataClass
    implements Insertable<TablaNovedadesPreceptoriaData> {
  final int id;
  final String tipoNovedad;
  final String categoria;
  final String? cursoReferencia;
  final String? alumnoReferencia;
  final String estado;
  final String prioridad;
  final String responsable;
  final String observaciones;
  final DateTime? fechaSeguimiento;
  final String rolDestino;
  final String nivelDestino;
  final String dependenciaDestino;
  final bool activo;
  final DateTime creadoEn;
  final DateTime actualizadoEn;
  const TablaNovedadesPreceptoriaData({
    required this.id,
    required this.tipoNovedad,
    required this.categoria,
    this.cursoReferencia,
    this.alumnoReferencia,
    required this.estado,
    required this.prioridad,
    required this.responsable,
    required this.observaciones,
    this.fechaSeguimiento,
    required this.rolDestino,
    required this.nivelDestino,
    required this.dependenciaDestino,
    required this.activo,
    required this.creadoEn,
    required this.actualizadoEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['tipo_novedad'] = Variable<String>(tipoNovedad);
    map['categoria'] = Variable<String>(categoria);
    if (!nullToAbsent || cursoReferencia != null) {
      map['curso_referencia'] = Variable<String>(cursoReferencia);
    }
    if (!nullToAbsent || alumnoReferencia != null) {
      map['alumno_referencia'] = Variable<String>(alumnoReferencia);
    }
    map['estado'] = Variable<String>(estado);
    map['prioridad'] = Variable<String>(prioridad);
    map['responsable'] = Variable<String>(responsable);
    map['observaciones'] = Variable<String>(observaciones);
    if (!nullToAbsent || fechaSeguimiento != null) {
      map['fecha_seguimiento'] = Variable<DateTime>(fechaSeguimiento);
    }
    map['rol_destino'] = Variable<String>(rolDestino);
    map['nivel_destino'] = Variable<String>(nivelDestino);
    map['dependencia_destino'] = Variable<String>(dependenciaDestino);
    map['activo'] = Variable<bool>(activo);
    map['creado_en'] = Variable<DateTime>(creadoEn);
    map['actualizado_en'] = Variable<DateTime>(actualizadoEn);
    return map;
  }

  TablaNovedadesPreceptoriaCompanion toCompanion(bool nullToAbsent) {
    return TablaNovedadesPreceptoriaCompanion(
      id: Value(id),
      tipoNovedad: Value(tipoNovedad),
      categoria: Value(categoria),
      cursoReferencia: cursoReferencia == null && nullToAbsent
          ? const Value.absent()
          : Value(cursoReferencia),
      alumnoReferencia: alumnoReferencia == null && nullToAbsent
          ? const Value.absent()
          : Value(alumnoReferencia),
      estado: Value(estado),
      prioridad: Value(prioridad),
      responsable: Value(responsable),
      observaciones: Value(observaciones),
      fechaSeguimiento: fechaSeguimiento == null && nullToAbsent
          ? const Value.absent()
          : Value(fechaSeguimiento),
      rolDestino: Value(rolDestino),
      nivelDestino: Value(nivelDestino),
      dependenciaDestino: Value(dependenciaDestino),
      activo: Value(activo),
      creadoEn: Value(creadoEn),
      actualizadoEn: Value(actualizadoEn),
    );
  }

  factory TablaNovedadesPreceptoriaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TablaNovedadesPreceptoriaData(
      id: serializer.fromJson<int>(json['id']),
      tipoNovedad: serializer.fromJson<String>(json['tipoNovedad']),
      categoria: serializer.fromJson<String>(json['categoria']),
      cursoReferencia: serializer.fromJson<String?>(json['cursoReferencia']),
      alumnoReferencia: serializer.fromJson<String?>(json['alumnoReferencia']),
      estado: serializer.fromJson<String>(json['estado']),
      prioridad: serializer.fromJson<String>(json['prioridad']),
      responsable: serializer.fromJson<String>(json['responsable']),
      observaciones: serializer.fromJson<String>(json['observaciones']),
      fechaSeguimiento: serializer.fromJson<DateTime?>(
        json['fechaSeguimiento'],
      ),
      rolDestino: serializer.fromJson<String>(json['rolDestino']),
      nivelDestino: serializer.fromJson<String>(json['nivelDestino']),
      dependenciaDestino: serializer.fromJson<String>(
        json['dependenciaDestino'],
      ),
      activo: serializer.fromJson<bool>(json['activo']),
      creadoEn: serializer.fromJson<DateTime>(json['creadoEn']),
      actualizadoEn: serializer.fromJson<DateTime>(json['actualizadoEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'tipoNovedad': serializer.toJson<String>(tipoNovedad),
      'categoria': serializer.toJson<String>(categoria),
      'cursoReferencia': serializer.toJson<String?>(cursoReferencia),
      'alumnoReferencia': serializer.toJson<String?>(alumnoReferencia),
      'estado': serializer.toJson<String>(estado),
      'prioridad': serializer.toJson<String>(prioridad),
      'responsable': serializer.toJson<String>(responsable),
      'observaciones': serializer.toJson<String>(observaciones),
      'fechaSeguimiento': serializer.toJson<DateTime?>(fechaSeguimiento),
      'rolDestino': serializer.toJson<String>(rolDestino),
      'nivelDestino': serializer.toJson<String>(nivelDestino),
      'dependenciaDestino': serializer.toJson<String>(dependenciaDestino),
      'activo': serializer.toJson<bool>(activo),
      'creadoEn': serializer.toJson<DateTime>(creadoEn),
      'actualizadoEn': serializer.toJson<DateTime>(actualizadoEn),
    };
  }

  TablaNovedadesPreceptoriaData copyWith({
    int? id,
    String? tipoNovedad,
    String? categoria,
    Value<String?> cursoReferencia = const Value.absent(),
    Value<String?> alumnoReferencia = const Value.absent(),
    String? estado,
    String? prioridad,
    String? responsable,
    String? observaciones,
    Value<DateTime?> fechaSeguimiento = const Value.absent(),
    String? rolDestino,
    String? nivelDestino,
    String? dependenciaDestino,
    bool? activo,
    DateTime? creadoEn,
    DateTime? actualizadoEn,
  }) => TablaNovedadesPreceptoriaData(
    id: id ?? this.id,
    tipoNovedad: tipoNovedad ?? this.tipoNovedad,
    categoria: categoria ?? this.categoria,
    cursoReferencia: cursoReferencia.present
        ? cursoReferencia.value
        : this.cursoReferencia,
    alumnoReferencia: alumnoReferencia.present
        ? alumnoReferencia.value
        : this.alumnoReferencia,
    estado: estado ?? this.estado,
    prioridad: prioridad ?? this.prioridad,
    responsable: responsable ?? this.responsable,
    observaciones: observaciones ?? this.observaciones,
    fechaSeguimiento: fechaSeguimiento.present
        ? fechaSeguimiento.value
        : this.fechaSeguimiento,
    rolDestino: rolDestino ?? this.rolDestino,
    nivelDestino: nivelDestino ?? this.nivelDestino,
    dependenciaDestino: dependenciaDestino ?? this.dependenciaDestino,
    activo: activo ?? this.activo,
    creadoEn: creadoEn ?? this.creadoEn,
    actualizadoEn: actualizadoEn ?? this.actualizadoEn,
  );
  TablaNovedadesPreceptoriaData copyWithCompanion(
    TablaNovedadesPreceptoriaCompanion data,
  ) {
    return TablaNovedadesPreceptoriaData(
      id: data.id.present ? data.id.value : this.id,
      tipoNovedad: data.tipoNovedad.present
          ? data.tipoNovedad.value
          : this.tipoNovedad,
      categoria: data.categoria.present ? data.categoria.value : this.categoria,
      cursoReferencia: data.cursoReferencia.present
          ? data.cursoReferencia.value
          : this.cursoReferencia,
      alumnoReferencia: data.alumnoReferencia.present
          ? data.alumnoReferencia.value
          : this.alumnoReferencia,
      estado: data.estado.present ? data.estado.value : this.estado,
      prioridad: data.prioridad.present ? data.prioridad.value : this.prioridad,
      responsable: data.responsable.present
          ? data.responsable.value
          : this.responsable,
      observaciones: data.observaciones.present
          ? data.observaciones.value
          : this.observaciones,
      fechaSeguimiento: data.fechaSeguimiento.present
          ? data.fechaSeguimiento.value
          : this.fechaSeguimiento,
      rolDestino: data.rolDestino.present
          ? data.rolDestino.value
          : this.rolDestino,
      nivelDestino: data.nivelDestino.present
          ? data.nivelDestino.value
          : this.nivelDestino,
      dependenciaDestino: data.dependenciaDestino.present
          ? data.dependenciaDestino.value
          : this.dependenciaDestino,
      activo: data.activo.present ? data.activo.value : this.activo,
      creadoEn: data.creadoEn.present ? data.creadoEn.value : this.creadoEn,
      actualizadoEn: data.actualizadoEn.present
          ? data.actualizadoEn.value
          : this.actualizadoEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TablaNovedadesPreceptoriaData(')
          ..write('id: $id, ')
          ..write('tipoNovedad: $tipoNovedad, ')
          ..write('categoria: $categoria, ')
          ..write('cursoReferencia: $cursoReferencia, ')
          ..write('alumnoReferencia: $alumnoReferencia, ')
          ..write('estado: $estado, ')
          ..write('prioridad: $prioridad, ')
          ..write('responsable: $responsable, ')
          ..write('observaciones: $observaciones, ')
          ..write('fechaSeguimiento: $fechaSeguimiento, ')
          ..write('rolDestino: $rolDestino, ')
          ..write('nivelDestino: $nivelDestino, ')
          ..write('dependenciaDestino: $dependenciaDestino, ')
          ..write('activo: $activo, ')
          ..write('creadoEn: $creadoEn, ')
          ..write('actualizadoEn: $actualizadoEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tipoNovedad,
    categoria,
    cursoReferencia,
    alumnoReferencia,
    estado,
    prioridad,
    responsable,
    observaciones,
    fechaSeguimiento,
    rolDestino,
    nivelDestino,
    dependenciaDestino,
    activo,
    creadoEn,
    actualizadoEn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TablaNovedadesPreceptoriaData &&
          other.id == this.id &&
          other.tipoNovedad == this.tipoNovedad &&
          other.categoria == this.categoria &&
          other.cursoReferencia == this.cursoReferencia &&
          other.alumnoReferencia == this.alumnoReferencia &&
          other.estado == this.estado &&
          other.prioridad == this.prioridad &&
          other.responsable == this.responsable &&
          other.observaciones == this.observaciones &&
          other.fechaSeguimiento == this.fechaSeguimiento &&
          other.rolDestino == this.rolDestino &&
          other.nivelDestino == this.nivelDestino &&
          other.dependenciaDestino == this.dependenciaDestino &&
          other.activo == this.activo &&
          other.creadoEn == this.creadoEn &&
          other.actualizadoEn == this.actualizadoEn);
}

class TablaNovedadesPreceptoriaCompanion
    extends UpdateCompanion<TablaNovedadesPreceptoriaData> {
  final Value<int> id;
  final Value<String> tipoNovedad;
  final Value<String> categoria;
  final Value<String?> cursoReferencia;
  final Value<String?> alumnoReferencia;
  final Value<String> estado;
  final Value<String> prioridad;
  final Value<String> responsable;
  final Value<String> observaciones;
  final Value<DateTime?> fechaSeguimiento;
  final Value<String> rolDestino;
  final Value<String> nivelDestino;
  final Value<String> dependenciaDestino;
  final Value<bool> activo;
  final Value<DateTime> creadoEn;
  final Value<DateTime> actualizadoEn;
  const TablaNovedadesPreceptoriaCompanion({
    this.id = const Value.absent(),
    this.tipoNovedad = const Value.absent(),
    this.categoria = const Value.absent(),
    this.cursoReferencia = const Value.absent(),
    this.alumnoReferencia = const Value.absent(),
    this.estado = const Value.absent(),
    this.prioridad = const Value.absent(),
    this.responsable = const Value.absent(),
    this.observaciones = const Value.absent(),
    this.fechaSeguimiento = const Value.absent(),
    this.rolDestino = const Value.absent(),
    this.nivelDestino = const Value.absent(),
    this.dependenciaDestino = const Value.absent(),
    this.activo = const Value.absent(),
    this.creadoEn = const Value.absent(),
    this.actualizadoEn = const Value.absent(),
  });
  TablaNovedadesPreceptoriaCompanion.insert({
    this.id = const Value.absent(),
    required String tipoNovedad,
    required String categoria,
    this.cursoReferencia = const Value.absent(),
    this.alumnoReferencia = const Value.absent(),
    required String estado,
    required String prioridad,
    required String responsable,
    required String observaciones,
    this.fechaSeguimiento = const Value.absent(),
    required String rolDestino,
    required String nivelDestino,
    required String dependenciaDestino,
    this.activo = const Value.absent(),
    this.creadoEn = const Value.absent(),
    this.actualizadoEn = const Value.absent(),
  }) : tipoNovedad = Value(tipoNovedad),
       categoria = Value(categoria),
       estado = Value(estado),
       prioridad = Value(prioridad),
       responsable = Value(responsable),
       observaciones = Value(observaciones),
       rolDestino = Value(rolDestino),
       nivelDestino = Value(nivelDestino),
       dependenciaDestino = Value(dependenciaDestino);
  static Insertable<TablaNovedadesPreceptoriaData> custom({
    Expression<int>? id,
    Expression<String>? tipoNovedad,
    Expression<String>? categoria,
    Expression<String>? cursoReferencia,
    Expression<String>? alumnoReferencia,
    Expression<String>? estado,
    Expression<String>? prioridad,
    Expression<String>? responsable,
    Expression<String>? observaciones,
    Expression<DateTime>? fechaSeguimiento,
    Expression<String>? rolDestino,
    Expression<String>? nivelDestino,
    Expression<String>? dependenciaDestino,
    Expression<bool>? activo,
    Expression<DateTime>? creadoEn,
    Expression<DateTime>? actualizadoEn,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tipoNovedad != null) 'tipo_novedad': tipoNovedad,
      if (categoria != null) 'categoria': categoria,
      if (cursoReferencia != null) 'curso_referencia': cursoReferencia,
      if (alumnoReferencia != null) 'alumno_referencia': alumnoReferencia,
      if (estado != null) 'estado': estado,
      if (prioridad != null) 'prioridad': prioridad,
      if (responsable != null) 'responsable': responsable,
      if (observaciones != null) 'observaciones': observaciones,
      if (fechaSeguimiento != null) 'fecha_seguimiento': fechaSeguimiento,
      if (rolDestino != null) 'rol_destino': rolDestino,
      if (nivelDestino != null) 'nivel_destino': nivelDestino,
      if (dependenciaDestino != null) 'dependencia_destino': dependenciaDestino,
      if (activo != null) 'activo': activo,
      if (creadoEn != null) 'creado_en': creadoEn,
      if (actualizadoEn != null) 'actualizado_en': actualizadoEn,
    });
  }

  TablaNovedadesPreceptoriaCompanion copyWith({
    Value<int>? id,
    Value<String>? tipoNovedad,
    Value<String>? categoria,
    Value<String?>? cursoReferencia,
    Value<String?>? alumnoReferencia,
    Value<String>? estado,
    Value<String>? prioridad,
    Value<String>? responsable,
    Value<String>? observaciones,
    Value<DateTime?>? fechaSeguimiento,
    Value<String>? rolDestino,
    Value<String>? nivelDestino,
    Value<String>? dependenciaDestino,
    Value<bool>? activo,
    Value<DateTime>? creadoEn,
    Value<DateTime>? actualizadoEn,
  }) {
    return TablaNovedadesPreceptoriaCompanion(
      id: id ?? this.id,
      tipoNovedad: tipoNovedad ?? this.tipoNovedad,
      categoria: categoria ?? this.categoria,
      cursoReferencia: cursoReferencia ?? this.cursoReferencia,
      alumnoReferencia: alumnoReferencia ?? this.alumnoReferencia,
      estado: estado ?? this.estado,
      prioridad: prioridad ?? this.prioridad,
      responsable: responsable ?? this.responsable,
      observaciones: observaciones ?? this.observaciones,
      fechaSeguimiento: fechaSeguimiento ?? this.fechaSeguimiento,
      rolDestino: rolDestino ?? this.rolDestino,
      nivelDestino: nivelDestino ?? this.nivelDestino,
      dependenciaDestino: dependenciaDestino ?? this.dependenciaDestino,
      activo: activo ?? this.activo,
      creadoEn: creadoEn ?? this.creadoEn,
      actualizadoEn: actualizadoEn ?? this.actualizadoEn,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (tipoNovedad.present) {
      map['tipo_novedad'] = Variable<String>(tipoNovedad.value);
    }
    if (categoria.present) {
      map['categoria'] = Variable<String>(categoria.value);
    }
    if (cursoReferencia.present) {
      map['curso_referencia'] = Variable<String>(cursoReferencia.value);
    }
    if (alumnoReferencia.present) {
      map['alumno_referencia'] = Variable<String>(alumnoReferencia.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    if (prioridad.present) {
      map['prioridad'] = Variable<String>(prioridad.value);
    }
    if (responsable.present) {
      map['responsable'] = Variable<String>(responsable.value);
    }
    if (observaciones.present) {
      map['observaciones'] = Variable<String>(observaciones.value);
    }
    if (fechaSeguimiento.present) {
      map['fecha_seguimiento'] = Variable<DateTime>(fechaSeguimiento.value);
    }
    if (rolDestino.present) {
      map['rol_destino'] = Variable<String>(rolDestino.value);
    }
    if (nivelDestino.present) {
      map['nivel_destino'] = Variable<String>(nivelDestino.value);
    }
    if (dependenciaDestino.present) {
      map['dependencia_destino'] = Variable<String>(dependenciaDestino.value);
    }
    if (activo.present) {
      map['activo'] = Variable<bool>(activo.value);
    }
    if (creadoEn.present) {
      map['creado_en'] = Variable<DateTime>(creadoEn.value);
    }
    if (actualizadoEn.present) {
      map['actualizado_en'] = Variable<DateTime>(actualizadoEn.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TablaNovedadesPreceptoriaCompanion(')
          ..write('id: $id, ')
          ..write('tipoNovedad: $tipoNovedad, ')
          ..write('categoria: $categoria, ')
          ..write('cursoReferencia: $cursoReferencia, ')
          ..write('alumnoReferencia: $alumnoReferencia, ')
          ..write('estado: $estado, ')
          ..write('prioridad: $prioridad, ')
          ..write('responsable: $responsable, ')
          ..write('observaciones: $observaciones, ')
          ..write('fechaSeguimiento: $fechaSeguimiento, ')
          ..write('rolDestino: $rolDestino, ')
          ..write('nivelDestino: $nivelDestino, ')
          ..write('dependenciaDestino: $dependenciaDestino, ')
          ..write('activo: $activo, ')
          ..write('creadoEn: $creadoEn, ')
          ..write('actualizadoEn: $actualizadoEn')
          ..write(')'))
        .toString();
  }
}

class $TablaResponsablesGestionTable extends TablaResponsablesGestion
    with
        TableInfo<
          $TablaResponsablesGestionTable,
          TablaResponsablesGestionData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TablaResponsablesGestionTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _areaMeta = const VerificationMeta('area');
  @override
  late final GeneratedColumn<String> area = GeneratedColumn<String>(
    'area',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rolDestinoMeta = const VerificationMeta(
    'rolDestino',
  );
  @override
  late final GeneratedColumn<String> rolDestino = GeneratedColumn<String>(
    'rol_destino',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 40,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nivelDestinoMeta = const VerificationMeta(
    'nivelDestino',
  );
  @override
  late final GeneratedColumn<String> nivelDestino = GeneratedColumn<String>(
    'nivel_destino',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 30,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dependenciaDestinoMeta =
      const VerificationMeta('dependenciaDestino');
  @override
  late final GeneratedColumn<String> dependenciaDestino =
      GeneratedColumn<String>(
        'dependencia_destino',
        aliasedName,
        false,
        additionalChecks: GeneratedColumn.checkTextLength(
          minTextLength: 1,
          maxTextLength: 30,
        ),
        type: DriftSqlType.string,
        requiredDuringInsert: true,
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
    area,
    rolDestino,
    nivelDestino,
    dependenciaDestino,
    activo,
    creadoEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tabla_responsables_gestion';
  @override
  VerificationContext validateIntegrity(
    Insertable<TablaResponsablesGestionData> instance, {
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
    if (data.containsKey('area')) {
      context.handle(
        _areaMeta,
        area.isAcceptableOrUnknown(data['area']!, _areaMeta),
      );
    } else if (isInserting) {
      context.missing(_areaMeta);
    }
    if (data.containsKey('rol_destino')) {
      context.handle(
        _rolDestinoMeta,
        rolDestino.isAcceptableOrUnknown(data['rol_destino']!, _rolDestinoMeta),
      );
    } else if (isInserting) {
      context.missing(_rolDestinoMeta);
    }
    if (data.containsKey('nivel_destino')) {
      context.handle(
        _nivelDestinoMeta,
        nivelDestino.isAcceptableOrUnknown(
          data['nivel_destino']!,
          _nivelDestinoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nivelDestinoMeta);
    }
    if (data.containsKey('dependencia_destino')) {
      context.handle(
        _dependenciaDestinoMeta,
        dependenciaDestino.isAcceptableOrUnknown(
          data['dependencia_destino']!,
          _dependenciaDestinoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dependenciaDestinoMeta);
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
  TablaResponsablesGestionData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TablaResponsablesGestionData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      area: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}area'],
      )!,
      rolDestino: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rol_destino'],
      )!,
      nivelDestino: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nivel_destino'],
      )!,
      dependenciaDestino: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dependencia_destino'],
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
  $TablaResponsablesGestionTable createAlias(String alias) {
    return $TablaResponsablesGestionTable(attachedDatabase, alias);
  }
}

class TablaResponsablesGestionData extends DataClass
    implements Insertable<TablaResponsablesGestionData> {
  final int id;
  final String nombre;
  final String area;
  final String rolDestino;
  final String nivelDestino;
  final String dependenciaDestino;
  final bool activo;
  final DateTime creadoEn;
  const TablaResponsablesGestionData({
    required this.id,
    required this.nombre,
    required this.area,
    required this.rolDestino,
    required this.nivelDestino,
    required this.dependenciaDestino,
    required this.activo,
    required this.creadoEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nombre'] = Variable<String>(nombre);
    map['area'] = Variable<String>(area);
    map['rol_destino'] = Variable<String>(rolDestino);
    map['nivel_destino'] = Variable<String>(nivelDestino);
    map['dependencia_destino'] = Variable<String>(dependenciaDestino);
    map['activo'] = Variable<bool>(activo);
    map['creado_en'] = Variable<DateTime>(creadoEn);
    return map;
  }

  TablaResponsablesGestionCompanion toCompanion(bool nullToAbsent) {
    return TablaResponsablesGestionCompanion(
      id: Value(id),
      nombre: Value(nombre),
      area: Value(area),
      rolDestino: Value(rolDestino),
      nivelDestino: Value(nivelDestino),
      dependenciaDestino: Value(dependenciaDestino),
      activo: Value(activo),
      creadoEn: Value(creadoEn),
    );
  }

  factory TablaResponsablesGestionData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TablaResponsablesGestionData(
      id: serializer.fromJson<int>(json['id']),
      nombre: serializer.fromJson<String>(json['nombre']),
      area: serializer.fromJson<String>(json['area']),
      rolDestino: serializer.fromJson<String>(json['rolDestino']),
      nivelDestino: serializer.fromJson<String>(json['nivelDestino']),
      dependenciaDestino: serializer.fromJson<String>(
        json['dependenciaDestino'],
      ),
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
      'area': serializer.toJson<String>(area),
      'rolDestino': serializer.toJson<String>(rolDestino),
      'nivelDestino': serializer.toJson<String>(nivelDestino),
      'dependenciaDestino': serializer.toJson<String>(dependenciaDestino),
      'activo': serializer.toJson<bool>(activo),
      'creadoEn': serializer.toJson<DateTime>(creadoEn),
    };
  }

  TablaResponsablesGestionData copyWith({
    int? id,
    String? nombre,
    String? area,
    String? rolDestino,
    String? nivelDestino,
    String? dependenciaDestino,
    bool? activo,
    DateTime? creadoEn,
  }) => TablaResponsablesGestionData(
    id: id ?? this.id,
    nombre: nombre ?? this.nombre,
    area: area ?? this.area,
    rolDestino: rolDestino ?? this.rolDestino,
    nivelDestino: nivelDestino ?? this.nivelDestino,
    dependenciaDestino: dependenciaDestino ?? this.dependenciaDestino,
    activo: activo ?? this.activo,
    creadoEn: creadoEn ?? this.creadoEn,
  );
  TablaResponsablesGestionData copyWithCompanion(
    TablaResponsablesGestionCompanion data,
  ) {
    return TablaResponsablesGestionData(
      id: data.id.present ? data.id.value : this.id,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      area: data.area.present ? data.area.value : this.area,
      rolDestino: data.rolDestino.present
          ? data.rolDestino.value
          : this.rolDestino,
      nivelDestino: data.nivelDestino.present
          ? data.nivelDestino.value
          : this.nivelDestino,
      dependenciaDestino: data.dependenciaDestino.present
          ? data.dependenciaDestino.value
          : this.dependenciaDestino,
      activo: data.activo.present ? data.activo.value : this.activo,
      creadoEn: data.creadoEn.present ? data.creadoEn.value : this.creadoEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TablaResponsablesGestionData(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('area: $area, ')
          ..write('rolDestino: $rolDestino, ')
          ..write('nivelDestino: $nivelDestino, ')
          ..write('dependenciaDestino: $dependenciaDestino, ')
          ..write('activo: $activo, ')
          ..write('creadoEn: $creadoEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nombre,
    area,
    rolDestino,
    nivelDestino,
    dependenciaDestino,
    activo,
    creadoEn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TablaResponsablesGestionData &&
          other.id == this.id &&
          other.nombre == this.nombre &&
          other.area == this.area &&
          other.rolDestino == this.rolDestino &&
          other.nivelDestino == this.nivelDestino &&
          other.dependenciaDestino == this.dependenciaDestino &&
          other.activo == this.activo &&
          other.creadoEn == this.creadoEn);
}

class TablaResponsablesGestionCompanion
    extends UpdateCompanion<TablaResponsablesGestionData> {
  final Value<int> id;
  final Value<String> nombre;
  final Value<String> area;
  final Value<String> rolDestino;
  final Value<String> nivelDestino;
  final Value<String> dependenciaDestino;
  final Value<bool> activo;
  final Value<DateTime> creadoEn;
  const TablaResponsablesGestionCompanion({
    this.id = const Value.absent(),
    this.nombre = const Value.absent(),
    this.area = const Value.absent(),
    this.rolDestino = const Value.absent(),
    this.nivelDestino = const Value.absent(),
    this.dependenciaDestino = const Value.absent(),
    this.activo = const Value.absent(),
    this.creadoEn = const Value.absent(),
  });
  TablaResponsablesGestionCompanion.insert({
    this.id = const Value.absent(),
    required String nombre,
    required String area,
    required String rolDestino,
    required String nivelDestino,
    required String dependenciaDestino,
    this.activo = const Value.absent(),
    this.creadoEn = const Value.absent(),
  }) : nombre = Value(nombre),
       area = Value(area),
       rolDestino = Value(rolDestino),
       nivelDestino = Value(nivelDestino),
       dependenciaDestino = Value(dependenciaDestino);
  static Insertable<TablaResponsablesGestionData> custom({
    Expression<int>? id,
    Expression<String>? nombre,
    Expression<String>? area,
    Expression<String>? rolDestino,
    Expression<String>? nivelDestino,
    Expression<String>? dependenciaDestino,
    Expression<bool>? activo,
    Expression<DateTime>? creadoEn,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombre != null) 'nombre': nombre,
      if (area != null) 'area': area,
      if (rolDestino != null) 'rol_destino': rolDestino,
      if (nivelDestino != null) 'nivel_destino': nivelDestino,
      if (dependenciaDestino != null) 'dependencia_destino': dependenciaDestino,
      if (activo != null) 'activo': activo,
      if (creadoEn != null) 'creado_en': creadoEn,
    });
  }

  TablaResponsablesGestionCompanion copyWith({
    Value<int>? id,
    Value<String>? nombre,
    Value<String>? area,
    Value<String>? rolDestino,
    Value<String>? nivelDestino,
    Value<String>? dependenciaDestino,
    Value<bool>? activo,
    Value<DateTime>? creadoEn,
  }) {
    return TablaResponsablesGestionCompanion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      area: area ?? this.area,
      rolDestino: rolDestino ?? this.rolDestino,
      nivelDestino: nivelDestino ?? this.nivelDestino,
      dependenciaDestino: dependenciaDestino ?? this.dependenciaDestino,
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
    if (area.present) {
      map['area'] = Variable<String>(area.value);
    }
    if (rolDestino.present) {
      map['rol_destino'] = Variable<String>(rolDestino.value);
    }
    if (nivelDestino.present) {
      map['nivel_destino'] = Variable<String>(nivelDestino.value);
    }
    if (dependenciaDestino.present) {
      map['dependencia_destino'] = Variable<String>(dependenciaDestino.value);
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
    return (StringBuffer('TablaResponsablesGestionCompanion(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('area: $area, ')
          ..write('rolDestino: $rolDestino, ')
          ..write('nivelDestino: $nivelDestino, ')
          ..write('dependenciaDestino: $dependenciaDestino, ')
          ..write('activo: $activo, ')
          ..write('creadoEn: $creadoEn')
          ..write(')'))
        .toString();
  }
}

class $TablaRecursosBibliotecaTable extends TablaRecursosBiblioteca
    with TableInfo<$TablaRecursosBibliotecaTable, TablaRecursosBibliotecaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TablaRecursosBibliotecaTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _tipoRecursoMeta = const VerificationMeta(
    'tipoRecurso',
  );
  @override
  late final GeneratedColumn<String> tipoRecurso = GeneratedColumn<String>(
    'tipo_recurso',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 40,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoriaMeta = const VerificationMeta(
    'categoria',
  );
  @override
  late final GeneratedColumn<String> categoria = GeneratedColumn<String>(
    'categoria',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 30,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codigoMeta = const VerificationMeta('codigo');
  @override
  late final GeneratedColumn<String> codigo = GeneratedColumn<String>(
    'codigo',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 40,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tituloMeta = const VerificationMeta('titulo');
  @override
  late final GeneratedColumn<String> titulo = GeneratedColumn<String>(
    'titulo',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 180,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _autorReferenciaMeta = const VerificationMeta(
    'autorReferencia',
  );
  @override
  late final GeneratedColumn<String> autorReferencia = GeneratedColumn<String>(
    'autor_referencia',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 160,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
    'estado',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 40,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _responsableMeta = const VerificationMeta(
    'responsable',
  );
  @override
  late final GeneratedColumn<String> responsable = GeneratedColumn<String>(
    'responsable',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _destinatarioMeta = const VerificationMeta(
    'destinatario',
  );
  @override
  late final GeneratedColumn<String> destinatario = GeneratedColumn<String>(
    'destinatario',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cursoReferenciaMeta = const VerificationMeta(
    'cursoReferencia',
  );
  @override
  late final GeneratedColumn<String> cursoReferencia = GeneratedColumn<String>(
    'curso_referencia',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cantidadTotalMeta = const VerificationMeta(
    'cantidadTotal',
  );
  @override
  late final GeneratedColumn<int> cantidadTotal = GeneratedColumn<int>(
    'cantidad_total',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _cantidadDisponibleMeta =
      const VerificationMeta('cantidadDisponible');
  @override
  late final GeneratedColumn<int> cantidadDisponible = GeneratedColumn<int>(
    'cantidad_disponible',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _fechaVencimientoMeta = const VerificationMeta(
    'fechaVencimiento',
  );
  @override
  late final GeneratedColumn<DateTime> fechaVencimiento =
      GeneratedColumn<DateTime>(
        'fecha_vencimiento',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _observacionesMeta = const VerificationMeta(
    'observaciones',
  );
  @override
  late final GeneratedColumn<String> observaciones = GeneratedColumn<String>(
    'observaciones',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 800,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rolDestinoMeta = const VerificationMeta(
    'rolDestino',
  );
  @override
  late final GeneratedColumn<String> rolDestino = GeneratedColumn<String>(
    'rol_destino',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 40,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nivelDestinoMeta = const VerificationMeta(
    'nivelDestino',
  );
  @override
  late final GeneratedColumn<String> nivelDestino = GeneratedColumn<String>(
    'nivel_destino',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 30,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dependenciaDestinoMeta =
      const VerificationMeta('dependenciaDestino');
  @override
  late final GeneratedColumn<String> dependenciaDestino =
      GeneratedColumn<String>(
        'dependencia_destino',
        aliasedName,
        false,
        additionalChecks: GeneratedColumn.checkTextLength(
          minTextLength: 1,
          maxTextLength: 30,
        ),
        type: DriftSqlType.string,
        requiredDuringInsert: true,
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
  static const VerificationMeta _actualizadoEnMeta = const VerificationMeta(
    'actualizadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> actualizadoEn =
      GeneratedColumn<DateTime>(
        'actualizado_en',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tipoRecurso,
    categoria,
    codigo,
    titulo,
    autorReferencia,
    estado,
    responsable,
    destinatario,
    cursoReferencia,
    cantidadTotal,
    cantidadDisponible,
    fechaVencimiento,
    observaciones,
    rolDestino,
    nivelDestino,
    dependenciaDestino,
    activo,
    creadoEn,
    actualizadoEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tabla_recursos_biblioteca';
  @override
  VerificationContext validateIntegrity(
    Insertable<TablaRecursosBibliotecaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('tipo_recurso')) {
      context.handle(
        _tipoRecursoMeta,
        tipoRecurso.isAcceptableOrUnknown(
          data['tipo_recurso']!,
          _tipoRecursoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tipoRecursoMeta);
    }
    if (data.containsKey('categoria')) {
      context.handle(
        _categoriaMeta,
        categoria.isAcceptableOrUnknown(data['categoria']!, _categoriaMeta),
      );
    } else if (isInserting) {
      context.missing(_categoriaMeta);
    }
    if (data.containsKey('codigo')) {
      context.handle(
        _codigoMeta,
        codigo.isAcceptableOrUnknown(data['codigo']!, _codigoMeta),
      );
    } else if (isInserting) {
      context.missing(_codigoMeta);
    }
    if (data.containsKey('titulo')) {
      context.handle(
        _tituloMeta,
        titulo.isAcceptableOrUnknown(data['titulo']!, _tituloMeta),
      );
    } else if (isInserting) {
      context.missing(_tituloMeta);
    }
    if (data.containsKey('autor_referencia')) {
      context.handle(
        _autorReferenciaMeta,
        autorReferencia.isAcceptableOrUnknown(
          data['autor_referencia']!,
          _autorReferenciaMeta,
        ),
      );
    }
    if (data.containsKey('estado')) {
      context.handle(
        _estadoMeta,
        estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta),
      );
    } else if (isInserting) {
      context.missing(_estadoMeta);
    }
    if (data.containsKey('responsable')) {
      context.handle(
        _responsableMeta,
        responsable.isAcceptableOrUnknown(
          data['responsable']!,
          _responsableMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_responsableMeta);
    }
    if (data.containsKey('destinatario')) {
      context.handle(
        _destinatarioMeta,
        destinatario.isAcceptableOrUnknown(
          data['destinatario']!,
          _destinatarioMeta,
        ),
      );
    }
    if (data.containsKey('curso_referencia')) {
      context.handle(
        _cursoReferenciaMeta,
        cursoReferencia.isAcceptableOrUnknown(
          data['curso_referencia']!,
          _cursoReferenciaMeta,
        ),
      );
    }
    if (data.containsKey('cantidad_total')) {
      context.handle(
        _cantidadTotalMeta,
        cantidadTotal.isAcceptableOrUnknown(
          data['cantidad_total']!,
          _cantidadTotalMeta,
        ),
      );
    }
    if (data.containsKey('cantidad_disponible')) {
      context.handle(
        _cantidadDisponibleMeta,
        cantidadDisponible.isAcceptableOrUnknown(
          data['cantidad_disponible']!,
          _cantidadDisponibleMeta,
        ),
      );
    }
    if (data.containsKey('fecha_vencimiento')) {
      context.handle(
        _fechaVencimientoMeta,
        fechaVencimiento.isAcceptableOrUnknown(
          data['fecha_vencimiento']!,
          _fechaVencimientoMeta,
        ),
      );
    }
    if (data.containsKey('observaciones')) {
      context.handle(
        _observacionesMeta,
        observaciones.isAcceptableOrUnknown(
          data['observaciones']!,
          _observacionesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_observacionesMeta);
    }
    if (data.containsKey('rol_destino')) {
      context.handle(
        _rolDestinoMeta,
        rolDestino.isAcceptableOrUnknown(data['rol_destino']!, _rolDestinoMeta),
      );
    } else if (isInserting) {
      context.missing(_rolDestinoMeta);
    }
    if (data.containsKey('nivel_destino')) {
      context.handle(
        _nivelDestinoMeta,
        nivelDestino.isAcceptableOrUnknown(
          data['nivel_destino']!,
          _nivelDestinoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nivelDestinoMeta);
    }
    if (data.containsKey('dependencia_destino')) {
      context.handle(
        _dependenciaDestinoMeta,
        dependenciaDestino.isAcceptableOrUnknown(
          data['dependencia_destino']!,
          _dependenciaDestinoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dependenciaDestinoMeta);
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
    if (data.containsKey('actualizado_en')) {
      context.handle(
        _actualizadoEnMeta,
        actualizadoEn.isAcceptableOrUnknown(
          data['actualizado_en']!,
          _actualizadoEnMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TablaRecursosBibliotecaData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TablaRecursosBibliotecaData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      tipoRecurso: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo_recurso'],
      )!,
      categoria: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}categoria'],
      )!,
      codigo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}codigo'],
      )!,
      titulo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}titulo'],
      )!,
      autorReferencia: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}autor_referencia'],
      ),
      estado: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado'],
      )!,
      responsable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}responsable'],
      )!,
      destinatario: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}destinatario'],
      ),
      cursoReferencia: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}curso_referencia'],
      ),
      cantidadTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cantidad_total'],
      )!,
      cantidadDisponible: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cantidad_disponible'],
      )!,
      fechaVencimiento: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha_vencimiento'],
      ),
      observaciones: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observaciones'],
      )!,
      rolDestino: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rol_destino'],
      )!,
      nivelDestino: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nivel_destino'],
      )!,
      dependenciaDestino: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dependencia_destino'],
      )!,
      activo: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}activo'],
      )!,
      creadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}creado_en'],
      )!,
      actualizadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}actualizado_en'],
      )!,
    );
  }

  @override
  $TablaRecursosBibliotecaTable createAlias(String alias) {
    return $TablaRecursosBibliotecaTable(attachedDatabase, alias);
  }
}

class TablaRecursosBibliotecaData extends DataClass
    implements Insertable<TablaRecursosBibliotecaData> {
  final int id;
  final String tipoRecurso;
  final String categoria;
  final String codigo;
  final String titulo;
  final String? autorReferencia;
  final String estado;
  final String responsable;
  final String? destinatario;
  final String? cursoReferencia;
  final int cantidadTotal;
  final int cantidadDisponible;
  final DateTime? fechaVencimiento;
  final String observaciones;
  final String rolDestino;
  final String nivelDestino;
  final String dependenciaDestino;
  final bool activo;
  final DateTime creadoEn;
  final DateTime actualizadoEn;
  const TablaRecursosBibliotecaData({
    required this.id,
    required this.tipoRecurso,
    required this.categoria,
    required this.codigo,
    required this.titulo,
    this.autorReferencia,
    required this.estado,
    required this.responsable,
    this.destinatario,
    this.cursoReferencia,
    required this.cantidadTotal,
    required this.cantidadDisponible,
    this.fechaVencimiento,
    required this.observaciones,
    required this.rolDestino,
    required this.nivelDestino,
    required this.dependenciaDestino,
    required this.activo,
    required this.creadoEn,
    required this.actualizadoEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['tipo_recurso'] = Variable<String>(tipoRecurso);
    map['categoria'] = Variable<String>(categoria);
    map['codigo'] = Variable<String>(codigo);
    map['titulo'] = Variable<String>(titulo);
    if (!nullToAbsent || autorReferencia != null) {
      map['autor_referencia'] = Variable<String>(autorReferencia);
    }
    map['estado'] = Variable<String>(estado);
    map['responsable'] = Variable<String>(responsable);
    if (!nullToAbsent || destinatario != null) {
      map['destinatario'] = Variable<String>(destinatario);
    }
    if (!nullToAbsent || cursoReferencia != null) {
      map['curso_referencia'] = Variable<String>(cursoReferencia);
    }
    map['cantidad_total'] = Variable<int>(cantidadTotal);
    map['cantidad_disponible'] = Variable<int>(cantidadDisponible);
    if (!nullToAbsent || fechaVencimiento != null) {
      map['fecha_vencimiento'] = Variable<DateTime>(fechaVencimiento);
    }
    map['observaciones'] = Variable<String>(observaciones);
    map['rol_destino'] = Variable<String>(rolDestino);
    map['nivel_destino'] = Variable<String>(nivelDestino);
    map['dependencia_destino'] = Variable<String>(dependenciaDestino);
    map['activo'] = Variable<bool>(activo);
    map['creado_en'] = Variable<DateTime>(creadoEn);
    map['actualizado_en'] = Variable<DateTime>(actualizadoEn);
    return map;
  }

  TablaRecursosBibliotecaCompanion toCompanion(bool nullToAbsent) {
    return TablaRecursosBibliotecaCompanion(
      id: Value(id),
      tipoRecurso: Value(tipoRecurso),
      categoria: Value(categoria),
      codigo: Value(codigo),
      titulo: Value(titulo),
      autorReferencia: autorReferencia == null && nullToAbsent
          ? const Value.absent()
          : Value(autorReferencia),
      estado: Value(estado),
      responsable: Value(responsable),
      destinatario: destinatario == null && nullToAbsent
          ? const Value.absent()
          : Value(destinatario),
      cursoReferencia: cursoReferencia == null && nullToAbsent
          ? const Value.absent()
          : Value(cursoReferencia),
      cantidadTotal: Value(cantidadTotal),
      cantidadDisponible: Value(cantidadDisponible),
      fechaVencimiento: fechaVencimiento == null && nullToAbsent
          ? const Value.absent()
          : Value(fechaVencimiento),
      observaciones: Value(observaciones),
      rolDestino: Value(rolDestino),
      nivelDestino: Value(nivelDestino),
      dependenciaDestino: Value(dependenciaDestino),
      activo: Value(activo),
      creadoEn: Value(creadoEn),
      actualizadoEn: Value(actualizadoEn),
    );
  }

  factory TablaRecursosBibliotecaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TablaRecursosBibliotecaData(
      id: serializer.fromJson<int>(json['id']),
      tipoRecurso: serializer.fromJson<String>(json['tipoRecurso']),
      categoria: serializer.fromJson<String>(json['categoria']),
      codigo: serializer.fromJson<String>(json['codigo']),
      titulo: serializer.fromJson<String>(json['titulo']),
      autorReferencia: serializer.fromJson<String?>(json['autorReferencia']),
      estado: serializer.fromJson<String>(json['estado']),
      responsable: serializer.fromJson<String>(json['responsable']),
      destinatario: serializer.fromJson<String?>(json['destinatario']),
      cursoReferencia: serializer.fromJson<String?>(json['cursoReferencia']),
      cantidadTotal: serializer.fromJson<int>(json['cantidadTotal']),
      cantidadDisponible: serializer.fromJson<int>(json['cantidadDisponible']),
      fechaVencimiento: serializer.fromJson<DateTime?>(
        json['fechaVencimiento'],
      ),
      observaciones: serializer.fromJson<String>(json['observaciones']),
      rolDestino: serializer.fromJson<String>(json['rolDestino']),
      nivelDestino: serializer.fromJson<String>(json['nivelDestino']),
      dependenciaDestino: serializer.fromJson<String>(
        json['dependenciaDestino'],
      ),
      activo: serializer.fromJson<bool>(json['activo']),
      creadoEn: serializer.fromJson<DateTime>(json['creadoEn']),
      actualizadoEn: serializer.fromJson<DateTime>(json['actualizadoEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'tipoRecurso': serializer.toJson<String>(tipoRecurso),
      'categoria': serializer.toJson<String>(categoria),
      'codigo': serializer.toJson<String>(codigo),
      'titulo': serializer.toJson<String>(titulo),
      'autorReferencia': serializer.toJson<String?>(autorReferencia),
      'estado': serializer.toJson<String>(estado),
      'responsable': serializer.toJson<String>(responsable),
      'destinatario': serializer.toJson<String?>(destinatario),
      'cursoReferencia': serializer.toJson<String?>(cursoReferencia),
      'cantidadTotal': serializer.toJson<int>(cantidadTotal),
      'cantidadDisponible': serializer.toJson<int>(cantidadDisponible),
      'fechaVencimiento': serializer.toJson<DateTime?>(fechaVencimiento),
      'observaciones': serializer.toJson<String>(observaciones),
      'rolDestino': serializer.toJson<String>(rolDestino),
      'nivelDestino': serializer.toJson<String>(nivelDestino),
      'dependenciaDestino': serializer.toJson<String>(dependenciaDestino),
      'activo': serializer.toJson<bool>(activo),
      'creadoEn': serializer.toJson<DateTime>(creadoEn),
      'actualizadoEn': serializer.toJson<DateTime>(actualizadoEn),
    };
  }

  TablaRecursosBibliotecaData copyWith({
    int? id,
    String? tipoRecurso,
    String? categoria,
    String? codigo,
    String? titulo,
    Value<String?> autorReferencia = const Value.absent(),
    String? estado,
    String? responsable,
    Value<String?> destinatario = const Value.absent(),
    Value<String?> cursoReferencia = const Value.absent(),
    int? cantidadTotal,
    int? cantidadDisponible,
    Value<DateTime?> fechaVencimiento = const Value.absent(),
    String? observaciones,
    String? rolDestino,
    String? nivelDestino,
    String? dependenciaDestino,
    bool? activo,
    DateTime? creadoEn,
    DateTime? actualizadoEn,
  }) => TablaRecursosBibliotecaData(
    id: id ?? this.id,
    tipoRecurso: tipoRecurso ?? this.tipoRecurso,
    categoria: categoria ?? this.categoria,
    codigo: codigo ?? this.codigo,
    titulo: titulo ?? this.titulo,
    autorReferencia: autorReferencia.present
        ? autorReferencia.value
        : this.autorReferencia,
    estado: estado ?? this.estado,
    responsable: responsable ?? this.responsable,
    destinatario: destinatario.present ? destinatario.value : this.destinatario,
    cursoReferencia: cursoReferencia.present
        ? cursoReferencia.value
        : this.cursoReferencia,
    cantidadTotal: cantidadTotal ?? this.cantidadTotal,
    cantidadDisponible: cantidadDisponible ?? this.cantidadDisponible,
    fechaVencimiento: fechaVencimiento.present
        ? fechaVencimiento.value
        : this.fechaVencimiento,
    observaciones: observaciones ?? this.observaciones,
    rolDestino: rolDestino ?? this.rolDestino,
    nivelDestino: nivelDestino ?? this.nivelDestino,
    dependenciaDestino: dependenciaDestino ?? this.dependenciaDestino,
    activo: activo ?? this.activo,
    creadoEn: creadoEn ?? this.creadoEn,
    actualizadoEn: actualizadoEn ?? this.actualizadoEn,
  );
  TablaRecursosBibliotecaData copyWithCompanion(
    TablaRecursosBibliotecaCompanion data,
  ) {
    return TablaRecursosBibliotecaData(
      id: data.id.present ? data.id.value : this.id,
      tipoRecurso: data.tipoRecurso.present
          ? data.tipoRecurso.value
          : this.tipoRecurso,
      categoria: data.categoria.present ? data.categoria.value : this.categoria,
      codigo: data.codigo.present ? data.codigo.value : this.codigo,
      titulo: data.titulo.present ? data.titulo.value : this.titulo,
      autorReferencia: data.autorReferencia.present
          ? data.autorReferencia.value
          : this.autorReferencia,
      estado: data.estado.present ? data.estado.value : this.estado,
      responsable: data.responsable.present
          ? data.responsable.value
          : this.responsable,
      destinatario: data.destinatario.present
          ? data.destinatario.value
          : this.destinatario,
      cursoReferencia: data.cursoReferencia.present
          ? data.cursoReferencia.value
          : this.cursoReferencia,
      cantidadTotal: data.cantidadTotal.present
          ? data.cantidadTotal.value
          : this.cantidadTotal,
      cantidadDisponible: data.cantidadDisponible.present
          ? data.cantidadDisponible.value
          : this.cantidadDisponible,
      fechaVencimiento: data.fechaVencimiento.present
          ? data.fechaVencimiento.value
          : this.fechaVencimiento,
      observaciones: data.observaciones.present
          ? data.observaciones.value
          : this.observaciones,
      rolDestino: data.rolDestino.present
          ? data.rolDestino.value
          : this.rolDestino,
      nivelDestino: data.nivelDestino.present
          ? data.nivelDestino.value
          : this.nivelDestino,
      dependenciaDestino: data.dependenciaDestino.present
          ? data.dependenciaDestino.value
          : this.dependenciaDestino,
      activo: data.activo.present ? data.activo.value : this.activo,
      creadoEn: data.creadoEn.present ? data.creadoEn.value : this.creadoEn,
      actualizadoEn: data.actualizadoEn.present
          ? data.actualizadoEn.value
          : this.actualizadoEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TablaRecursosBibliotecaData(')
          ..write('id: $id, ')
          ..write('tipoRecurso: $tipoRecurso, ')
          ..write('categoria: $categoria, ')
          ..write('codigo: $codigo, ')
          ..write('titulo: $titulo, ')
          ..write('autorReferencia: $autorReferencia, ')
          ..write('estado: $estado, ')
          ..write('responsable: $responsable, ')
          ..write('destinatario: $destinatario, ')
          ..write('cursoReferencia: $cursoReferencia, ')
          ..write('cantidadTotal: $cantidadTotal, ')
          ..write('cantidadDisponible: $cantidadDisponible, ')
          ..write('fechaVencimiento: $fechaVencimiento, ')
          ..write('observaciones: $observaciones, ')
          ..write('rolDestino: $rolDestino, ')
          ..write('nivelDestino: $nivelDestino, ')
          ..write('dependenciaDestino: $dependenciaDestino, ')
          ..write('activo: $activo, ')
          ..write('creadoEn: $creadoEn, ')
          ..write('actualizadoEn: $actualizadoEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tipoRecurso,
    categoria,
    codigo,
    titulo,
    autorReferencia,
    estado,
    responsable,
    destinatario,
    cursoReferencia,
    cantidadTotal,
    cantidadDisponible,
    fechaVencimiento,
    observaciones,
    rolDestino,
    nivelDestino,
    dependenciaDestino,
    activo,
    creadoEn,
    actualizadoEn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TablaRecursosBibliotecaData &&
          other.id == this.id &&
          other.tipoRecurso == this.tipoRecurso &&
          other.categoria == this.categoria &&
          other.codigo == this.codigo &&
          other.titulo == this.titulo &&
          other.autorReferencia == this.autorReferencia &&
          other.estado == this.estado &&
          other.responsable == this.responsable &&
          other.destinatario == this.destinatario &&
          other.cursoReferencia == this.cursoReferencia &&
          other.cantidadTotal == this.cantidadTotal &&
          other.cantidadDisponible == this.cantidadDisponible &&
          other.fechaVencimiento == this.fechaVencimiento &&
          other.observaciones == this.observaciones &&
          other.rolDestino == this.rolDestino &&
          other.nivelDestino == this.nivelDestino &&
          other.dependenciaDestino == this.dependenciaDestino &&
          other.activo == this.activo &&
          other.creadoEn == this.creadoEn &&
          other.actualizadoEn == this.actualizadoEn);
}

class TablaRecursosBibliotecaCompanion
    extends UpdateCompanion<TablaRecursosBibliotecaData> {
  final Value<int> id;
  final Value<String> tipoRecurso;
  final Value<String> categoria;
  final Value<String> codigo;
  final Value<String> titulo;
  final Value<String?> autorReferencia;
  final Value<String> estado;
  final Value<String> responsable;
  final Value<String?> destinatario;
  final Value<String?> cursoReferencia;
  final Value<int> cantidadTotal;
  final Value<int> cantidadDisponible;
  final Value<DateTime?> fechaVencimiento;
  final Value<String> observaciones;
  final Value<String> rolDestino;
  final Value<String> nivelDestino;
  final Value<String> dependenciaDestino;
  final Value<bool> activo;
  final Value<DateTime> creadoEn;
  final Value<DateTime> actualizadoEn;
  const TablaRecursosBibliotecaCompanion({
    this.id = const Value.absent(),
    this.tipoRecurso = const Value.absent(),
    this.categoria = const Value.absent(),
    this.codigo = const Value.absent(),
    this.titulo = const Value.absent(),
    this.autorReferencia = const Value.absent(),
    this.estado = const Value.absent(),
    this.responsable = const Value.absent(),
    this.destinatario = const Value.absent(),
    this.cursoReferencia = const Value.absent(),
    this.cantidadTotal = const Value.absent(),
    this.cantidadDisponible = const Value.absent(),
    this.fechaVencimiento = const Value.absent(),
    this.observaciones = const Value.absent(),
    this.rolDestino = const Value.absent(),
    this.nivelDestino = const Value.absent(),
    this.dependenciaDestino = const Value.absent(),
    this.activo = const Value.absent(),
    this.creadoEn = const Value.absent(),
    this.actualizadoEn = const Value.absent(),
  });
  TablaRecursosBibliotecaCompanion.insert({
    this.id = const Value.absent(),
    required String tipoRecurso,
    required String categoria,
    required String codigo,
    required String titulo,
    this.autorReferencia = const Value.absent(),
    required String estado,
    required String responsable,
    this.destinatario = const Value.absent(),
    this.cursoReferencia = const Value.absent(),
    this.cantidadTotal = const Value.absent(),
    this.cantidadDisponible = const Value.absent(),
    this.fechaVencimiento = const Value.absent(),
    required String observaciones,
    required String rolDestino,
    required String nivelDestino,
    required String dependenciaDestino,
    this.activo = const Value.absent(),
    this.creadoEn = const Value.absent(),
    this.actualizadoEn = const Value.absent(),
  }) : tipoRecurso = Value(tipoRecurso),
       categoria = Value(categoria),
       codigo = Value(codigo),
       titulo = Value(titulo),
       estado = Value(estado),
       responsable = Value(responsable),
       observaciones = Value(observaciones),
       rolDestino = Value(rolDestino),
       nivelDestino = Value(nivelDestino),
       dependenciaDestino = Value(dependenciaDestino);
  static Insertable<TablaRecursosBibliotecaData> custom({
    Expression<int>? id,
    Expression<String>? tipoRecurso,
    Expression<String>? categoria,
    Expression<String>? codigo,
    Expression<String>? titulo,
    Expression<String>? autorReferencia,
    Expression<String>? estado,
    Expression<String>? responsable,
    Expression<String>? destinatario,
    Expression<String>? cursoReferencia,
    Expression<int>? cantidadTotal,
    Expression<int>? cantidadDisponible,
    Expression<DateTime>? fechaVencimiento,
    Expression<String>? observaciones,
    Expression<String>? rolDestino,
    Expression<String>? nivelDestino,
    Expression<String>? dependenciaDestino,
    Expression<bool>? activo,
    Expression<DateTime>? creadoEn,
    Expression<DateTime>? actualizadoEn,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tipoRecurso != null) 'tipo_recurso': tipoRecurso,
      if (categoria != null) 'categoria': categoria,
      if (codigo != null) 'codigo': codigo,
      if (titulo != null) 'titulo': titulo,
      if (autorReferencia != null) 'autor_referencia': autorReferencia,
      if (estado != null) 'estado': estado,
      if (responsable != null) 'responsable': responsable,
      if (destinatario != null) 'destinatario': destinatario,
      if (cursoReferencia != null) 'curso_referencia': cursoReferencia,
      if (cantidadTotal != null) 'cantidad_total': cantidadTotal,
      if (cantidadDisponible != null) 'cantidad_disponible': cantidadDisponible,
      if (fechaVencimiento != null) 'fecha_vencimiento': fechaVencimiento,
      if (observaciones != null) 'observaciones': observaciones,
      if (rolDestino != null) 'rol_destino': rolDestino,
      if (nivelDestino != null) 'nivel_destino': nivelDestino,
      if (dependenciaDestino != null) 'dependencia_destino': dependenciaDestino,
      if (activo != null) 'activo': activo,
      if (creadoEn != null) 'creado_en': creadoEn,
      if (actualizadoEn != null) 'actualizado_en': actualizadoEn,
    });
  }

  TablaRecursosBibliotecaCompanion copyWith({
    Value<int>? id,
    Value<String>? tipoRecurso,
    Value<String>? categoria,
    Value<String>? codigo,
    Value<String>? titulo,
    Value<String?>? autorReferencia,
    Value<String>? estado,
    Value<String>? responsable,
    Value<String?>? destinatario,
    Value<String?>? cursoReferencia,
    Value<int>? cantidadTotal,
    Value<int>? cantidadDisponible,
    Value<DateTime?>? fechaVencimiento,
    Value<String>? observaciones,
    Value<String>? rolDestino,
    Value<String>? nivelDestino,
    Value<String>? dependenciaDestino,
    Value<bool>? activo,
    Value<DateTime>? creadoEn,
    Value<DateTime>? actualizadoEn,
  }) {
    return TablaRecursosBibliotecaCompanion(
      id: id ?? this.id,
      tipoRecurso: tipoRecurso ?? this.tipoRecurso,
      categoria: categoria ?? this.categoria,
      codigo: codigo ?? this.codigo,
      titulo: titulo ?? this.titulo,
      autorReferencia: autorReferencia ?? this.autorReferencia,
      estado: estado ?? this.estado,
      responsable: responsable ?? this.responsable,
      destinatario: destinatario ?? this.destinatario,
      cursoReferencia: cursoReferencia ?? this.cursoReferencia,
      cantidadTotal: cantidadTotal ?? this.cantidadTotal,
      cantidadDisponible: cantidadDisponible ?? this.cantidadDisponible,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      observaciones: observaciones ?? this.observaciones,
      rolDestino: rolDestino ?? this.rolDestino,
      nivelDestino: nivelDestino ?? this.nivelDestino,
      dependenciaDestino: dependenciaDestino ?? this.dependenciaDestino,
      activo: activo ?? this.activo,
      creadoEn: creadoEn ?? this.creadoEn,
      actualizadoEn: actualizadoEn ?? this.actualizadoEn,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (tipoRecurso.present) {
      map['tipo_recurso'] = Variable<String>(tipoRecurso.value);
    }
    if (categoria.present) {
      map['categoria'] = Variable<String>(categoria.value);
    }
    if (codigo.present) {
      map['codigo'] = Variable<String>(codigo.value);
    }
    if (titulo.present) {
      map['titulo'] = Variable<String>(titulo.value);
    }
    if (autorReferencia.present) {
      map['autor_referencia'] = Variable<String>(autorReferencia.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    if (responsable.present) {
      map['responsable'] = Variable<String>(responsable.value);
    }
    if (destinatario.present) {
      map['destinatario'] = Variable<String>(destinatario.value);
    }
    if (cursoReferencia.present) {
      map['curso_referencia'] = Variable<String>(cursoReferencia.value);
    }
    if (cantidadTotal.present) {
      map['cantidad_total'] = Variable<int>(cantidadTotal.value);
    }
    if (cantidadDisponible.present) {
      map['cantidad_disponible'] = Variable<int>(cantidadDisponible.value);
    }
    if (fechaVencimiento.present) {
      map['fecha_vencimiento'] = Variable<DateTime>(fechaVencimiento.value);
    }
    if (observaciones.present) {
      map['observaciones'] = Variable<String>(observaciones.value);
    }
    if (rolDestino.present) {
      map['rol_destino'] = Variable<String>(rolDestino.value);
    }
    if (nivelDestino.present) {
      map['nivel_destino'] = Variable<String>(nivelDestino.value);
    }
    if (dependenciaDestino.present) {
      map['dependencia_destino'] = Variable<String>(dependenciaDestino.value);
    }
    if (activo.present) {
      map['activo'] = Variable<bool>(activo.value);
    }
    if (creadoEn.present) {
      map['creado_en'] = Variable<DateTime>(creadoEn.value);
    }
    if (actualizadoEn.present) {
      map['actualizado_en'] = Variable<DateTime>(actualizadoEn.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TablaRecursosBibliotecaCompanion(')
          ..write('id: $id, ')
          ..write('tipoRecurso: $tipoRecurso, ')
          ..write('categoria: $categoria, ')
          ..write('codigo: $codigo, ')
          ..write('titulo: $titulo, ')
          ..write('autorReferencia: $autorReferencia, ')
          ..write('estado: $estado, ')
          ..write('responsable: $responsable, ')
          ..write('destinatario: $destinatario, ')
          ..write('cursoReferencia: $cursoReferencia, ')
          ..write('cantidadTotal: $cantidadTotal, ')
          ..write('cantidadDisponible: $cantidadDisponible, ')
          ..write('fechaVencimiento: $fechaVencimiento, ')
          ..write('observaciones: $observaciones, ')
          ..write('rolDestino: $rolDestino, ')
          ..write('nivelDestino: $nivelDestino, ')
          ..write('dependenciaDestino: $dependenciaDestino, ')
          ..write('activo: $activo, ')
          ..write('creadoEn: $creadoEn, ')
          ..write('actualizadoEn: $actualizadoEn')
          ..write(')'))
        .toString();
  }
}

class $TablaTramitesSecretariaTable extends TablaTramitesSecretaria
    with TableInfo<$TablaTramitesSecretariaTable, TablaTramitesSecretariaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TablaTramitesSecretariaTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _tipoTramiteMeta = const VerificationMeta(
    'tipoTramite',
  );
  @override
  late final GeneratedColumn<String> tipoTramite = GeneratedColumn<String>(
    'tipo_tramite',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 40,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoriaMeta = const VerificationMeta(
    'categoria',
  );
  @override
  late final GeneratedColumn<String> categoria = GeneratedColumn<String>(
    'categoria',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 30,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codigoMeta = const VerificationMeta('codigo');
  @override
  late final GeneratedColumn<String> codigo = GeneratedColumn<String>(
    'codigo',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 40,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _asuntoMeta = const VerificationMeta('asunto');
  @override
  late final GeneratedColumn<String> asunto = GeneratedColumn<String>(
    'asunto',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 180,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _solicitanteMeta = const VerificationMeta(
    'solicitante',
  );
  @override
  late final GeneratedColumn<String> solicitante = GeneratedColumn<String>(
    'solicitante',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cursoReferenciaMeta = const VerificationMeta(
    'cursoReferencia',
  );
  @override
  late final GeneratedColumn<String> cursoReferencia = GeneratedColumn<String>(
    'curso_referencia',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
    'estado',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 40,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _prioridadMeta = const VerificationMeta(
    'prioridad',
  );
  @override
  late final GeneratedColumn<String> prioridad = GeneratedColumn<String>(
    'prioridad',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 20,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _responsableMeta = const VerificationMeta(
    'responsable',
  );
  @override
  late final GeneratedColumn<String> responsable = GeneratedColumn<String>(
    'responsable',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _observacionesMeta = const VerificationMeta(
    'observaciones',
  );
  @override
  late final GeneratedColumn<String> observaciones = GeneratedColumn<String>(
    'observaciones',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 800,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fechaLimiteMeta = const VerificationMeta(
    'fechaLimite',
  );
  @override
  late final GeneratedColumn<DateTime> fechaLimite = GeneratedColumn<DateTime>(
    'fecha_limite',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rolDestinoMeta = const VerificationMeta(
    'rolDestino',
  );
  @override
  late final GeneratedColumn<String> rolDestino = GeneratedColumn<String>(
    'rol_destino',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 40,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nivelDestinoMeta = const VerificationMeta(
    'nivelDestino',
  );
  @override
  late final GeneratedColumn<String> nivelDestino = GeneratedColumn<String>(
    'nivel_destino',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 30,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dependenciaDestinoMeta =
      const VerificationMeta('dependenciaDestino');
  @override
  late final GeneratedColumn<String> dependenciaDestino =
      GeneratedColumn<String>(
        'dependencia_destino',
        aliasedName,
        false,
        additionalChecks: GeneratedColumn.checkTextLength(
          minTextLength: 1,
          maxTextLength: 30,
        ),
        type: DriftSqlType.string,
        requiredDuringInsert: true,
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
  static const VerificationMeta _actualizadoEnMeta = const VerificationMeta(
    'actualizadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> actualizadoEn =
      GeneratedColumn<DateTime>(
        'actualizado_en',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tipoTramite,
    categoria,
    codigo,
    asunto,
    solicitante,
    cursoReferencia,
    estado,
    prioridad,
    responsable,
    observaciones,
    fechaLimite,
    rolDestino,
    nivelDestino,
    dependenciaDestino,
    activo,
    creadoEn,
    actualizadoEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tabla_tramites_secretaria';
  @override
  VerificationContext validateIntegrity(
    Insertable<TablaTramitesSecretariaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('tipo_tramite')) {
      context.handle(
        _tipoTramiteMeta,
        tipoTramite.isAcceptableOrUnknown(
          data['tipo_tramite']!,
          _tipoTramiteMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tipoTramiteMeta);
    }
    if (data.containsKey('categoria')) {
      context.handle(
        _categoriaMeta,
        categoria.isAcceptableOrUnknown(data['categoria']!, _categoriaMeta),
      );
    } else if (isInserting) {
      context.missing(_categoriaMeta);
    }
    if (data.containsKey('codigo')) {
      context.handle(
        _codigoMeta,
        codigo.isAcceptableOrUnknown(data['codigo']!, _codigoMeta),
      );
    } else if (isInserting) {
      context.missing(_codigoMeta);
    }
    if (data.containsKey('asunto')) {
      context.handle(
        _asuntoMeta,
        asunto.isAcceptableOrUnknown(data['asunto']!, _asuntoMeta),
      );
    } else if (isInserting) {
      context.missing(_asuntoMeta);
    }
    if (data.containsKey('solicitante')) {
      context.handle(
        _solicitanteMeta,
        solicitante.isAcceptableOrUnknown(
          data['solicitante']!,
          _solicitanteMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_solicitanteMeta);
    }
    if (data.containsKey('curso_referencia')) {
      context.handle(
        _cursoReferenciaMeta,
        cursoReferencia.isAcceptableOrUnknown(
          data['curso_referencia']!,
          _cursoReferenciaMeta,
        ),
      );
    }
    if (data.containsKey('estado')) {
      context.handle(
        _estadoMeta,
        estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta),
      );
    } else if (isInserting) {
      context.missing(_estadoMeta);
    }
    if (data.containsKey('prioridad')) {
      context.handle(
        _prioridadMeta,
        prioridad.isAcceptableOrUnknown(data['prioridad']!, _prioridadMeta),
      );
    } else if (isInserting) {
      context.missing(_prioridadMeta);
    }
    if (data.containsKey('responsable')) {
      context.handle(
        _responsableMeta,
        responsable.isAcceptableOrUnknown(
          data['responsable']!,
          _responsableMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_responsableMeta);
    }
    if (data.containsKey('observaciones')) {
      context.handle(
        _observacionesMeta,
        observaciones.isAcceptableOrUnknown(
          data['observaciones']!,
          _observacionesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_observacionesMeta);
    }
    if (data.containsKey('fecha_limite')) {
      context.handle(
        _fechaLimiteMeta,
        fechaLimite.isAcceptableOrUnknown(
          data['fecha_limite']!,
          _fechaLimiteMeta,
        ),
      );
    }
    if (data.containsKey('rol_destino')) {
      context.handle(
        _rolDestinoMeta,
        rolDestino.isAcceptableOrUnknown(data['rol_destino']!, _rolDestinoMeta),
      );
    } else if (isInserting) {
      context.missing(_rolDestinoMeta);
    }
    if (data.containsKey('nivel_destino')) {
      context.handle(
        _nivelDestinoMeta,
        nivelDestino.isAcceptableOrUnknown(
          data['nivel_destino']!,
          _nivelDestinoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nivelDestinoMeta);
    }
    if (data.containsKey('dependencia_destino')) {
      context.handle(
        _dependenciaDestinoMeta,
        dependenciaDestino.isAcceptableOrUnknown(
          data['dependencia_destino']!,
          _dependenciaDestinoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dependenciaDestinoMeta);
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
    if (data.containsKey('actualizado_en')) {
      context.handle(
        _actualizadoEnMeta,
        actualizadoEn.isAcceptableOrUnknown(
          data['actualizado_en']!,
          _actualizadoEnMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TablaTramitesSecretariaData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TablaTramitesSecretariaData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      tipoTramite: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo_tramite'],
      )!,
      categoria: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}categoria'],
      )!,
      codigo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}codigo'],
      )!,
      asunto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}asunto'],
      )!,
      solicitante: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}solicitante'],
      )!,
      cursoReferencia: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}curso_referencia'],
      ),
      estado: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado'],
      )!,
      prioridad: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prioridad'],
      )!,
      responsable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}responsable'],
      )!,
      observaciones: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observaciones'],
      )!,
      fechaLimite: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha_limite'],
      ),
      rolDestino: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rol_destino'],
      )!,
      nivelDestino: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nivel_destino'],
      )!,
      dependenciaDestino: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dependencia_destino'],
      )!,
      activo: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}activo'],
      )!,
      creadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}creado_en'],
      )!,
      actualizadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}actualizado_en'],
      )!,
    );
  }

  @override
  $TablaTramitesSecretariaTable createAlias(String alias) {
    return $TablaTramitesSecretariaTable(attachedDatabase, alias);
  }
}

class TablaTramitesSecretariaData extends DataClass
    implements Insertable<TablaTramitesSecretariaData> {
  final int id;
  final String tipoTramite;
  final String categoria;
  final String codigo;
  final String asunto;
  final String solicitante;
  final String? cursoReferencia;
  final String estado;
  final String prioridad;
  final String responsable;
  final String observaciones;
  final DateTime? fechaLimite;
  final String rolDestino;
  final String nivelDestino;
  final String dependenciaDestino;
  final bool activo;
  final DateTime creadoEn;
  final DateTime actualizadoEn;
  const TablaTramitesSecretariaData({
    required this.id,
    required this.tipoTramite,
    required this.categoria,
    required this.codigo,
    required this.asunto,
    required this.solicitante,
    this.cursoReferencia,
    required this.estado,
    required this.prioridad,
    required this.responsable,
    required this.observaciones,
    this.fechaLimite,
    required this.rolDestino,
    required this.nivelDestino,
    required this.dependenciaDestino,
    required this.activo,
    required this.creadoEn,
    required this.actualizadoEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['tipo_tramite'] = Variable<String>(tipoTramite);
    map['categoria'] = Variable<String>(categoria);
    map['codigo'] = Variable<String>(codigo);
    map['asunto'] = Variable<String>(asunto);
    map['solicitante'] = Variable<String>(solicitante);
    if (!nullToAbsent || cursoReferencia != null) {
      map['curso_referencia'] = Variable<String>(cursoReferencia);
    }
    map['estado'] = Variable<String>(estado);
    map['prioridad'] = Variable<String>(prioridad);
    map['responsable'] = Variable<String>(responsable);
    map['observaciones'] = Variable<String>(observaciones);
    if (!nullToAbsent || fechaLimite != null) {
      map['fecha_limite'] = Variable<DateTime>(fechaLimite);
    }
    map['rol_destino'] = Variable<String>(rolDestino);
    map['nivel_destino'] = Variable<String>(nivelDestino);
    map['dependencia_destino'] = Variable<String>(dependenciaDestino);
    map['activo'] = Variable<bool>(activo);
    map['creado_en'] = Variable<DateTime>(creadoEn);
    map['actualizado_en'] = Variable<DateTime>(actualizadoEn);
    return map;
  }

  TablaTramitesSecretariaCompanion toCompanion(bool nullToAbsent) {
    return TablaTramitesSecretariaCompanion(
      id: Value(id),
      tipoTramite: Value(tipoTramite),
      categoria: Value(categoria),
      codigo: Value(codigo),
      asunto: Value(asunto),
      solicitante: Value(solicitante),
      cursoReferencia: cursoReferencia == null && nullToAbsent
          ? const Value.absent()
          : Value(cursoReferencia),
      estado: Value(estado),
      prioridad: Value(prioridad),
      responsable: Value(responsable),
      observaciones: Value(observaciones),
      fechaLimite: fechaLimite == null && nullToAbsent
          ? const Value.absent()
          : Value(fechaLimite),
      rolDestino: Value(rolDestino),
      nivelDestino: Value(nivelDestino),
      dependenciaDestino: Value(dependenciaDestino),
      activo: Value(activo),
      creadoEn: Value(creadoEn),
      actualizadoEn: Value(actualizadoEn),
    );
  }

  factory TablaTramitesSecretariaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TablaTramitesSecretariaData(
      id: serializer.fromJson<int>(json['id']),
      tipoTramite: serializer.fromJson<String>(json['tipoTramite']),
      categoria: serializer.fromJson<String>(json['categoria']),
      codigo: serializer.fromJson<String>(json['codigo']),
      asunto: serializer.fromJson<String>(json['asunto']),
      solicitante: serializer.fromJson<String>(json['solicitante']),
      cursoReferencia: serializer.fromJson<String?>(json['cursoReferencia']),
      estado: serializer.fromJson<String>(json['estado']),
      prioridad: serializer.fromJson<String>(json['prioridad']),
      responsable: serializer.fromJson<String>(json['responsable']),
      observaciones: serializer.fromJson<String>(json['observaciones']),
      fechaLimite: serializer.fromJson<DateTime?>(json['fechaLimite']),
      rolDestino: serializer.fromJson<String>(json['rolDestino']),
      nivelDestino: serializer.fromJson<String>(json['nivelDestino']),
      dependenciaDestino: serializer.fromJson<String>(
        json['dependenciaDestino'],
      ),
      activo: serializer.fromJson<bool>(json['activo']),
      creadoEn: serializer.fromJson<DateTime>(json['creadoEn']),
      actualizadoEn: serializer.fromJson<DateTime>(json['actualizadoEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'tipoTramite': serializer.toJson<String>(tipoTramite),
      'categoria': serializer.toJson<String>(categoria),
      'codigo': serializer.toJson<String>(codigo),
      'asunto': serializer.toJson<String>(asunto),
      'solicitante': serializer.toJson<String>(solicitante),
      'cursoReferencia': serializer.toJson<String?>(cursoReferencia),
      'estado': serializer.toJson<String>(estado),
      'prioridad': serializer.toJson<String>(prioridad),
      'responsable': serializer.toJson<String>(responsable),
      'observaciones': serializer.toJson<String>(observaciones),
      'fechaLimite': serializer.toJson<DateTime?>(fechaLimite),
      'rolDestino': serializer.toJson<String>(rolDestino),
      'nivelDestino': serializer.toJson<String>(nivelDestino),
      'dependenciaDestino': serializer.toJson<String>(dependenciaDestino),
      'activo': serializer.toJson<bool>(activo),
      'creadoEn': serializer.toJson<DateTime>(creadoEn),
      'actualizadoEn': serializer.toJson<DateTime>(actualizadoEn),
    };
  }

  TablaTramitesSecretariaData copyWith({
    int? id,
    String? tipoTramite,
    String? categoria,
    String? codigo,
    String? asunto,
    String? solicitante,
    Value<String?> cursoReferencia = const Value.absent(),
    String? estado,
    String? prioridad,
    String? responsable,
    String? observaciones,
    Value<DateTime?> fechaLimite = const Value.absent(),
    String? rolDestino,
    String? nivelDestino,
    String? dependenciaDestino,
    bool? activo,
    DateTime? creadoEn,
    DateTime? actualizadoEn,
  }) => TablaTramitesSecretariaData(
    id: id ?? this.id,
    tipoTramite: tipoTramite ?? this.tipoTramite,
    categoria: categoria ?? this.categoria,
    codigo: codigo ?? this.codigo,
    asunto: asunto ?? this.asunto,
    solicitante: solicitante ?? this.solicitante,
    cursoReferencia: cursoReferencia.present
        ? cursoReferencia.value
        : this.cursoReferencia,
    estado: estado ?? this.estado,
    prioridad: prioridad ?? this.prioridad,
    responsable: responsable ?? this.responsable,
    observaciones: observaciones ?? this.observaciones,
    fechaLimite: fechaLimite.present ? fechaLimite.value : this.fechaLimite,
    rolDestino: rolDestino ?? this.rolDestino,
    nivelDestino: nivelDestino ?? this.nivelDestino,
    dependenciaDestino: dependenciaDestino ?? this.dependenciaDestino,
    activo: activo ?? this.activo,
    creadoEn: creadoEn ?? this.creadoEn,
    actualizadoEn: actualizadoEn ?? this.actualizadoEn,
  );
  TablaTramitesSecretariaData copyWithCompanion(
    TablaTramitesSecretariaCompanion data,
  ) {
    return TablaTramitesSecretariaData(
      id: data.id.present ? data.id.value : this.id,
      tipoTramite: data.tipoTramite.present
          ? data.tipoTramite.value
          : this.tipoTramite,
      categoria: data.categoria.present ? data.categoria.value : this.categoria,
      codigo: data.codigo.present ? data.codigo.value : this.codigo,
      asunto: data.asunto.present ? data.asunto.value : this.asunto,
      solicitante: data.solicitante.present
          ? data.solicitante.value
          : this.solicitante,
      cursoReferencia: data.cursoReferencia.present
          ? data.cursoReferencia.value
          : this.cursoReferencia,
      estado: data.estado.present ? data.estado.value : this.estado,
      prioridad: data.prioridad.present ? data.prioridad.value : this.prioridad,
      responsable: data.responsable.present
          ? data.responsable.value
          : this.responsable,
      observaciones: data.observaciones.present
          ? data.observaciones.value
          : this.observaciones,
      fechaLimite: data.fechaLimite.present
          ? data.fechaLimite.value
          : this.fechaLimite,
      rolDestino: data.rolDestino.present
          ? data.rolDestino.value
          : this.rolDestino,
      nivelDestino: data.nivelDestino.present
          ? data.nivelDestino.value
          : this.nivelDestino,
      dependenciaDestino: data.dependenciaDestino.present
          ? data.dependenciaDestino.value
          : this.dependenciaDestino,
      activo: data.activo.present ? data.activo.value : this.activo,
      creadoEn: data.creadoEn.present ? data.creadoEn.value : this.creadoEn,
      actualizadoEn: data.actualizadoEn.present
          ? data.actualizadoEn.value
          : this.actualizadoEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TablaTramitesSecretariaData(')
          ..write('id: $id, ')
          ..write('tipoTramite: $tipoTramite, ')
          ..write('categoria: $categoria, ')
          ..write('codigo: $codigo, ')
          ..write('asunto: $asunto, ')
          ..write('solicitante: $solicitante, ')
          ..write('cursoReferencia: $cursoReferencia, ')
          ..write('estado: $estado, ')
          ..write('prioridad: $prioridad, ')
          ..write('responsable: $responsable, ')
          ..write('observaciones: $observaciones, ')
          ..write('fechaLimite: $fechaLimite, ')
          ..write('rolDestino: $rolDestino, ')
          ..write('nivelDestino: $nivelDestino, ')
          ..write('dependenciaDestino: $dependenciaDestino, ')
          ..write('activo: $activo, ')
          ..write('creadoEn: $creadoEn, ')
          ..write('actualizadoEn: $actualizadoEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tipoTramite,
    categoria,
    codigo,
    asunto,
    solicitante,
    cursoReferencia,
    estado,
    prioridad,
    responsable,
    observaciones,
    fechaLimite,
    rolDestino,
    nivelDestino,
    dependenciaDestino,
    activo,
    creadoEn,
    actualizadoEn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TablaTramitesSecretariaData &&
          other.id == this.id &&
          other.tipoTramite == this.tipoTramite &&
          other.categoria == this.categoria &&
          other.codigo == this.codigo &&
          other.asunto == this.asunto &&
          other.solicitante == this.solicitante &&
          other.cursoReferencia == this.cursoReferencia &&
          other.estado == this.estado &&
          other.prioridad == this.prioridad &&
          other.responsable == this.responsable &&
          other.observaciones == this.observaciones &&
          other.fechaLimite == this.fechaLimite &&
          other.rolDestino == this.rolDestino &&
          other.nivelDestino == this.nivelDestino &&
          other.dependenciaDestino == this.dependenciaDestino &&
          other.activo == this.activo &&
          other.creadoEn == this.creadoEn &&
          other.actualizadoEn == this.actualizadoEn);
}

class TablaTramitesSecretariaCompanion
    extends UpdateCompanion<TablaTramitesSecretariaData> {
  final Value<int> id;
  final Value<String> tipoTramite;
  final Value<String> categoria;
  final Value<String> codigo;
  final Value<String> asunto;
  final Value<String> solicitante;
  final Value<String?> cursoReferencia;
  final Value<String> estado;
  final Value<String> prioridad;
  final Value<String> responsable;
  final Value<String> observaciones;
  final Value<DateTime?> fechaLimite;
  final Value<String> rolDestino;
  final Value<String> nivelDestino;
  final Value<String> dependenciaDestino;
  final Value<bool> activo;
  final Value<DateTime> creadoEn;
  final Value<DateTime> actualizadoEn;
  const TablaTramitesSecretariaCompanion({
    this.id = const Value.absent(),
    this.tipoTramite = const Value.absent(),
    this.categoria = const Value.absent(),
    this.codigo = const Value.absent(),
    this.asunto = const Value.absent(),
    this.solicitante = const Value.absent(),
    this.cursoReferencia = const Value.absent(),
    this.estado = const Value.absent(),
    this.prioridad = const Value.absent(),
    this.responsable = const Value.absent(),
    this.observaciones = const Value.absent(),
    this.fechaLimite = const Value.absent(),
    this.rolDestino = const Value.absent(),
    this.nivelDestino = const Value.absent(),
    this.dependenciaDestino = const Value.absent(),
    this.activo = const Value.absent(),
    this.creadoEn = const Value.absent(),
    this.actualizadoEn = const Value.absent(),
  });
  TablaTramitesSecretariaCompanion.insert({
    this.id = const Value.absent(),
    required String tipoTramite,
    required String categoria,
    required String codigo,
    required String asunto,
    required String solicitante,
    this.cursoReferencia = const Value.absent(),
    required String estado,
    required String prioridad,
    required String responsable,
    required String observaciones,
    this.fechaLimite = const Value.absent(),
    required String rolDestino,
    required String nivelDestino,
    required String dependenciaDestino,
    this.activo = const Value.absent(),
    this.creadoEn = const Value.absent(),
    this.actualizadoEn = const Value.absent(),
  }) : tipoTramite = Value(tipoTramite),
       categoria = Value(categoria),
       codigo = Value(codigo),
       asunto = Value(asunto),
       solicitante = Value(solicitante),
       estado = Value(estado),
       prioridad = Value(prioridad),
       responsable = Value(responsable),
       observaciones = Value(observaciones),
       rolDestino = Value(rolDestino),
       nivelDestino = Value(nivelDestino),
       dependenciaDestino = Value(dependenciaDestino);
  static Insertable<TablaTramitesSecretariaData> custom({
    Expression<int>? id,
    Expression<String>? tipoTramite,
    Expression<String>? categoria,
    Expression<String>? codigo,
    Expression<String>? asunto,
    Expression<String>? solicitante,
    Expression<String>? cursoReferencia,
    Expression<String>? estado,
    Expression<String>? prioridad,
    Expression<String>? responsable,
    Expression<String>? observaciones,
    Expression<DateTime>? fechaLimite,
    Expression<String>? rolDestino,
    Expression<String>? nivelDestino,
    Expression<String>? dependenciaDestino,
    Expression<bool>? activo,
    Expression<DateTime>? creadoEn,
    Expression<DateTime>? actualizadoEn,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tipoTramite != null) 'tipo_tramite': tipoTramite,
      if (categoria != null) 'categoria': categoria,
      if (codigo != null) 'codigo': codigo,
      if (asunto != null) 'asunto': asunto,
      if (solicitante != null) 'solicitante': solicitante,
      if (cursoReferencia != null) 'curso_referencia': cursoReferencia,
      if (estado != null) 'estado': estado,
      if (prioridad != null) 'prioridad': prioridad,
      if (responsable != null) 'responsable': responsable,
      if (observaciones != null) 'observaciones': observaciones,
      if (fechaLimite != null) 'fecha_limite': fechaLimite,
      if (rolDestino != null) 'rol_destino': rolDestino,
      if (nivelDestino != null) 'nivel_destino': nivelDestino,
      if (dependenciaDestino != null) 'dependencia_destino': dependenciaDestino,
      if (activo != null) 'activo': activo,
      if (creadoEn != null) 'creado_en': creadoEn,
      if (actualizadoEn != null) 'actualizado_en': actualizadoEn,
    });
  }

  TablaTramitesSecretariaCompanion copyWith({
    Value<int>? id,
    Value<String>? tipoTramite,
    Value<String>? categoria,
    Value<String>? codigo,
    Value<String>? asunto,
    Value<String>? solicitante,
    Value<String?>? cursoReferencia,
    Value<String>? estado,
    Value<String>? prioridad,
    Value<String>? responsable,
    Value<String>? observaciones,
    Value<DateTime?>? fechaLimite,
    Value<String>? rolDestino,
    Value<String>? nivelDestino,
    Value<String>? dependenciaDestino,
    Value<bool>? activo,
    Value<DateTime>? creadoEn,
    Value<DateTime>? actualizadoEn,
  }) {
    return TablaTramitesSecretariaCompanion(
      id: id ?? this.id,
      tipoTramite: tipoTramite ?? this.tipoTramite,
      categoria: categoria ?? this.categoria,
      codigo: codigo ?? this.codigo,
      asunto: asunto ?? this.asunto,
      solicitante: solicitante ?? this.solicitante,
      cursoReferencia: cursoReferencia ?? this.cursoReferencia,
      estado: estado ?? this.estado,
      prioridad: prioridad ?? this.prioridad,
      responsable: responsable ?? this.responsable,
      observaciones: observaciones ?? this.observaciones,
      fechaLimite: fechaLimite ?? this.fechaLimite,
      rolDestino: rolDestino ?? this.rolDestino,
      nivelDestino: nivelDestino ?? this.nivelDestino,
      dependenciaDestino: dependenciaDestino ?? this.dependenciaDestino,
      activo: activo ?? this.activo,
      creadoEn: creadoEn ?? this.creadoEn,
      actualizadoEn: actualizadoEn ?? this.actualizadoEn,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (tipoTramite.present) {
      map['tipo_tramite'] = Variable<String>(tipoTramite.value);
    }
    if (categoria.present) {
      map['categoria'] = Variable<String>(categoria.value);
    }
    if (codigo.present) {
      map['codigo'] = Variable<String>(codigo.value);
    }
    if (asunto.present) {
      map['asunto'] = Variable<String>(asunto.value);
    }
    if (solicitante.present) {
      map['solicitante'] = Variable<String>(solicitante.value);
    }
    if (cursoReferencia.present) {
      map['curso_referencia'] = Variable<String>(cursoReferencia.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    if (prioridad.present) {
      map['prioridad'] = Variable<String>(prioridad.value);
    }
    if (responsable.present) {
      map['responsable'] = Variable<String>(responsable.value);
    }
    if (observaciones.present) {
      map['observaciones'] = Variable<String>(observaciones.value);
    }
    if (fechaLimite.present) {
      map['fecha_limite'] = Variable<DateTime>(fechaLimite.value);
    }
    if (rolDestino.present) {
      map['rol_destino'] = Variable<String>(rolDestino.value);
    }
    if (nivelDestino.present) {
      map['nivel_destino'] = Variable<String>(nivelDestino.value);
    }
    if (dependenciaDestino.present) {
      map['dependencia_destino'] = Variable<String>(dependenciaDestino.value);
    }
    if (activo.present) {
      map['activo'] = Variable<bool>(activo.value);
    }
    if (creadoEn.present) {
      map['creado_en'] = Variable<DateTime>(creadoEn.value);
    }
    if (actualizadoEn.present) {
      map['actualizado_en'] = Variable<DateTime>(actualizadoEn.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TablaTramitesSecretariaCompanion(')
          ..write('id: $id, ')
          ..write('tipoTramite: $tipoTramite, ')
          ..write('categoria: $categoria, ')
          ..write('codigo: $codigo, ')
          ..write('asunto: $asunto, ')
          ..write('solicitante: $solicitante, ')
          ..write('cursoReferencia: $cursoReferencia, ')
          ..write('estado: $estado, ')
          ..write('prioridad: $prioridad, ')
          ..write('responsable: $responsable, ')
          ..write('observaciones: $observaciones, ')
          ..write('fechaLimite: $fechaLimite, ')
          ..write('rolDestino: $rolDestino, ')
          ..write('nivelDestino: $nivelDestino, ')
          ..write('dependenciaDestino: $dependenciaDestino, ')
          ..write('activo: $activo, ')
          ..write('creadoEn: $creadoEn, ')
          ..write('actualizadoEn: $actualizadoEn')
          ..write(')'))
        .toString();
  }
}

abstract class _$BaseDeDatos extends GeneratedDatabase {
  _$BaseDeDatos(QueryExecutor e) : super(e);
  $BaseDeDatosManager get managers => $BaseDeDatosManager(this);
  late final $TablaInstitucionesTable tablaInstituciones =
      $TablaInstitucionesTable(this);
  late final $TablaCarrerasTable tablaCarreras = $TablaCarrerasTable(this);
  late final $TablaAlumnosTable tablaAlumnos = $TablaAlumnosTable(this);
  late final $TablaMateriasTable tablaMaterias = $TablaMateriasTable(this);
  late final $TablaCursosTable tablaCursos = $TablaCursosTable(this);
  late final $TablaInscripcionesTable tablaInscripciones =
      $TablaInscripcionesTable(this);
  late final $TablaClasesTable tablaClases = $TablaClasesTable(this);
  late final $TablaAsistenciasTable tablaAsistencias = $TablaAsistenciasTable(
    this,
  );
  late final $TablaAlertasGestionHistorialTable tablaAlertasGestionHistorial =
      $TablaAlertasGestionHistorialTable(this);
  late final $TablaAlertasGestionEstadoTable tablaAlertasGestionEstado =
      $TablaAlertasGestionEstadoTable(this);
  late final $TablaIncidenciasTransversalesHistorialTable
  tablaIncidenciasTransversalesHistorial =
      $TablaIncidenciasTransversalesHistorialTable(this);
  late final $TablaLegajosDocumentalesTable tablaLegajosDocumentales =
      $TablaLegajosDocumentalesTable(this);
  late final $TablaNotasManualesTable tablaNotasManuales =
      $TablaNotasManualesTable(this);
  late final $TablaNovedadesPreceptoriaTable tablaNovedadesPreceptoria =
      $TablaNovedadesPreceptoriaTable(this);
  late final $TablaResponsablesGestionTable tablaResponsablesGestion =
      $TablaResponsablesGestionTable(this);
  late final $TablaRecursosBibliotecaTable tablaRecursosBiblioteca =
      $TablaRecursosBibliotecaTable(this);
  late final $TablaTramitesSecretariaTable tablaTramitesSecretaria =
      $TablaTramitesSecretariaTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    tablaInstituciones,
    tablaCarreras,
    tablaAlumnos,
    tablaMaterias,
    tablaCursos,
    tablaInscripciones,
    tablaClases,
    tablaAsistencias,
    tablaAlertasGestionHistorial,
    tablaAlertasGestionEstado,
    tablaIncidenciasTransversalesHistorial,
    tablaLegajosDocumentales,
    tablaNotasManuales,
    tablaNovedadesPreceptoria,
    tablaResponsablesGestion,
    tablaRecursosBiblioteca,
    tablaTramitesSecretaria,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tabla_instituciones',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('tabla_carreras', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tabla_instituciones',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('tabla_alumnos', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tabla_carreras',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('tabla_alumnos', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tabla_carreras',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('tabla_materias', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tabla_instituciones',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('tabla_cursos', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tabla_carreras',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('tabla_cursos', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tabla_materias',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('tabla_cursos', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tabla_alumnos',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('tabla_inscripciones', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tabla_cursos',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('tabla_inscripciones', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tabla_cursos',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('tabla_clases', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tabla_clases',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('tabla_asistencias', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tabla_alumnos',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('tabla_asistencias', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tabla_alumnos',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('tabla_notas_manuales', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$TablaInstitucionesTableCreateCompanionBuilder =
    TablaInstitucionesCompanion Function({
      Value<int> id,
      required String nombre,
      Value<bool> activo,
      Value<DateTime> creadoEn,
    });
typedef $$TablaInstitucionesTableUpdateCompanionBuilder =
    TablaInstitucionesCompanion Function({
      Value<int> id,
      Value<String> nombre,
      Value<bool> activo,
      Value<DateTime> creadoEn,
    });

final class $$TablaInstitucionesTableReferences
    extends
        BaseReferences<
          _$BaseDeDatos,
          $TablaInstitucionesTable,
          TablaInstitucione
        > {
  $$TablaInstitucionesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$TablaCarrerasTable, List<TablaCarrera>>
  _tablaCarrerasRefsTable(_$BaseDeDatos db) => MultiTypedResultKey.fromTable(
    db.tablaCarreras,
    aliasName: $_aliasNameGenerator(
      db.tablaInstituciones.id,
      db.tablaCarreras.institucionId,
    ),
  );

  $$TablaCarrerasTableProcessedTableManager get tablaCarrerasRefs {
    final manager = $$TablaCarrerasTableTableManager(
      $_db,
      $_db.tablaCarreras,
    ).filter((f) => f.institucionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_tablaCarrerasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TablaAlumnosTable, List<TablaAlumno>>
  _tablaAlumnosRefsTable(_$BaseDeDatos db) => MultiTypedResultKey.fromTable(
    db.tablaAlumnos,
    aliasName: $_aliasNameGenerator(
      db.tablaInstituciones.id,
      db.tablaAlumnos.institucionId,
    ),
  );

  $$TablaAlumnosTableProcessedTableManager get tablaAlumnosRefs {
    final manager = $$TablaAlumnosTableTableManager(
      $_db,
      $_db.tablaAlumnos,
    ).filter((f) => f.institucionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_tablaAlumnosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TablaCursosTable, List<TablaCurso>>
  _tablaCursosRefsTable(_$BaseDeDatos db) => MultiTypedResultKey.fromTable(
    db.tablaCursos,
    aliasName: $_aliasNameGenerator(
      db.tablaInstituciones.id,
      db.tablaCursos.institucionId,
    ),
  );

  $$TablaCursosTableProcessedTableManager get tablaCursosRefs {
    final manager = $$TablaCursosTableTableManager(
      $_db,
      $_db.tablaCursos,
    ).filter((f) => f.institucionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_tablaCursosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TablaInstitucionesTableFilterComposer
    extends Composer<_$BaseDeDatos, $TablaInstitucionesTable> {
  $$TablaInstitucionesTableFilterComposer({
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

  ColumnFilters<bool> get activo => $composableBuilder(
    column: $table.activo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> tablaCarrerasRefs(
    Expression<bool> Function($$TablaCarrerasTableFilterComposer f) f,
  ) {
    final $$TablaCarrerasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tablaCarreras,
      getReferencedColumn: (t) => t.institucionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaCarrerasTableFilterComposer(
            $db: $db,
            $table: $db.tablaCarreras,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> tablaAlumnosRefs(
    Expression<bool> Function($$TablaAlumnosTableFilterComposer f) f,
  ) {
    final $$TablaAlumnosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tablaAlumnos,
      getReferencedColumn: (t) => t.institucionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaAlumnosTableFilterComposer(
            $db: $db,
            $table: $db.tablaAlumnos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> tablaCursosRefs(
    Expression<bool> Function($$TablaCursosTableFilterComposer f) f,
  ) {
    final $$TablaCursosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tablaCursos,
      getReferencedColumn: (t) => t.institucionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaCursosTableFilterComposer(
            $db: $db,
            $table: $db.tablaCursos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TablaInstitucionesTableOrderingComposer
    extends Composer<_$BaseDeDatos, $TablaInstitucionesTable> {
  $$TablaInstitucionesTableOrderingComposer({
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

  ColumnOrderings<bool> get activo => $composableBuilder(
    column: $table.activo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TablaInstitucionesTableAnnotationComposer
    extends Composer<_$BaseDeDatos, $TablaInstitucionesTable> {
  $$TablaInstitucionesTableAnnotationComposer({
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

  GeneratedColumn<bool> get activo =>
      $composableBuilder(column: $table.activo, builder: (column) => column);

  GeneratedColumn<DateTime> get creadoEn =>
      $composableBuilder(column: $table.creadoEn, builder: (column) => column);

  Expression<T> tablaCarrerasRefs<T extends Object>(
    Expression<T> Function($$TablaCarrerasTableAnnotationComposer a) f,
  ) {
    final $$TablaCarrerasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tablaCarreras,
      getReferencedColumn: (t) => t.institucionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaCarrerasTableAnnotationComposer(
            $db: $db,
            $table: $db.tablaCarreras,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> tablaAlumnosRefs<T extends Object>(
    Expression<T> Function($$TablaAlumnosTableAnnotationComposer a) f,
  ) {
    final $$TablaAlumnosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tablaAlumnos,
      getReferencedColumn: (t) => t.institucionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaAlumnosTableAnnotationComposer(
            $db: $db,
            $table: $db.tablaAlumnos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> tablaCursosRefs<T extends Object>(
    Expression<T> Function($$TablaCursosTableAnnotationComposer a) f,
  ) {
    final $$TablaCursosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tablaCursos,
      getReferencedColumn: (t) => t.institucionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaCursosTableAnnotationComposer(
            $db: $db,
            $table: $db.tablaCursos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TablaInstitucionesTableTableManager
    extends
        RootTableManager<
          _$BaseDeDatos,
          $TablaInstitucionesTable,
          TablaInstitucione,
          $$TablaInstitucionesTableFilterComposer,
          $$TablaInstitucionesTableOrderingComposer,
          $$TablaInstitucionesTableAnnotationComposer,
          $$TablaInstitucionesTableCreateCompanionBuilder,
          $$TablaInstitucionesTableUpdateCompanionBuilder,
          (TablaInstitucione, $$TablaInstitucionesTableReferences),
          TablaInstitucione,
          PrefetchHooks Function({
            bool tablaCarrerasRefs,
            bool tablaAlumnosRefs,
            bool tablaCursosRefs,
          })
        > {
  $$TablaInstitucionesTableTableManager(
    _$BaseDeDatos db,
    $TablaInstitucionesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TablaInstitucionesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TablaInstitucionesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TablaInstitucionesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<bool> activo = const Value.absent(),
                Value<DateTime> creadoEn = const Value.absent(),
              }) => TablaInstitucionesCompanion(
                id: id,
                nombre: nombre,
                activo: activo,
                creadoEn: creadoEn,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nombre,
                Value<bool> activo = const Value.absent(),
                Value<DateTime> creadoEn = const Value.absent(),
              }) => TablaInstitucionesCompanion.insert(
                id: id,
                nombre: nombre,
                activo: activo,
                creadoEn: creadoEn,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TablaInstitucionesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                tablaCarrerasRefs = false,
                tablaAlumnosRefs = false,
                tablaCursosRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (tablaCarrerasRefs) db.tablaCarreras,
                    if (tablaAlumnosRefs) db.tablaAlumnos,
                    if (tablaCursosRefs) db.tablaCursos,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (tablaCarrerasRefs)
                        await $_getPrefetchedData<
                          TablaInstitucione,
                          $TablaInstitucionesTable,
                          TablaCarrera
                        >(
                          currentTable: table,
                          referencedTable: $$TablaInstitucionesTableReferences
                              ._tablaCarrerasRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TablaInstitucionesTableReferences(
                                db,
                                table,
                                p0,
                              ).tablaCarrerasRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.institucionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (tablaAlumnosRefs)
                        await $_getPrefetchedData<
                          TablaInstitucione,
                          $TablaInstitucionesTable,
                          TablaAlumno
                        >(
                          currentTable: table,
                          referencedTable: $$TablaInstitucionesTableReferences
                              ._tablaAlumnosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TablaInstitucionesTableReferences(
                                db,
                                table,
                                p0,
                              ).tablaAlumnosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.institucionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (tablaCursosRefs)
                        await $_getPrefetchedData<
                          TablaInstitucione,
                          $TablaInstitucionesTable,
                          TablaCurso
                        >(
                          currentTable: table,
                          referencedTable: $$TablaInstitucionesTableReferences
                              ._tablaCursosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TablaInstitucionesTableReferences(
                                db,
                                table,
                                p0,
                              ).tablaCursosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.institucionId == item.id,
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

typedef $$TablaInstitucionesTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDeDatos,
      $TablaInstitucionesTable,
      TablaInstitucione,
      $$TablaInstitucionesTableFilterComposer,
      $$TablaInstitucionesTableOrderingComposer,
      $$TablaInstitucionesTableAnnotationComposer,
      $$TablaInstitucionesTableCreateCompanionBuilder,
      $$TablaInstitucionesTableUpdateCompanionBuilder,
      (TablaInstitucione, $$TablaInstitucionesTableReferences),
      TablaInstitucione,
      PrefetchHooks Function({
        bool tablaCarrerasRefs,
        bool tablaAlumnosRefs,
        bool tablaCursosRefs,
      })
    >;
typedef $$TablaCarrerasTableCreateCompanionBuilder =
    TablaCarrerasCompanion Function({
      Value<int> id,
      required int institucionId,
      required String nombre,
      Value<bool> activo,
      Value<DateTime> creadoEn,
    });
typedef $$TablaCarrerasTableUpdateCompanionBuilder =
    TablaCarrerasCompanion Function({
      Value<int> id,
      Value<int> institucionId,
      Value<String> nombre,
      Value<bool> activo,
      Value<DateTime> creadoEn,
    });

final class $$TablaCarrerasTableReferences
    extends BaseReferences<_$BaseDeDatos, $TablaCarrerasTable, TablaCarrera> {
  $$TablaCarrerasTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TablaInstitucionesTable _institucionIdTable(_$BaseDeDatos db) =>
      db.tablaInstituciones.createAlias(
        $_aliasNameGenerator(
          db.tablaCarreras.institucionId,
          db.tablaInstituciones.id,
        ),
      );

  $$TablaInstitucionesTableProcessedTableManager get institucionId {
    final $_column = $_itemColumn<int>('institucion_id')!;

    final manager = $$TablaInstitucionesTableTableManager(
      $_db,
      $_db.tablaInstituciones,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_institucionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TablaAlumnosTable, List<TablaAlumno>>
  _tablaAlumnosRefsTable(_$BaseDeDatos db) => MultiTypedResultKey.fromTable(
    db.tablaAlumnos,
    aliasName: $_aliasNameGenerator(
      db.tablaCarreras.id,
      db.tablaAlumnos.carreraId,
    ),
  );

  $$TablaAlumnosTableProcessedTableManager get tablaAlumnosRefs {
    final manager = $$TablaAlumnosTableTableManager(
      $_db,
      $_db.tablaAlumnos,
    ).filter((f) => f.carreraId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_tablaAlumnosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TablaMateriasTable, List<TablaMateria>>
  _tablaMateriasRefsTable(_$BaseDeDatos db) => MultiTypedResultKey.fromTable(
    db.tablaMaterias,
    aliasName: $_aliasNameGenerator(
      db.tablaCarreras.id,
      db.tablaMaterias.carreraId,
    ),
  );

  $$TablaMateriasTableProcessedTableManager get tablaMateriasRefs {
    final manager = $$TablaMateriasTableTableManager(
      $_db,
      $_db.tablaMaterias,
    ).filter((f) => f.carreraId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_tablaMateriasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TablaCursosTable, List<TablaCurso>>
  _tablaCursosRefsTable(_$BaseDeDatos db) => MultiTypedResultKey.fromTable(
    db.tablaCursos,
    aliasName: $_aliasNameGenerator(
      db.tablaCarreras.id,
      db.tablaCursos.carreraId,
    ),
  );

  $$TablaCursosTableProcessedTableManager get tablaCursosRefs {
    final manager = $$TablaCursosTableTableManager(
      $_db,
      $_db.tablaCursos,
    ).filter((f) => f.carreraId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_tablaCursosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TablaCarrerasTableFilterComposer
    extends Composer<_$BaseDeDatos, $TablaCarrerasTable> {
  $$TablaCarrerasTableFilterComposer({
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

  ColumnFilters<bool> get activo => $composableBuilder(
    column: $table.activo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnFilters(column),
  );

  $$TablaInstitucionesTableFilterComposer get institucionId {
    final $$TablaInstitucionesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.institucionId,
      referencedTable: $db.tablaInstituciones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaInstitucionesTableFilterComposer(
            $db: $db,
            $table: $db.tablaInstituciones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> tablaAlumnosRefs(
    Expression<bool> Function($$TablaAlumnosTableFilterComposer f) f,
  ) {
    final $$TablaAlumnosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tablaAlumnos,
      getReferencedColumn: (t) => t.carreraId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaAlumnosTableFilterComposer(
            $db: $db,
            $table: $db.tablaAlumnos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> tablaMateriasRefs(
    Expression<bool> Function($$TablaMateriasTableFilterComposer f) f,
  ) {
    final $$TablaMateriasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tablaMaterias,
      getReferencedColumn: (t) => t.carreraId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaMateriasTableFilterComposer(
            $db: $db,
            $table: $db.tablaMaterias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> tablaCursosRefs(
    Expression<bool> Function($$TablaCursosTableFilterComposer f) f,
  ) {
    final $$TablaCursosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tablaCursos,
      getReferencedColumn: (t) => t.carreraId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaCursosTableFilterComposer(
            $db: $db,
            $table: $db.tablaCursos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TablaCarrerasTableOrderingComposer
    extends Composer<_$BaseDeDatos, $TablaCarrerasTable> {
  $$TablaCarrerasTableOrderingComposer({
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

  ColumnOrderings<bool> get activo => $composableBuilder(
    column: $table.activo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnOrderings(column),
  );

  $$TablaInstitucionesTableOrderingComposer get institucionId {
    final $$TablaInstitucionesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.institucionId,
      referencedTable: $db.tablaInstituciones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaInstitucionesTableOrderingComposer(
            $db: $db,
            $table: $db.tablaInstituciones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TablaCarrerasTableAnnotationComposer
    extends Composer<_$BaseDeDatos, $TablaCarrerasTable> {
  $$TablaCarrerasTableAnnotationComposer({
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

  GeneratedColumn<bool> get activo =>
      $composableBuilder(column: $table.activo, builder: (column) => column);

  GeneratedColumn<DateTime> get creadoEn =>
      $composableBuilder(column: $table.creadoEn, builder: (column) => column);

  $$TablaInstitucionesTableAnnotationComposer get institucionId {
    final $$TablaInstitucionesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.institucionId,
          referencedTable: $db.tablaInstituciones,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TablaInstitucionesTableAnnotationComposer(
                $db: $db,
                $table: $db.tablaInstituciones,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> tablaAlumnosRefs<T extends Object>(
    Expression<T> Function($$TablaAlumnosTableAnnotationComposer a) f,
  ) {
    final $$TablaAlumnosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tablaAlumnos,
      getReferencedColumn: (t) => t.carreraId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaAlumnosTableAnnotationComposer(
            $db: $db,
            $table: $db.tablaAlumnos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> tablaMateriasRefs<T extends Object>(
    Expression<T> Function($$TablaMateriasTableAnnotationComposer a) f,
  ) {
    final $$TablaMateriasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tablaMaterias,
      getReferencedColumn: (t) => t.carreraId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaMateriasTableAnnotationComposer(
            $db: $db,
            $table: $db.tablaMaterias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> tablaCursosRefs<T extends Object>(
    Expression<T> Function($$TablaCursosTableAnnotationComposer a) f,
  ) {
    final $$TablaCursosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tablaCursos,
      getReferencedColumn: (t) => t.carreraId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaCursosTableAnnotationComposer(
            $db: $db,
            $table: $db.tablaCursos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TablaCarrerasTableTableManager
    extends
        RootTableManager<
          _$BaseDeDatos,
          $TablaCarrerasTable,
          TablaCarrera,
          $$TablaCarrerasTableFilterComposer,
          $$TablaCarrerasTableOrderingComposer,
          $$TablaCarrerasTableAnnotationComposer,
          $$TablaCarrerasTableCreateCompanionBuilder,
          $$TablaCarrerasTableUpdateCompanionBuilder,
          (TablaCarrera, $$TablaCarrerasTableReferences),
          TablaCarrera,
          PrefetchHooks Function({
            bool institucionId,
            bool tablaAlumnosRefs,
            bool tablaMateriasRefs,
            bool tablaCursosRefs,
          })
        > {
  $$TablaCarrerasTableTableManager(_$BaseDeDatos db, $TablaCarrerasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TablaCarrerasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TablaCarrerasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TablaCarrerasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> institucionId = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<bool> activo = const Value.absent(),
                Value<DateTime> creadoEn = const Value.absent(),
              }) => TablaCarrerasCompanion(
                id: id,
                institucionId: institucionId,
                nombre: nombre,
                activo: activo,
                creadoEn: creadoEn,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int institucionId,
                required String nombre,
                Value<bool> activo = const Value.absent(),
                Value<DateTime> creadoEn = const Value.absent(),
              }) => TablaCarrerasCompanion.insert(
                id: id,
                institucionId: institucionId,
                nombre: nombre,
                activo: activo,
                creadoEn: creadoEn,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TablaCarrerasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                institucionId = false,
                tablaAlumnosRefs = false,
                tablaMateriasRefs = false,
                tablaCursosRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (tablaAlumnosRefs) db.tablaAlumnos,
                    if (tablaMateriasRefs) db.tablaMaterias,
                    if (tablaCursosRefs) db.tablaCursos,
                  ],
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
                        if (institucionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.institucionId,
                                    referencedTable:
                                        $$TablaCarrerasTableReferences
                                            ._institucionIdTable(db),
                                    referencedColumn:
                                        $$TablaCarrerasTableReferences
                                            ._institucionIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (tablaAlumnosRefs)
                        await $_getPrefetchedData<
                          TablaCarrera,
                          $TablaCarrerasTable,
                          TablaAlumno
                        >(
                          currentTable: table,
                          referencedTable: $$TablaCarrerasTableReferences
                              ._tablaAlumnosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TablaCarrerasTableReferences(
                                db,
                                table,
                                p0,
                              ).tablaAlumnosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.carreraId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (tablaMateriasRefs)
                        await $_getPrefetchedData<
                          TablaCarrera,
                          $TablaCarrerasTable,
                          TablaMateria
                        >(
                          currentTable: table,
                          referencedTable: $$TablaCarrerasTableReferences
                              ._tablaMateriasRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TablaCarrerasTableReferences(
                                db,
                                table,
                                p0,
                              ).tablaMateriasRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.carreraId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (tablaCursosRefs)
                        await $_getPrefetchedData<
                          TablaCarrera,
                          $TablaCarrerasTable,
                          TablaCurso
                        >(
                          currentTable: table,
                          referencedTable: $$TablaCarrerasTableReferences
                              ._tablaCursosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TablaCarrerasTableReferences(
                                db,
                                table,
                                p0,
                              ).tablaCursosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.carreraId == item.id,
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

typedef $$TablaCarrerasTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDeDatos,
      $TablaCarrerasTable,
      TablaCarrera,
      $$TablaCarrerasTableFilterComposer,
      $$TablaCarrerasTableOrderingComposer,
      $$TablaCarrerasTableAnnotationComposer,
      $$TablaCarrerasTableCreateCompanionBuilder,
      $$TablaCarrerasTableUpdateCompanionBuilder,
      (TablaCarrera, $$TablaCarrerasTableReferences),
      TablaCarrera,
      PrefetchHooks Function({
        bool institucionId,
        bool tablaAlumnosRefs,
        bool tablaMateriasRefs,
        bool tablaCursosRefs,
      })
    >;
typedef $$TablaAlumnosTableCreateCompanionBuilder =
    TablaAlumnosCompanion Function({
      Value<int> id,
      required String apellido,
      required String nombre,
      Value<int?> edad,
      Value<String?> documento,
      Value<String?> email,
      Value<String?> telefono,
      Value<String?> fotoPath,
      Value<int?> institucionId,
      Value<int?> carreraId,
      Value<bool> activo,
      Value<DateTime> creadoEn,
    });
typedef $$TablaAlumnosTableUpdateCompanionBuilder =
    TablaAlumnosCompanion Function({
      Value<int> id,
      Value<String> apellido,
      Value<String> nombre,
      Value<int?> edad,
      Value<String?> documento,
      Value<String?> email,
      Value<String?> telefono,
      Value<String?> fotoPath,
      Value<int?> institucionId,
      Value<int?> carreraId,
      Value<bool> activo,
      Value<DateTime> creadoEn,
    });

final class $$TablaAlumnosTableReferences
    extends BaseReferences<_$BaseDeDatos, $TablaAlumnosTable, TablaAlumno> {
  $$TablaAlumnosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TablaInstitucionesTable _institucionIdTable(_$BaseDeDatos db) =>
      db.tablaInstituciones.createAlias(
        $_aliasNameGenerator(
          db.tablaAlumnos.institucionId,
          db.tablaInstituciones.id,
        ),
      );

  $$TablaInstitucionesTableProcessedTableManager? get institucionId {
    final $_column = $_itemColumn<int>('institucion_id');
    if ($_column == null) return null;
    final manager = $$TablaInstitucionesTableTableManager(
      $_db,
      $_db.tablaInstituciones,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_institucionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TablaCarrerasTable _carreraIdTable(_$BaseDeDatos db) =>
      db.tablaCarreras.createAlias(
        $_aliasNameGenerator(db.tablaAlumnos.carreraId, db.tablaCarreras.id),
      );

  $$TablaCarrerasTableProcessedTableManager? get carreraId {
    final $_column = $_itemColumn<int>('carrera_id');
    if ($_column == null) return null;
    final manager = $$TablaCarrerasTableTableManager(
      $_db,
      $_db.tablaCarreras,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_carreraIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TablaInscripcionesTable, List<TablaInscripcione>>
  _tablaInscripcionesRefsTable(_$BaseDeDatos db) =>
      MultiTypedResultKey.fromTable(
        db.tablaInscripciones,
        aliasName: $_aliasNameGenerator(
          db.tablaAlumnos.id,
          db.tablaInscripciones.alumnoId,
        ),
      );

  $$TablaInscripcionesTableProcessedTableManager get tablaInscripcionesRefs {
    final manager = $$TablaInscripcionesTableTableManager(
      $_db,
      $_db.tablaInscripciones,
    ).filter((f) => f.alumnoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _tablaInscripcionesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TablaAsistenciasTable, List<TablaAsistencia>>
  _tablaAsistenciasRefsTable(_$BaseDeDatos db) => MultiTypedResultKey.fromTable(
    db.tablaAsistencias,
    aliasName: $_aliasNameGenerator(
      db.tablaAlumnos.id,
      db.tablaAsistencias.alumnoId,
    ),
  );

  $$TablaAsistenciasTableProcessedTableManager get tablaAsistenciasRefs {
    final manager = $$TablaAsistenciasTableTableManager(
      $_db,
      $_db.tablaAsistencias,
    ).filter((f) => f.alumnoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _tablaAsistenciasRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TablaNotasManualesTable, List<TablaNotasManuale>>
  _tablaNotasManualesRefsTable(_$BaseDeDatos db) =>
      MultiTypedResultKey.fromTable(
        db.tablaNotasManuales,
        aliasName: $_aliasNameGenerator(
          db.tablaAlumnos.id,
          db.tablaNotasManuales.alumnoId,
        ),
      );

  $$TablaNotasManualesTableProcessedTableManager get tablaNotasManualesRefs {
    final manager = $$TablaNotasManualesTableTableManager(
      $_db,
      $_db.tablaNotasManuales,
    ).filter((f) => f.alumnoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _tablaNotasManualesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TablaAlumnosTableFilterComposer
    extends Composer<_$BaseDeDatos, $TablaAlumnosTable> {
  $$TablaAlumnosTableFilterComposer({
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

  ColumnFilters<String> get apellido => $composableBuilder(
    column: $table.apellido,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get edad => $composableBuilder(
    column: $table.edad,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get documento => $composableBuilder(
    column: $table.documento,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get telefono => $composableBuilder(
    column: $table.telefono,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fotoPath => $composableBuilder(
    column: $table.fotoPath,
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

  $$TablaInstitucionesTableFilterComposer get institucionId {
    final $$TablaInstitucionesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.institucionId,
      referencedTable: $db.tablaInstituciones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaInstitucionesTableFilterComposer(
            $db: $db,
            $table: $db.tablaInstituciones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TablaCarrerasTableFilterComposer get carreraId {
    final $$TablaCarrerasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.carreraId,
      referencedTable: $db.tablaCarreras,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaCarrerasTableFilterComposer(
            $db: $db,
            $table: $db.tablaCarreras,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> tablaInscripcionesRefs(
    Expression<bool> Function($$TablaInscripcionesTableFilterComposer f) f,
  ) {
    final $$TablaInscripcionesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tablaInscripciones,
      getReferencedColumn: (t) => t.alumnoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaInscripcionesTableFilterComposer(
            $db: $db,
            $table: $db.tablaInscripciones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> tablaAsistenciasRefs(
    Expression<bool> Function($$TablaAsistenciasTableFilterComposer f) f,
  ) {
    final $$TablaAsistenciasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tablaAsistencias,
      getReferencedColumn: (t) => t.alumnoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaAsistenciasTableFilterComposer(
            $db: $db,
            $table: $db.tablaAsistencias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> tablaNotasManualesRefs(
    Expression<bool> Function($$TablaNotasManualesTableFilterComposer f) f,
  ) {
    final $$TablaNotasManualesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tablaNotasManuales,
      getReferencedColumn: (t) => t.alumnoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaNotasManualesTableFilterComposer(
            $db: $db,
            $table: $db.tablaNotasManuales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TablaAlumnosTableOrderingComposer
    extends Composer<_$BaseDeDatos, $TablaAlumnosTable> {
  $$TablaAlumnosTableOrderingComposer({
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

  ColumnOrderings<String> get apellido => $composableBuilder(
    column: $table.apellido,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get edad => $composableBuilder(
    column: $table.edad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get documento => $composableBuilder(
    column: $table.documento,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get telefono => $composableBuilder(
    column: $table.telefono,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fotoPath => $composableBuilder(
    column: $table.fotoPath,
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

  $$TablaInstitucionesTableOrderingComposer get institucionId {
    final $$TablaInstitucionesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.institucionId,
      referencedTable: $db.tablaInstituciones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaInstitucionesTableOrderingComposer(
            $db: $db,
            $table: $db.tablaInstituciones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TablaCarrerasTableOrderingComposer get carreraId {
    final $$TablaCarrerasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.carreraId,
      referencedTable: $db.tablaCarreras,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaCarrerasTableOrderingComposer(
            $db: $db,
            $table: $db.tablaCarreras,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TablaAlumnosTableAnnotationComposer
    extends Composer<_$BaseDeDatos, $TablaAlumnosTable> {
  $$TablaAlumnosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get apellido =>
      $composableBuilder(column: $table.apellido, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<int> get edad =>
      $composableBuilder(column: $table.edad, builder: (column) => column);

  GeneratedColumn<String> get documento =>
      $composableBuilder(column: $table.documento, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get telefono =>
      $composableBuilder(column: $table.telefono, builder: (column) => column);

  GeneratedColumn<String> get fotoPath =>
      $composableBuilder(column: $table.fotoPath, builder: (column) => column);

  GeneratedColumn<bool> get activo =>
      $composableBuilder(column: $table.activo, builder: (column) => column);

  GeneratedColumn<DateTime> get creadoEn =>
      $composableBuilder(column: $table.creadoEn, builder: (column) => column);

  $$TablaInstitucionesTableAnnotationComposer get institucionId {
    final $$TablaInstitucionesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.institucionId,
          referencedTable: $db.tablaInstituciones,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TablaInstitucionesTableAnnotationComposer(
                $db: $db,
                $table: $db.tablaInstituciones,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$TablaCarrerasTableAnnotationComposer get carreraId {
    final $$TablaCarrerasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.carreraId,
      referencedTable: $db.tablaCarreras,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaCarrerasTableAnnotationComposer(
            $db: $db,
            $table: $db.tablaCarreras,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> tablaInscripcionesRefs<T extends Object>(
    Expression<T> Function($$TablaInscripcionesTableAnnotationComposer a) f,
  ) {
    final $$TablaInscripcionesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.tablaInscripciones,
          getReferencedColumn: (t) => t.alumnoId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TablaInscripcionesTableAnnotationComposer(
                $db: $db,
                $table: $db.tablaInscripciones,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> tablaAsistenciasRefs<T extends Object>(
    Expression<T> Function($$TablaAsistenciasTableAnnotationComposer a) f,
  ) {
    final $$TablaAsistenciasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tablaAsistencias,
      getReferencedColumn: (t) => t.alumnoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaAsistenciasTableAnnotationComposer(
            $db: $db,
            $table: $db.tablaAsistencias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> tablaNotasManualesRefs<T extends Object>(
    Expression<T> Function($$TablaNotasManualesTableAnnotationComposer a) f,
  ) {
    final $$TablaNotasManualesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.tablaNotasManuales,
          getReferencedColumn: (t) => t.alumnoId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TablaNotasManualesTableAnnotationComposer(
                $db: $db,
                $table: $db.tablaNotasManuales,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$TablaAlumnosTableTableManager
    extends
        RootTableManager<
          _$BaseDeDatos,
          $TablaAlumnosTable,
          TablaAlumno,
          $$TablaAlumnosTableFilterComposer,
          $$TablaAlumnosTableOrderingComposer,
          $$TablaAlumnosTableAnnotationComposer,
          $$TablaAlumnosTableCreateCompanionBuilder,
          $$TablaAlumnosTableUpdateCompanionBuilder,
          (TablaAlumno, $$TablaAlumnosTableReferences),
          TablaAlumno,
          PrefetchHooks Function({
            bool institucionId,
            bool carreraId,
            bool tablaInscripcionesRefs,
            bool tablaAsistenciasRefs,
            bool tablaNotasManualesRefs,
          })
        > {
  $$TablaAlumnosTableTableManager(_$BaseDeDatos db, $TablaAlumnosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TablaAlumnosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TablaAlumnosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TablaAlumnosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> apellido = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<int?> edad = const Value.absent(),
                Value<String?> documento = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> telefono = const Value.absent(),
                Value<String?> fotoPath = const Value.absent(),
                Value<int?> institucionId = const Value.absent(),
                Value<int?> carreraId = const Value.absent(),
                Value<bool> activo = const Value.absent(),
                Value<DateTime> creadoEn = const Value.absent(),
              }) => TablaAlumnosCompanion(
                id: id,
                apellido: apellido,
                nombre: nombre,
                edad: edad,
                documento: documento,
                email: email,
                telefono: telefono,
                fotoPath: fotoPath,
                institucionId: institucionId,
                carreraId: carreraId,
                activo: activo,
                creadoEn: creadoEn,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String apellido,
                required String nombre,
                Value<int?> edad = const Value.absent(),
                Value<String?> documento = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> telefono = const Value.absent(),
                Value<String?> fotoPath = const Value.absent(),
                Value<int?> institucionId = const Value.absent(),
                Value<int?> carreraId = const Value.absent(),
                Value<bool> activo = const Value.absent(),
                Value<DateTime> creadoEn = const Value.absent(),
              }) => TablaAlumnosCompanion.insert(
                id: id,
                apellido: apellido,
                nombre: nombre,
                edad: edad,
                documento: documento,
                email: email,
                telefono: telefono,
                fotoPath: fotoPath,
                institucionId: institucionId,
                carreraId: carreraId,
                activo: activo,
                creadoEn: creadoEn,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TablaAlumnosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                institucionId = false,
                carreraId = false,
                tablaInscripcionesRefs = false,
                tablaAsistenciasRefs = false,
                tablaNotasManualesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (tablaInscripcionesRefs) db.tablaInscripciones,
                    if (tablaAsistenciasRefs) db.tablaAsistencias,
                    if (tablaNotasManualesRefs) db.tablaNotasManuales,
                  ],
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
                        if (institucionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.institucionId,
                                    referencedTable:
                                        $$TablaAlumnosTableReferences
                                            ._institucionIdTable(db),
                                    referencedColumn:
                                        $$TablaAlumnosTableReferences
                                            ._institucionIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (carreraId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.carreraId,
                                    referencedTable:
                                        $$TablaAlumnosTableReferences
                                            ._carreraIdTable(db),
                                    referencedColumn:
                                        $$TablaAlumnosTableReferences
                                            ._carreraIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (tablaInscripcionesRefs)
                        await $_getPrefetchedData<
                          TablaAlumno,
                          $TablaAlumnosTable,
                          TablaInscripcione
                        >(
                          currentTable: table,
                          referencedTable: $$TablaAlumnosTableReferences
                              ._tablaInscripcionesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TablaAlumnosTableReferences(
                                db,
                                table,
                                p0,
                              ).tablaInscripcionesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.alumnoId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (tablaAsistenciasRefs)
                        await $_getPrefetchedData<
                          TablaAlumno,
                          $TablaAlumnosTable,
                          TablaAsistencia
                        >(
                          currentTable: table,
                          referencedTable: $$TablaAlumnosTableReferences
                              ._tablaAsistenciasRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TablaAlumnosTableReferences(
                                db,
                                table,
                                p0,
                              ).tablaAsistenciasRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.alumnoId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (tablaNotasManualesRefs)
                        await $_getPrefetchedData<
                          TablaAlumno,
                          $TablaAlumnosTable,
                          TablaNotasManuale
                        >(
                          currentTable: table,
                          referencedTable: $$TablaAlumnosTableReferences
                              ._tablaNotasManualesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TablaAlumnosTableReferences(
                                db,
                                table,
                                p0,
                              ).tablaNotasManualesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.alumnoId == item.id,
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

typedef $$TablaAlumnosTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDeDatos,
      $TablaAlumnosTable,
      TablaAlumno,
      $$TablaAlumnosTableFilterComposer,
      $$TablaAlumnosTableOrderingComposer,
      $$TablaAlumnosTableAnnotationComposer,
      $$TablaAlumnosTableCreateCompanionBuilder,
      $$TablaAlumnosTableUpdateCompanionBuilder,
      (TablaAlumno, $$TablaAlumnosTableReferences),
      TablaAlumno,
      PrefetchHooks Function({
        bool institucionId,
        bool carreraId,
        bool tablaInscripcionesRefs,
        bool tablaAsistenciasRefs,
        bool tablaNotasManualesRefs,
      })
    >;
typedef $$TablaMateriasTableCreateCompanionBuilder =
    TablaMateriasCompanion Function({
      Value<int> id,
      required int carreraId,
      required String nombre,
      required int anioCursada,
      required String curso,
      Value<bool> activo,
      Value<DateTime> creadoEn,
    });
typedef $$TablaMateriasTableUpdateCompanionBuilder =
    TablaMateriasCompanion Function({
      Value<int> id,
      Value<int> carreraId,
      Value<String> nombre,
      Value<int> anioCursada,
      Value<String> curso,
      Value<bool> activo,
      Value<DateTime> creadoEn,
    });

final class $$TablaMateriasTableReferences
    extends BaseReferences<_$BaseDeDatos, $TablaMateriasTable, TablaMateria> {
  $$TablaMateriasTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TablaCarrerasTable _carreraIdTable(_$BaseDeDatos db) =>
      db.tablaCarreras.createAlias(
        $_aliasNameGenerator(db.tablaMaterias.carreraId, db.tablaCarreras.id),
      );

  $$TablaCarrerasTableProcessedTableManager get carreraId {
    final $_column = $_itemColumn<int>('carrera_id')!;

    final manager = $$TablaCarrerasTableTableManager(
      $_db,
      $_db.tablaCarreras,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_carreraIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TablaCursosTable, List<TablaCurso>>
  _tablaCursosRefsTable(_$BaseDeDatos db) => MultiTypedResultKey.fromTable(
    db.tablaCursos,
    aliasName: $_aliasNameGenerator(
      db.tablaMaterias.id,
      db.tablaCursos.materiaId,
    ),
  );

  $$TablaCursosTableProcessedTableManager get tablaCursosRefs {
    final manager = $$TablaCursosTableTableManager(
      $_db,
      $_db.tablaCursos,
    ).filter((f) => f.materiaId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_tablaCursosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TablaMateriasTableFilterComposer
    extends Composer<_$BaseDeDatos, $TablaMateriasTable> {
  $$TablaMateriasTableFilterComposer({
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

  ColumnFilters<int> get anioCursada => $composableBuilder(
    column: $table.anioCursada,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get curso => $composableBuilder(
    column: $table.curso,
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

  $$TablaCarrerasTableFilterComposer get carreraId {
    final $$TablaCarrerasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.carreraId,
      referencedTable: $db.tablaCarreras,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaCarrerasTableFilterComposer(
            $db: $db,
            $table: $db.tablaCarreras,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> tablaCursosRefs(
    Expression<bool> Function($$TablaCursosTableFilterComposer f) f,
  ) {
    final $$TablaCursosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tablaCursos,
      getReferencedColumn: (t) => t.materiaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaCursosTableFilterComposer(
            $db: $db,
            $table: $db.tablaCursos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TablaMateriasTableOrderingComposer
    extends Composer<_$BaseDeDatos, $TablaMateriasTable> {
  $$TablaMateriasTableOrderingComposer({
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

  ColumnOrderings<int> get anioCursada => $composableBuilder(
    column: $table.anioCursada,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get curso => $composableBuilder(
    column: $table.curso,
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

  $$TablaCarrerasTableOrderingComposer get carreraId {
    final $$TablaCarrerasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.carreraId,
      referencedTable: $db.tablaCarreras,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaCarrerasTableOrderingComposer(
            $db: $db,
            $table: $db.tablaCarreras,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TablaMateriasTableAnnotationComposer
    extends Composer<_$BaseDeDatos, $TablaMateriasTable> {
  $$TablaMateriasTableAnnotationComposer({
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

  GeneratedColumn<int> get anioCursada => $composableBuilder(
    column: $table.anioCursada,
    builder: (column) => column,
  );

  GeneratedColumn<String> get curso =>
      $composableBuilder(column: $table.curso, builder: (column) => column);

  GeneratedColumn<bool> get activo =>
      $composableBuilder(column: $table.activo, builder: (column) => column);

  GeneratedColumn<DateTime> get creadoEn =>
      $composableBuilder(column: $table.creadoEn, builder: (column) => column);

  $$TablaCarrerasTableAnnotationComposer get carreraId {
    final $$TablaCarrerasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.carreraId,
      referencedTable: $db.tablaCarreras,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaCarrerasTableAnnotationComposer(
            $db: $db,
            $table: $db.tablaCarreras,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> tablaCursosRefs<T extends Object>(
    Expression<T> Function($$TablaCursosTableAnnotationComposer a) f,
  ) {
    final $$TablaCursosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tablaCursos,
      getReferencedColumn: (t) => t.materiaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaCursosTableAnnotationComposer(
            $db: $db,
            $table: $db.tablaCursos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TablaMateriasTableTableManager
    extends
        RootTableManager<
          _$BaseDeDatos,
          $TablaMateriasTable,
          TablaMateria,
          $$TablaMateriasTableFilterComposer,
          $$TablaMateriasTableOrderingComposer,
          $$TablaMateriasTableAnnotationComposer,
          $$TablaMateriasTableCreateCompanionBuilder,
          $$TablaMateriasTableUpdateCompanionBuilder,
          (TablaMateria, $$TablaMateriasTableReferences),
          TablaMateria,
          PrefetchHooks Function({bool carreraId, bool tablaCursosRefs})
        > {
  $$TablaMateriasTableTableManager(_$BaseDeDatos db, $TablaMateriasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TablaMateriasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TablaMateriasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TablaMateriasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> carreraId = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<int> anioCursada = const Value.absent(),
                Value<String> curso = const Value.absent(),
                Value<bool> activo = const Value.absent(),
                Value<DateTime> creadoEn = const Value.absent(),
              }) => TablaMateriasCompanion(
                id: id,
                carreraId: carreraId,
                nombre: nombre,
                anioCursada: anioCursada,
                curso: curso,
                activo: activo,
                creadoEn: creadoEn,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int carreraId,
                required String nombre,
                required int anioCursada,
                required String curso,
                Value<bool> activo = const Value.absent(),
                Value<DateTime> creadoEn = const Value.absent(),
              }) => TablaMateriasCompanion.insert(
                id: id,
                carreraId: carreraId,
                nombre: nombre,
                anioCursada: anioCursada,
                curso: curso,
                activo: activo,
                creadoEn: creadoEn,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TablaMateriasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({carreraId = false, tablaCursosRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (tablaCursosRefs) db.tablaCursos,
                  ],
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
                        if (carreraId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.carreraId,
                                    referencedTable:
                                        $$TablaMateriasTableReferences
                                            ._carreraIdTable(db),
                                    referencedColumn:
                                        $$TablaMateriasTableReferences
                                            ._carreraIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (tablaCursosRefs)
                        await $_getPrefetchedData<
                          TablaMateria,
                          $TablaMateriasTable,
                          TablaCurso
                        >(
                          currentTable: table,
                          referencedTable: $$TablaMateriasTableReferences
                              ._tablaCursosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TablaMateriasTableReferences(
                                db,
                                table,
                                p0,
                              ).tablaCursosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.materiaId == item.id,
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

typedef $$TablaMateriasTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDeDatos,
      $TablaMateriasTable,
      TablaMateria,
      $$TablaMateriasTableFilterComposer,
      $$TablaMateriasTableOrderingComposer,
      $$TablaMateriasTableAnnotationComposer,
      $$TablaMateriasTableCreateCompanionBuilder,
      $$TablaMateriasTableUpdateCompanionBuilder,
      (TablaMateria, $$TablaMateriasTableReferences),
      TablaMateria,
      PrefetchHooks Function({bool carreraId, bool tablaCursosRefs})
    >;
typedef $$TablaCursosTableCreateCompanionBuilder =
    TablaCursosCompanion Function({
      Value<int> id,
      required String nombre,
      Value<String?> division,
      Value<String?> materia,
      Value<String?> turno,
      Value<int?> anio,
      Value<int?> institucionId,
      Value<int?> carreraId,
      Value<int?> materiaId,
      Value<bool> activo,
      Value<DateTime> creadoEn,
    });
typedef $$TablaCursosTableUpdateCompanionBuilder =
    TablaCursosCompanion Function({
      Value<int> id,
      Value<String> nombre,
      Value<String?> division,
      Value<String?> materia,
      Value<String?> turno,
      Value<int?> anio,
      Value<int?> institucionId,
      Value<int?> carreraId,
      Value<int?> materiaId,
      Value<bool> activo,
      Value<DateTime> creadoEn,
    });

final class $$TablaCursosTableReferences
    extends BaseReferences<_$BaseDeDatos, $TablaCursosTable, TablaCurso> {
  $$TablaCursosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TablaInstitucionesTable _institucionIdTable(_$BaseDeDatos db) =>
      db.tablaInstituciones.createAlias(
        $_aliasNameGenerator(
          db.tablaCursos.institucionId,
          db.tablaInstituciones.id,
        ),
      );

  $$TablaInstitucionesTableProcessedTableManager? get institucionId {
    final $_column = $_itemColumn<int>('institucion_id');
    if ($_column == null) return null;
    final manager = $$TablaInstitucionesTableTableManager(
      $_db,
      $_db.tablaInstituciones,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_institucionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TablaCarrerasTable _carreraIdTable(_$BaseDeDatos db) =>
      db.tablaCarreras.createAlias(
        $_aliasNameGenerator(db.tablaCursos.carreraId, db.tablaCarreras.id),
      );

  $$TablaCarrerasTableProcessedTableManager? get carreraId {
    final $_column = $_itemColumn<int>('carrera_id');
    if ($_column == null) return null;
    final manager = $$TablaCarrerasTableTableManager(
      $_db,
      $_db.tablaCarreras,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_carreraIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TablaMateriasTable _materiaIdTable(_$BaseDeDatos db) =>
      db.tablaMaterias.createAlias(
        $_aliasNameGenerator(db.tablaCursos.materiaId, db.tablaMaterias.id),
      );

  $$TablaMateriasTableProcessedTableManager? get materiaId {
    final $_column = $_itemColumn<int>('materia_id');
    if ($_column == null) return null;
    final manager = $$TablaMateriasTableTableManager(
      $_db,
      $_db.tablaMaterias,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_materiaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TablaInscripcionesTable, List<TablaInscripcione>>
  _tablaInscripcionesRefsTable(_$BaseDeDatos db) =>
      MultiTypedResultKey.fromTable(
        db.tablaInscripciones,
        aliasName: $_aliasNameGenerator(
          db.tablaCursos.id,
          db.tablaInscripciones.cursoId,
        ),
      );

  $$TablaInscripcionesTableProcessedTableManager get tablaInscripcionesRefs {
    final manager = $$TablaInscripcionesTableTableManager(
      $_db,
      $_db.tablaInscripciones,
    ).filter((f) => f.cursoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _tablaInscripcionesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TablaClasesTable, List<TablaClase>>
  _tablaClasesRefsTable(_$BaseDeDatos db) => MultiTypedResultKey.fromTable(
    db.tablaClases,
    aliasName: $_aliasNameGenerator(db.tablaCursos.id, db.tablaClases.cursoId),
  );

  $$TablaClasesTableProcessedTableManager get tablaClasesRefs {
    final manager = $$TablaClasesTableTableManager(
      $_db,
      $_db.tablaClases,
    ).filter((f) => f.cursoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_tablaClasesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TablaCursosTableFilterComposer
    extends Composer<_$BaseDeDatos, $TablaCursosTable> {
  $$TablaCursosTableFilterComposer({
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

  ColumnFilters<String> get division => $composableBuilder(
    column: $table.division,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get materia => $composableBuilder(
    column: $table.materia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get turno => $composableBuilder(
    column: $table.turno,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get anio => $composableBuilder(
    column: $table.anio,
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

  $$TablaInstitucionesTableFilterComposer get institucionId {
    final $$TablaInstitucionesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.institucionId,
      referencedTable: $db.tablaInstituciones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaInstitucionesTableFilterComposer(
            $db: $db,
            $table: $db.tablaInstituciones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TablaCarrerasTableFilterComposer get carreraId {
    final $$TablaCarrerasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.carreraId,
      referencedTable: $db.tablaCarreras,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaCarrerasTableFilterComposer(
            $db: $db,
            $table: $db.tablaCarreras,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TablaMateriasTableFilterComposer get materiaId {
    final $$TablaMateriasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.materiaId,
      referencedTable: $db.tablaMaterias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaMateriasTableFilterComposer(
            $db: $db,
            $table: $db.tablaMaterias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> tablaInscripcionesRefs(
    Expression<bool> Function($$TablaInscripcionesTableFilterComposer f) f,
  ) {
    final $$TablaInscripcionesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tablaInscripciones,
      getReferencedColumn: (t) => t.cursoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaInscripcionesTableFilterComposer(
            $db: $db,
            $table: $db.tablaInscripciones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> tablaClasesRefs(
    Expression<bool> Function($$TablaClasesTableFilterComposer f) f,
  ) {
    final $$TablaClasesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tablaClases,
      getReferencedColumn: (t) => t.cursoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaClasesTableFilterComposer(
            $db: $db,
            $table: $db.tablaClases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TablaCursosTableOrderingComposer
    extends Composer<_$BaseDeDatos, $TablaCursosTable> {
  $$TablaCursosTableOrderingComposer({
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

  ColumnOrderings<String> get division => $composableBuilder(
    column: $table.division,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get materia => $composableBuilder(
    column: $table.materia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get turno => $composableBuilder(
    column: $table.turno,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get anio => $composableBuilder(
    column: $table.anio,
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

  $$TablaInstitucionesTableOrderingComposer get institucionId {
    final $$TablaInstitucionesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.institucionId,
      referencedTable: $db.tablaInstituciones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaInstitucionesTableOrderingComposer(
            $db: $db,
            $table: $db.tablaInstituciones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TablaCarrerasTableOrderingComposer get carreraId {
    final $$TablaCarrerasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.carreraId,
      referencedTable: $db.tablaCarreras,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaCarrerasTableOrderingComposer(
            $db: $db,
            $table: $db.tablaCarreras,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TablaMateriasTableOrderingComposer get materiaId {
    final $$TablaMateriasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.materiaId,
      referencedTable: $db.tablaMaterias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaMateriasTableOrderingComposer(
            $db: $db,
            $table: $db.tablaMaterias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TablaCursosTableAnnotationComposer
    extends Composer<_$BaseDeDatos, $TablaCursosTable> {
  $$TablaCursosTableAnnotationComposer({
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

  GeneratedColumn<String> get division =>
      $composableBuilder(column: $table.division, builder: (column) => column);

  GeneratedColumn<String> get materia =>
      $composableBuilder(column: $table.materia, builder: (column) => column);

  GeneratedColumn<String> get turno =>
      $composableBuilder(column: $table.turno, builder: (column) => column);

  GeneratedColumn<int> get anio =>
      $composableBuilder(column: $table.anio, builder: (column) => column);

  GeneratedColumn<bool> get activo =>
      $composableBuilder(column: $table.activo, builder: (column) => column);

  GeneratedColumn<DateTime> get creadoEn =>
      $composableBuilder(column: $table.creadoEn, builder: (column) => column);

  $$TablaInstitucionesTableAnnotationComposer get institucionId {
    final $$TablaInstitucionesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.institucionId,
          referencedTable: $db.tablaInstituciones,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TablaInstitucionesTableAnnotationComposer(
                $db: $db,
                $table: $db.tablaInstituciones,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$TablaCarrerasTableAnnotationComposer get carreraId {
    final $$TablaCarrerasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.carreraId,
      referencedTable: $db.tablaCarreras,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaCarrerasTableAnnotationComposer(
            $db: $db,
            $table: $db.tablaCarreras,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TablaMateriasTableAnnotationComposer get materiaId {
    final $$TablaMateriasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.materiaId,
      referencedTable: $db.tablaMaterias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaMateriasTableAnnotationComposer(
            $db: $db,
            $table: $db.tablaMaterias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> tablaInscripcionesRefs<T extends Object>(
    Expression<T> Function($$TablaInscripcionesTableAnnotationComposer a) f,
  ) {
    final $$TablaInscripcionesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.tablaInscripciones,
          getReferencedColumn: (t) => t.cursoId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TablaInscripcionesTableAnnotationComposer(
                $db: $db,
                $table: $db.tablaInscripciones,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> tablaClasesRefs<T extends Object>(
    Expression<T> Function($$TablaClasesTableAnnotationComposer a) f,
  ) {
    final $$TablaClasesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tablaClases,
      getReferencedColumn: (t) => t.cursoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaClasesTableAnnotationComposer(
            $db: $db,
            $table: $db.tablaClases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TablaCursosTableTableManager
    extends
        RootTableManager<
          _$BaseDeDatos,
          $TablaCursosTable,
          TablaCurso,
          $$TablaCursosTableFilterComposer,
          $$TablaCursosTableOrderingComposer,
          $$TablaCursosTableAnnotationComposer,
          $$TablaCursosTableCreateCompanionBuilder,
          $$TablaCursosTableUpdateCompanionBuilder,
          (TablaCurso, $$TablaCursosTableReferences),
          TablaCurso,
          PrefetchHooks Function({
            bool institucionId,
            bool carreraId,
            bool materiaId,
            bool tablaInscripcionesRefs,
            bool tablaClasesRefs,
          })
        > {
  $$TablaCursosTableTableManager(_$BaseDeDatos db, $TablaCursosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TablaCursosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TablaCursosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TablaCursosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<String?> division = const Value.absent(),
                Value<String?> materia = const Value.absent(),
                Value<String?> turno = const Value.absent(),
                Value<int?> anio = const Value.absent(),
                Value<int?> institucionId = const Value.absent(),
                Value<int?> carreraId = const Value.absent(),
                Value<int?> materiaId = const Value.absent(),
                Value<bool> activo = const Value.absent(),
                Value<DateTime> creadoEn = const Value.absent(),
              }) => TablaCursosCompanion(
                id: id,
                nombre: nombre,
                division: division,
                materia: materia,
                turno: turno,
                anio: anio,
                institucionId: institucionId,
                carreraId: carreraId,
                materiaId: materiaId,
                activo: activo,
                creadoEn: creadoEn,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nombre,
                Value<String?> division = const Value.absent(),
                Value<String?> materia = const Value.absent(),
                Value<String?> turno = const Value.absent(),
                Value<int?> anio = const Value.absent(),
                Value<int?> institucionId = const Value.absent(),
                Value<int?> carreraId = const Value.absent(),
                Value<int?> materiaId = const Value.absent(),
                Value<bool> activo = const Value.absent(),
                Value<DateTime> creadoEn = const Value.absent(),
              }) => TablaCursosCompanion.insert(
                id: id,
                nombre: nombre,
                division: division,
                materia: materia,
                turno: turno,
                anio: anio,
                institucionId: institucionId,
                carreraId: carreraId,
                materiaId: materiaId,
                activo: activo,
                creadoEn: creadoEn,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TablaCursosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                institucionId = false,
                carreraId = false,
                materiaId = false,
                tablaInscripcionesRefs = false,
                tablaClasesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (tablaInscripcionesRefs) db.tablaInscripciones,
                    if (tablaClasesRefs) db.tablaClases,
                  ],
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
                        if (institucionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.institucionId,
                                    referencedTable:
                                        $$TablaCursosTableReferences
                                            ._institucionIdTable(db),
                                    referencedColumn:
                                        $$TablaCursosTableReferences
                                            ._institucionIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (carreraId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.carreraId,
                                    referencedTable:
                                        $$TablaCursosTableReferences
                                            ._carreraIdTable(db),
                                    referencedColumn:
                                        $$TablaCursosTableReferences
                                            ._carreraIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (materiaId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.materiaId,
                                    referencedTable:
                                        $$TablaCursosTableReferences
                                            ._materiaIdTable(db),
                                    referencedColumn:
                                        $$TablaCursosTableReferences
                                            ._materiaIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (tablaInscripcionesRefs)
                        await $_getPrefetchedData<
                          TablaCurso,
                          $TablaCursosTable,
                          TablaInscripcione
                        >(
                          currentTable: table,
                          referencedTable: $$TablaCursosTableReferences
                              ._tablaInscripcionesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TablaCursosTableReferences(
                                db,
                                table,
                                p0,
                              ).tablaInscripcionesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.cursoId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (tablaClasesRefs)
                        await $_getPrefetchedData<
                          TablaCurso,
                          $TablaCursosTable,
                          TablaClase
                        >(
                          currentTable: table,
                          referencedTable: $$TablaCursosTableReferences
                              ._tablaClasesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TablaCursosTableReferences(
                                db,
                                table,
                                p0,
                              ).tablaClasesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.cursoId == item.id,
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

typedef $$TablaCursosTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDeDatos,
      $TablaCursosTable,
      TablaCurso,
      $$TablaCursosTableFilterComposer,
      $$TablaCursosTableOrderingComposer,
      $$TablaCursosTableAnnotationComposer,
      $$TablaCursosTableCreateCompanionBuilder,
      $$TablaCursosTableUpdateCompanionBuilder,
      (TablaCurso, $$TablaCursosTableReferences),
      TablaCurso,
      PrefetchHooks Function({
        bool institucionId,
        bool carreraId,
        bool materiaId,
        bool tablaInscripcionesRefs,
        bool tablaClasesRefs,
      })
    >;
typedef $$TablaInscripcionesTableCreateCompanionBuilder =
    TablaInscripcionesCompanion Function({
      Value<int> id,
      required int alumnoId,
      required int cursoId,
      Value<DateTime> fechaAlta,
      Value<bool> activo,
    });
typedef $$TablaInscripcionesTableUpdateCompanionBuilder =
    TablaInscripcionesCompanion Function({
      Value<int> id,
      Value<int> alumnoId,
      Value<int> cursoId,
      Value<DateTime> fechaAlta,
      Value<bool> activo,
    });

final class $$TablaInscripcionesTableReferences
    extends
        BaseReferences<
          _$BaseDeDatos,
          $TablaInscripcionesTable,
          TablaInscripcione
        > {
  $$TablaInscripcionesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TablaAlumnosTable _alumnoIdTable(_$BaseDeDatos db) =>
      db.tablaAlumnos.createAlias(
        $_aliasNameGenerator(
          db.tablaInscripciones.alumnoId,
          db.tablaAlumnos.id,
        ),
      );

  $$TablaAlumnosTableProcessedTableManager get alumnoId {
    final $_column = $_itemColumn<int>('alumno_id')!;

    final manager = $$TablaAlumnosTableTableManager(
      $_db,
      $_db.tablaAlumnos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_alumnoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TablaCursosTable _cursoIdTable(_$BaseDeDatos db) =>
      db.tablaCursos.createAlias(
        $_aliasNameGenerator(db.tablaInscripciones.cursoId, db.tablaCursos.id),
      );

  $$TablaCursosTableProcessedTableManager get cursoId {
    final $_column = $_itemColumn<int>('curso_id')!;

    final manager = $$TablaCursosTableTableManager(
      $_db,
      $_db.tablaCursos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cursoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TablaInscripcionesTableFilterComposer
    extends Composer<_$BaseDeDatos, $TablaInscripcionesTable> {
  $$TablaInscripcionesTableFilterComposer({
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

  ColumnFilters<DateTime> get fechaAlta => $composableBuilder(
    column: $table.fechaAlta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get activo => $composableBuilder(
    column: $table.activo,
    builder: (column) => ColumnFilters(column),
  );

  $$TablaAlumnosTableFilterComposer get alumnoId {
    final $$TablaAlumnosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.alumnoId,
      referencedTable: $db.tablaAlumnos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaAlumnosTableFilterComposer(
            $db: $db,
            $table: $db.tablaAlumnos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TablaCursosTableFilterComposer get cursoId {
    final $$TablaCursosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cursoId,
      referencedTable: $db.tablaCursos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaCursosTableFilterComposer(
            $db: $db,
            $table: $db.tablaCursos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TablaInscripcionesTableOrderingComposer
    extends Composer<_$BaseDeDatos, $TablaInscripcionesTable> {
  $$TablaInscripcionesTableOrderingComposer({
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

  ColumnOrderings<DateTime> get fechaAlta => $composableBuilder(
    column: $table.fechaAlta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get activo => $composableBuilder(
    column: $table.activo,
    builder: (column) => ColumnOrderings(column),
  );

  $$TablaAlumnosTableOrderingComposer get alumnoId {
    final $$TablaAlumnosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.alumnoId,
      referencedTable: $db.tablaAlumnos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaAlumnosTableOrderingComposer(
            $db: $db,
            $table: $db.tablaAlumnos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TablaCursosTableOrderingComposer get cursoId {
    final $$TablaCursosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cursoId,
      referencedTable: $db.tablaCursos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaCursosTableOrderingComposer(
            $db: $db,
            $table: $db.tablaCursos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TablaInscripcionesTableAnnotationComposer
    extends Composer<_$BaseDeDatos, $TablaInscripcionesTable> {
  $$TablaInscripcionesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaAlta =>
      $composableBuilder(column: $table.fechaAlta, builder: (column) => column);

  GeneratedColumn<bool> get activo =>
      $composableBuilder(column: $table.activo, builder: (column) => column);

  $$TablaAlumnosTableAnnotationComposer get alumnoId {
    final $$TablaAlumnosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.alumnoId,
      referencedTable: $db.tablaAlumnos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaAlumnosTableAnnotationComposer(
            $db: $db,
            $table: $db.tablaAlumnos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TablaCursosTableAnnotationComposer get cursoId {
    final $$TablaCursosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cursoId,
      referencedTable: $db.tablaCursos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaCursosTableAnnotationComposer(
            $db: $db,
            $table: $db.tablaCursos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TablaInscripcionesTableTableManager
    extends
        RootTableManager<
          _$BaseDeDatos,
          $TablaInscripcionesTable,
          TablaInscripcione,
          $$TablaInscripcionesTableFilterComposer,
          $$TablaInscripcionesTableOrderingComposer,
          $$TablaInscripcionesTableAnnotationComposer,
          $$TablaInscripcionesTableCreateCompanionBuilder,
          $$TablaInscripcionesTableUpdateCompanionBuilder,
          (TablaInscripcione, $$TablaInscripcionesTableReferences),
          TablaInscripcione,
          PrefetchHooks Function({bool alumnoId, bool cursoId})
        > {
  $$TablaInscripcionesTableTableManager(
    _$BaseDeDatos db,
    $TablaInscripcionesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TablaInscripcionesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TablaInscripcionesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TablaInscripcionesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> alumnoId = const Value.absent(),
                Value<int> cursoId = const Value.absent(),
                Value<DateTime> fechaAlta = const Value.absent(),
                Value<bool> activo = const Value.absent(),
              }) => TablaInscripcionesCompanion(
                id: id,
                alumnoId: alumnoId,
                cursoId: cursoId,
                fechaAlta: fechaAlta,
                activo: activo,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int alumnoId,
                required int cursoId,
                Value<DateTime> fechaAlta = const Value.absent(),
                Value<bool> activo = const Value.absent(),
              }) => TablaInscripcionesCompanion.insert(
                id: id,
                alumnoId: alumnoId,
                cursoId: cursoId,
                fechaAlta: fechaAlta,
                activo: activo,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TablaInscripcionesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({alumnoId = false, cursoId = false}) {
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
                    if (alumnoId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.alumnoId,
                                referencedTable:
                                    $$TablaInscripcionesTableReferences
                                        ._alumnoIdTable(db),
                                referencedColumn:
                                    $$TablaInscripcionesTableReferences
                                        ._alumnoIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (cursoId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.cursoId,
                                referencedTable:
                                    $$TablaInscripcionesTableReferences
                                        ._cursoIdTable(db),
                                referencedColumn:
                                    $$TablaInscripcionesTableReferences
                                        ._cursoIdTable(db)
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

typedef $$TablaInscripcionesTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDeDatos,
      $TablaInscripcionesTable,
      TablaInscripcione,
      $$TablaInscripcionesTableFilterComposer,
      $$TablaInscripcionesTableOrderingComposer,
      $$TablaInscripcionesTableAnnotationComposer,
      $$TablaInscripcionesTableCreateCompanionBuilder,
      $$TablaInscripcionesTableUpdateCompanionBuilder,
      (TablaInscripcione, $$TablaInscripcionesTableReferences),
      TablaInscripcione,
      PrefetchHooks Function({bool alumnoId, bool cursoId})
    >;
typedef $$TablaClasesTableCreateCompanionBuilder =
    TablaClasesCompanion Function({
      Value<int> id,
      required int cursoId,
      Value<DateTime> fecha,
      Value<String?> tema,
      Value<String?> observacion,
      Value<String?> actividadDia,
    });
typedef $$TablaClasesTableUpdateCompanionBuilder =
    TablaClasesCompanion Function({
      Value<int> id,
      Value<int> cursoId,
      Value<DateTime> fecha,
      Value<String?> tema,
      Value<String?> observacion,
      Value<String?> actividadDia,
    });

final class $$TablaClasesTableReferences
    extends BaseReferences<_$BaseDeDatos, $TablaClasesTable, TablaClase> {
  $$TablaClasesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TablaCursosTable _cursoIdTable(_$BaseDeDatos db) =>
      db.tablaCursos.createAlias(
        $_aliasNameGenerator(db.tablaClases.cursoId, db.tablaCursos.id),
      );

  $$TablaCursosTableProcessedTableManager get cursoId {
    final $_column = $_itemColumn<int>('curso_id')!;

    final manager = $$TablaCursosTableTableManager(
      $_db,
      $_db.tablaCursos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cursoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TablaAsistenciasTable, List<TablaAsistencia>>
  _tablaAsistenciasRefsTable(_$BaseDeDatos db) => MultiTypedResultKey.fromTable(
    db.tablaAsistencias,
    aliasName: $_aliasNameGenerator(
      db.tablaClases.id,
      db.tablaAsistencias.claseId,
    ),
  );

  $$TablaAsistenciasTableProcessedTableManager get tablaAsistenciasRefs {
    final manager = $$TablaAsistenciasTableTableManager(
      $_db,
      $_db.tablaAsistencias,
    ).filter((f) => f.claseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _tablaAsistenciasRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TablaClasesTableFilterComposer
    extends Composer<_$BaseDeDatos, $TablaClasesTable> {
  $$TablaClasesTableFilterComposer({
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

  ColumnFilters<String> get tema => $composableBuilder(
    column: $table.tema,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observacion => $composableBuilder(
    column: $table.observacion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actividadDia => $composableBuilder(
    column: $table.actividadDia,
    builder: (column) => ColumnFilters(column),
  );

  $$TablaCursosTableFilterComposer get cursoId {
    final $$TablaCursosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cursoId,
      referencedTable: $db.tablaCursos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaCursosTableFilterComposer(
            $db: $db,
            $table: $db.tablaCursos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> tablaAsistenciasRefs(
    Expression<bool> Function($$TablaAsistenciasTableFilterComposer f) f,
  ) {
    final $$TablaAsistenciasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tablaAsistencias,
      getReferencedColumn: (t) => t.claseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaAsistenciasTableFilterComposer(
            $db: $db,
            $table: $db.tablaAsistencias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TablaClasesTableOrderingComposer
    extends Composer<_$BaseDeDatos, $TablaClasesTable> {
  $$TablaClasesTableOrderingComposer({
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

  ColumnOrderings<String> get tema => $composableBuilder(
    column: $table.tema,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observacion => $composableBuilder(
    column: $table.observacion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actividadDia => $composableBuilder(
    column: $table.actividadDia,
    builder: (column) => ColumnOrderings(column),
  );

  $$TablaCursosTableOrderingComposer get cursoId {
    final $$TablaCursosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cursoId,
      referencedTable: $db.tablaCursos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaCursosTableOrderingComposer(
            $db: $db,
            $table: $db.tablaCursos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TablaClasesTableAnnotationComposer
    extends Composer<_$BaseDeDatos, $TablaClasesTable> {
  $$TablaClasesTableAnnotationComposer({
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

  GeneratedColumn<String> get tema =>
      $composableBuilder(column: $table.tema, builder: (column) => column);

  GeneratedColumn<String> get observacion => $composableBuilder(
    column: $table.observacion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get actividadDia => $composableBuilder(
    column: $table.actividadDia,
    builder: (column) => column,
  );

  $$TablaCursosTableAnnotationComposer get cursoId {
    final $$TablaCursosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cursoId,
      referencedTable: $db.tablaCursos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaCursosTableAnnotationComposer(
            $db: $db,
            $table: $db.tablaCursos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> tablaAsistenciasRefs<T extends Object>(
    Expression<T> Function($$TablaAsistenciasTableAnnotationComposer a) f,
  ) {
    final $$TablaAsistenciasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tablaAsistencias,
      getReferencedColumn: (t) => t.claseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaAsistenciasTableAnnotationComposer(
            $db: $db,
            $table: $db.tablaAsistencias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TablaClasesTableTableManager
    extends
        RootTableManager<
          _$BaseDeDatos,
          $TablaClasesTable,
          TablaClase,
          $$TablaClasesTableFilterComposer,
          $$TablaClasesTableOrderingComposer,
          $$TablaClasesTableAnnotationComposer,
          $$TablaClasesTableCreateCompanionBuilder,
          $$TablaClasesTableUpdateCompanionBuilder,
          (TablaClase, $$TablaClasesTableReferences),
          TablaClase,
          PrefetchHooks Function({bool cursoId, bool tablaAsistenciasRefs})
        > {
  $$TablaClasesTableTableManager(_$BaseDeDatos db, $TablaClasesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TablaClasesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TablaClasesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TablaClasesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> cursoId = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
                Value<String?> tema = const Value.absent(),
                Value<String?> observacion = const Value.absent(),
                Value<String?> actividadDia = const Value.absent(),
              }) => TablaClasesCompanion(
                id: id,
                cursoId: cursoId,
                fecha: fecha,
                tema: tema,
                observacion: observacion,
                actividadDia: actividadDia,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int cursoId,
                Value<DateTime> fecha = const Value.absent(),
                Value<String?> tema = const Value.absent(),
                Value<String?> observacion = const Value.absent(),
                Value<String?> actividadDia = const Value.absent(),
              }) => TablaClasesCompanion.insert(
                id: id,
                cursoId: cursoId,
                fecha: fecha,
                tema: tema,
                observacion: observacion,
                actividadDia: actividadDia,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TablaClasesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({cursoId = false, tablaAsistenciasRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (tablaAsistenciasRefs) db.tablaAsistencias,
                  ],
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
                        if (cursoId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.cursoId,
                                    referencedTable:
                                        $$TablaClasesTableReferences
                                            ._cursoIdTable(db),
                                    referencedColumn:
                                        $$TablaClasesTableReferences
                                            ._cursoIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (tablaAsistenciasRefs)
                        await $_getPrefetchedData<
                          TablaClase,
                          $TablaClasesTable,
                          TablaAsistencia
                        >(
                          currentTable: table,
                          referencedTable: $$TablaClasesTableReferences
                              ._tablaAsistenciasRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TablaClasesTableReferences(
                                db,
                                table,
                                p0,
                              ).tablaAsistenciasRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.claseId == item.id,
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

typedef $$TablaClasesTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDeDatos,
      $TablaClasesTable,
      TablaClase,
      $$TablaClasesTableFilterComposer,
      $$TablaClasesTableOrderingComposer,
      $$TablaClasesTableAnnotationComposer,
      $$TablaClasesTableCreateCompanionBuilder,
      $$TablaClasesTableUpdateCompanionBuilder,
      (TablaClase, $$TablaClasesTableReferences),
      TablaClase,
      PrefetchHooks Function({bool cursoId, bool tablaAsistenciasRefs})
    >;
typedef $$TablaAsistenciasTableCreateCompanionBuilder =
    TablaAsistenciasCompanion Function({
      Value<int> id,
      required int claseId,
      required int alumnoId,
      Value<String> estado,
      Value<String?> observacion,
      Value<bool> justificada,
      Value<String?> detalleJustificacion,
      Value<bool> actividadEntregada,
      Value<String?> notaActividad,
      Value<String?> detalleActividad,
      Value<DateTime> registradoEn,
    });
typedef $$TablaAsistenciasTableUpdateCompanionBuilder =
    TablaAsistenciasCompanion Function({
      Value<int> id,
      Value<int> claseId,
      Value<int> alumnoId,
      Value<String> estado,
      Value<String?> observacion,
      Value<bool> justificada,
      Value<String?> detalleJustificacion,
      Value<bool> actividadEntregada,
      Value<String?> notaActividad,
      Value<String?> detalleActividad,
      Value<DateTime> registradoEn,
    });

final class $$TablaAsistenciasTableReferences
    extends
        BaseReferences<_$BaseDeDatos, $TablaAsistenciasTable, TablaAsistencia> {
  $$TablaAsistenciasTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TablaClasesTable _claseIdTable(_$BaseDeDatos db) =>
      db.tablaClases.createAlias(
        $_aliasNameGenerator(db.tablaAsistencias.claseId, db.tablaClases.id),
      );

  $$TablaClasesTableProcessedTableManager get claseId {
    final $_column = $_itemColumn<int>('clase_id')!;

    final manager = $$TablaClasesTableTableManager(
      $_db,
      $_db.tablaClases,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_claseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TablaAlumnosTable _alumnoIdTable(_$BaseDeDatos db) =>
      db.tablaAlumnos.createAlias(
        $_aliasNameGenerator(db.tablaAsistencias.alumnoId, db.tablaAlumnos.id),
      );

  $$TablaAlumnosTableProcessedTableManager get alumnoId {
    final $_column = $_itemColumn<int>('alumno_id')!;

    final manager = $$TablaAlumnosTableTableManager(
      $_db,
      $_db.tablaAlumnos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_alumnoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TablaAsistenciasTableFilterComposer
    extends Composer<_$BaseDeDatos, $TablaAsistenciasTable> {
  $$TablaAsistenciasTableFilterComposer({
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

  ColumnFilters<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observacion => $composableBuilder(
    column: $table.observacion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get justificada => $composableBuilder(
    column: $table.justificada,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detalleJustificacion => $composableBuilder(
    column: $table.detalleJustificacion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get actividadEntregada => $composableBuilder(
    column: $table.actividadEntregada,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notaActividad => $composableBuilder(
    column: $table.notaActividad,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detalleActividad => $composableBuilder(
    column: $table.detalleActividad,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get registradoEn => $composableBuilder(
    column: $table.registradoEn,
    builder: (column) => ColumnFilters(column),
  );

  $$TablaClasesTableFilterComposer get claseId {
    final $$TablaClasesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.claseId,
      referencedTable: $db.tablaClases,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaClasesTableFilterComposer(
            $db: $db,
            $table: $db.tablaClases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TablaAlumnosTableFilterComposer get alumnoId {
    final $$TablaAlumnosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.alumnoId,
      referencedTable: $db.tablaAlumnos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaAlumnosTableFilterComposer(
            $db: $db,
            $table: $db.tablaAlumnos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TablaAsistenciasTableOrderingComposer
    extends Composer<_$BaseDeDatos, $TablaAsistenciasTable> {
  $$TablaAsistenciasTableOrderingComposer({
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

  ColumnOrderings<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observacion => $composableBuilder(
    column: $table.observacion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get justificada => $composableBuilder(
    column: $table.justificada,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detalleJustificacion => $composableBuilder(
    column: $table.detalleJustificacion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get actividadEntregada => $composableBuilder(
    column: $table.actividadEntregada,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notaActividad => $composableBuilder(
    column: $table.notaActividad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detalleActividad => $composableBuilder(
    column: $table.detalleActividad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get registradoEn => $composableBuilder(
    column: $table.registradoEn,
    builder: (column) => ColumnOrderings(column),
  );

  $$TablaClasesTableOrderingComposer get claseId {
    final $$TablaClasesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.claseId,
      referencedTable: $db.tablaClases,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaClasesTableOrderingComposer(
            $db: $db,
            $table: $db.tablaClases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TablaAlumnosTableOrderingComposer get alumnoId {
    final $$TablaAlumnosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.alumnoId,
      referencedTable: $db.tablaAlumnos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaAlumnosTableOrderingComposer(
            $db: $db,
            $table: $db.tablaAlumnos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TablaAsistenciasTableAnnotationComposer
    extends Composer<_$BaseDeDatos, $TablaAsistenciasTable> {
  $$TablaAsistenciasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);

  GeneratedColumn<String> get observacion => $composableBuilder(
    column: $table.observacion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get justificada => $composableBuilder(
    column: $table.justificada,
    builder: (column) => column,
  );

  GeneratedColumn<String> get detalleJustificacion => $composableBuilder(
    column: $table.detalleJustificacion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get actividadEntregada => $composableBuilder(
    column: $table.actividadEntregada,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notaActividad => $composableBuilder(
    column: $table.notaActividad,
    builder: (column) => column,
  );

  GeneratedColumn<String> get detalleActividad => $composableBuilder(
    column: $table.detalleActividad,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get registradoEn => $composableBuilder(
    column: $table.registradoEn,
    builder: (column) => column,
  );

  $$TablaClasesTableAnnotationComposer get claseId {
    final $$TablaClasesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.claseId,
      referencedTable: $db.tablaClases,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaClasesTableAnnotationComposer(
            $db: $db,
            $table: $db.tablaClases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TablaAlumnosTableAnnotationComposer get alumnoId {
    final $$TablaAlumnosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.alumnoId,
      referencedTable: $db.tablaAlumnos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaAlumnosTableAnnotationComposer(
            $db: $db,
            $table: $db.tablaAlumnos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TablaAsistenciasTableTableManager
    extends
        RootTableManager<
          _$BaseDeDatos,
          $TablaAsistenciasTable,
          TablaAsistencia,
          $$TablaAsistenciasTableFilterComposer,
          $$TablaAsistenciasTableOrderingComposer,
          $$TablaAsistenciasTableAnnotationComposer,
          $$TablaAsistenciasTableCreateCompanionBuilder,
          $$TablaAsistenciasTableUpdateCompanionBuilder,
          (TablaAsistencia, $$TablaAsistenciasTableReferences),
          TablaAsistencia,
          PrefetchHooks Function({bool claseId, bool alumnoId})
        > {
  $$TablaAsistenciasTableTableManager(
    _$BaseDeDatos db,
    $TablaAsistenciasTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TablaAsistenciasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TablaAsistenciasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TablaAsistenciasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> claseId = const Value.absent(),
                Value<int> alumnoId = const Value.absent(),
                Value<String> estado = const Value.absent(),
                Value<String?> observacion = const Value.absent(),
                Value<bool> justificada = const Value.absent(),
                Value<String?> detalleJustificacion = const Value.absent(),
                Value<bool> actividadEntregada = const Value.absent(),
                Value<String?> notaActividad = const Value.absent(),
                Value<String?> detalleActividad = const Value.absent(),
                Value<DateTime> registradoEn = const Value.absent(),
              }) => TablaAsistenciasCompanion(
                id: id,
                claseId: claseId,
                alumnoId: alumnoId,
                estado: estado,
                observacion: observacion,
                justificada: justificada,
                detalleJustificacion: detalleJustificacion,
                actividadEntregada: actividadEntregada,
                notaActividad: notaActividad,
                detalleActividad: detalleActividad,
                registradoEn: registradoEn,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int claseId,
                required int alumnoId,
                Value<String> estado = const Value.absent(),
                Value<String?> observacion = const Value.absent(),
                Value<bool> justificada = const Value.absent(),
                Value<String?> detalleJustificacion = const Value.absent(),
                Value<bool> actividadEntregada = const Value.absent(),
                Value<String?> notaActividad = const Value.absent(),
                Value<String?> detalleActividad = const Value.absent(),
                Value<DateTime> registradoEn = const Value.absent(),
              }) => TablaAsistenciasCompanion.insert(
                id: id,
                claseId: claseId,
                alumnoId: alumnoId,
                estado: estado,
                observacion: observacion,
                justificada: justificada,
                detalleJustificacion: detalleJustificacion,
                actividadEntregada: actividadEntregada,
                notaActividad: notaActividad,
                detalleActividad: detalleActividad,
                registradoEn: registradoEn,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TablaAsistenciasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({claseId = false, alumnoId = false}) {
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
                    if (claseId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.claseId,
                                referencedTable:
                                    $$TablaAsistenciasTableReferences
                                        ._claseIdTable(db),
                                referencedColumn:
                                    $$TablaAsistenciasTableReferences
                                        ._claseIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (alumnoId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.alumnoId,
                                referencedTable:
                                    $$TablaAsistenciasTableReferences
                                        ._alumnoIdTable(db),
                                referencedColumn:
                                    $$TablaAsistenciasTableReferences
                                        ._alumnoIdTable(db)
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

typedef $$TablaAsistenciasTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDeDatos,
      $TablaAsistenciasTable,
      TablaAsistencia,
      $$TablaAsistenciasTableFilterComposer,
      $$TablaAsistenciasTableOrderingComposer,
      $$TablaAsistenciasTableAnnotationComposer,
      $$TablaAsistenciasTableCreateCompanionBuilder,
      $$TablaAsistenciasTableUpdateCompanionBuilder,
      (TablaAsistencia, $$TablaAsistenciasTableReferences),
      TablaAsistencia,
      PrefetchHooks Function({bool claseId, bool alumnoId})
    >;
typedef $$TablaAlertasGestionHistorialTableCreateCompanionBuilder =
    TablaAlertasGestionHistorialCompanion Function({
      Value<int> id,
      required String clave,
      required String accion,
      Value<String?> estadoAnterior,
      required String estadoNuevo,
      Value<String?> derivadaA,
      Value<String?> comentario,
      Value<DateTime> creadoEn,
    });
typedef $$TablaAlertasGestionHistorialTableUpdateCompanionBuilder =
    TablaAlertasGestionHistorialCompanion Function({
      Value<int> id,
      Value<String> clave,
      Value<String> accion,
      Value<String?> estadoAnterior,
      Value<String> estadoNuevo,
      Value<String?> derivadaA,
      Value<String?> comentario,
      Value<DateTime> creadoEn,
    });

class $$TablaAlertasGestionHistorialTableFilterComposer
    extends Composer<_$BaseDeDatos, $TablaAlertasGestionHistorialTable> {
  $$TablaAlertasGestionHistorialTableFilterComposer({
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

  ColumnFilters<String> get clave => $composableBuilder(
    column: $table.clave,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accion => $composableBuilder(
    column: $table.accion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estadoAnterior => $composableBuilder(
    column: $table.estadoAnterior,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estadoNuevo => $composableBuilder(
    column: $table.estadoNuevo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get derivadaA => $composableBuilder(
    column: $table.derivadaA,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get comentario => $composableBuilder(
    column: $table.comentario,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TablaAlertasGestionHistorialTableOrderingComposer
    extends Composer<_$BaseDeDatos, $TablaAlertasGestionHistorialTable> {
  $$TablaAlertasGestionHistorialTableOrderingComposer({
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

  ColumnOrderings<String> get clave => $composableBuilder(
    column: $table.clave,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accion => $composableBuilder(
    column: $table.accion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estadoAnterior => $composableBuilder(
    column: $table.estadoAnterior,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estadoNuevo => $composableBuilder(
    column: $table.estadoNuevo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get derivadaA => $composableBuilder(
    column: $table.derivadaA,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get comentario => $composableBuilder(
    column: $table.comentario,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TablaAlertasGestionHistorialTableAnnotationComposer
    extends Composer<_$BaseDeDatos, $TablaAlertasGestionHistorialTable> {
  $$TablaAlertasGestionHistorialTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get clave =>
      $composableBuilder(column: $table.clave, builder: (column) => column);

  GeneratedColumn<String> get accion =>
      $composableBuilder(column: $table.accion, builder: (column) => column);

  GeneratedColumn<String> get estadoAnterior => $composableBuilder(
    column: $table.estadoAnterior,
    builder: (column) => column,
  );

  GeneratedColumn<String> get estadoNuevo => $composableBuilder(
    column: $table.estadoNuevo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get derivadaA =>
      $composableBuilder(column: $table.derivadaA, builder: (column) => column);

  GeneratedColumn<String> get comentario => $composableBuilder(
    column: $table.comentario,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get creadoEn =>
      $composableBuilder(column: $table.creadoEn, builder: (column) => column);
}

class $$TablaAlertasGestionHistorialTableTableManager
    extends
        RootTableManager<
          _$BaseDeDatos,
          $TablaAlertasGestionHistorialTable,
          TablaAlertasGestionHistorialData,
          $$TablaAlertasGestionHistorialTableFilterComposer,
          $$TablaAlertasGestionHistorialTableOrderingComposer,
          $$TablaAlertasGestionHistorialTableAnnotationComposer,
          $$TablaAlertasGestionHistorialTableCreateCompanionBuilder,
          $$TablaAlertasGestionHistorialTableUpdateCompanionBuilder,
          (
            TablaAlertasGestionHistorialData,
            BaseReferences<
              _$BaseDeDatos,
              $TablaAlertasGestionHistorialTable,
              TablaAlertasGestionHistorialData
            >,
          ),
          TablaAlertasGestionHistorialData,
          PrefetchHooks Function()
        > {
  $$TablaAlertasGestionHistorialTableTableManager(
    _$BaseDeDatos db,
    $TablaAlertasGestionHistorialTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TablaAlertasGestionHistorialTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$TablaAlertasGestionHistorialTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TablaAlertasGestionHistorialTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> clave = const Value.absent(),
                Value<String> accion = const Value.absent(),
                Value<String?> estadoAnterior = const Value.absent(),
                Value<String> estadoNuevo = const Value.absent(),
                Value<String?> derivadaA = const Value.absent(),
                Value<String?> comentario = const Value.absent(),
                Value<DateTime> creadoEn = const Value.absent(),
              }) => TablaAlertasGestionHistorialCompanion(
                id: id,
                clave: clave,
                accion: accion,
                estadoAnterior: estadoAnterior,
                estadoNuevo: estadoNuevo,
                derivadaA: derivadaA,
                comentario: comentario,
                creadoEn: creadoEn,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String clave,
                required String accion,
                Value<String?> estadoAnterior = const Value.absent(),
                required String estadoNuevo,
                Value<String?> derivadaA = const Value.absent(),
                Value<String?> comentario = const Value.absent(),
                Value<DateTime> creadoEn = const Value.absent(),
              }) => TablaAlertasGestionHistorialCompanion.insert(
                id: id,
                clave: clave,
                accion: accion,
                estadoAnterior: estadoAnterior,
                estadoNuevo: estadoNuevo,
                derivadaA: derivadaA,
                comentario: comentario,
                creadoEn: creadoEn,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TablaAlertasGestionHistorialTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDeDatos,
      $TablaAlertasGestionHistorialTable,
      TablaAlertasGestionHistorialData,
      $$TablaAlertasGestionHistorialTableFilterComposer,
      $$TablaAlertasGestionHistorialTableOrderingComposer,
      $$TablaAlertasGestionHistorialTableAnnotationComposer,
      $$TablaAlertasGestionHistorialTableCreateCompanionBuilder,
      $$TablaAlertasGestionHistorialTableUpdateCompanionBuilder,
      (
        TablaAlertasGestionHistorialData,
        BaseReferences<
          _$BaseDeDatos,
          $TablaAlertasGestionHistorialTable,
          TablaAlertasGestionHistorialData
        >,
      ),
      TablaAlertasGestionHistorialData,
      PrefetchHooks Function()
    >;
typedef $$TablaAlertasGestionEstadoTableCreateCompanionBuilder =
    TablaAlertasGestionEstadoCompanion Function({
      Value<int> id,
      required String clave,
      required String estado,
      Value<DateTime?> pospuestaHasta,
      Value<String?> derivadaA,
      Value<String?> comentario,
      Value<DateTime> actualizadoEn,
    });
typedef $$TablaAlertasGestionEstadoTableUpdateCompanionBuilder =
    TablaAlertasGestionEstadoCompanion Function({
      Value<int> id,
      Value<String> clave,
      Value<String> estado,
      Value<DateTime?> pospuestaHasta,
      Value<String?> derivadaA,
      Value<String?> comentario,
      Value<DateTime> actualizadoEn,
    });

class $$TablaAlertasGestionEstadoTableFilterComposer
    extends Composer<_$BaseDeDatos, $TablaAlertasGestionEstadoTable> {
  $$TablaAlertasGestionEstadoTableFilterComposer({
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

  ColumnFilters<String> get clave => $composableBuilder(
    column: $table.clave,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get pospuestaHasta => $composableBuilder(
    column: $table.pospuestaHasta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get derivadaA => $composableBuilder(
    column: $table.derivadaA,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get comentario => $composableBuilder(
    column: $table.comentario,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TablaAlertasGestionEstadoTableOrderingComposer
    extends Composer<_$BaseDeDatos, $TablaAlertasGestionEstadoTable> {
  $$TablaAlertasGestionEstadoTableOrderingComposer({
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

  ColumnOrderings<String> get clave => $composableBuilder(
    column: $table.clave,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get pospuestaHasta => $composableBuilder(
    column: $table.pospuestaHasta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get derivadaA => $composableBuilder(
    column: $table.derivadaA,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get comentario => $composableBuilder(
    column: $table.comentario,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TablaAlertasGestionEstadoTableAnnotationComposer
    extends Composer<_$BaseDeDatos, $TablaAlertasGestionEstadoTable> {
  $$TablaAlertasGestionEstadoTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get clave =>
      $composableBuilder(column: $table.clave, builder: (column) => column);

  GeneratedColumn<String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);

  GeneratedColumn<DateTime> get pospuestaHasta => $composableBuilder(
    column: $table.pospuestaHasta,
    builder: (column) => column,
  );

  GeneratedColumn<String> get derivadaA =>
      $composableBuilder(column: $table.derivadaA, builder: (column) => column);

  GeneratedColumn<String> get comentario => $composableBuilder(
    column: $table.comentario,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => column,
  );
}

class $$TablaAlertasGestionEstadoTableTableManager
    extends
        RootTableManager<
          _$BaseDeDatos,
          $TablaAlertasGestionEstadoTable,
          TablaAlertasGestionEstadoData,
          $$TablaAlertasGestionEstadoTableFilterComposer,
          $$TablaAlertasGestionEstadoTableOrderingComposer,
          $$TablaAlertasGestionEstadoTableAnnotationComposer,
          $$TablaAlertasGestionEstadoTableCreateCompanionBuilder,
          $$TablaAlertasGestionEstadoTableUpdateCompanionBuilder,
          (
            TablaAlertasGestionEstadoData,
            BaseReferences<
              _$BaseDeDatos,
              $TablaAlertasGestionEstadoTable,
              TablaAlertasGestionEstadoData
            >,
          ),
          TablaAlertasGestionEstadoData,
          PrefetchHooks Function()
        > {
  $$TablaAlertasGestionEstadoTableTableManager(
    _$BaseDeDatos db,
    $TablaAlertasGestionEstadoTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TablaAlertasGestionEstadoTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$TablaAlertasGestionEstadoTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TablaAlertasGestionEstadoTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> clave = const Value.absent(),
                Value<String> estado = const Value.absent(),
                Value<DateTime?> pospuestaHasta = const Value.absent(),
                Value<String?> derivadaA = const Value.absent(),
                Value<String?> comentario = const Value.absent(),
                Value<DateTime> actualizadoEn = const Value.absent(),
              }) => TablaAlertasGestionEstadoCompanion(
                id: id,
                clave: clave,
                estado: estado,
                pospuestaHasta: pospuestaHasta,
                derivadaA: derivadaA,
                comentario: comentario,
                actualizadoEn: actualizadoEn,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String clave,
                required String estado,
                Value<DateTime?> pospuestaHasta = const Value.absent(),
                Value<String?> derivadaA = const Value.absent(),
                Value<String?> comentario = const Value.absent(),
                Value<DateTime> actualizadoEn = const Value.absent(),
              }) => TablaAlertasGestionEstadoCompanion.insert(
                id: id,
                clave: clave,
                estado: estado,
                pospuestaHasta: pospuestaHasta,
                derivadaA: derivadaA,
                comentario: comentario,
                actualizadoEn: actualizadoEn,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TablaAlertasGestionEstadoTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDeDatos,
      $TablaAlertasGestionEstadoTable,
      TablaAlertasGestionEstadoData,
      $$TablaAlertasGestionEstadoTableFilterComposer,
      $$TablaAlertasGestionEstadoTableOrderingComposer,
      $$TablaAlertasGestionEstadoTableAnnotationComposer,
      $$TablaAlertasGestionEstadoTableCreateCompanionBuilder,
      $$TablaAlertasGestionEstadoTableUpdateCompanionBuilder,
      (
        TablaAlertasGestionEstadoData,
        BaseReferences<
          _$BaseDeDatos,
          $TablaAlertasGestionEstadoTable,
          TablaAlertasGestionEstadoData
        >,
      ),
      TablaAlertasGestionEstadoData,
      PrefetchHooks Function()
    >;
typedef $$TablaIncidenciasTransversalesHistorialTableCreateCompanionBuilder =
    TablaIncidenciasTransversalesHistorialCompanion Function({
      Value<int> id,
      required String origen,
      required String referencia,
      required String accion,
      Value<String?> estadoOperativo,
      Value<String?> estadoDocumental,
      Value<String?> detalle,
      Value<DateTime> creadoEn,
    });
typedef $$TablaIncidenciasTransversalesHistorialTableUpdateCompanionBuilder =
    TablaIncidenciasTransversalesHistorialCompanion Function({
      Value<int> id,
      Value<String> origen,
      Value<String> referencia,
      Value<String> accion,
      Value<String?> estadoOperativo,
      Value<String?> estadoDocumental,
      Value<String?> detalle,
      Value<DateTime> creadoEn,
    });

class $$TablaIncidenciasTransversalesHistorialTableFilterComposer
    extends
        Composer<_$BaseDeDatos, $TablaIncidenciasTransversalesHistorialTable> {
  $$TablaIncidenciasTransversalesHistorialTableFilterComposer({
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

  ColumnFilters<String> get origen => $composableBuilder(
    column: $table.origen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referencia => $composableBuilder(
    column: $table.referencia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accion => $composableBuilder(
    column: $table.accion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estadoOperativo => $composableBuilder(
    column: $table.estadoOperativo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estadoDocumental => $composableBuilder(
    column: $table.estadoDocumental,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detalle => $composableBuilder(
    column: $table.detalle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TablaIncidenciasTransversalesHistorialTableOrderingComposer
    extends
        Composer<_$BaseDeDatos, $TablaIncidenciasTransversalesHistorialTable> {
  $$TablaIncidenciasTransversalesHistorialTableOrderingComposer({
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

  ColumnOrderings<String> get origen => $composableBuilder(
    column: $table.origen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referencia => $composableBuilder(
    column: $table.referencia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accion => $composableBuilder(
    column: $table.accion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estadoOperativo => $composableBuilder(
    column: $table.estadoOperativo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estadoDocumental => $composableBuilder(
    column: $table.estadoDocumental,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detalle => $composableBuilder(
    column: $table.detalle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TablaIncidenciasTransversalesHistorialTableAnnotationComposer
    extends
        Composer<_$BaseDeDatos, $TablaIncidenciasTransversalesHistorialTable> {
  $$TablaIncidenciasTransversalesHistorialTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get origen =>
      $composableBuilder(column: $table.origen, builder: (column) => column);

  GeneratedColumn<String> get referencia => $composableBuilder(
    column: $table.referencia,
    builder: (column) => column,
  );

  GeneratedColumn<String> get accion =>
      $composableBuilder(column: $table.accion, builder: (column) => column);

  GeneratedColumn<String> get estadoOperativo => $composableBuilder(
    column: $table.estadoOperativo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get estadoDocumental => $composableBuilder(
    column: $table.estadoDocumental,
    builder: (column) => column,
  );

  GeneratedColumn<String> get detalle =>
      $composableBuilder(column: $table.detalle, builder: (column) => column);

  GeneratedColumn<DateTime> get creadoEn =>
      $composableBuilder(column: $table.creadoEn, builder: (column) => column);
}

class $$TablaIncidenciasTransversalesHistorialTableTableManager
    extends
        RootTableManager<
          _$BaseDeDatos,
          $TablaIncidenciasTransversalesHistorialTable,
          TablaIncidenciasTransversalesHistorialData,
          $$TablaIncidenciasTransversalesHistorialTableFilterComposer,
          $$TablaIncidenciasTransversalesHistorialTableOrderingComposer,
          $$TablaIncidenciasTransversalesHistorialTableAnnotationComposer,
          $$TablaIncidenciasTransversalesHistorialTableCreateCompanionBuilder,
          $$TablaIncidenciasTransversalesHistorialTableUpdateCompanionBuilder,
          (
            TablaIncidenciasTransversalesHistorialData,
            BaseReferences<
              _$BaseDeDatos,
              $TablaIncidenciasTransversalesHistorialTable,
              TablaIncidenciasTransversalesHistorialData
            >,
          ),
          TablaIncidenciasTransversalesHistorialData,
          PrefetchHooks Function()
        > {
  $$TablaIncidenciasTransversalesHistorialTableTableManager(
    _$BaseDeDatos db,
    $TablaIncidenciasTransversalesHistorialTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TablaIncidenciasTransversalesHistorialTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$TablaIncidenciasTransversalesHistorialTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TablaIncidenciasTransversalesHistorialTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> origen = const Value.absent(),
                Value<String> referencia = const Value.absent(),
                Value<String> accion = const Value.absent(),
                Value<String?> estadoOperativo = const Value.absent(),
                Value<String?> estadoDocumental = const Value.absent(),
                Value<String?> detalle = const Value.absent(),
                Value<DateTime> creadoEn = const Value.absent(),
              }) => TablaIncidenciasTransversalesHistorialCompanion(
                id: id,
                origen: origen,
                referencia: referencia,
                accion: accion,
                estadoOperativo: estadoOperativo,
                estadoDocumental: estadoDocumental,
                detalle: detalle,
                creadoEn: creadoEn,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String origen,
                required String referencia,
                required String accion,
                Value<String?> estadoOperativo = const Value.absent(),
                Value<String?> estadoDocumental = const Value.absent(),
                Value<String?> detalle = const Value.absent(),
                Value<DateTime> creadoEn = const Value.absent(),
              }) => TablaIncidenciasTransversalesHistorialCompanion.insert(
                id: id,
                origen: origen,
                referencia: referencia,
                accion: accion,
                estadoOperativo: estadoOperativo,
                estadoDocumental: estadoDocumental,
                detalle: detalle,
                creadoEn: creadoEn,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TablaIncidenciasTransversalesHistorialTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDeDatos,
      $TablaIncidenciasTransversalesHistorialTable,
      TablaIncidenciasTransversalesHistorialData,
      $$TablaIncidenciasTransversalesHistorialTableFilterComposer,
      $$TablaIncidenciasTransversalesHistorialTableOrderingComposer,
      $$TablaIncidenciasTransversalesHistorialTableAnnotationComposer,
      $$TablaIncidenciasTransversalesHistorialTableCreateCompanionBuilder,
      $$TablaIncidenciasTransversalesHistorialTableUpdateCompanionBuilder,
      (
        TablaIncidenciasTransversalesHistorialData,
        BaseReferences<
          _$BaseDeDatos,
          $TablaIncidenciasTransversalesHistorialTable,
          TablaIncidenciasTransversalesHistorialData
        >,
      ),
      TablaIncidenciasTransversalesHistorialData,
      PrefetchHooks Function()
    >;
typedef $$TablaLegajosDocumentalesTableCreateCompanionBuilder =
    TablaLegajosDocumentalesCompanion Function({
      Value<int> id,
      required String tipoRegistro,
      required String categoria,
      required String codigo,
      required String titulo,
      required String detalle,
      required String responsable,
      required String estado,
      required String severidad,
      required String rolDestino,
      required String nivelDestino,
      required String dependenciaDestino,
      Value<int?> horasHastaVencimiento,
      Value<bool> activo,
      Value<DateTime> creadoEn,
      Value<DateTime> actualizadoEn,
    });
typedef $$TablaLegajosDocumentalesTableUpdateCompanionBuilder =
    TablaLegajosDocumentalesCompanion Function({
      Value<int> id,
      Value<String> tipoRegistro,
      Value<String> categoria,
      Value<String> codigo,
      Value<String> titulo,
      Value<String> detalle,
      Value<String> responsable,
      Value<String> estado,
      Value<String> severidad,
      Value<String> rolDestino,
      Value<String> nivelDestino,
      Value<String> dependenciaDestino,
      Value<int?> horasHastaVencimiento,
      Value<bool> activo,
      Value<DateTime> creadoEn,
      Value<DateTime> actualizadoEn,
    });

class $$TablaLegajosDocumentalesTableFilterComposer
    extends Composer<_$BaseDeDatos, $TablaLegajosDocumentalesTable> {
  $$TablaLegajosDocumentalesTableFilterComposer({
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

  ColumnFilters<String> get tipoRegistro => $composableBuilder(
    column: $table.tipoRegistro,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoria => $composableBuilder(
    column: $table.categoria,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get codigo => $composableBuilder(
    column: $table.codigo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get titulo => $composableBuilder(
    column: $table.titulo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detalle => $composableBuilder(
    column: $table.detalle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get responsable => $composableBuilder(
    column: $table.responsable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get severidad => $composableBuilder(
    column: $table.severidad,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rolDestino => $composableBuilder(
    column: $table.rolDestino,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nivelDestino => $composableBuilder(
    column: $table.nivelDestino,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dependenciaDestino => $composableBuilder(
    column: $table.dependenciaDestino,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get horasHastaVencimiento => $composableBuilder(
    column: $table.horasHastaVencimiento,
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

  ColumnFilters<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TablaLegajosDocumentalesTableOrderingComposer
    extends Composer<_$BaseDeDatos, $TablaLegajosDocumentalesTable> {
  $$TablaLegajosDocumentalesTableOrderingComposer({
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

  ColumnOrderings<String> get tipoRegistro => $composableBuilder(
    column: $table.tipoRegistro,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoria => $composableBuilder(
    column: $table.categoria,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get codigo => $composableBuilder(
    column: $table.codigo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get titulo => $composableBuilder(
    column: $table.titulo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detalle => $composableBuilder(
    column: $table.detalle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get responsable => $composableBuilder(
    column: $table.responsable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get severidad => $composableBuilder(
    column: $table.severidad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rolDestino => $composableBuilder(
    column: $table.rolDestino,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nivelDestino => $composableBuilder(
    column: $table.nivelDestino,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dependenciaDestino => $composableBuilder(
    column: $table.dependenciaDestino,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get horasHastaVencimiento => $composableBuilder(
    column: $table.horasHastaVencimiento,
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

  ColumnOrderings<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TablaLegajosDocumentalesTableAnnotationComposer
    extends Composer<_$BaseDeDatos, $TablaLegajosDocumentalesTable> {
  $$TablaLegajosDocumentalesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tipoRegistro => $composableBuilder(
    column: $table.tipoRegistro,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoria =>
      $composableBuilder(column: $table.categoria, builder: (column) => column);

  GeneratedColumn<String> get codigo =>
      $composableBuilder(column: $table.codigo, builder: (column) => column);

  GeneratedColumn<String> get titulo =>
      $composableBuilder(column: $table.titulo, builder: (column) => column);

  GeneratedColumn<String> get detalle =>
      $composableBuilder(column: $table.detalle, builder: (column) => column);

  GeneratedColumn<String> get responsable => $composableBuilder(
    column: $table.responsable,
    builder: (column) => column,
  );

  GeneratedColumn<String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);

  GeneratedColumn<String> get severidad =>
      $composableBuilder(column: $table.severidad, builder: (column) => column);

  GeneratedColumn<String> get rolDestino => $composableBuilder(
    column: $table.rolDestino,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nivelDestino => $composableBuilder(
    column: $table.nivelDestino,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dependenciaDestino => $composableBuilder(
    column: $table.dependenciaDestino,
    builder: (column) => column,
  );

  GeneratedColumn<int> get horasHastaVencimiento => $composableBuilder(
    column: $table.horasHastaVencimiento,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get activo =>
      $composableBuilder(column: $table.activo, builder: (column) => column);

  GeneratedColumn<DateTime> get creadoEn =>
      $composableBuilder(column: $table.creadoEn, builder: (column) => column);

  GeneratedColumn<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => column,
  );
}

class $$TablaLegajosDocumentalesTableTableManager
    extends
        RootTableManager<
          _$BaseDeDatos,
          $TablaLegajosDocumentalesTable,
          TablaLegajosDocumentale,
          $$TablaLegajosDocumentalesTableFilterComposer,
          $$TablaLegajosDocumentalesTableOrderingComposer,
          $$TablaLegajosDocumentalesTableAnnotationComposer,
          $$TablaLegajosDocumentalesTableCreateCompanionBuilder,
          $$TablaLegajosDocumentalesTableUpdateCompanionBuilder,
          (
            TablaLegajosDocumentale,
            BaseReferences<
              _$BaseDeDatos,
              $TablaLegajosDocumentalesTable,
              TablaLegajosDocumentale
            >,
          ),
          TablaLegajosDocumentale,
          PrefetchHooks Function()
        > {
  $$TablaLegajosDocumentalesTableTableManager(
    _$BaseDeDatos db,
    $TablaLegajosDocumentalesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TablaLegajosDocumentalesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$TablaLegajosDocumentalesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TablaLegajosDocumentalesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> tipoRegistro = const Value.absent(),
                Value<String> categoria = const Value.absent(),
                Value<String> codigo = const Value.absent(),
                Value<String> titulo = const Value.absent(),
                Value<String> detalle = const Value.absent(),
                Value<String> responsable = const Value.absent(),
                Value<String> estado = const Value.absent(),
                Value<String> severidad = const Value.absent(),
                Value<String> rolDestino = const Value.absent(),
                Value<String> nivelDestino = const Value.absent(),
                Value<String> dependenciaDestino = const Value.absent(),
                Value<int?> horasHastaVencimiento = const Value.absent(),
                Value<bool> activo = const Value.absent(),
                Value<DateTime> creadoEn = const Value.absent(),
                Value<DateTime> actualizadoEn = const Value.absent(),
              }) => TablaLegajosDocumentalesCompanion(
                id: id,
                tipoRegistro: tipoRegistro,
                categoria: categoria,
                codigo: codigo,
                titulo: titulo,
                detalle: detalle,
                responsable: responsable,
                estado: estado,
                severidad: severidad,
                rolDestino: rolDestino,
                nivelDestino: nivelDestino,
                dependenciaDestino: dependenciaDestino,
                horasHastaVencimiento: horasHastaVencimiento,
                activo: activo,
                creadoEn: creadoEn,
                actualizadoEn: actualizadoEn,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String tipoRegistro,
                required String categoria,
                required String codigo,
                required String titulo,
                required String detalle,
                required String responsable,
                required String estado,
                required String severidad,
                required String rolDestino,
                required String nivelDestino,
                required String dependenciaDestino,
                Value<int?> horasHastaVencimiento = const Value.absent(),
                Value<bool> activo = const Value.absent(),
                Value<DateTime> creadoEn = const Value.absent(),
                Value<DateTime> actualizadoEn = const Value.absent(),
              }) => TablaLegajosDocumentalesCompanion.insert(
                id: id,
                tipoRegistro: tipoRegistro,
                categoria: categoria,
                codigo: codigo,
                titulo: titulo,
                detalle: detalle,
                responsable: responsable,
                estado: estado,
                severidad: severidad,
                rolDestino: rolDestino,
                nivelDestino: nivelDestino,
                dependenciaDestino: dependenciaDestino,
                horasHastaVencimiento: horasHastaVencimiento,
                activo: activo,
                creadoEn: creadoEn,
                actualizadoEn: actualizadoEn,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TablaLegajosDocumentalesTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDeDatos,
      $TablaLegajosDocumentalesTable,
      TablaLegajosDocumentale,
      $$TablaLegajosDocumentalesTableFilterComposer,
      $$TablaLegajosDocumentalesTableOrderingComposer,
      $$TablaLegajosDocumentalesTableAnnotationComposer,
      $$TablaLegajosDocumentalesTableCreateCompanionBuilder,
      $$TablaLegajosDocumentalesTableUpdateCompanionBuilder,
      (
        TablaLegajosDocumentale,
        BaseReferences<
          _$BaseDeDatos,
          $TablaLegajosDocumentalesTable,
          TablaLegajosDocumentale
        >,
      ),
      TablaLegajosDocumentale,
      PrefetchHooks Function()
    >;
typedef $$TablaNotasManualesTableCreateCompanionBuilder =
    TablaNotasManualesCompanion Function({
      Value<int> id,
      required int alumnoId,
      Value<int?> cursoId,
      required String claveContexto,
      required String nota,
      Value<DateTime> actualizadoEn,
    });
typedef $$TablaNotasManualesTableUpdateCompanionBuilder =
    TablaNotasManualesCompanion Function({
      Value<int> id,
      Value<int> alumnoId,
      Value<int?> cursoId,
      Value<String> claveContexto,
      Value<String> nota,
      Value<DateTime> actualizadoEn,
    });

final class $$TablaNotasManualesTableReferences
    extends
        BaseReferences<
          _$BaseDeDatos,
          $TablaNotasManualesTable,
          TablaNotasManuale
        > {
  $$TablaNotasManualesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TablaAlumnosTable _alumnoIdTable(_$BaseDeDatos db) =>
      db.tablaAlumnos.createAlias(
        $_aliasNameGenerator(
          db.tablaNotasManuales.alumnoId,
          db.tablaAlumnos.id,
        ),
      );

  $$TablaAlumnosTableProcessedTableManager get alumnoId {
    final $_column = $_itemColumn<int>('alumno_id')!;

    final manager = $$TablaAlumnosTableTableManager(
      $_db,
      $_db.tablaAlumnos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_alumnoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TablaNotasManualesTableFilterComposer
    extends Composer<_$BaseDeDatos, $TablaNotasManualesTable> {
  $$TablaNotasManualesTableFilterComposer({
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

  ColumnFilters<int> get cursoId => $composableBuilder(
    column: $table.cursoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get claveContexto => $composableBuilder(
    column: $table.claveContexto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nota => $composableBuilder(
    column: $table.nota,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => ColumnFilters(column),
  );

  $$TablaAlumnosTableFilterComposer get alumnoId {
    final $$TablaAlumnosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.alumnoId,
      referencedTable: $db.tablaAlumnos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaAlumnosTableFilterComposer(
            $db: $db,
            $table: $db.tablaAlumnos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TablaNotasManualesTableOrderingComposer
    extends Composer<_$BaseDeDatos, $TablaNotasManualesTable> {
  $$TablaNotasManualesTableOrderingComposer({
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

  ColumnOrderings<int> get cursoId => $composableBuilder(
    column: $table.cursoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get claveContexto => $composableBuilder(
    column: $table.claveContexto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nota => $composableBuilder(
    column: $table.nota,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => ColumnOrderings(column),
  );

  $$TablaAlumnosTableOrderingComposer get alumnoId {
    final $$TablaAlumnosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.alumnoId,
      referencedTable: $db.tablaAlumnos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaAlumnosTableOrderingComposer(
            $db: $db,
            $table: $db.tablaAlumnos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TablaNotasManualesTableAnnotationComposer
    extends Composer<_$BaseDeDatos, $TablaNotasManualesTable> {
  $$TablaNotasManualesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get cursoId =>
      $composableBuilder(column: $table.cursoId, builder: (column) => column);

  GeneratedColumn<String> get claveContexto => $composableBuilder(
    column: $table.claveContexto,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nota =>
      $composableBuilder(column: $table.nota, builder: (column) => column);

  GeneratedColumn<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => column,
  );

  $$TablaAlumnosTableAnnotationComposer get alumnoId {
    final $$TablaAlumnosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.alumnoId,
      referencedTable: $db.tablaAlumnos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TablaAlumnosTableAnnotationComposer(
            $db: $db,
            $table: $db.tablaAlumnos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TablaNotasManualesTableTableManager
    extends
        RootTableManager<
          _$BaseDeDatos,
          $TablaNotasManualesTable,
          TablaNotasManuale,
          $$TablaNotasManualesTableFilterComposer,
          $$TablaNotasManualesTableOrderingComposer,
          $$TablaNotasManualesTableAnnotationComposer,
          $$TablaNotasManualesTableCreateCompanionBuilder,
          $$TablaNotasManualesTableUpdateCompanionBuilder,
          (TablaNotasManuale, $$TablaNotasManualesTableReferences),
          TablaNotasManuale,
          PrefetchHooks Function({bool alumnoId})
        > {
  $$TablaNotasManualesTableTableManager(
    _$BaseDeDatos db,
    $TablaNotasManualesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TablaNotasManualesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TablaNotasManualesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TablaNotasManualesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> alumnoId = const Value.absent(),
                Value<int?> cursoId = const Value.absent(),
                Value<String> claveContexto = const Value.absent(),
                Value<String> nota = const Value.absent(),
                Value<DateTime> actualizadoEn = const Value.absent(),
              }) => TablaNotasManualesCompanion(
                id: id,
                alumnoId: alumnoId,
                cursoId: cursoId,
                claveContexto: claveContexto,
                nota: nota,
                actualizadoEn: actualizadoEn,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int alumnoId,
                Value<int?> cursoId = const Value.absent(),
                required String claveContexto,
                required String nota,
                Value<DateTime> actualizadoEn = const Value.absent(),
              }) => TablaNotasManualesCompanion.insert(
                id: id,
                alumnoId: alumnoId,
                cursoId: cursoId,
                claveContexto: claveContexto,
                nota: nota,
                actualizadoEn: actualizadoEn,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TablaNotasManualesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({alumnoId = false}) {
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
                    if (alumnoId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.alumnoId,
                                referencedTable:
                                    $$TablaNotasManualesTableReferences
                                        ._alumnoIdTable(db),
                                referencedColumn:
                                    $$TablaNotasManualesTableReferences
                                        ._alumnoIdTable(db)
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

typedef $$TablaNotasManualesTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDeDatos,
      $TablaNotasManualesTable,
      TablaNotasManuale,
      $$TablaNotasManualesTableFilterComposer,
      $$TablaNotasManualesTableOrderingComposer,
      $$TablaNotasManualesTableAnnotationComposer,
      $$TablaNotasManualesTableCreateCompanionBuilder,
      $$TablaNotasManualesTableUpdateCompanionBuilder,
      (TablaNotasManuale, $$TablaNotasManualesTableReferences),
      TablaNotasManuale,
      PrefetchHooks Function({bool alumnoId})
    >;
typedef $$TablaNovedadesPreceptoriaTableCreateCompanionBuilder =
    TablaNovedadesPreceptoriaCompanion Function({
      Value<int> id,
      required String tipoNovedad,
      required String categoria,
      Value<String?> cursoReferencia,
      Value<String?> alumnoReferencia,
      required String estado,
      required String prioridad,
      required String responsable,
      required String observaciones,
      Value<DateTime?> fechaSeguimiento,
      required String rolDestino,
      required String nivelDestino,
      required String dependenciaDestino,
      Value<bool> activo,
      Value<DateTime> creadoEn,
      Value<DateTime> actualizadoEn,
    });
typedef $$TablaNovedadesPreceptoriaTableUpdateCompanionBuilder =
    TablaNovedadesPreceptoriaCompanion Function({
      Value<int> id,
      Value<String> tipoNovedad,
      Value<String> categoria,
      Value<String?> cursoReferencia,
      Value<String?> alumnoReferencia,
      Value<String> estado,
      Value<String> prioridad,
      Value<String> responsable,
      Value<String> observaciones,
      Value<DateTime?> fechaSeguimiento,
      Value<String> rolDestino,
      Value<String> nivelDestino,
      Value<String> dependenciaDestino,
      Value<bool> activo,
      Value<DateTime> creadoEn,
      Value<DateTime> actualizadoEn,
    });

class $$TablaNovedadesPreceptoriaTableFilterComposer
    extends Composer<_$BaseDeDatos, $TablaNovedadesPreceptoriaTable> {
  $$TablaNovedadesPreceptoriaTableFilterComposer({
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

  ColumnFilters<String> get tipoNovedad => $composableBuilder(
    column: $table.tipoNovedad,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoria => $composableBuilder(
    column: $table.categoria,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cursoReferencia => $composableBuilder(
    column: $table.cursoReferencia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alumnoReferencia => $composableBuilder(
    column: $table.alumnoReferencia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get prioridad => $composableBuilder(
    column: $table.prioridad,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get responsable => $composableBuilder(
    column: $table.responsable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observaciones => $composableBuilder(
    column: $table.observaciones,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fechaSeguimiento => $composableBuilder(
    column: $table.fechaSeguimiento,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rolDestino => $composableBuilder(
    column: $table.rolDestino,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nivelDestino => $composableBuilder(
    column: $table.nivelDestino,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dependenciaDestino => $composableBuilder(
    column: $table.dependenciaDestino,
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

  ColumnFilters<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TablaNovedadesPreceptoriaTableOrderingComposer
    extends Composer<_$BaseDeDatos, $TablaNovedadesPreceptoriaTable> {
  $$TablaNovedadesPreceptoriaTableOrderingComposer({
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

  ColumnOrderings<String> get tipoNovedad => $composableBuilder(
    column: $table.tipoNovedad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoria => $composableBuilder(
    column: $table.categoria,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cursoReferencia => $composableBuilder(
    column: $table.cursoReferencia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alumnoReferencia => $composableBuilder(
    column: $table.alumnoReferencia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get prioridad => $composableBuilder(
    column: $table.prioridad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get responsable => $composableBuilder(
    column: $table.responsable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observaciones => $composableBuilder(
    column: $table.observaciones,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fechaSeguimiento => $composableBuilder(
    column: $table.fechaSeguimiento,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rolDestino => $composableBuilder(
    column: $table.rolDestino,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nivelDestino => $composableBuilder(
    column: $table.nivelDestino,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dependenciaDestino => $composableBuilder(
    column: $table.dependenciaDestino,
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

  ColumnOrderings<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TablaNovedadesPreceptoriaTableAnnotationComposer
    extends Composer<_$BaseDeDatos, $TablaNovedadesPreceptoriaTable> {
  $$TablaNovedadesPreceptoriaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tipoNovedad => $composableBuilder(
    column: $table.tipoNovedad,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoria =>
      $composableBuilder(column: $table.categoria, builder: (column) => column);

  GeneratedColumn<String> get cursoReferencia => $composableBuilder(
    column: $table.cursoReferencia,
    builder: (column) => column,
  );

  GeneratedColumn<String> get alumnoReferencia => $composableBuilder(
    column: $table.alumnoReferencia,
    builder: (column) => column,
  );

  GeneratedColumn<String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);

  GeneratedColumn<String> get prioridad =>
      $composableBuilder(column: $table.prioridad, builder: (column) => column);

  GeneratedColumn<String> get responsable => $composableBuilder(
    column: $table.responsable,
    builder: (column) => column,
  );

  GeneratedColumn<String> get observaciones => $composableBuilder(
    column: $table.observaciones,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fechaSeguimiento => $composableBuilder(
    column: $table.fechaSeguimiento,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rolDestino => $composableBuilder(
    column: $table.rolDestino,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nivelDestino => $composableBuilder(
    column: $table.nivelDestino,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dependenciaDestino => $composableBuilder(
    column: $table.dependenciaDestino,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get activo =>
      $composableBuilder(column: $table.activo, builder: (column) => column);

  GeneratedColumn<DateTime> get creadoEn =>
      $composableBuilder(column: $table.creadoEn, builder: (column) => column);

  GeneratedColumn<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => column,
  );
}

class $$TablaNovedadesPreceptoriaTableTableManager
    extends
        RootTableManager<
          _$BaseDeDatos,
          $TablaNovedadesPreceptoriaTable,
          TablaNovedadesPreceptoriaData,
          $$TablaNovedadesPreceptoriaTableFilterComposer,
          $$TablaNovedadesPreceptoriaTableOrderingComposer,
          $$TablaNovedadesPreceptoriaTableAnnotationComposer,
          $$TablaNovedadesPreceptoriaTableCreateCompanionBuilder,
          $$TablaNovedadesPreceptoriaTableUpdateCompanionBuilder,
          (
            TablaNovedadesPreceptoriaData,
            BaseReferences<
              _$BaseDeDatos,
              $TablaNovedadesPreceptoriaTable,
              TablaNovedadesPreceptoriaData
            >,
          ),
          TablaNovedadesPreceptoriaData,
          PrefetchHooks Function()
        > {
  $$TablaNovedadesPreceptoriaTableTableManager(
    _$BaseDeDatos db,
    $TablaNovedadesPreceptoriaTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TablaNovedadesPreceptoriaTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$TablaNovedadesPreceptoriaTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TablaNovedadesPreceptoriaTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> tipoNovedad = const Value.absent(),
                Value<String> categoria = const Value.absent(),
                Value<String?> cursoReferencia = const Value.absent(),
                Value<String?> alumnoReferencia = const Value.absent(),
                Value<String> estado = const Value.absent(),
                Value<String> prioridad = const Value.absent(),
                Value<String> responsable = const Value.absent(),
                Value<String> observaciones = const Value.absent(),
                Value<DateTime?> fechaSeguimiento = const Value.absent(),
                Value<String> rolDestino = const Value.absent(),
                Value<String> nivelDestino = const Value.absent(),
                Value<String> dependenciaDestino = const Value.absent(),
                Value<bool> activo = const Value.absent(),
                Value<DateTime> creadoEn = const Value.absent(),
                Value<DateTime> actualizadoEn = const Value.absent(),
              }) => TablaNovedadesPreceptoriaCompanion(
                id: id,
                tipoNovedad: tipoNovedad,
                categoria: categoria,
                cursoReferencia: cursoReferencia,
                alumnoReferencia: alumnoReferencia,
                estado: estado,
                prioridad: prioridad,
                responsable: responsable,
                observaciones: observaciones,
                fechaSeguimiento: fechaSeguimiento,
                rolDestino: rolDestino,
                nivelDestino: nivelDestino,
                dependenciaDestino: dependenciaDestino,
                activo: activo,
                creadoEn: creadoEn,
                actualizadoEn: actualizadoEn,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String tipoNovedad,
                required String categoria,
                Value<String?> cursoReferencia = const Value.absent(),
                Value<String?> alumnoReferencia = const Value.absent(),
                required String estado,
                required String prioridad,
                required String responsable,
                required String observaciones,
                Value<DateTime?> fechaSeguimiento = const Value.absent(),
                required String rolDestino,
                required String nivelDestino,
                required String dependenciaDestino,
                Value<bool> activo = const Value.absent(),
                Value<DateTime> creadoEn = const Value.absent(),
                Value<DateTime> actualizadoEn = const Value.absent(),
              }) => TablaNovedadesPreceptoriaCompanion.insert(
                id: id,
                tipoNovedad: tipoNovedad,
                categoria: categoria,
                cursoReferencia: cursoReferencia,
                alumnoReferencia: alumnoReferencia,
                estado: estado,
                prioridad: prioridad,
                responsable: responsable,
                observaciones: observaciones,
                fechaSeguimiento: fechaSeguimiento,
                rolDestino: rolDestino,
                nivelDestino: nivelDestino,
                dependenciaDestino: dependenciaDestino,
                activo: activo,
                creadoEn: creadoEn,
                actualizadoEn: actualizadoEn,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TablaNovedadesPreceptoriaTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDeDatos,
      $TablaNovedadesPreceptoriaTable,
      TablaNovedadesPreceptoriaData,
      $$TablaNovedadesPreceptoriaTableFilterComposer,
      $$TablaNovedadesPreceptoriaTableOrderingComposer,
      $$TablaNovedadesPreceptoriaTableAnnotationComposer,
      $$TablaNovedadesPreceptoriaTableCreateCompanionBuilder,
      $$TablaNovedadesPreceptoriaTableUpdateCompanionBuilder,
      (
        TablaNovedadesPreceptoriaData,
        BaseReferences<
          _$BaseDeDatos,
          $TablaNovedadesPreceptoriaTable,
          TablaNovedadesPreceptoriaData
        >,
      ),
      TablaNovedadesPreceptoriaData,
      PrefetchHooks Function()
    >;
typedef $$TablaResponsablesGestionTableCreateCompanionBuilder =
    TablaResponsablesGestionCompanion Function({
      Value<int> id,
      required String nombre,
      required String area,
      required String rolDestino,
      required String nivelDestino,
      required String dependenciaDestino,
      Value<bool> activo,
      Value<DateTime> creadoEn,
    });
typedef $$TablaResponsablesGestionTableUpdateCompanionBuilder =
    TablaResponsablesGestionCompanion Function({
      Value<int> id,
      Value<String> nombre,
      Value<String> area,
      Value<String> rolDestino,
      Value<String> nivelDestino,
      Value<String> dependenciaDestino,
      Value<bool> activo,
      Value<DateTime> creadoEn,
    });

class $$TablaResponsablesGestionTableFilterComposer
    extends Composer<_$BaseDeDatos, $TablaResponsablesGestionTable> {
  $$TablaResponsablesGestionTableFilterComposer({
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

  ColumnFilters<String> get area => $composableBuilder(
    column: $table.area,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rolDestino => $composableBuilder(
    column: $table.rolDestino,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nivelDestino => $composableBuilder(
    column: $table.nivelDestino,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dependenciaDestino => $composableBuilder(
    column: $table.dependenciaDestino,
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
}

class $$TablaResponsablesGestionTableOrderingComposer
    extends Composer<_$BaseDeDatos, $TablaResponsablesGestionTable> {
  $$TablaResponsablesGestionTableOrderingComposer({
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

  ColumnOrderings<String> get area => $composableBuilder(
    column: $table.area,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rolDestino => $composableBuilder(
    column: $table.rolDestino,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nivelDestino => $composableBuilder(
    column: $table.nivelDestino,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dependenciaDestino => $composableBuilder(
    column: $table.dependenciaDestino,
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

class $$TablaResponsablesGestionTableAnnotationComposer
    extends Composer<_$BaseDeDatos, $TablaResponsablesGestionTable> {
  $$TablaResponsablesGestionTableAnnotationComposer({
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

  GeneratedColumn<String> get area =>
      $composableBuilder(column: $table.area, builder: (column) => column);

  GeneratedColumn<String> get rolDestino => $composableBuilder(
    column: $table.rolDestino,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nivelDestino => $composableBuilder(
    column: $table.nivelDestino,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dependenciaDestino => $composableBuilder(
    column: $table.dependenciaDestino,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get activo =>
      $composableBuilder(column: $table.activo, builder: (column) => column);

  GeneratedColumn<DateTime> get creadoEn =>
      $composableBuilder(column: $table.creadoEn, builder: (column) => column);
}

class $$TablaResponsablesGestionTableTableManager
    extends
        RootTableManager<
          _$BaseDeDatos,
          $TablaResponsablesGestionTable,
          TablaResponsablesGestionData,
          $$TablaResponsablesGestionTableFilterComposer,
          $$TablaResponsablesGestionTableOrderingComposer,
          $$TablaResponsablesGestionTableAnnotationComposer,
          $$TablaResponsablesGestionTableCreateCompanionBuilder,
          $$TablaResponsablesGestionTableUpdateCompanionBuilder,
          (
            TablaResponsablesGestionData,
            BaseReferences<
              _$BaseDeDatos,
              $TablaResponsablesGestionTable,
              TablaResponsablesGestionData
            >,
          ),
          TablaResponsablesGestionData,
          PrefetchHooks Function()
        > {
  $$TablaResponsablesGestionTableTableManager(
    _$BaseDeDatos db,
    $TablaResponsablesGestionTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TablaResponsablesGestionTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$TablaResponsablesGestionTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TablaResponsablesGestionTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<String> area = const Value.absent(),
                Value<String> rolDestino = const Value.absent(),
                Value<String> nivelDestino = const Value.absent(),
                Value<String> dependenciaDestino = const Value.absent(),
                Value<bool> activo = const Value.absent(),
                Value<DateTime> creadoEn = const Value.absent(),
              }) => TablaResponsablesGestionCompanion(
                id: id,
                nombre: nombre,
                area: area,
                rolDestino: rolDestino,
                nivelDestino: nivelDestino,
                dependenciaDestino: dependenciaDestino,
                activo: activo,
                creadoEn: creadoEn,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nombre,
                required String area,
                required String rolDestino,
                required String nivelDestino,
                required String dependenciaDestino,
                Value<bool> activo = const Value.absent(),
                Value<DateTime> creadoEn = const Value.absent(),
              }) => TablaResponsablesGestionCompanion.insert(
                id: id,
                nombre: nombre,
                area: area,
                rolDestino: rolDestino,
                nivelDestino: nivelDestino,
                dependenciaDestino: dependenciaDestino,
                activo: activo,
                creadoEn: creadoEn,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TablaResponsablesGestionTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDeDatos,
      $TablaResponsablesGestionTable,
      TablaResponsablesGestionData,
      $$TablaResponsablesGestionTableFilterComposer,
      $$TablaResponsablesGestionTableOrderingComposer,
      $$TablaResponsablesGestionTableAnnotationComposer,
      $$TablaResponsablesGestionTableCreateCompanionBuilder,
      $$TablaResponsablesGestionTableUpdateCompanionBuilder,
      (
        TablaResponsablesGestionData,
        BaseReferences<
          _$BaseDeDatos,
          $TablaResponsablesGestionTable,
          TablaResponsablesGestionData
        >,
      ),
      TablaResponsablesGestionData,
      PrefetchHooks Function()
    >;
typedef $$TablaRecursosBibliotecaTableCreateCompanionBuilder =
    TablaRecursosBibliotecaCompanion Function({
      Value<int> id,
      required String tipoRecurso,
      required String categoria,
      required String codigo,
      required String titulo,
      Value<String?> autorReferencia,
      required String estado,
      required String responsable,
      Value<String?> destinatario,
      Value<String?> cursoReferencia,
      Value<int> cantidadTotal,
      Value<int> cantidadDisponible,
      Value<DateTime?> fechaVencimiento,
      required String observaciones,
      required String rolDestino,
      required String nivelDestino,
      required String dependenciaDestino,
      Value<bool> activo,
      Value<DateTime> creadoEn,
      Value<DateTime> actualizadoEn,
    });
typedef $$TablaRecursosBibliotecaTableUpdateCompanionBuilder =
    TablaRecursosBibliotecaCompanion Function({
      Value<int> id,
      Value<String> tipoRecurso,
      Value<String> categoria,
      Value<String> codigo,
      Value<String> titulo,
      Value<String?> autorReferencia,
      Value<String> estado,
      Value<String> responsable,
      Value<String?> destinatario,
      Value<String?> cursoReferencia,
      Value<int> cantidadTotal,
      Value<int> cantidadDisponible,
      Value<DateTime?> fechaVencimiento,
      Value<String> observaciones,
      Value<String> rolDestino,
      Value<String> nivelDestino,
      Value<String> dependenciaDestino,
      Value<bool> activo,
      Value<DateTime> creadoEn,
      Value<DateTime> actualizadoEn,
    });

class $$TablaRecursosBibliotecaTableFilterComposer
    extends Composer<_$BaseDeDatos, $TablaRecursosBibliotecaTable> {
  $$TablaRecursosBibliotecaTableFilterComposer({
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

  ColumnFilters<String> get tipoRecurso => $composableBuilder(
    column: $table.tipoRecurso,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoria => $composableBuilder(
    column: $table.categoria,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get codigo => $composableBuilder(
    column: $table.codigo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get titulo => $composableBuilder(
    column: $table.titulo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get autorReferencia => $composableBuilder(
    column: $table.autorReferencia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get responsable => $composableBuilder(
    column: $table.responsable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get destinatario => $composableBuilder(
    column: $table.destinatario,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cursoReferencia => $composableBuilder(
    column: $table.cursoReferencia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cantidadTotal => $composableBuilder(
    column: $table.cantidadTotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cantidadDisponible => $composableBuilder(
    column: $table.cantidadDisponible,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fechaVencimiento => $composableBuilder(
    column: $table.fechaVencimiento,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observaciones => $composableBuilder(
    column: $table.observaciones,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rolDestino => $composableBuilder(
    column: $table.rolDestino,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nivelDestino => $composableBuilder(
    column: $table.nivelDestino,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dependenciaDestino => $composableBuilder(
    column: $table.dependenciaDestino,
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

  ColumnFilters<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TablaRecursosBibliotecaTableOrderingComposer
    extends Composer<_$BaseDeDatos, $TablaRecursosBibliotecaTable> {
  $$TablaRecursosBibliotecaTableOrderingComposer({
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

  ColumnOrderings<String> get tipoRecurso => $composableBuilder(
    column: $table.tipoRecurso,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoria => $composableBuilder(
    column: $table.categoria,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get codigo => $composableBuilder(
    column: $table.codigo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get titulo => $composableBuilder(
    column: $table.titulo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get autorReferencia => $composableBuilder(
    column: $table.autorReferencia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get responsable => $composableBuilder(
    column: $table.responsable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get destinatario => $composableBuilder(
    column: $table.destinatario,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cursoReferencia => $composableBuilder(
    column: $table.cursoReferencia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cantidadTotal => $composableBuilder(
    column: $table.cantidadTotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cantidadDisponible => $composableBuilder(
    column: $table.cantidadDisponible,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fechaVencimiento => $composableBuilder(
    column: $table.fechaVencimiento,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observaciones => $composableBuilder(
    column: $table.observaciones,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rolDestino => $composableBuilder(
    column: $table.rolDestino,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nivelDestino => $composableBuilder(
    column: $table.nivelDestino,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dependenciaDestino => $composableBuilder(
    column: $table.dependenciaDestino,
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

  ColumnOrderings<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TablaRecursosBibliotecaTableAnnotationComposer
    extends Composer<_$BaseDeDatos, $TablaRecursosBibliotecaTable> {
  $$TablaRecursosBibliotecaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tipoRecurso => $composableBuilder(
    column: $table.tipoRecurso,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoria =>
      $composableBuilder(column: $table.categoria, builder: (column) => column);

  GeneratedColumn<String> get codigo =>
      $composableBuilder(column: $table.codigo, builder: (column) => column);

  GeneratedColumn<String> get titulo =>
      $composableBuilder(column: $table.titulo, builder: (column) => column);

  GeneratedColumn<String> get autorReferencia => $composableBuilder(
    column: $table.autorReferencia,
    builder: (column) => column,
  );

  GeneratedColumn<String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);

  GeneratedColumn<String> get responsable => $composableBuilder(
    column: $table.responsable,
    builder: (column) => column,
  );

  GeneratedColumn<String> get destinatario => $composableBuilder(
    column: $table.destinatario,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cursoReferencia => $composableBuilder(
    column: $table.cursoReferencia,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cantidadTotal => $composableBuilder(
    column: $table.cantidadTotal,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cantidadDisponible => $composableBuilder(
    column: $table.cantidadDisponible,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fechaVencimiento => $composableBuilder(
    column: $table.fechaVencimiento,
    builder: (column) => column,
  );

  GeneratedColumn<String> get observaciones => $composableBuilder(
    column: $table.observaciones,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rolDestino => $composableBuilder(
    column: $table.rolDestino,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nivelDestino => $composableBuilder(
    column: $table.nivelDestino,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dependenciaDestino => $composableBuilder(
    column: $table.dependenciaDestino,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get activo =>
      $composableBuilder(column: $table.activo, builder: (column) => column);

  GeneratedColumn<DateTime> get creadoEn =>
      $composableBuilder(column: $table.creadoEn, builder: (column) => column);

  GeneratedColumn<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => column,
  );
}

class $$TablaRecursosBibliotecaTableTableManager
    extends
        RootTableManager<
          _$BaseDeDatos,
          $TablaRecursosBibliotecaTable,
          TablaRecursosBibliotecaData,
          $$TablaRecursosBibliotecaTableFilterComposer,
          $$TablaRecursosBibliotecaTableOrderingComposer,
          $$TablaRecursosBibliotecaTableAnnotationComposer,
          $$TablaRecursosBibliotecaTableCreateCompanionBuilder,
          $$TablaRecursosBibliotecaTableUpdateCompanionBuilder,
          (
            TablaRecursosBibliotecaData,
            BaseReferences<
              _$BaseDeDatos,
              $TablaRecursosBibliotecaTable,
              TablaRecursosBibliotecaData
            >,
          ),
          TablaRecursosBibliotecaData,
          PrefetchHooks Function()
        > {
  $$TablaRecursosBibliotecaTableTableManager(
    _$BaseDeDatos db,
    $TablaRecursosBibliotecaTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TablaRecursosBibliotecaTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$TablaRecursosBibliotecaTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TablaRecursosBibliotecaTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> tipoRecurso = const Value.absent(),
                Value<String> categoria = const Value.absent(),
                Value<String> codigo = const Value.absent(),
                Value<String> titulo = const Value.absent(),
                Value<String?> autorReferencia = const Value.absent(),
                Value<String> estado = const Value.absent(),
                Value<String> responsable = const Value.absent(),
                Value<String?> destinatario = const Value.absent(),
                Value<String?> cursoReferencia = const Value.absent(),
                Value<int> cantidadTotal = const Value.absent(),
                Value<int> cantidadDisponible = const Value.absent(),
                Value<DateTime?> fechaVencimiento = const Value.absent(),
                Value<String> observaciones = const Value.absent(),
                Value<String> rolDestino = const Value.absent(),
                Value<String> nivelDestino = const Value.absent(),
                Value<String> dependenciaDestino = const Value.absent(),
                Value<bool> activo = const Value.absent(),
                Value<DateTime> creadoEn = const Value.absent(),
                Value<DateTime> actualizadoEn = const Value.absent(),
              }) => TablaRecursosBibliotecaCompanion(
                id: id,
                tipoRecurso: tipoRecurso,
                categoria: categoria,
                codigo: codigo,
                titulo: titulo,
                autorReferencia: autorReferencia,
                estado: estado,
                responsable: responsable,
                destinatario: destinatario,
                cursoReferencia: cursoReferencia,
                cantidadTotal: cantidadTotal,
                cantidadDisponible: cantidadDisponible,
                fechaVencimiento: fechaVencimiento,
                observaciones: observaciones,
                rolDestino: rolDestino,
                nivelDestino: nivelDestino,
                dependenciaDestino: dependenciaDestino,
                activo: activo,
                creadoEn: creadoEn,
                actualizadoEn: actualizadoEn,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String tipoRecurso,
                required String categoria,
                required String codigo,
                required String titulo,
                Value<String?> autorReferencia = const Value.absent(),
                required String estado,
                required String responsable,
                Value<String?> destinatario = const Value.absent(),
                Value<String?> cursoReferencia = const Value.absent(),
                Value<int> cantidadTotal = const Value.absent(),
                Value<int> cantidadDisponible = const Value.absent(),
                Value<DateTime?> fechaVencimiento = const Value.absent(),
                required String observaciones,
                required String rolDestino,
                required String nivelDestino,
                required String dependenciaDestino,
                Value<bool> activo = const Value.absent(),
                Value<DateTime> creadoEn = const Value.absent(),
                Value<DateTime> actualizadoEn = const Value.absent(),
              }) => TablaRecursosBibliotecaCompanion.insert(
                id: id,
                tipoRecurso: tipoRecurso,
                categoria: categoria,
                codigo: codigo,
                titulo: titulo,
                autorReferencia: autorReferencia,
                estado: estado,
                responsable: responsable,
                destinatario: destinatario,
                cursoReferencia: cursoReferencia,
                cantidadTotal: cantidadTotal,
                cantidadDisponible: cantidadDisponible,
                fechaVencimiento: fechaVencimiento,
                observaciones: observaciones,
                rolDestino: rolDestino,
                nivelDestino: nivelDestino,
                dependenciaDestino: dependenciaDestino,
                activo: activo,
                creadoEn: creadoEn,
                actualizadoEn: actualizadoEn,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TablaRecursosBibliotecaTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDeDatos,
      $TablaRecursosBibliotecaTable,
      TablaRecursosBibliotecaData,
      $$TablaRecursosBibliotecaTableFilterComposer,
      $$TablaRecursosBibliotecaTableOrderingComposer,
      $$TablaRecursosBibliotecaTableAnnotationComposer,
      $$TablaRecursosBibliotecaTableCreateCompanionBuilder,
      $$TablaRecursosBibliotecaTableUpdateCompanionBuilder,
      (
        TablaRecursosBibliotecaData,
        BaseReferences<
          _$BaseDeDatos,
          $TablaRecursosBibliotecaTable,
          TablaRecursosBibliotecaData
        >,
      ),
      TablaRecursosBibliotecaData,
      PrefetchHooks Function()
    >;
typedef $$TablaTramitesSecretariaTableCreateCompanionBuilder =
    TablaTramitesSecretariaCompanion Function({
      Value<int> id,
      required String tipoTramite,
      required String categoria,
      required String codigo,
      required String asunto,
      required String solicitante,
      Value<String?> cursoReferencia,
      required String estado,
      required String prioridad,
      required String responsable,
      required String observaciones,
      Value<DateTime?> fechaLimite,
      required String rolDestino,
      required String nivelDestino,
      required String dependenciaDestino,
      Value<bool> activo,
      Value<DateTime> creadoEn,
      Value<DateTime> actualizadoEn,
    });
typedef $$TablaTramitesSecretariaTableUpdateCompanionBuilder =
    TablaTramitesSecretariaCompanion Function({
      Value<int> id,
      Value<String> tipoTramite,
      Value<String> categoria,
      Value<String> codigo,
      Value<String> asunto,
      Value<String> solicitante,
      Value<String?> cursoReferencia,
      Value<String> estado,
      Value<String> prioridad,
      Value<String> responsable,
      Value<String> observaciones,
      Value<DateTime?> fechaLimite,
      Value<String> rolDestino,
      Value<String> nivelDestino,
      Value<String> dependenciaDestino,
      Value<bool> activo,
      Value<DateTime> creadoEn,
      Value<DateTime> actualizadoEn,
    });

class $$TablaTramitesSecretariaTableFilterComposer
    extends Composer<_$BaseDeDatos, $TablaTramitesSecretariaTable> {
  $$TablaTramitesSecretariaTableFilterComposer({
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

  ColumnFilters<String> get tipoTramite => $composableBuilder(
    column: $table.tipoTramite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoria => $composableBuilder(
    column: $table.categoria,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get codigo => $composableBuilder(
    column: $table.codigo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get asunto => $composableBuilder(
    column: $table.asunto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get solicitante => $composableBuilder(
    column: $table.solicitante,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cursoReferencia => $composableBuilder(
    column: $table.cursoReferencia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get prioridad => $composableBuilder(
    column: $table.prioridad,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get responsable => $composableBuilder(
    column: $table.responsable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observaciones => $composableBuilder(
    column: $table.observaciones,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fechaLimite => $composableBuilder(
    column: $table.fechaLimite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rolDestino => $composableBuilder(
    column: $table.rolDestino,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nivelDestino => $composableBuilder(
    column: $table.nivelDestino,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dependenciaDestino => $composableBuilder(
    column: $table.dependenciaDestino,
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

  ColumnFilters<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TablaTramitesSecretariaTableOrderingComposer
    extends Composer<_$BaseDeDatos, $TablaTramitesSecretariaTable> {
  $$TablaTramitesSecretariaTableOrderingComposer({
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

  ColumnOrderings<String> get tipoTramite => $composableBuilder(
    column: $table.tipoTramite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoria => $composableBuilder(
    column: $table.categoria,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get codigo => $composableBuilder(
    column: $table.codigo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get asunto => $composableBuilder(
    column: $table.asunto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get solicitante => $composableBuilder(
    column: $table.solicitante,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cursoReferencia => $composableBuilder(
    column: $table.cursoReferencia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get prioridad => $composableBuilder(
    column: $table.prioridad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get responsable => $composableBuilder(
    column: $table.responsable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observaciones => $composableBuilder(
    column: $table.observaciones,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fechaLimite => $composableBuilder(
    column: $table.fechaLimite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rolDestino => $composableBuilder(
    column: $table.rolDestino,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nivelDestino => $composableBuilder(
    column: $table.nivelDestino,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dependenciaDestino => $composableBuilder(
    column: $table.dependenciaDestino,
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

  ColumnOrderings<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TablaTramitesSecretariaTableAnnotationComposer
    extends Composer<_$BaseDeDatos, $TablaTramitesSecretariaTable> {
  $$TablaTramitesSecretariaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tipoTramite => $composableBuilder(
    column: $table.tipoTramite,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoria =>
      $composableBuilder(column: $table.categoria, builder: (column) => column);

  GeneratedColumn<String> get codigo =>
      $composableBuilder(column: $table.codigo, builder: (column) => column);

  GeneratedColumn<String> get asunto =>
      $composableBuilder(column: $table.asunto, builder: (column) => column);

  GeneratedColumn<String> get solicitante => $composableBuilder(
    column: $table.solicitante,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cursoReferencia => $composableBuilder(
    column: $table.cursoReferencia,
    builder: (column) => column,
  );

  GeneratedColumn<String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);

  GeneratedColumn<String> get prioridad =>
      $composableBuilder(column: $table.prioridad, builder: (column) => column);

  GeneratedColumn<String> get responsable => $composableBuilder(
    column: $table.responsable,
    builder: (column) => column,
  );

  GeneratedColumn<String> get observaciones => $composableBuilder(
    column: $table.observaciones,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fechaLimite => $composableBuilder(
    column: $table.fechaLimite,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rolDestino => $composableBuilder(
    column: $table.rolDestino,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nivelDestino => $composableBuilder(
    column: $table.nivelDestino,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dependenciaDestino => $composableBuilder(
    column: $table.dependenciaDestino,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get activo =>
      $composableBuilder(column: $table.activo, builder: (column) => column);

  GeneratedColumn<DateTime> get creadoEn =>
      $composableBuilder(column: $table.creadoEn, builder: (column) => column);

  GeneratedColumn<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => column,
  );
}

class $$TablaTramitesSecretariaTableTableManager
    extends
        RootTableManager<
          _$BaseDeDatos,
          $TablaTramitesSecretariaTable,
          TablaTramitesSecretariaData,
          $$TablaTramitesSecretariaTableFilterComposer,
          $$TablaTramitesSecretariaTableOrderingComposer,
          $$TablaTramitesSecretariaTableAnnotationComposer,
          $$TablaTramitesSecretariaTableCreateCompanionBuilder,
          $$TablaTramitesSecretariaTableUpdateCompanionBuilder,
          (
            TablaTramitesSecretariaData,
            BaseReferences<
              _$BaseDeDatos,
              $TablaTramitesSecretariaTable,
              TablaTramitesSecretariaData
            >,
          ),
          TablaTramitesSecretariaData,
          PrefetchHooks Function()
        > {
  $$TablaTramitesSecretariaTableTableManager(
    _$BaseDeDatos db,
    $TablaTramitesSecretariaTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TablaTramitesSecretariaTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$TablaTramitesSecretariaTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TablaTramitesSecretariaTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> tipoTramite = const Value.absent(),
                Value<String> categoria = const Value.absent(),
                Value<String> codigo = const Value.absent(),
                Value<String> asunto = const Value.absent(),
                Value<String> solicitante = const Value.absent(),
                Value<String?> cursoReferencia = const Value.absent(),
                Value<String> estado = const Value.absent(),
                Value<String> prioridad = const Value.absent(),
                Value<String> responsable = const Value.absent(),
                Value<String> observaciones = const Value.absent(),
                Value<DateTime?> fechaLimite = const Value.absent(),
                Value<String> rolDestino = const Value.absent(),
                Value<String> nivelDestino = const Value.absent(),
                Value<String> dependenciaDestino = const Value.absent(),
                Value<bool> activo = const Value.absent(),
                Value<DateTime> creadoEn = const Value.absent(),
                Value<DateTime> actualizadoEn = const Value.absent(),
              }) => TablaTramitesSecretariaCompanion(
                id: id,
                tipoTramite: tipoTramite,
                categoria: categoria,
                codigo: codigo,
                asunto: asunto,
                solicitante: solicitante,
                cursoReferencia: cursoReferencia,
                estado: estado,
                prioridad: prioridad,
                responsable: responsable,
                observaciones: observaciones,
                fechaLimite: fechaLimite,
                rolDestino: rolDestino,
                nivelDestino: nivelDestino,
                dependenciaDestino: dependenciaDestino,
                activo: activo,
                creadoEn: creadoEn,
                actualizadoEn: actualizadoEn,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String tipoTramite,
                required String categoria,
                required String codigo,
                required String asunto,
                required String solicitante,
                Value<String?> cursoReferencia = const Value.absent(),
                required String estado,
                required String prioridad,
                required String responsable,
                required String observaciones,
                Value<DateTime?> fechaLimite = const Value.absent(),
                required String rolDestino,
                required String nivelDestino,
                required String dependenciaDestino,
                Value<bool> activo = const Value.absent(),
                Value<DateTime> creadoEn = const Value.absent(),
                Value<DateTime> actualizadoEn = const Value.absent(),
              }) => TablaTramitesSecretariaCompanion.insert(
                id: id,
                tipoTramite: tipoTramite,
                categoria: categoria,
                codigo: codigo,
                asunto: asunto,
                solicitante: solicitante,
                cursoReferencia: cursoReferencia,
                estado: estado,
                prioridad: prioridad,
                responsable: responsable,
                observaciones: observaciones,
                fechaLimite: fechaLimite,
                rolDestino: rolDestino,
                nivelDestino: nivelDestino,
                dependenciaDestino: dependenciaDestino,
                activo: activo,
                creadoEn: creadoEn,
                actualizadoEn: actualizadoEn,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TablaTramitesSecretariaTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDeDatos,
      $TablaTramitesSecretariaTable,
      TablaTramitesSecretariaData,
      $$TablaTramitesSecretariaTableFilterComposer,
      $$TablaTramitesSecretariaTableOrderingComposer,
      $$TablaTramitesSecretariaTableAnnotationComposer,
      $$TablaTramitesSecretariaTableCreateCompanionBuilder,
      $$TablaTramitesSecretariaTableUpdateCompanionBuilder,
      (
        TablaTramitesSecretariaData,
        BaseReferences<
          _$BaseDeDatos,
          $TablaTramitesSecretariaTable,
          TablaTramitesSecretariaData
        >,
      ),
      TablaTramitesSecretariaData,
      PrefetchHooks Function()
    >;

class $BaseDeDatosManager {
  final _$BaseDeDatos _db;
  $BaseDeDatosManager(this._db);
  $$TablaInstitucionesTableTableManager get tablaInstituciones =>
      $$TablaInstitucionesTableTableManager(_db, _db.tablaInstituciones);
  $$TablaCarrerasTableTableManager get tablaCarreras =>
      $$TablaCarrerasTableTableManager(_db, _db.tablaCarreras);
  $$TablaAlumnosTableTableManager get tablaAlumnos =>
      $$TablaAlumnosTableTableManager(_db, _db.tablaAlumnos);
  $$TablaMateriasTableTableManager get tablaMaterias =>
      $$TablaMateriasTableTableManager(_db, _db.tablaMaterias);
  $$TablaCursosTableTableManager get tablaCursos =>
      $$TablaCursosTableTableManager(_db, _db.tablaCursos);
  $$TablaInscripcionesTableTableManager get tablaInscripciones =>
      $$TablaInscripcionesTableTableManager(_db, _db.tablaInscripciones);
  $$TablaClasesTableTableManager get tablaClases =>
      $$TablaClasesTableTableManager(_db, _db.tablaClases);
  $$TablaAsistenciasTableTableManager get tablaAsistencias =>
      $$TablaAsistenciasTableTableManager(_db, _db.tablaAsistencias);
  $$TablaAlertasGestionHistorialTableTableManager
  get tablaAlertasGestionHistorial =>
      $$TablaAlertasGestionHistorialTableTableManager(
        _db,
        _db.tablaAlertasGestionHistorial,
      );
  $$TablaAlertasGestionEstadoTableTableManager get tablaAlertasGestionEstado =>
      $$TablaAlertasGestionEstadoTableTableManager(
        _db,
        _db.tablaAlertasGestionEstado,
      );
  $$TablaIncidenciasTransversalesHistorialTableTableManager
  get tablaIncidenciasTransversalesHistorial =>
      $$TablaIncidenciasTransversalesHistorialTableTableManager(
        _db,
        _db.tablaIncidenciasTransversalesHistorial,
      );
  $$TablaLegajosDocumentalesTableTableManager get tablaLegajosDocumentales =>
      $$TablaLegajosDocumentalesTableTableManager(
        _db,
        _db.tablaLegajosDocumentales,
      );
  $$TablaNotasManualesTableTableManager get tablaNotasManuales =>
      $$TablaNotasManualesTableTableManager(_db, _db.tablaNotasManuales);
  $$TablaNovedadesPreceptoriaTableTableManager get tablaNovedadesPreceptoria =>
      $$TablaNovedadesPreceptoriaTableTableManager(
        _db,
        _db.tablaNovedadesPreceptoria,
      );
  $$TablaResponsablesGestionTableTableManager get tablaResponsablesGestion =>
      $$TablaResponsablesGestionTableTableManager(
        _db,
        _db.tablaResponsablesGestion,
      );
  $$TablaRecursosBibliotecaTableTableManager get tablaRecursosBiblioteca =>
      $$TablaRecursosBibliotecaTableTableManager(
        _db,
        _db.tablaRecursosBiblioteca,
      );
  $$TablaTramitesSecretariaTableTableManager get tablaTramitesSecretaria =>
      $$TablaTramitesSecretariaTableTableManager(
        _db,
        _db.tablaTramitesSecretaria,
      );
}
