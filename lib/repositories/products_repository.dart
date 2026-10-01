import '../core/database/app_database.dart';
import '../services/products_service.dart';

/// Repository de la couche Domaine/Métier gérant les produits.
/// Il dépend du ProductsService pour l'accès aux données.
class ProductsRepository {
  final ProductsService service;

  ProductsRepository(this.service);

  Future<int> createProduct({
    required String name,
    required String uuid,
    int? categoryId,
    String? barcode,
    String? photoPath,
    required int purchasePrice,
    required int salePrice,
    required int stockQuantity,
    required int alertThreshold,
  }) {
    return service.createProduct(
      name: name,
      uuid: uuid,
      categoryId: categoryId,
      barcode: barcode,
      photoPath: photoPath,
      purchasePrice: purchasePrice,
      salePrice: salePrice,
      stockQuantity: stockQuantity,
      alertThreshold: alertThreshold,
    );
  }

  Future<List<Product>> filterProducts({
    String? searchQuery,
    String? name,
    String? uuid,
    int? categoryId,
    String? barcode,
    String? photoPath,
    int? purchasePrice,
    int? salePrice,
    int? stockQuantity,
    int? alertThreshold,
  }) {
    return service.filterProducts(
      searchQuery: searchQuery,
      name: name,
      uuid: uuid,
      categoryId: categoryId,
      barcode: barcode,
      photoPath: photoPath,
      purchasePrice: purchasePrice,
      salePrice: salePrice,
      stockQuantity: stockQuantity,
      alertThreshold: alertThreshold,
    );
  }

  Stream<List<Product>> watchFilteredProducts({
    String? searchQuery,
    String? name,
    String? uuid,
    DateTime? created_at,
    DateTime? updated_at,
    bool? ascending,
    int? categoryId,
    String? barcode,
    String? photoPath,
    int? purchasePrice,
    int? salePrice,
    int? isActive,
    int? stockQuantity,
    int? alertThreshold,
  }) {
    return service.watchFilteredProducts(
      searchQuery: searchQuery,
      name: name,
      created_at: created_at,
      updated_at: updated_at,
      ascending: ascending,
      uuid: uuid,
      categoryId: categoryId,
      barcode: barcode,
      photoPath: photoPath,
      purchasePrice: purchasePrice,
      salePrice: salePrice,
      stockQuantity: stockQuantity,
      alertThreshold: alertThreshold,
    );
  }

  Future<Product?> findById(int id) {
    return service.findById(id);
  }

  Future<bool> updateProduct({
    required int id,
    String? name,
    String? uuid,
    int? categoryId,
    String? barcode,
    String? photoPath,
    int? purchasePrice,
    int? salePrice,
    int? stockQuantity,
    int? alertThreshold,
    int? isActive,
  }) {
    return service.updateProduct(
      id: id,
      name: name,
      uuid: uuid,
      categoryId: categoryId,
      barcode: barcode,
      photoPath: photoPath,
      purchasePrice: purchasePrice,
      salePrice: salePrice,
      stockQuantity: stockQuantity,
      alertThreshold: alertThreshold,
      isActive: isActive,
    );
  }

  Future<int> deleteProduct(int id) {
    return service.deleteProduct(id);
  }
}
