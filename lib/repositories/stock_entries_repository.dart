import '../core/database/app_database.dart';
import '../services/stock_entries_service.dart';

/// Repository pour la gestion des entrées de stock (Domaine / Métier)
class StockEntriesRepository {
  final StockEntriesService service;

  StockEntriesRepository(this.service);

  Future<int> createStockEntryWithItems({
    required String uuid,
    int? supplierId,
    required int totalAmount,
    required int userId,
    required List<StockEntryItemsCompanion> items,
  }) {
    return service.createStockEntryWithItems(
      uuid: uuid,
      supplierId: supplierId,
      totalAmount: totalAmount,
      userId: userId,
      items: items,
    );
  }

  Future<StockEntry?> findById(int id) {
    return service.findById(id);
  }

  Future<List<StockEntryItem>> findItemsByStockEntryId(int stockEntryId) {
    return service.findItemsByStockEntryId(stockEntryId);
  }

  Stream<List<StockEntry>> watchStockEntries({int? supplierId, int? userId}) {
    return service.watchStockEntries(supplierId: supplierId, userId: userId);
  }

  Future<int> deleteStockEntry(int id) {
    return service.deleteStockEntry(id);
  }
}
