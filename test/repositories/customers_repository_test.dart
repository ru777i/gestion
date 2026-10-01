import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_stock/core/database/app_database.dart';
import 'package:gestion_stock/repositories/customers_repository.dart';
import 'package:gestion_stock/services/customers_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late CustomersService service;
  late CustomersRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    service = CustomersService(database);
    repository = CustomersRepository(service);
  });

  tearDown(() async {
    await database.close();
  });

  test('Créer et récupérer un client', () async {
    final id = await repository.createCustomer(
      name: 'Alice',
      phone: '12345678',
      address: 'Paris',
      creditLimit: 50000,
    );

    final customer = await repository.findById(id);
    expect(customer, isNotNull);
    expect(customer!.name, 'Alice');
    expect(customer.phone, '12345678');
    expect(customer.creditLimit, 50000);
  });

  test('Filtrer et mettre à jour un client', () async {
    await repository.createCustomer(name: 'Bob', phone: '87654321');
    final customers = await repository.filterCustomers(searchQuery: 'Bob');
    expect(customers.length, 1);

    final customerId = customers.first.id;
    final updated = await repository.updateCustomer(
      id: customerId,
      name: 'Robert',
      currentCredit: 1000,
    );
    expect(updated, isTrue);

    final updatedCustomer = await repository.findById(customerId);
    expect(updatedCustomer!.name, 'Robert');
    expect(updatedCustomer.currentCredit, 1000);

    final deletedCount = await repository.deleteCustomer(customerId);
    expect(deletedCount, 1);
  });
}
