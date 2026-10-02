import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_stock/core/database/app_database.dart';
import 'package:gestion_stock/core/database/database_provider.dart';
import 'package:gestion_stock/services/suppliers_service.dart';
import '../repositories/suppliers_repository.dart';

final suppliersServiceProvider = Provider<SuppliersService>((ref) {
  return SuppliersService(ref.watch(appDatabaseProvider));
});

final suppliersRepositoryProvider = Provider<SuppliersRepository>((ref) {
  return SuppliersRepository(ref.watch(suppliersServiceProvider));
});

class SupplierFilterState {
  final String searchQuery;

  const SupplierFilterState({
    this.searchQuery = '',
  });

  bool get hasActiveFilters => searchQuery.trim().isNotEmpty;

  SupplierFilterState copyWith({
    String? searchQuery,
  }) {
    return SupplierFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class SupplierFilterNotifier extends Notifier<SupplierFilterState> {
  @override
  SupplierFilterState build() => const SupplierFilterState();

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void reset() {
    state = const SupplierFilterState();
  }
}

final supplierFilterNotifierProvider =
    NotifierProvider<SupplierFilterNotifier, SupplierFilterState>(
  SupplierFilterNotifier.new,
);

final filteredSuppliersProvider = StreamProvider<List<Supplier>>((ref) {
  final repository = ref.watch(suppliersRepositoryProvider);
  final filter = ref.watch(supplierFilterNotifierProvider);

  return repository.watchFilteredSuppliers(
    searchQuery: filter.searchQuery,
  );
});
