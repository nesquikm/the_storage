import 'package:drift/drift.dart';

/// Drift table definition for the storage table.
@TableIndex(name: 'storage_domain_index', columns: {#domain})
class StorageEntries extends Table {
  /// Domain column.
  TextColumn get domain => text()();

  /// Key column.
  TextColumn get key => text()();

  /// Value column.
  TextColumn get value => text()();

  /// Initialization vector column.
  TextColumn get iv => text()();

  @override
  Set<Column<Object>> get primaryKey => {domain, key};

  @override
  String get tableName => 'storage';
}
