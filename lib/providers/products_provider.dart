import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/database/app_database.dart';
import '../core/database/database_provider.dart';
import '../repositories/products_repository.dart';
import '../services/products_service.dart';

/// Provider instanciant la couche Service des produits
final productsServiceProvider = Provider<ProductsService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ProductsService(db);
});

/// Provider instanciant la couche Repository des produits
final productsRepositoryProvider = Provider<ProductsRepository>((ref) {
  final service = ref.watch(productsServiceProvider);
  return ProductsRepository(service);
});

/// État immutable pour les filtres de produits
class ProductFilterState {
  final String searchQuery;
  final int? categoryId;

  const ProductFilterState({
    this.searchQuery = '',
    this.categoryId,
  });

  bool get hasActiveFilters => searchQuery.trim().isNotEmpty || categoryId != null;

  ProductFilterState copyWith({
    String? searchQuery,
    int? categoryId,
    bool clearCategory = false,
  }) {
    return ProductFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
    );
  }
}

/// Gestionnaire d'état des filtres de produits
class ProductFilterNotifier extends Notifier<ProductFilterState> {
  @override
  ProductFilterState build() => const ProductFilterState();

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setCategory(int? categoryId) {
    state = state.copyWith(categoryId: categoryId, clearCategory: categoryId == null);
  }

  void reset() {
    state = const ProductFilterState();
  }
}

final productFilterNotifierProvider =
    NotifierProvider<ProductFilterNotifier, ProductFilterState>(
  ProductFilterNotifier.new,
);

/// StreamProvider diffusant la liste filtrée des produits en temps réel
final filteredProductsProvider = StreamProvider<List<Product>>((ref) {
  final repository = ref.watch(productsRepositoryProvider);
  final filter = ref.watch(productFilterNotifierProvider);

  return repository.watchFilteredProducts(
    searchQuery: filter.searchQuery,
    categoryId: filter.categoryId,
  );
});
