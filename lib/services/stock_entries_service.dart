import 'package:drift/drift.dart';

import '../core/database/app_database.dart';

/// Service gérant les entrées de stock et leurs éléments associés dans Drift.
class StockEntriesService {
  final AppDatabase database;

  StockEntriesService(this.database);

  Future<int> createStockEntryWithItems({
    required String uuid,
    int? supplierId,
    required int totalAmount,
    required int userId,
    required List<StockEntryItemsCompanion> items,
  }) async {
    return await database.transaction(() async {
      final now = DateTime.now().toIso8601String();

      final stockEntryId = await database.into(database.stockEntries).insert(
            StockEntriesCompanion.insert(
              uuid: uuid,
              supplierId: Value(supplierId),
              totalAmount: totalAmount,
              userId: userId,
              createdAt: now,
              updatedAt: now,
            ),
          );

      for (final item in items) {
        await database.into(database.stockEntryItems).insert(
              item.copyWith(stockEntryId: Value(stockEntryId)),
            );
      }

      return stockEntryId;
    });
  }

  Future<StockEntry?> findById(int id) async {
    return await (database.select(database.stockEntries)
          ..where((s) => s.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<StockEntryItem>> findItemsByStockEntryId(int stockEntryId) async {
    return await (database.select(database.stockEntryItems)
          ..where((item) => item.stockEntryId.equals(stockEntryId)))
        .get();
  }

  Stream<List<StockEntry>> watchStockEntries({int? supplierId, int? userId}) {
    final query = database.select(database.stockEntries);
    if (supplierId != null) {
      query.where((s) => s.supplierId.equals(supplierId));
    }
    if (userId != null) {
      query.where((s) => s.userId.equals(userId));
    }
    return query.watch();
  }

  Future<int> deleteStockEntry(int id) async {
    return await (database.delete(database.stockEntries)
          ..where((s) => s.id.equals(id)))
        .go();
  }
}
