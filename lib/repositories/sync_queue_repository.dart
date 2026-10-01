import '../core/database/app_database.dart';
import '../services/sync_queue_service.dart';

/// Repository pour la gestion de la file de synchronisation (Domaine / Métier)
class SyncQueueRepository {
  final SyncQueueService service;

  SyncQueueRepository(this.service);

  Future<int> enqueueItem({
    required String tableNam,
    required String recordUuid,
    required String operation,
    required String payload,
  }) {
    return service.enqueueItem(
      tableNam: tableNam,
      recordUuid: recordUuid,
      operation: operation,
      payload: payload,
    );
  }

  Future<List<SyncQueueData>> getPendingSyncItems() {
    return service.getPendingSyncItems();
  }

  Future<bool> markAsSynced(int id) {
    return service.markAsSynced(id);
  }
}
