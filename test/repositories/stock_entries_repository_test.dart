import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_stock/core/database/app_database.dart';
import 'package:gestion_stock/repositories/stock_entries_repository.dart';
import 'package:gestion_stock/services/stock_entries_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late StockEntriesService service;
  late StockEntriesRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    service = StockEntriesService(database);
    repository = StockEntriesRepository(service);
  });

  tearDown(() async {
    await database.close();
  });

  test('Créer une entrée de stock avec items', () async {
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
            purchasePrice: 5000,
            salePrice: 7000,
            stockQuantity: 10,
            alertThreshold: 2,
            createdAt: '2026-09-30 10:00:00',
            updatedAt: '2026-09-30 10:00:00',
          ),
        );

    final entryId = await repository.createStockEntryWithItems(
      uuid: 'stock-entry-uuid-1',
      totalAmount: 50000,
      userId: userId,
      items: [
        StockEntryItemsCompanion.insert(
          stockEntryId: 0,
          productId: productId,
          quantity: 10,
          unitCost: 5000,
          subtotal: 50000,
        ),
      ],
    );

    expect(entryId, greaterThan(0));

    final entry = await repository.findById(entryId);
    expect(entry, isNotNull);
    expect(entry!.uuid, 'stock-entry-uuid-1');
    expect(entry.totalAmount, 50000);

    final items = await repository.findItemsByStockEntryId(entryId);
    expect(items.length, 1);
    expect(items.first.productId, productId);
    expect(items.first.subtotal, 50000);

    final deleted = await repository.deleteStockEntry(entryId);
    expect(deleted, 1);
  });
}
