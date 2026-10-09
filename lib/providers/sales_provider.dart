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
  final bool ascending;
  final DateTime? startDate;
  final DateTime? endDate;

  const SaleFilterState({
    this.customerId,
    this.userId,
    this.ascending = false,
    this.startDate,
    this.endDate,
  });

  bool get hasActiveFilters =>
      customerId != null ||
      userId != null ||
      startDate != null ||
      endDate != null;

  SaleFilterState copyWith({
    int? customerId,
    int? userId,
    bool? ascending,
    DateTime? startDate,
    DateTime? endDate,
    bool clearCustomer = false,
    bool clearUser = false,
    bool clearStartDate = false,
    bool clearEndDate = false,
  }) {
    return SaleFilterState(
      customerId: clearCustomer ? null : (customerId ?? this.customerId),
      userId: clearUser ? null : (userId ?? this.userId),
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      ascending: ascending ?? this.ascending,
    );
  }
}

class SaleFilterNotifier extends Notifier<SaleFilterState> {
  @override
  SaleFilterState build() => const SaleFilterState();

  void setCustomerId(int? customerId) {
    state = state.copyWith(
      customerId: customerId,
      clearCustomer: customerId == null,
    );
  }

  void setUserId(int? userId) {
    state = state.copyWith(userId: userId, clearUser: userId == null);
  }

  void setAscending(bool ascending) {
    state = state.copyWith(ascending: ascending);
  }

  void setStartDate(DateTime? startDate) {
    state = state.copyWith(startDate: startDate);
  }

  void setEndDate(DateTime? endDate) {
    state = state.copyWith(endDate: endDate);
  }

  void setDate(DateTime? startDate, DateTime? endDate) {
    state = state.copyWith(
      startDate: startDate,
      endDate: endDate,
      clearStartDate: startDate == null,
      clearEndDate: endDate == null,
    );
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

  return repository
      .watchSales(
        customerId: filter.customerId,
        userId: filter.userId,
      )
      .map((sales) {
    var filtered = sales;

    if (filter.startDate != null) {
      filtered = filtered
          .where((s) => DateTime.parse(s.createdAt).isAfter(filter.startDate!))
          .toList();
    }

    if (filter.endDate != null) {
      filtered = filtered
          .where((s) => DateTime.parse(s.createdAt).isBefore(filter.endDate!))
          .toList();
    }

    filtered.sort((a, b) {
      final dateA = DateTime.parse(a.createdAt);
      final dateB = DateTime.parse(b.createdAt);
      return filter.ascending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
    });

    return filtered;
  });
});
