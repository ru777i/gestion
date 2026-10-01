import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_stock/core/database/app_database.dart';
import 'package:gestion_stock/repositories/suppliers_repository.dart';
import 'package:gestion_stock/services/suppliers_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late SuppliersService service;
  late SuppliersRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    service = SuppliersService(database);
    repository = SuppliersRepository(service);
  });

  tearDown(() async {
    await database.close();
  });

  test('Créer, mettre à jour et supprimer un fournisseur', () async {
    final id = await repository.createSupplier(
      name: 'Fournisseur A',
      phone: '99887766',
      address: 'Lyon',
    );

    final supplier = await repository.findById(id);
    expect(supplier, isNotNull);
    expect(supplier!.name, 'Fournisseur A');

    final updated = await repository.updateSupplier(
      id: id,
      name: 'Fournisseur Alpha',
    );
    expect(updated, isTrue);

    final updatedSupplier = await repository.findById(id);
    expect(updatedSupplier!.name, 'Fournisseur Alpha');

    final deleted = await repository.deleteSupplier(id);
    expect(deleted, 1);
  });
}
