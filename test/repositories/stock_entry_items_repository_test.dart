import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_stock/core/database/app_database.dart';
import 'package:gestion_stock/repositories/stock_entry_items_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late StockEntryItemsRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = StockEntryItemsRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('Créer, modifier et supprimer des lignes d’entrée de stock', () async {
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
            purchasePrice: 2000,
            salePrice: 3000,
            stockQuantity: 5,
            alertThreshold: 2,
            createdAt: '2026-09-30 10:00:00',
            updatedAt: '2026-09-30 10:00:00',
          ),
        );

    final entryId = await database.into(database.stockEntries).insert(
          StockEntriesCompanion.insert(
            uuid: 'entry-uuid-test',
            totalAmount: 10000,
            userId: userId,
            createdAt: '2026-09-30 10:00:00',
            updatedAt: '2026-09-30 10:00:00',
          ),
        );

    final itemId = await repository.create(
      stockEntryId: entryId,
      productId: productId,
      quantity: 5,
      unitCost: 2000,
    );

    expect(itemId, greaterThan(0));

    final item = await repository.findById(itemId);
    expect(item, isNotNull);
    expect(item!.quantity, 5);
    expect(item.subtotal, 10000);

    final total = await repository.getStockEntryTotal(entryId);
    expect(total, 10000);

    final updated = await repository.update(
      id: itemId,
      quantity: 6,
      unitCost: 2000,
    );
    expect(updated, isTrue);

    final deleted = await repository.delete(itemId);
    expect(deleted, isTrue);
  });
}
