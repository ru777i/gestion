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

  test('Récupérer les lignes de vente d’une vente avec findItemsBySaleId', () async {
    final userId = await database.into(database.users).insert(
          UsersCompanion.insert(
            username: 'user1',
            fullName: 'User One',
            passwordHash: 'hash',
            role: 'patron',
            createdAt: DateTime.now().toIso8601String(),
            updatedAt: DateTime.now().toIso8601String(),
          ),
        );

    final productId = await database.into(database.products).insert(
          ProductsCompanion.insert(
            uuid: 'prod-uuid-2',
            name: 'Produit 2',
            purchasePrice: 1000,
            salePrice: 1500,
            stockQuantity: 20,
            alertThreshold: 5,
            createdAt: DateTime.now().toIso8601String(),
            updatedAt: DateTime.now().toIso8601String(),
          ),
        );

    final saleId = await repository.createSaleWithItems(
      uuid: 'sale-uuid-items',
      totalAmount: 3000,
      amountPaid: 3000,
      paymentMethod: 'Espèces',
      paymentStatus: 'paid',
      userId: userId,
      items: [
        SaleItemsCompanion.insert(
          saleId: 0,
          productId: productId,
          quantity: 2,
          unitPrice: 1500,
          subtotal: 3000,
        ),
      ],
    );

    final items = await repository.findItemsBySaleId(saleId);
    expect(items.length, 1);
    expect(items.first.saleId, saleId);
    expect(items.first.productId, productId);
    expect(items.first.quantity, 2);
  });

  test('Filtrer les ventes par date (findSalesBefore, findSalesAfter, findSalesOnDate, findSalesBetween)', () async {
    final userId = await database.into(database.users).insert(
          UsersCompanion.insert(
            username: 'user_date',
            fullName: 'User Date',
            passwordHash: 'hash',
            role: 'patron',
            createdAt: DateTime.now().toIso8601String(),
            updatedAt: DateTime.now().toIso8601String(),
          ),
        );

    final date1 = DateTime(2026, 5, 10, 10, 0, 0);
    final date2 = DateTime(2026, 5, 15, 14, 0, 0);
    final date3 = DateTime(2026, 5, 20, 18, 0, 0);

    // Insertion directe de ventes avec dates spécifiques
    await database.into(database.sales).insert(
          SalesCompanion.insert(
            uuid: 'sale-may-10',
            totalAmount: 1000,
            amountPaid: 1000,
            paymentMethod: 'Espèces',
            paymentStatus: 'paid',
            userId: userId,
            createdAt: date1.toIso8601String(),
            updatedAt: date1.toIso8601String(),
          ),
        );

    await database.into(database.sales).insert(
          SalesCompanion.insert(
            uuid: 'sale-may-15',
            totalAmount: 2000,
            amountPaid: 2000,
            paymentMethod: 'Espèces',
            paymentStatus: 'paid',
            userId: userId,
            createdAt: date2.toIso8601String(),
            updatedAt: date2.toIso8601String(),
          ),
        );

    await database.into(database.sales).insert(
          SalesCompanion.insert(
            uuid: 'sale-may-20',
            totalAmount: 3000,
            amountPaid: 3000,
            paymentMethod: 'Espèces',
            paymentStatus: 'paid',
            userId: userId,
            createdAt: date3.toIso8601String(),
            updatedAt: date3.toIso8601String(),
          ),
        );

    // 1. Ventes avant le 12 mai
    final salesBefore = await repository.findSalesBefore(DateTime(2026, 5, 12));
    expect(salesBefore.length, 1);
    expect(salesBefore.first.uuid, 'sale-may-10');

    // 2. Ventes après le 12 mai
    final salesAfter = await repository.findSalesAfter(DateTime(2026, 5, 12));
    expect(salesAfter.length, 2);

    // 3. Ventes le 15 mai
    final salesOnDate = await repository.findSalesOnDate(DateTime(2026, 5, 15));
    expect(salesOnDate.length, 1);
    expect(salesOnDate.first.uuid, 'sale-may-15');

    // 4. Ventes entre le 10 mai et le 16 mai
    final salesBetween = await repository.findSalesBetween(
      DateTime(2026, 5, 10),
      DateTime(2026, 5, 16),
    );
    expect(salesBetween.length, 2);
  });

  test('Observer les ventes en temps réel avec watchSales', () async {
    final userId = await database.into(database.users).insert(
          UsersCompanion.insert(
            username: 'user_watch',
            fullName: 'User Watch',
            passwordHash: 'hash',
            role: 'vendeur',
            createdAt: DateTime.now().toIso8601String(),
            updatedAt: DateTime.now().toIso8601String(),
          ),
        );

    final stream = repository.watchSales(userId: userId);

    expect(
      stream,
      emitsInOrder([
        isEmpty, // Initialement vide
        hasLength(1), // Après l'ajout d'une vente
      ]),
    );

    await repository.createSaleWithItems(
      uuid: 'sale-watch-1',
      totalAmount: 5000,
      amountPaid: 5000,
      paymentMethod: 'Mobile Money',
      paymentStatus: 'paid',
      userId: userId,
      items: [],
    );
  });
}
