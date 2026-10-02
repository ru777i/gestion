import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_stock/core/database/app_database.dart';
import 'package:gestion_stock/core/database/database_provider.dart';
import 'package:gestion_stock/services/sync_queue_service.dart';
import '../repositories/sync_queue_repository.dart';

final syncQueueServiceProvider = Provider<SyncQueueService>((ref) {
  return SyncQueueService(ref.watch(appDatabaseProvider));
});

final syncQueueRepositoryProvider = Provider<SyncQueueRepository>((ref) {
  return SyncQueueRepository(ref.watch(syncQueueServiceProvider));
});

final pendingSyncQueueItemsProvider = FutureProvider<List<SyncQueueData>>((ref) {
  final repository = ref.watch(syncQueueRepositoryProvider);
  return repository.getPendingSyncItems();
});
