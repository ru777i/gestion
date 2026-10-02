import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_stock/core/database/app_database.dart';
import 'package:gestion_stock/core/database/database_provider.dart';
import 'package:gestion_stock/services/stock_entries_service.dart';
import '../repositories/stock_entries_repository.dart';

final stockEntriesServiceProvider = Provider<StockEntriesService>((ref) {
  return StockEntriesService(ref.watch(appDatabaseProvider));
});

final stockEntriesRepositoryProvider = Provider<StockEntriesRepository>((ref) {
  return StockEntriesRepository(ref.watch(stockEntriesServiceProvider));
});

class StockEntryFilterState {
  final int? supplierId;
  final int? userId;

  const StockEntryFilterState({
    this.supplierId,
    this.userId,
  });

  bool get hasActiveFilters => supplierId != null || userId != null;

  StockEntryFilterState copyWith({
    int? supplierId,
    int? userId,
    bool clearSupplier = false,
    bool clearUser = false,
  }) {
    return StockEntryFilterState(
      supplierId: clearSupplier ? null : (supplierId ?? this.supplierId),
      userId: clearUser ? null : (userId ?? this.userId),
    );
  }
}

class StockEntryFilterNotifier extends Notifier<StockEntryFilterState> {
  @override
  StockEntryFilterState build() => const StockEntryFilterState();

  void setSupplierId(int? supplierId) {
    state = state.copyWith(supplierId: supplierId, clearSupplier: supplierId == null);
  }

  void setUserId(int? userId) {
    state = state.copyWith(userId: userId, clearUser: userId == null);
  }

  void reset() {
    state = const StockEntryFilterState();
  }
}

final stockEntryFilterNotifierProvider =
    NotifierProvider<StockEntryFilterNotifier, StockEntryFilterState>(
  StockEntryFilterNotifier.new,
);

final stockEntriesProvider = StreamProvider<List<StockEntry>>((ref) {
  final repository = ref.watch(stockEntriesRepositoryProvider);
  final filter = ref.watch(stockEntryFilterNotifierProvider);

  return repository.watchStockEntries(
    supplierId: filter.supplierId,
    userId: filter.userId,
  );
});
