import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_stock/core/database/app_database.dart';
import 'package:gestion_stock/core/database/database_provider.dart';
import 'package:gestion_stock/services/credit_payments_service.dart';
import '../repositories/credit_payments_repository.dart';

final creditPaymentsServiceProvider = Provider<CreditPaymentsService>((ref) {
  return CreditPaymentsService(ref.watch(appDatabaseProvider));
});

final creditPaymentsRepositoryProvider = Provider<CreditPaymentsRepository>((ref) {
  return CreditPaymentsRepository(ref.watch(creditPaymentsServiceProvider));
});

class CreditPaymentFilterState {
  final int? customerId;

  const CreditPaymentFilterState({
    this.customerId,
  });

  bool get hasActiveFilters => customerId != null;

  CreditPaymentFilterState copyWith({
    int? customerId,
    bool clearCustomer = false,
  }) {
    return CreditPaymentFilterState(
      customerId: clearCustomer ? null : (customerId ?? this.customerId),
    );
  }
}

class CreditPaymentFilterNotifier extends Notifier<CreditPaymentFilterState> {
  @override
  CreditPaymentFilterState build() => const CreditPaymentFilterState();

  void setCustomerId(int? customerId) {
    state = state.copyWith(customerId: customerId, clearCustomer: customerId == null);
  }

  void reset() {
    state = const CreditPaymentFilterState();
  }
}

final creditPaymentFilterNotifierProvider =
    NotifierProvider<CreditPaymentFilterNotifier, CreditPaymentFilterState>(
  CreditPaymentFilterNotifier.new,
);

final creditPaymentsByCustomerProvider = StreamProvider.family<List<CreditPayment>, int>((ref, customerId) {
  final repository = ref.watch(creditPaymentsRepositoryProvider);
  return repository.watchPaymentsByCustomer(customerId);
});
