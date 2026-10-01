import '../core/database/app_database.dart';
import '../services/credit_payments_service.dart';

/// Repository pour la gestion des règlements de crédits (Domaine / Métier)
class CreditPaymentsRepository {
  final CreditPaymentsService service;

  CreditPaymentsRepository(this.service);

  Future<int> createCreditPayment({
    required int customerId,
    required int amount,
    required String paymentMethod,
    String? notes,
  }) async {
    return await service.createCreditPayment(
      customerId: customerId,
      amount: amount,
      paymentMethod: paymentMethod,
      notes: notes,
    );
  }

  Stream<List<CreditPayment>> watchPaymentsByCustomer(int customerId)  {
    return service.watchPaymentsByCustomer(customerId);
  }

  Future<List<CreditPayment>> getPaymentsByCustomer(int customerId) {
    return service.getPaymentsByCustomer(customerId);
  }
}
