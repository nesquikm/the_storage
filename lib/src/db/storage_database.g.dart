// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage_database.dart';

// ignore_for_file: type=lint
class $StorageEntriesTable extends StorageEntries
    with TableInfo<$StorageEntriesTable, StorageEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StorageEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _domainMeta = const VerificationMeta('domain');
  @override
  late final GeneratedColumn<String> domain = GeneratedColumn<String>(
    'domain',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ivMeta = const VerificationMeta('iv');
  @override
  late final GeneratedColumn<String> iv = GeneratedColumn<String>(
    'iv',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [domain, key, value, iv];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'storage';
  @override
  VerificationContext validateIntegrity(
    Insertable<StorageEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('domain')) {
      context.handle(
        _domainMeta,
        domain.isAcceptableOrUnknown(data['domain']!, _domainMeta),
      );
    } else if (isInserting) {
      context.missing(_domainMeta);
    }
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('iv')) {
      context.handle(_ivMeta, iv.isAcceptableOrUnknown(data['iv']!, _ivMeta));
    } else if (isInserting) {
      context.missing(_ivMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {domain, key};
  @override
  StorageEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StorageEntry(
      domain: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}domain'],
      )!,
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      iv: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}iv'],
      )!,
    );
  }

  @override
  $StorageEntriesTable createAlias(String alias) {
    return $StorageEntriesTable(attachedDatabase, alias);
  }
}

class StorageEntry extends DataClass implements Insertable<StorageEntry> {
  /// Domain column.
  final String domain;

  /// Key column.
  final String key;

  /// Value column.
  final String value;

