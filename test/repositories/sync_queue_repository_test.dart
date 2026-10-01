import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_stock/core/database/app_database.dart';
import 'package:gestion_stock/repositories/sync_queue_repository.dart';
import 'package:gestion_stock/services/sync_queue_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late SyncQueueService service;
  late SyncQueueRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    service = SyncQueueService(database);
    repository = SyncQueueRepository(service);
  });

  tearDown(() async {
    await database.close();
  });

  test('Ajouter, récupérer et marquer comme synchronisé', () async {
    final id = await repository.enqueueItem(
      tableNam: 'products',
      recordUuid: 'prod-uuid-xyz',
      operation: 'insert',
      payload: '{"name":"Test"}',
    );

    expect(id, greaterThan(0));

    final pending = await repository.getPendingSyncItems();
    expect(pending.length, 1);
    expect(pending.first.recordUuid, 'prod-uuid-xyz');

    final marked = await repository.markAsSynced(id);
    expect(marked, isTrue);

    final remainingPending = await repository.getPendingSyncItems();
    expect(remainingPending, isEmpty);
  });
}
