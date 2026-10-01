import '../repositories/sale_items_repository.dart';
import '../core/database/app_database.dart';


class SaleItemsService {
  final SaleItemsRepository repository;

  SaleItemsService(this.repository);

  Future<int> addItem({
    required int saleId,
    required int productId,
    required int quantity,
    required int unitPrice,
  }) async {
    if (quantity <= 0) {
      throw ArgumentError('La quantité doit être supérieure à 0.');
    }

    if (unitPrice < 0) {
      throw ArgumentError('Le prix unitaire ne peut pas être négatif.');
    }

    return repository.create(
      saleId: saleId,
      productId: productId,
      quantity: quantity,
      unitPrice: unitPrice,
    );
  }

  Future<SaleItem?> getItem(int id) {
    return repository.findById(id);
  }

  Future<List<SaleItem>> getItemsBySale(int saleId) {
    return repository.findBySaleId(saleId);
  }

  Future<List<SaleItem>> getItemsByProduct(int productId) {
    return repository.findByProductId(productId);
  }

  Future<bool> updateItem({
    required int id,
    required int quantity,
    required int unitPrice,
  }) {
    if (quantity <= 0) {
      throw ArgumentError('La quantité doit être supérieure à 0.');
    }

    if (unitPrice < 0) {
      throw ArgumentError('Le prix unitaire ne peut pas être négatif.');
    }

    return repository.update(
      id: id,
      quantity: quantity,
      unitPrice: unitPrice,
    );
  }

  Future<int> deleteItem(int id) {
    return repository.delete(id);
  }

  Future<int> deleteItemsBySale(int saleId) {
    return repository.deleteBySaleId(saleId);
  }

  Future<int> getSaleTotal(int saleId) {
    return repository.getSaleTotal(saleId);
  }
}