import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:the_storage/src/db/database_path.dart';
import 'package:the_storage/src/db/storage_table.dart';

part 'storage_database.g.dart';

/// Drift database for the storage package.
@DriftDatabase(tables: [StorageEntries])
class StorageDatabase extends _$StorageDatabase {
  /// Creates a database with the default name.
  StorageDatabase([QueryExecutor? executor])
    : super(executor ?? _openConnection('storage.db'));

  /// Creates a database with a custom name.
  StorageDatabase.withName(String name, [QueryExecutor? executor])
    : super(executor ?? _openConnection(name));

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection(String name) {
    return driftDatabase(
      name: name,
      native: nativeDatabaseOptions(name),
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    );
  }
}
