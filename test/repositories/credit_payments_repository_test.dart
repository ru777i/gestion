import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_stock/core/database/app_database.dart';
import 'package:gestion_stock/repositories/credit_payments_repository.dart';
import 'package:gestion_stock/services/credit_payments_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late CreditPaymentsService service;
  late CreditPaymentsRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    service = CreditPaymentsService(database);
    repository = CreditPaymentsRepository(service);
  });

  tearDown(() async {
    await database.close();
  });

  test('Créer et récupérer un règlement de crédit', () async {
    final customerId = await database.into(database.customers).insert(
          CustomersCompanion.insert(
            name: 'Client Test',
            creditLimit: 10000,
            currentCredit: 5000,
            createdAt: '2026-09-30 10:00:00',
            updatedAt: '2026-09-30 10:00:00',
          ),
        );

    final paymentId = await repository.createCreditPayment(
      customerId: customerId,
      amount: 2500,
      paymentMethod: 'Espèces',
      notes: 'Paiement partiel',
    );

    expect(paymentId, greaterThan(0));

    final payments = await repository.getPaymentsByCustomer(customerId);
    expect(payments.length, 1);
    expect(payments.first.amount, 2500);
    expect(payments.first.paymentMethod, 'Espèces');
  });
}
