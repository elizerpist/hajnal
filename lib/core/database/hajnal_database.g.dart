// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hajnal_database.dart';

// ignore_for_file: type=lint
class $RecoveryPeriodsTable extends RecoveryPeriods
    with TableInfo<$RecoveryPeriodsTable, RecoveryPeriod> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecoveryPeriodsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _startLocalDateMeta = const VerificationMeta(
    'startLocalDate',
  );
  @override
  late final GeneratedColumn<String> startLocalDate = GeneratedColumn<String>(
    'start_local_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta(
    'createdAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> createdAtUtc = GeneratedColumn<DateTime>(
    'created_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _closedAtUtcMeta = const VerificationMeta(
    'closedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> closedAtUtc = GeneratedColumn<DateTime>(
    'closed_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    startLocalDate,
    createdAtUtc,
    closedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recovery_periods';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecoveryPeriod> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('start_local_date')) {
      context.handle(
        _startLocalDateMeta,
        startLocalDate.isAcceptableOrUnknown(
          data['start_local_date']!,
          _startLocalDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startLocalDateMeta);
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
        _createdAtUtcMeta,
        createdAtUtc.isAcceptableOrUnknown(
          data['created_at_utc']!,
          _createdAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    if (data.containsKey('closed_at_utc')) {
      context.handle(
        _closedAtUtcMeta,
        closedAtUtc.isAcceptableOrUnknown(
          data['closed_at_utc']!,
          _closedAtUtcMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecoveryPeriod map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecoveryPeriod(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      startLocalDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_local_date'],
      )!,
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at_utc'],
      )!,
      closedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}closed_at_utc'],
      ),
    );
  }

  @override
  $RecoveryPeriodsTable createAlias(String alias) {
    return $RecoveryPeriodsTable(attachedDatabase, alias);
  }
}

