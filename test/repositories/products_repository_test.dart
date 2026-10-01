import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_stock/core/database/app_database.dart';
import 'package:gestion_stock/repositories/products_repository.dart';
import 'package:gestion_stock/services/products_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late ProductsService service;
  late ProductsRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    service = ProductsService(database);
    repository = ProductsRepository(service);
  });

  tearDown(() async {
    await database.close();
  });

  test('Créer, filtrer et mettre à jour un produit', () async {
    final id = await repository.createProduct(
      name: 'Laptop',
      uuid: 'prod-uuid-1',
      purchasePrice: 300000,
      salePrice: 400000,
      stockQuantity: 10,
      alertThreshold: 2,
    );

    final product = await repository.findById(id);
    expect(product, isNotNull);
    expect(product!.name, 'Laptop');
    expect(product.salePrice, 400000);

    final filtered = await repository.filterProducts(searchQuery: 'Laptop');
    expect(filtered.length, 1);

    final updated = await repository.updateProduct(
      id: id,
      stockQuantity: 8,
      salePrice: 390000,
    );
    expect(updated, isTrue);

    final updatedProduct = await repository.findById(id);
    expect(updatedProduct!.stockQuantity, 8);
    expect(updatedProduct.salePrice, 390000);

    final deleted = await repository.deleteProduct(id);
    expect(deleted, 1);
  });
}
