import 'package:drift/drift.dart';

import '../core/database/app_database.dart';

/// Service responsable de l'accès direct à la base de données Drift pour les produits.
class ProductsService {
  final AppDatabase database;

  ProductsService(this.database);

  /// Insère un nouveau produit
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
  }) async {
    final now = DateTime.now().toIso8601String();

    return await database
        .into(database.products)
        .insert(
          ProductsCompanion.insert(
            uuid: uuid,
            name: name,
            categoryId: Value(categoryId),
            barcode: Value(barcode ?? ''),
            photoPath: Value(photoPath),
            purchasePrice: purchasePrice,
            salePrice: salePrice,
            stockQuantity: stockQuantity,
            alertThreshold: alertThreshold,
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  /// Récupère la liste des produits filtrés (Future)
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
  }) async {
    return await _buildFilteredQuery(
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
    ).get();
  }

  /// Diffuse un flux en temps réel des produits filtrés (Stream)
  Stream<List<Product>> watchFilteredProducts({
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
    return _buildFilteredQuery(
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
    ).watch();
  }

  /// Construit la requête SELECT paramétrée dans Drift
  SimpleSelectStatement<$ProductsTable, Product> _buildFilteredQuery({
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
    final query = database.select(database.products);

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final cleanQuery = searchQuery.trim();

      query.where(
        (product) =>
            product.name.contains(cleanQuery) |
            product.uuid.contains(cleanQuery) |
            product.barcode.contains(cleanQuery),
      );
    }

    if (name != null && name.trim().isNotEmpty) {
      query.where((product) => product.name.contains(name.trim()));
    }

    if (uuid != null && uuid.trim().isNotEmpty) {
      query.where((product) => product.uuid.contains(uuid.trim()));
    }

    if (categoryId != null) {
      query.where((product) => product.categoryId.equals(categoryId));
    }

    if (barcode != null && barcode.trim().isNotEmpty) {
      query.where((product) => product.barcode.contains(barcode.trim()));
    }

    if (photoPath != null && photoPath.trim().isNotEmpty) {
      query.where((product) => product.photoPath.equals(photoPath));
    }

    if (purchasePrice != null) {
      query.where((product) => product.purchasePrice.equals(purchasePrice));
    }

    if (salePrice != null) {
      query.where((product) => product.salePrice.equals(salePrice));
    }

    if (stockQuantity != null) {
      query.where((product) => product.stockQuantity.equals(stockQuantity));
    }

    if (alertThreshold != null) {
      query.where((product) => product.alertThreshold.equals(alertThreshold));
    }

    return query;
  }

  /// Recherche un produit par son ID
  Future<Product?> findById(int id) async {
    return await (database.select(
      database.products,
    )..where((product) => product.id.equals(id))).getSingleOrNull();
  }

  /// Met à jour un produit
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
  }) async {
    final now = DateTime.now().toIso8601String();

    final updated =
        await (database.update(
          database.products,
        )..where((product) => product.id.equals(id))).write(
          ProductsCompanion(
            name: name != null ? Value(name) : const Value.absent(),
            uuid: uuid != null ? Value(uuid) : const Value.absent(),
            categoryId: categoryId != null
                ? Value(categoryId)
                : const Value.absent(),
            barcode: barcode != null ? Value(barcode) : const Value.absent(),
            photoPath: photoPath != null
                ? Value(photoPath)
                : const Value.absent(),
            purchasePrice: purchasePrice != null
                ? Value(purchasePrice)
                : const Value.absent(),
            salePrice: salePrice != null
                ? Value(salePrice)
                : const Value.absent(),
            stockQuantity: stockQuantity != null
                ? Value(stockQuantity)
                : const Value.absent(),
            alertThreshold: alertThreshold != null
                ? Value(alertThreshold)
                : const Value.absent(),
            isActive: isActive != null ? Value(isActive) : const Value.absent(),
            updatedAt: Value(now),
          ),
        );

    return updated > 0;
  }

  /// Supprime un produit par son ID
  Future<int> deleteProduct(int id) async {
    return await (database.delete(database.products)
          ..where((product) => product.id.equals(id)))
        .go();
  }
}
