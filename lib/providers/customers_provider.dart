import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_stock/core/database/app_database.dart';
import 'package:gestion_stock/core/database/database_provider.dart';
import 'package:gestion_stock/services/customers_service.dart';
import '../repositories/customers_repository.dart';

final customersServiceProvider = Provider<CustomersService>((ref) {
  return CustomersService(ref.watch(appDatabaseProvider));
});

final customersRepositoryProvider = Provider<CustomersRepository>((ref) {
  return CustomersRepository(ref.watch(customersServiceProvider));
});

class CustomerFilterState {
  final String searchQuery;

  const CustomerFilterState({
    this.searchQuery = '',
  });

  bool get hasActiveFilters => searchQuery.trim().isNotEmpty;

  CustomerFilterState copyWith({
    String? searchQuery,
  }) {
    return CustomerFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class CustomerFilterNotifier extends Notifier<CustomerFilterState> {
  @override
  CustomerFilterState build() => const CustomerFilterState();

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void reset() {
    state = const CustomerFilterState();
  }
}

final customerFilterNotifierProvider =
    NotifierProvider<CustomerFilterNotifier, CustomerFilterState>(
  CustomerFilterNotifier.new,
);

final filteredCustomersProvider = StreamProvider<List<Customer>>((ref) {
  final repository = ref.watch(customersRepositoryProvider);
  final filter = ref.watch(customerFilterNotifierProvider);

  return repository.watchFilteredCustomers(
    searchQuery: filter.searchQuery,
  );
});
