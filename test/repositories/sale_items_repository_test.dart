import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_stock/core/database/app_database.dart';
import 'package:gestion_stock/repositories/sale_items_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late SaleItemsRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = SaleItemsRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('Créer, modifier et supprimer des lignes de vente', () async {
    final userId = await database.into(database.users).insert(
          UsersCompanion.insert(
            username: 'admin',
            fullName: 'Admin',
            passwordHash: 'hash',
            role: 'patron',
            createdAt: '2026-09-30 10:00:00',
            updatedAt: '2026-09-30 10:00:00',
          ),
        );

    final categoryId = await database.into(database.categories).insert(
          CategoriesCompanion.insert(
            name: 'Cat 1',
            createdAt: '2026-09-30 10:00:00',
            updatedAt: '2026-09-30 10:00:00',
          ),
        );

    final productId = await database.into(database.products).insert(
          ProductsCompanion.insert(
            uuid: 'prod-uuid-1',
            name: 'Produit Test',
            categoryId: Value(categoryId),
            purchasePrice: 500,
            salePrice: 700,
            stockQuantity: 10,
            alertThreshold: 2,
            createdAt: '2026-09-30 10:00:00',
            updatedAt: '2026-09-30 10:00:00',
          ),
        );

    final saleId = await database.into(database.sales).insert(
          SalesCompanion.insert(
            uuid: 'sale-uuid-1',
            totalAmount: 1400,
            amountPaid: 1400,
            paymentMethod: 'Espèces',
            paymentStatus: 'paid',
            userId: userId,
            createdAt: '2026-09-30 10:00:00',
            updatedAt: '2026-09-30 10:00:00',
          ),
        );

    final itemId = await repository.create(
      saleId: saleId,
      productId: productId,
      quantity: 2,
      unitPrice: 700,
    );

    expect(itemId, greaterThan(0));

    final item = await repository.findById(itemId);
    expect(item, isNotNull);
    expect(item!.quantity, 2);
    expect(item.subtotal, 1400);

    final total = await repository.getSaleTotal(saleId);
    expect(total, 1400);

    final updated = await repository.update(
      id: itemId,
      quantity: 3,
      unitPrice: 700,
    );
    expect(updated, isTrue);

    final updatedItem = await repository.findById(itemId);
    expect(updatedItem!.subtotal, 2100);

    final deletedCount = await repository.delete(itemId);
    expect(deletedCount, 1);
  });
}
