
import '../core/database/app_database.dart';
import '../repositories/stock_entry_items_repository.dart';

class StockEntryItemsService {
  final StockEntryItemsRepository repository;

  StockEntryItemsService(this.repository);

  /// Ajouter un produit à une entrée de stock
  Future<int> addItem({
    required int stockEntryId,
    required int productId,
    required int quantity,
    required int unitCost,
  }) {
    if (quantity <= 0) {
      throw ArgumentError(
        'La quantité doit être supérieure à 0.',
      );
    }

    if (unitCost < 0) {
      throw ArgumentError(
        'Le coût unitaire ne peut pas être négatif.',
      );
    }

    return repository.create(
      stockEntryId: stockEntryId,
      productId: productId,
      quantity: quantity,
      unitCost: unitCost,
    );
  }

  /// Récupérer une ligne
  Future<StockEntryItem?> getItem(int id) {
    return repository.findById(id);
  }

  /// Récupérer toutes les lignes d'une entrée
  Future<List<StockEntryItem>> getItemsByStockEntry(
      int stockEntryId,
      ) {
    return repository.findByStockEntryId(stockEntryId);
  }

  /// Récupérer les entrées concernant un produit
  Future<List<StockEntryItem>> getItemsByProduct(
      int productId,
      ) {
    return repository.findByProductId(productId);
  }

  /// Modifier une ligne
  Future<bool> updateItem({
    required int id,
    required int quantity,
    required int unitCost,
  }) {
    if (quantity <= 0) {
      throw ArgumentError(
        'La quantité doit être supérieure à 0.',
      );
    }

    if (unitCost < 0) {
      throw ArgumentError(
        'Le coût unitaire ne peut pas être négatif.',
      );
    }

    return repository.update(
      id: id,
      quantity: quantity,
      unitCost: unitCost,
    );
  }

  /// Supprimer une ligne
  Future<bool> deleteItem(int id) {
    return repository.delete(id);
  }

  /// Supprimer toutes les lignes d'une entrée
  Future<int> deleteItemsByStockEntry(int stockEntryId) {
    return repository.deleteByStockEntryId(stockEntryId);
  }

  /// Total de l'entrée de stock
  Future<int> getStockEntryTotal(int stockEntryId) {
    return repository.getStockEntryTotal(stockEntryId);
  }
}