  /// Initialization vector column.
  final String iv;
  const StorageEntry({
    required this.domain,
    required this.key,
    required this.value,
    required this.iv,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['domain'] = Variable<String>(domain);
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['iv'] = Variable<String>(iv);
    return map;
  }

  StorageEntriesCompanion toCompanion(bool nullToAbsent) {
    return StorageEntriesCompanion(
      domain: Value(domain),
      key: Value(key),
      value: Value(value),
      iv: Value(iv),
    );
  }

  factory StorageEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StorageEntry(
      domain: serializer.fromJson<String>(json['domain']),
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      iv: serializer.fromJson<String>(json['iv']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'domain': serializer.toJson<String>(domain),
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'iv': serializer.toJson<String>(iv),
    };
  }

  StorageEntry copyWith({
    String? domain,
    String? key,
    String? value,
    String? iv,
  }) => StorageEntry(
    domain: domain ?? this.domain,
    key: key ?? this.key,
    value: value ?? this.value,
    iv: iv ?? this.iv,
  );
  StorageEntry copyWithCompanion(StorageEntriesCompanion data) {
    return StorageEntry(
      domain: data.domain.present ? data.domain.value : this.domain,
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      iv: data.iv.present ? data.iv.value : this.iv,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StorageEntry(')
          ..write('domain: $domain, ')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('iv: $iv')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(domain, key, value, iv);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StorageEntry &&
          other.domain == this.domain &&
          other.key == this.key &&
          other.value == this.value &&
          other.iv == this.iv);
}

class StorageEntriesCompanion extends UpdateCompanion<StorageEntry> {
  final Value<String> domain;
  final Value<String> key;
  final Value<String> value;
  final Value<String> iv;
  final Value<int> rowid;
  const StorageEntriesCompanion({
    this.domain = const Value.absent(),
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.iv = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StorageEntriesCompanion.insert({
    required String domain,
    required String key,
    required String value,
    required String iv,
    this.rowid = const Value.absent(),
  }) : domain = Value(domain),
       key = Value(key),
       value = Value(value),
       iv = Value(iv);
  static Insertable<StorageEntry> custom({
    Expression<String>? domain,
    Expression<String>? key,
    Expression<String>? value,
    Expression<String>? iv,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (domain != null) 'domain': domain,
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (iv != null) 'iv': iv,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StorageEntriesCompanion copyWith({
    Value<String>? domain,
    Value<String>? key,
    Value<String>? value,
    Value<String>? iv,
    Value<int>? rowid,
  }) {
    return StorageEntriesCompanion(
      domain: domain ?? this.domain,
      key: key ?? this.key,
      value: value ?? this.value,
      iv: iv ?? this.iv,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (domain.present) {
      map['domain'] = Variable<String>(domain.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (iv.present) {
      map['iv'] = Variable<String>(iv.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StorageEntriesCompanion(')
          ..write('domain: $domain, ')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('iv: $iv, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$StorageDatabase extends GeneratedDatabase {
  _$StorageDatabase(QueryExecutor e) : super(e);
  $StorageDatabaseManager get managers => $StorageDatabaseManager(this);
  late final $StorageEntriesTable storageEntries = $StorageEntriesTable(this);
  late final Index storageDomainIndex = Index(
    'storage_domain_index',
    'CREATE INDEX storage_domain_index ON storage (domain)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    storageEntries,
    storageDomainIndex,
  ];
}

typedef $$StorageEntriesTableCreateCompanionBuilder =
    StorageEntriesCompanion Function({
      required String domain,
      required String key,
      required String value,
      required String iv,
      Value<int> rowid,
    });
typedef $$StorageEntriesTableUpdateCompanionBuilder =
    StorageEntriesCompanion Function({
      Value<String> domain,
      Value<String> key,
      Value<String> value,
      Value<String> iv,
      Value<int> rowid,
    });

class $$StorageEntriesTableFilterComposer
    extends Composer<_$StorageDatabase, $StorageEntriesTable> {
  $$StorageEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iv => $composableBuilder(
    column: $table.iv,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StorageEntriesTableOrderingComposer
    extends Composer<_$StorageDatabase, $StorageEntriesTable> {
  $$StorageEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iv => $composableBuilder(
    column: $table.iv,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StorageEntriesTableAnnotationComposer
    extends Composer<_$StorageDatabase, $StorageEntriesTable> {
  $$StorageEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get domain =>
      $composableBuilder(column: $table.domain, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get iv =>
      $composableBuilder(column: $table.iv, builder: (column) => column);
}

class $$StorageEntriesTableTableManager
    extends
        RootTableManager<
          _$StorageDatabase,
          $StorageEntriesTable,
          StorageEntry,
          $$StorageEntriesTableFilterComposer,
          $$StorageEntriesTableOrderingComposer,
          $$StorageEntriesTableAnnotationComposer,
          $$StorageEntriesTableCreateCompanionBuilder,
          $$StorageEntriesTableUpdateCompanionBuilder,
          (
            StorageEntry,
            BaseReferences<
              _$StorageDatabase,
              $StorageEntriesTable,
              StorageEntry
            >,
          ),
          StorageEntry,
          PrefetchHooks Function()
        > {
  $$StorageEntriesTableTableManager(
    _$StorageDatabase db,
    $StorageEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StorageEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StorageEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StorageEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> domain = const Value.absent(),
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<String> iv = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StorageEntriesCompanion(
                domain: domain,
                key: key,
                value: value,
                iv: iv,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String domain,
                required String key,
                required String value,
                required String iv,
                Value<int> rowid = const Value.absent(),
              }) => StorageEntriesCompanion.insert(
                domain: domain,
                key: key,
                value: value,
                iv: iv,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StorageEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$StorageDatabase,
      $StorageEntriesTable,
      StorageEntry,
      $$StorageEntriesTableFilterComposer,
      $$StorageEntriesTableOrderingComposer,
      $$StorageEntriesTableAnnotationComposer,
      $$StorageEntriesTableCreateCompanionBuilder,
      $$StorageEntriesTableUpdateCompanionBuilder,
      (
        StorageEntry,
        BaseReferences<_$StorageDatabase, $StorageEntriesTable, StorageEntry>,
      ),
      StorageEntry,
      PrefetchHooks Function()
    >;

class $StorageDatabaseManager {
  final _$StorageDatabase _db;
  $StorageDatabaseManager(this._db);
  $$StorageEntriesTableTableManager get storageEntries =>
      $$StorageEntriesTableTableManager(_db, _db.storageEntries);
}
