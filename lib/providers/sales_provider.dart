import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_stock/core/database/app_database.dart';
import 'package:gestion_stock/core/database/database_provider.dart';
import 'package:gestion_stock/services/sales_service.dart';
import '../repositories/sales_repository.dart';

final salesServiceProvider = Provider<SalesService>((ref) {
  return SalesService(ref.watch(appDatabaseProvider));
});

final salesRepositoryProvider = Provider<SalesRepository>((ref) {
  return SalesRepository(ref.watch(salesServiceProvider));
});

class SaleFilterState {
  final int? customerId;
  final int? userId;

  const SaleFilterState({
    this.customerId,
    this.userId,
  });

  bool get hasActiveFilters => customerId != null || userId != null;

  SaleFilterState copyWith({
    int? customerId,
    int? userId,
    bool clearCustomer = false,
    bool clearUser = false,
  }) {
    return SaleFilterState(
      customerId: clearCustomer ? null : (customerId ?? this.customerId),
      userId: clearUser ? null : (userId ?? this.userId),
    );
  }
}

class SaleFilterNotifier extends Notifier<SaleFilterState> {
  @override
  SaleFilterState build() => const SaleFilterState();

  void setCustomerId(int? customerId) {
    state = state.copyWith(customerId: customerId, clearCustomer: customerId == null);
  }

  void setUserId(int? userId) {
    state = state.copyWith(userId: userId, clearUser: userId == null);
  }

  void reset() {
    state = const SaleFilterState();
  }
}

final saleFilterNotifierProvider =
    NotifierProvider<SaleFilterNotifier, SaleFilterState>(
  SaleFilterNotifier.new,
);

final salesProvider = StreamProvider<List<Sale>>((ref) {
  final repository = ref.watch(salesRepositoryProvider);
  final filter = ref.watch(saleFilterNotifierProvider);

  return repository.watchSales(
    customerId: filter.customerId,
    userId: filter.userId,
  );
});
