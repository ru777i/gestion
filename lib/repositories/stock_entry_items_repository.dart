import 'package:drift/drift.dart';
import '../core/database/app_database.dart';


class StockEntryItemsRepository {
  final AppDatabase db;

  StockEntryItemsRepository(this.db);

  /// Ajouter une ligne d'entrée de stock
  Future<int> create({
    required int stockEntryId,
    required int productId,
    required int quantity,
    required int unitCost,
  }) async {
    final subtotal = quantity * unitCost;

    return db.into(db.stockEntryItems).insert(
      StockEntryItemsCompanion.insert(
        stockEntryId: stockEntryId,
        productId: productId,
        quantity: quantity,
        unitCost: unitCost,
        subtotal: subtotal,
      ),
    );
  }

  /// Trouver une ligne par son ID
  Future<StockEntryItem?> findById(int id) {
    return (db.select(db.stockEntryItems)
      ..where((table) => table.id.equals(id)))
        .getSingleOrNull();
  }

  /// Récupérer les lignes d'une entrée de stock
  Future<List<StockEntryItem>> findByStockEntryId(
      int stockEntryId,
      ) {
    return (db.select(db.stockEntryItems)
      ..where(
            (table) => table.stockEntryId.equals(stockEntryId),
      ))
        .get();
  }

  /// Récupérer les lignes liées à un produit
  Future<List<StockEntryItem>> findByProductId(
      int productId,
      ) {
    return (db.select(db.stockEntryItems)
      ..where(
            (table) => table.productId.equals(productId),
      ))
        .get();
  }

  /// Modifier une ligne
  Future<bool> update({
    required int id,
    required int quantity,
    required int unitCost,
  }) async {
    final subtotal = quantity * unitCost;

    final count = await (db.update(db.stockEntryItems)
      ..where((table) => table.id.equals(id)))
        .write(
      StockEntryItemsCompanion(
        quantity: Value(quantity),
        unitCost: Value(unitCost),
        subtotal: Value(subtotal),
      ),
    );

    return count > 0;
  }

  /// Supprimer une ligne
  Future<bool> delete(int id) async {
    final count = await (db.delete(db.stockEntryItems)
      ..where((table) => table.id.equals(id)))
        .go();

    return count > 0;
  }

  /// Supprimer toutes les lignes d'une entrée de stock
  Future<int> deleteByStockEntryId(int stockEntryId) {
    return (db.delete(db.stockEntryItems)
      ..where(
            (table) => table.stockEntryId.equals(stockEntryId),
      ))
        .go();
  }

  /// Calculer le total d'une entrée de stock
  Future<int> getStockEntryTotal(int stockEntryId) async {
    final items = await findByStockEntryId(stockEntryId);

    return items.fold<int>(
      0,
          (total, item) => total + item.subtotal,
    );
  }
}