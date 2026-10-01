import 'package:drift/drift.dart';
import '../core/database/app_database.dart';
class SaleItemsRepository {
  final AppDatabase db;

  SaleItemsRepository(this.db);

  /// Ajouter une ligne de vente
  Future<int> create({
    required int saleId,
    required int productId,
    required int quantity,
    required int unitPrice,
  }) async {
    final subtotal = quantity * unitPrice;

    return db.into(db.saleItems).insert(
      SaleItemsCompanion.insert(
        saleId: saleId,
        productId: productId,
        quantity: quantity,
        unitPrice: unitPrice,
        subtotal: subtotal,
      ),
    );
  }

  /// Récupérer une ligne par son ID
  Future<SaleItem?> findById(int id) async {
    return (db.select(db.saleItems)
      ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  /// Récupérer toutes les lignes d'une vente
  Future<List<SaleItem>> findBySaleId(int saleId) {
    return (db.select(db.saleItems)
      ..where((tbl) => tbl.saleId.equals(saleId)))
        .get();
  }

  /// Récupérer toutes les lignes d'un produit
  Future<List<SaleItem>> findByProductId(int productId) {
    return (db.select(db.saleItems)
      ..where((tbl) => tbl.productId.equals(productId)))
        .get();
  }

  /// Modifier une ligne de vente
  Future<bool> update({
    required int id,
    required int quantity,
    required int unitPrice,
  }) async {
    final subtotal = quantity * unitPrice;

    return (db.update(db.saleItems)
      ..where((tbl) => tbl.id.equals(id)))
        .write(
      SaleItemsCompanion(
        quantity: Value(quantity),
        unitPrice: Value(unitPrice),
        subtotal: Value(subtotal),
      ),
    )
        .then((count) => count > 0);
  }

  /// Supprimer une ligne
  Future<int> delete(int id) {
    return (db.delete(db.saleItems)
      ..where((tbl) => tbl.id.equals(id)))
        .go();
  }

  /// Supprimer toutes les lignes d'une vente
  Future<int> deleteBySaleId(int saleId) {
    return (db.delete(db.saleItems)
      ..where((tbl) => tbl.saleId.equals(saleId)))
        .go();
  }

  /// Calculer le total d'une vente
  Future<int> getSaleTotal(int saleId) async {
    final items = await findBySaleId(saleId);

    return items.fold<int>(
      0,
          (total, item) => total + item.subtotal,
    );
  }


}