class RecoveryPeriod extends DataClass implements Insertable<RecoveryPeriod> {
  final int id;
  final String startLocalDate;
  final DateTime createdAtUtc;
  final DateTime? closedAtUtc;
  const RecoveryPeriod({
    required this.id,
    required this.startLocalDate,
    required this.createdAtUtc,
    this.closedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['start_local_date'] = Variable<String>(startLocalDate);
    map['created_at_utc'] = Variable<DateTime>(createdAtUtc);
    if (!nullToAbsent || closedAtUtc != null) {
      map['closed_at_utc'] = Variable<DateTime>(closedAtUtc);
    }
    return map;
  }

  RecoveryPeriodsCompanion toCompanion(bool nullToAbsent) {
    return RecoveryPeriodsCompanion(
      id: Value(id),
      startLocalDate: Value(startLocalDate),
      createdAtUtc: Value(createdAtUtc),
      closedAtUtc: closedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(closedAtUtc),
    );
  }

  factory RecoveryPeriod.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecoveryPeriod(
      id: serializer.fromJson<int>(json['id']),
      startLocalDate: serializer.fromJson<String>(json['startLocalDate']),
      createdAtUtc: serializer.fromJson<DateTime>(json['createdAtUtc']),
      closedAtUtc: serializer.fromJson<DateTime?>(json['closedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'startLocalDate': serializer.toJson<String>(startLocalDate),
      'createdAtUtc': serializer.toJson<DateTime>(createdAtUtc),
      'closedAtUtc': serializer.toJson<DateTime?>(closedAtUtc),
    };
  }

  RecoveryPeriod copyWith({
    int? id,
    String? startLocalDate,
    DateTime? createdAtUtc,
    Value<DateTime?> closedAtUtc = const Value.absent(),
  }) => RecoveryPeriod(
    id: id ?? this.id,
    startLocalDate: startLocalDate ?? this.startLocalDate,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    closedAtUtc: closedAtUtc.present ? closedAtUtc.value : this.closedAtUtc,
  );
  RecoveryPeriod copyWithCompanion(RecoveryPeriodsCompanion data) {
    return RecoveryPeriod(
      id: data.id.present ? data.id.value : this.id,
      startLocalDate: data.startLocalDate.present
          ? data.startLocalDate.value
          : this.startLocalDate,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      closedAtUtc: data.closedAtUtc.present
          ? data.closedAtUtc.value
          : this.closedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecoveryPeriod(')
          ..write('id: $id, ')
          ..write('startLocalDate: $startLocalDate, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('closedAtUtc: $closedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, startLocalDate, createdAtUtc, closedAtUtc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecoveryPeriod &&
          other.id == this.id &&
          other.startLocalDate == this.startLocalDate &&
          other.createdAtUtc == this.createdAtUtc &&
          other.closedAtUtc == this.closedAtUtc);
}

class RecoveryPeriodsCompanion extends UpdateCompanion<RecoveryPeriod> {
  final Value<int> id;
  final Value<String> startLocalDate;
  final Value<DateTime> createdAtUtc;
  final Value<DateTime?> closedAtUtc;
  const RecoveryPeriodsCompanion({
    this.id = const Value.absent(),
    this.startLocalDate = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.closedAtUtc = const Value.absent(),
  });
  RecoveryPeriodsCompanion.insert({
    this.id = const Value.absent(),
    required String startLocalDate,
    required DateTime createdAtUtc,
    this.closedAtUtc = const Value.absent(),
  }) : startLocalDate = Value(startLocalDate),
       createdAtUtc = Value(createdAtUtc);
  static Insertable<RecoveryPeriod> custom({
    Expression<int>? id,
    Expression<String>? startLocalDate,
    Expression<DateTime>? createdAtUtc,
    Expression<DateTime>? closedAtUtc,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startLocalDate != null) 'start_local_date': startLocalDate,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (closedAtUtc != null) 'closed_at_utc': closedAtUtc,
    });
  }

  RecoveryPeriodsCompanion copyWith({
    Value<int>? id,
    Value<String>? startLocalDate,
    Value<DateTime>? createdAtUtc,
    Value<DateTime?>? closedAtUtc,
  }) {
    return RecoveryPeriodsCompanion(
      id: id ?? this.id,
      startLocalDate: startLocalDate ?? this.startLocalDate,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      closedAtUtc: closedAtUtc ?? this.closedAtUtc,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (startLocalDate.present) {
      map['start_local_date'] = Variable<String>(startLocalDate.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<DateTime>(createdAtUtc.value);
    }
    if (closedAtUtc.present) {
      map['closed_at_utc'] = Variable<DateTime>(closedAtUtc.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecoveryPeriodsCompanion(')
          ..write('id: $id, ')
          ..write('startLocalDate: $startLocalDate, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('closedAtUtc: $closedAtUtc')
          ..write(')'))
        .toString();
  }
}

class $ArtworkOverridesTable extends ArtworkOverrides
    with TableInfo<$ArtworkOverridesTable, ArtworkOverride> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ArtworkOverridesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filenameMeta = const VerificationMeta(
    'filename',
  );
  @override
  late final GeneratedColumn<String> filename = GeneratedColumn<String>(
    'filename',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<String> revision = GeneratedColumn<String>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [role, filename, revision];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'artwork_overrides';
  @override
  VerificationContext validateIntegrity(
    Insertable<ArtworkOverride> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('filename')) {
      context.handle(
        _filenameMeta,
        filename.isAcceptableOrUnknown(data['filename']!, _filenameMeta),
      );
    } else if (isInserting) {
      context.missing(_filenameMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {role};
  @override
  ArtworkOverride map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ArtworkOverride(
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      filename: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}filename'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}revision'],
      )!,
    );
  }

  @override
  $ArtworkOverridesTable createAlias(String alias) {
    return $ArtworkOverridesTable(attachedDatabase, alias);
  }
}

class ArtworkOverride extends DataClass implements Insertable<ArtworkOverride> {
  final String role;
  final String filename;
  final String revision;
  const ArtworkOverride({
    required this.role,
    required this.filename,
    required this.revision,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['role'] = Variable<String>(role);
    map['filename'] = Variable<String>(filename);
    map['revision'] = Variable<String>(revision);
    return map;
  }

  ArtworkOverridesCompanion toCompanion(bool nullToAbsent) {
    return ArtworkOverridesCompanion(
      role: Value(role),
      filename: Value(filename),
      revision: Value(revision),
    );
  }

  factory ArtworkOverride.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ArtworkOverride(
      role: serializer.fromJson<String>(json['role']),
      filename: serializer.fromJson<String>(json['filename']),
      revision: serializer.fromJson<String>(json['revision']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'role': serializer.toJson<String>(role),
      'filename': serializer.toJson<String>(filename),
      'revision': serializer.toJson<String>(revision),
    };
  }

  ArtworkOverride copyWith({
    String? role,
    String? filename,
    String? revision,
  }) => ArtworkOverride(
    role: role ?? this.role,
    filename: filename ?? this.filename,
    revision: revision ?? this.revision,
  );
  ArtworkOverride copyWithCompanion(ArtworkOverridesCompanion data) {
    return ArtworkOverride(
      role: data.role.present ? data.role.value : this.role,
      filename: data.filename.present ? data.filename.value : this.filename,
      revision: data.revision.present ? data.revision.value : this.revision,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ArtworkOverride(')
          ..write('role: $role, ')
          ..write('filename: $filename, ')
          ..write('revision: $revision')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(role, filename, revision);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ArtworkOverride &&
          other.role == this.role &&
          other.filename == this.filename &&
          other.revision == this.revision);
}

class ArtworkOverridesCompanion extends UpdateCompanion<ArtworkOverride> {
  final Value<String> role;
  final Value<String> filename;
  final Value<String> revision;
  final Value<int> rowid;
  const ArtworkOverridesCompanion({
    this.role = const Value.absent(),
    this.filename = const Value.absent(),
    this.revision = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ArtworkOverridesCompanion.insert({
    required String role,
    required String filename,
    required String revision,
    this.rowid = const Value.absent(),
  }) : role = Value(role),
       filename = Value(filename),
       revision = Value(revision);
  static Insertable<ArtworkOverride> custom({
    Expression<String>? role,
    Expression<String>? filename,
    Expression<String>? revision,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (role != null) 'role': role,
      if (filename != null) 'filename': filename,
      if (revision != null) 'revision': revision,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ArtworkOverridesCompanion copyWith({
    Value<String>? role,
    Value<String>? filename,
    Value<String>? revision,
    Value<int>? rowid,
  }) {
    return ArtworkOverridesCompanion(
      role: role ?? this.role,
      filename: filename ?? this.filename,
      revision: revision ?? this.revision,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (filename.present) {
      map['filename'] = Variable<String>(filename.value);
    }
    if (revision.present) {
      map['revision'] = Variable<String>(revision.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ArtworkOverridesCompanion(')
          ..write('role: $role, ')
          ..write('filename: $filename, ')
          ..write('revision: $revision, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$HajnalDatabase extends GeneratedDatabase {
  _$HajnalDatabase(QueryExecutor e) : super(e);
  $HajnalDatabaseManager get managers => $HajnalDatabaseManager(this);
  late final $RecoveryPeriodsTable recoveryPeriods = $RecoveryPeriodsTable(
    this,
  );
  late final $ArtworkOverridesTable artworkOverrides = $ArtworkOverridesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    recoveryPeriods,
    artworkOverrides,
  ];
}

typedef $$RecoveryPeriodsTableCreateCompanionBuilder =
    RecoveryPeriodsCompanion Function({
      Value<int> id,
      required String startLocalDate,
      required DateTime createdAtUtc,
      Value<DateTime?> closedAtUtc,
    });
typedef $$RecoveryPeriodsTableUpdateCompanionBuilder =
    RecoveryPeriodsCompanion Function({
      Value<int> id,
      Value<String> startLocalDate,
      Value<DateTime> createdAtUtc,
      Value<DateTime?> closedAtUtc,
    });

class $$RecoveryPeriodsTableFilterComposer
    extends Composer<_$HajnalDatabase, $RecoveryPeriodsTable> {
  $$RecoveryPeriodsTableFilterComposer({
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

  ColumnFilters<String> get startLocalDate => $composableBuilder(
    column: $table.startLocalDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get closedAtUtc => $composableBuilder(
    column: $table.closedAtUtc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecoveryPeriodsTableOrderingComposer
    extends Composer<_$HajnalDatabase, $RecoveryPeriodsTable> {
  $$RecoveryPeriodsTableOrderingComposer({
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

  ColumnOrderings<String> get startLocalDate => $composableBuilder(
    column: $table.startLocalDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get closedAtUtc => $composableBuilder(
    column: $table.closedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecoveryPeriodsTableAnnotationComposer
    extends Composer<_$HajnalDatabase, $RecoveryPeriodsTable> {
  $$RecoveryPeriodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get startLocalDate => $composableBuilder(
    column: $table.startLocalDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get closedAtUtc => $composableBuilder(
    column: $table.closedAtUtc,
    builder: (column) => column,
  );
}

class $$RecoveryPeriodsTableTableManager
    extends
        RootTableManager<
          _$HajnalDatabase,
          $RecoveryPeriodsTable,
          RecoveryPeriod,
          $$RecoveryPeriodsTableFilterComposer,
          $$RecoveryPeriodsTableOrderingComposer,
          $$RecoveryPeriodsTableAnnotationComposer,
          $$RecoveryPeriodsTableCreateCompanionBuilder,
          $$RecoveryPeriodsTableUpdateCompanionBuilder,
          (
            RecoveryPeriod,
            BaseReferences<
              _$HajnalDatabase,
              $RecoveryPeriodsTable,
              RecoveryPeriod
            >,
          ),
          RecoveryPeriod,
          PrefetchHooks Function()
        > {
  $$RecoveryPeriodsTableTableManager(
    _$HajnalDatabase db,
    $RecoveryPeriodsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecoveryPeriodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecoveryPeriodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecoveryPeriodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> startLocalDate = const Value.absent(),
                Value<DateTime> createdAtUtc = const Value.absent(),
                Value<DateTime?> closedAtUtc = const Value.absent(),
              }) => RecoveryPeriodsCompanion(
                id: id,
                startLocalDate: startLocalDate,
                createdAtUtc: createdAtUtc,
                closedAtUtc: closedAtUtc,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String startLocalDate,
                required DateTime createdAtUtc,
                Value<DateTime?> closedAtUtc = const Value.absent(),
              }) => RecoveryPeriodsCompanion.insert(
                id: id,
                startLocalDate: startLocalDate,
                createdAtUtc: createdAtUtc,
                closedAtUtc: closedAtUtc,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecoveryPeriodsTableProcessedTableManager =
    ProcessedTableManager<
      _$HajnalDatabase,
      $RecoveryPeriodsTable,
      RecoveryPeriod,
      $$RecoveryPeriodsTableFilterComposer,
      $$RecoveryPeriodsTableOrderingComposer,
      $$RecoveryPeriodsTableAnnotationComposer,
      $$RecoveryPeriodsTableCreateCompanionBuilder,
      $$RecoveryPeriodsTableUpdateCompanionBuilder,
      (
        RecoveryPeriod,
        BaseReferences<_$HajnalDatabase, $RecoveryPeriodsTable, RecoveryPeriod>,
      ),
      RecoveryPeriod,
      PrefetchHooks Function()
    >;
typedef $$ArtworkOverridesTableCreateCompanionBuilder =
    ArtworkOverridesCompanion Function({
      required String role,
      required String filename,
      required String revision,
      Value<int> rowid,
    });
typedef $$ArtworkOverridesTableUpdateCompanionBuilder =
    ArtworkOverridesCompanion Function({
      Value<String> role,
      Value<String> filename,
      Value<String> revision,
      Value<int> rowid,
    });

class $$ArtworkOverridesTableFilterComposer
    extends Composer<_$HajnalDatabase, $ArtworkOverridesTable> {
  $$ArtworkOverridesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filename => $composableBuilder(
    column: $table.filename,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ArtworkOverridesTableOrderingComposer
    extends Composer<_$HajnalDatabase, $ArtworkOverridesTable> {
  $$ArtworkOverridesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filename => $composableBuilder(
    column: $table.filename,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ArtworkOverridesTableAnnotationComposer
    extends Composer<_$HajnalDatabase, $ArtworkOverridesTable> {
  $$ArtworkOverridesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get filename =>
      $composableBuilder(column: $table.filename, builder: (column) => column);

  GeneratedColumn<String> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);
}

class $$ArtworkOverridesTableTableManager
    extends
        RootTableManager<
          _$HajnalDatabase,
          $ArtworkOverridesTable,
          ArtworkOverride,
          $$ArtworkOverridesTableFilterComposer,
          $$ArtworkOverridesTableOrderingComposer,
          $$ArtworkOverridesTableAnnotationComposer,
          $$ArtworkOverridesTableCreateCompanionBuilder,
          $$ArtworkOverridesTableUpdateCompanionBuilder,
          (
            ArtworkOverride,
            BaseReferences<
              _$HajnalDatabase,
              $ArtworkOverridesTable,
              ArtworkOverride
            >,
          ),
          ArtworkOverride,
          PrefetchHooks Function()
        > {
  $$ArtworkOverridesTableTableManager(
    _$HajnalDatabase db,
    $ArtworkOverridesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ArtworkOverridesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ArtworkOverridesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ArtworkOverridesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> role = const Value.absent(),
                Value<String> filename = const Value.absent(),
                Value<String> revision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ArtworkOverridesCompanion(
                role: role,
                filename: filename,
                revision: revision,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String role,
                required String filename,
                required String revision,
                Value<int> rowid = const Value.absent(),
              }) => ArtworkOverridesCompanion.insert(
                role: role,
                filename: filename,
                revision: revision,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ArtworkOverridesTableProcessedTableManager =
    ProcessedTableManager<
      _$HajnalDatabase,
      $ArtworkOverridesTable,
      ArtworkOverride,
      $$ArtworkOverridesTableFilterComposer,
      $$ArtworkOverridesTableOrderingComposer,
      $$ArtworkOverridesTableAnnotationComposer,
      $$ArtworkOverridesTableCreateCompanionBuilder,
      $$ArtworkOverridesTableUpdateCompanionBuilder,
      (
        ArtworkOverride,
        BaseReferences<
          _$HajnalDatabase,
          $ArtworkOverridesTable,
          ArtworkOverride
        >,
      ),
      ArtworkOverride,
      PrefetchHooks Function()
    >;

class $HajnalDatabaseManager {
  final _$HajnalDatabase _db;
  $HajnalDatabaseManager(this._db);
  $$RecoveryPeriodsTableTableManager get recoveryPeriods =>
      $$RecoveryPeriodsTableTableManager(_db, _db.recoveryPeriods);
  $$ArtworkOverridesTableTableManager get artworkOverrides =>
      $$ArtworkOverridesTableTableManager(_db, _db.artworkOverrides);
}
