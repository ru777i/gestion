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
      barcode: 'bc-laptop',
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

  test('Filtrage avancé des produits par catégorie et prix', () async {
    final categoryId = await database.into(database.categories).insert(
          CategoriesCompanion.insert(
            name: 'Informatique',
            createdAt: '2026-09-30 10:00:00',
            updatedAt: '2026-09-30 10:00:00',
          ),
        );

    await repository.createProduct(
      name: 'Souris',
      uuid: 'prod-uuid-2',
      categoryId: categoryId,
      barcode: 'bc-souris',
      purchasePrice: 5000,
      salePrice: 8000,
      stockQuantity: 25,
      alertThreshold: 5,
    );

    await repository.createProduct(
      name: 'Clavier',
      uuid: 'prod-uuid-3',
      categoryId: categoryId,
      barcode: 'bc-clavier',
      purchasePrice: 10000,
      salePrice: 15000,
      stockQuantity: 15,
      alertThreshold: 3,
    );

    final resultsByCategory = await repository.filterProducts(categoryId: categoryId);
    expect(resultsByCategory.length, 2);

    final resultsByPrice = await repository.filterProducts(salePrice: 8000);
    expect(resultsByPrice.length, 1);
    expect(resultsByPrice.first.name, 'Souris');

    final streamResults = repository.watchFilteredProducts(searchQuery: 'Clavier');
    expect(streamResults, emits(isA<List<Product>>().having((l) => l.length, 'length', 1)));
  });
}
