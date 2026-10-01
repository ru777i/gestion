import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_stock/core/database/app_database.dart';
import 'package:gestion_stock/repositories/sales_repository.dart';
import 'package:gestion_stock/services/sales_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late SalesService service;
  late SalesRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    service = SalesService(database);
    repository = SalesRepository(service);
  });

  tearDown(() async {
    await database.close();
  });

  test('Créer une vente avec ses items', () async {
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
            salePrice: 500,
            stockQuantity: 10,
            alertThreshold: 2,
            createdAt: '2026-09-30 10:00:00',
            updatedAt: '2026-09-30 10:00:00',
          ),
        );

    final saleId = await repository.createSaleWithItems(
      uuid: 'sale-uuid-abc',
      totalAmount: 1500,
      amountPaid: 1500,
      paymentMethod: 'Mobile Money',
      paymentStatus: 'paid',
      userId: userId,
      items: [
        SaleItemsCompanion.insert(
          saleId: 0,
          productId: productId,
          quantity: 3,
          unitPrice: 500,
          subtotal: 1500,
        ),
      ],
    );

    expect(saleId, greaterThan(0));

    final sale = await repository.findById(saleId);
    expect(sale, isNotNull);
    expect(sale!.uuid, 'sale-uuid-abc');
    expect(sale.totalAmount, 1500);

    final items = await repository.findItemsBySaleId(saleId);
    expect(items.length, 1);
    expect(items.first.productId, productId);
    expect(items.first.subtotal, 1500);

    final deleted = await repository.deleteSale(saleId);
    expect(deleted, 1);
  });
}
