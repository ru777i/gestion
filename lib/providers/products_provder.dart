import 'package:gestion_stock/core/database/database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_stock/services/products_service.dart';

import '../core/database/app_database.dart';
import '../repositories/products_repository.dart';

final productsServiceProvider = Provider<ProductsService>((ref) {
  return ProductsService(ref.watch(appDatabaseProvider));
});
final productsRepositoryProvider = Provider<ProductsRepository>((ref) {
  return ProductsRepository(ref.watch(productsServiceProvider));
});

class ProductFilterState {
  final String searchQuery;
  final int? categoryId;
  final bool? ascending;
  final String? status;
  final String? barcode;
  final String? photoPath;
  final String? name;
  final String? uuid;
  final int? purchasePrice;
  final int? salePrice;
  final int? stockQuantity;
  final int? alertThreshold;
  final int? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProductFilterState({
    this.searchQuery = '',
    this.categoryId,
    this.ascending = true,
    this.updatedAt,
    this.isActive,
    this.alertThreshold,
    this.stockQuantity,
    this.salePrice,
    this.purchasePrice,
    this.uuid,
    this.name,
    this.photoPath,
    this.barcode,
    this.status,
    this.createdAt,
  });
  bool get hasActiveFilters =>
      searchQuery.trim().isNotEmpty ||
      categoryId != null ||
      ascending != null ||
      updatedAt != null ||
      isActive != null ||
      alertThreshold != null ||
      stockQuantity != null ||
      salePrice != null ||
      purchasePrice != null ||
      uuid != null ||
      name != null ||
      photoPath != null ||
      barcode != null ||
      status != null ||
      createdAt != null;

  ProductFilterState copyWith({
    String? searchQuery,
    int? categoryId,
    bool? ascending,
    DateTime? updatedAt,
    int? isActive,
    int? alertThreshold,
    int? stockQuantity,
    int? salePrice,
    int? purchasePrice,
    String? uuid,
    String? name,
    String? photoPath,
    String? barcode,
    String? status,
    DateTime? createdAt,
  }) {
    return ProductFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      categoryId: categoryId ?? this.categoryId,
      ascending: ascending ?? this.ascending,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      alertThreshold: alertThreshold ?? this.alertThreshold,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      salePrice: salePrice ?? this.salePrice,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      photoPath: photoPath ?? this.photoPath,
      barcode: barcode ?? this.barcode,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ProductFilterNotifier extends Notifier<ProductFilterState> {
  @override
  ProductFilterState build() => const ProductFilterState();
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setCategoryId(int? categoryId) {
    state = state.copyWith(categoryId: categoryId);
  }

  void setAscending(bool? ascending) {
    state = state.copyWith(ascending: ascending);
  }

  void setUpdatedAt(DateTime? updatedAt) {
    state = state.copyWith(updatedAt: updatedAt);
  }

  void setIsActive(int? isActive) {
    state = state.copyWith(isActive: isActive);
  }

  void setAlertThreshold(int? alertThreshold) {
    state = state.copyWith(alertThreshold: alertThreshold);
  }

  void setStockQuantity(int? stockQuantity) {
    state = state.copyWith(stockQuantity: stockQuantity);
  }

  void setSalePrice(int? salePrice) {
    state = state.copyWith(salePrice: salePrice);
  }

  void setPurchasePrice(int? purchasePrice) {
    state = state.copyWith(purchasePrice: purchasePrice);
  }

  void setUuid(String? uuid) {
    state = state.copyWith(uuid: uuid);
  }

  void setName(String? name) {
    state = state.copyWith(name: name);
  }

  void setPhotoPath(String? photoPath) {
    state = state.copyWith(photoPath: photoPath);
  }

  void setBarcode(String? barcode) {
    state = state.copyWith(barcode: barcode);
  }

  void setStatus(String? status) {
    state = state.copyWith(status: status);
  }

  void setCreatedAt(DateTime? createdAt) {
    state = state.copyWith(createdAt: createdAt);
  }

  void reset() {
    state = const ProductFilterState();
  }
}

final productFilterNotifierProvider =
    NotifierProvider<ProductFilterNotifier, ProductFilterState>(
      ProductFilterNotifier.new,
    );
final productsFilteredProvider = StreamProvider<List<Product>>((ref){
           final repository = ref.watch(productsRepositoryProvider);
           final filter = ref.watch(productFilterNotifierProvider);
           return repository.watchFilteredProducts(
             searchQuery: filter.searchQuery,
             categoryId: filter.categoryId,
             ascending: filter.ascending,
               name: filter.name,
               barcode: filter.barcode,
               photoPath: filter.photoPath,
               purchasePrice: filter.purchasePrice,
               salePrice: filter.salePrice,
               stockQuantity: filter.stockQuantity,
               alertThreshold: filter.alertThreshold,
               isActive: filter.isActive,
               created_at: filter.createdAt,
               updated_at: filter.updatedAt,
           );
});
