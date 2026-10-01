import 'package:drift/drift.dart';

import '../core/database/app_database.dart';

/// Service gérant la file de synchronisation hors-ligne dans Drift.
class SyncQueueService {
  final AppDatabase database;

  SyncQueueService(this.database);

  Future<int> enqueueItem({
    required String tableNam,
    required String recordUuid,
    required String operation,
    required String payload,
  }) async {
    final now = DateTime.now().toIso8601String();

    return await database.into(database.syncQueue).insert(
          SyncQueueCompanion.insert(
            tableNam: tableNam,
            recordUuid: recordUuid,
            operation: operation,
            payload: payload,
            createdAt: now,
          ),
        );
  }

  Future<List<SyncQueueData>> getPendingSyncItems() async {
    return await (database.select(database.syncQueue)
          ..where((sq) => sq.syncedAt.isNull()))
        .get();
  }

  Future<bool> markAsSynced(int id) async {
    final now = DateTime.now().toIso8601String();

    final updated = await (database.update(database.syncQueue)
          ..where((sq) => sq.id.equals(id)))
        .write(
      SyncQueueCompanion(
        syncedAt: Value(now),
      ),
    );

    return updated > 0;
  }
}
