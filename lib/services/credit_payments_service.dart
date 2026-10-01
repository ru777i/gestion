import 'package:drift/drift.dart';

import '../core/database/app_database.dart';

/// Service gérant les règlements de crédits clients dans Drift.
class CreditPaymentsService {
  final AppDatabase database;

  CreditPaymentsService(this.database);

  Future<int> createCreditPayment({
    required int customerId,
    required int amount,
    required String paymentMethod,
    String? notes,
  }) async {
    final now = DateTime.now().toIso8601String();

    return await database.into(database.creditPayments).insert(
          CreditPaymentsCompanion.insert(
            customerId: customerId,
            amount: amount,
            paymentMethod: paymentMethod,
            notes: Value(notes),
            createdAt: now,
          ),
        );
  }

  Stream<List<CreditPayment>> watchPaymentsByCustomer(int customerId) {
    return (database.select(database.creditPayments)
          ..where((cp) => cp.customerId.equals(customerId)))
        .watch();
  }

  Future<List<CreditPayment>> getPaymentsByCustomer(int customerId) async {
    return await (database.select(database.creditPayments)
          ..where((cp) => cp.customerId.equals(customerId)))
        .get();
  }
}
