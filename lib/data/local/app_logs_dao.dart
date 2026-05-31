import 'package:drift/drift.dart';

import 'database.dart';

class AppLogsDao {
  AppLogsDao(this._database);

  static const maxLogs = 500;

  final AppDatabase _database;

  Stream<List<AppLog>> watchLogs({
    String search = '',
    String? category,
    bool newestFirst = true,
  }) {
    final normalizedSearch = search.trim().toLowerCase();
    final query = _database.select(_database.appLogs);

    if (category != null && category.trim().isNotEmpty) {
      query.where((table) => table.category.equals(category));
    }
    if (normalizedSearch.isNotEmpty) {
      query.where(
        (table) =>
            table.message.lower().contains(normalizedSearch) |
            table.operation.lower().contains(normalizedSearch) |
            table.category.lower().contains(normalizedSearch) |
            table.screenName.lower().contains(normalizedSearch),
      );
    }
    query.orderBy([
      (table) => OrderingTerm(
            expression: table.timestamp,
            mode: newestFirst ? OrderingMode.desc : OrderingMode.asc,
          ),
    ]);
    return query.watch();
  }

  Future<List<AppLog>> getLogs({
    String search = '',
    String? category,
    bool newestFirst = true,
  }) {
    final normalizedSearch = search.trim().toLowerCase();
    final query = _database.select(_database.appLogs);

    if (category != null && category.trim().isNotEmpty) {
      query.where((table) => table.category.equals(category));
    }
    if (normalizedSearch.isNotEmpty) {
      query.where(
        (table) =>
            table.message.lower().contains(normalizedSearch) |
            table.operation.lower().contains(normalizedSearch) |
            table.category.lower().contains(normalizedSearch) |
            table.screenName.lower().contains(normalizedSearch),
      );
    }
    query.orderBy([
      (table) => OrderingTerm(
            expression: table.timestamp,
            mode: newestFirst ? OrderingMode.desc : OrderingMode.asc,
          ),
    ]);
    return query.get();
  }

  Future<void> insertLog(AppLogsCompanion log) async {
    await _database.into(_database.appLogs).insertOnConflictUpdate(log);
    await pruneOldLogs();
  }

  Future<void> clearLogs() {
    return _database.delete(_database.appLogs).go();
  }

  Future<void> pruneOldLogs() async {
    await _database.customStatement(
      '''
      DELETE FROM app_logs
      WHERE id NOT IN (
        SELECT id
        FROM app_logs
        ORDER BY timestamp DESC
        LIMIT $maxLogs
      )
      ''',
    );
  }
}
