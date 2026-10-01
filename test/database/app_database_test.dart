import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart' hide isNotNull;
import 'package:gestion_stock/core/database/app_database.dart';
import 'package:gestion_stock/services/users_service.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('La table users est accessible', () async {
    final users = await database.select(database.users).get();

    expect(users, isEmpty);
  });
  test('Une catégorie peut être créée et lue', () async {
    await database
        .into(database.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Boissons',
            createdAt: '2026-09-30 10:00:00',
            updatedAt: '2026-09-30 10:00:00',
          ),
        );

    final categories = await database.select(database.categories).get();

    expect(categories.length, 1);
    expect(categories.first.name, 'Boissons');
  });
  test('Un produit peut être créé et lu', () async {
    // 1. Créer la catégorie Boissons
    await database
        .into(database.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Boissons',
            createdAt: '2026-09-30 10:00:00',
            updatedAt: '2026-09-30 10:00:00',
          ),
        );

    // 2. Créer le produit Coca-Cola dans la catégorie Boissons
    await database
        .into(database.products)
        .insert(
          ProductsCompanion.insert(
            uuid: 'test-product-001',
            name: 'Coca-Cola',
            categoryId: const Value(1),
            barcode: const Value('123456789'),
            photoPath: const Value(null),
            purchasePrice: 500,
            salePrice: 700,
            stockQuantity: 20,
            alertThreshold: 5,
            createdAt: '2026-09-30 10:00:00',
            updatedAt: '2026-09-30 10:00:00',
          ),
        );

    // 3. Lire les produits
    final products = await database.select(database.products).get();

    // 4. Vérifier le résultat
    expect(products.length, 1);
    expect(products.first.name, 'Coca-Cola');
    expect(products.first.categoryId, 1);
    expect(products.first.salePrice, 700);
    expect(products.first.stockQuantity, 20);
  });

  test('Un client peut être créé et lu', () async {
    await database
        .into(database.customers)
        .insert(
          CustomersCompanion.insert(
            name: 'Jean Dupont',
            phone: const Value('690000000'),
            address: const Value('Yaoundé'),
            creditLimit: 100000,
            currentCredit: 0,
            createdAt: '2026-09-30 10:00:00',
            updatedAt: '2026-09-30 10:00:00',
          ),
        );

    final customers = await database.select(database.customers).get();

    expect(customers.length, 1);
    expect(customers.first.name, 'Jean Dupont');
    expect(customers.first.phone, '690000000');
    expect(customers.first.creditLimit, 100000);
    expect(customers.first.currentCredit, 0);
    expect(customers.first.isActive, 1);
  });

  test('Une ligne de vente peut être créée et lue', () async {
    // 1. Créer l'utilisateur
    await database
        .into(database.users)
        .insert(
          UsersCompanion.insert(
            username: 'vendeur2',
            fullName: 'Vendeur Test',
            passwordHash: 'hash-test',
            role: 'vendeur',
            createdAt: '2026-09-30 11:00:00',
            updatedAt: '2026-09-30 11:00:00',
          ),
        );

    // 2. Créer le produit
    await database
        .into(database.products)
        .insert(
          ProductsCompanion.insert(
            uuid: 'test-product-002',
            name: 'Coca-Cola',
            categoryId: const Value(null),
            barcode: const Value('987654321'),
            photoPath: const Value(null),
            purchasePrice: 500,
            salePrice: 700,
            stockQuantity: 20,
            alertThreshold: 5,
            createdAt: '2026-09-30 11:00:00',
            updatedAt: '2026-09-30 11:00:00',
          ),
        );

    // 3. Créer la vente
    await database
        .into(database.sales)
        .insert(
          SalesCompanion.insert(
            uuid: 'test-sale-002',
            customerId: const Value(null),
            totalAmount: 1400,
            amountPaid: 1400,
            paymentMethod: 'especes',
            paymentStatus: 'paye',
            userId: 1,
            createdAt: '2026-09-30 11:00:00',
            updatedAt: '2026-09-30 11:00:00',
          ),
        );

    // 4. Créer la ligne de vente
    await database
        .into(database.saleItems)
        .insert(
          SaleItemsCompanion.insert(
            saleId: 1,
            productId: 1,
            quantity: 2,
            unitPrice: 700,
            subtotal: 1400,
          ),
        );

    // 5. Lire les lignes de vente
    final items = await database.select(database.saleItems).get();

    // 6. Vérifier
    expect(items.length, 1);
    expect(items.first.saleId, 1);
    expect(items.first.productId, 1);
    expect(items.first.quantity, 2);
    expect(items.first.unitPrice, 700);
    expect(items.first.subtotal, 1400);
  });
  test('Un paiement de crédit peut être créé et lu', () async {
    // 1. Créer le client
    await database
        .into(database.customers)
        .insert(
          CustomersCompanion.insert(
            name: 'Client Crédit',
            phone: const Value('690111111'),
            address: const Value('Yaoundé'),
            creditLimit: 100000,
            currentCredit: 50000,
            createdAt: '2026-09-30 12:00:00',
            updatedAt: '2026-09-30 12:00:00',
          ),
        );

    // 2. Enregistrer un paiement de crédit
    await database
        .into(database.creditPayments)
        .insert(
          CreditPaymentsCompanion.insert(
            customerId: 1,
            amount: 20000,
            paymentMethod: 'especes',
            notes: const Value('Paiement partiel'),
            createdAt: '2026-09-30 12:00:00',
          ),
        );

    // 3. Lire les paiements
    final payments = await database.select(database.creditPayments).get();

    // 4. Vérifier
    expect(payments.length, 1);
    expect(payments.first.customerId, 1);
    expect(payments.first.amount, 20000);
    expect(payments.first.paymentMethod, 'especes');
    expect(payments.first.notes, 'Paiement partiel');
  });
  test('Un fournisseur peut être créé et lu', () async {
    await database
        .into(database.suppliers)
        .insert(
          SuppliersCompanion.insert(
            name: 'Fournisseur Test',
            phone: const Value('677000000'),
            address: const Value('Douala'),
            createdAt: '2026-09-30 13:00:00',
            updatedAt: '2026-09-30 13:00:00',
          ),
        );

    final suppliers = await database.select(database.suppliers).get();

    expect(suppliers.length, 1);
    expect(suppliers.first.name, 'Fournisseur Test');
    expect(suppliers.first.phone, '677000000');
    expect(suppliers.first.address, 'Douala');
  });
  test('Une entrée de stock peut être créée et lue', () async {
    // Utilisateur responsable de l'entrée
    await database
        .into(database.users)
        .insert(
          UsersCompanion.insert(
            username: 'magasinier1',
            fullName: 'Magasinier Test',
            passwordHash: 'hash-test',
            role: 'patron',
            createdAt: '2026-09-30 14:00:00',
            updatedAt: '2026-09-30 14:00:00',
          ),
        );

    // Fournisseur
    await database
        .into(database.suppliers)
        .insert(
          SuppliersCompanion.insert(
            name: 'Fournisseur Stock',
            phone: const Value('677111111'),
            address: const Value('Douala'),
            createdAt: '2026-09-30 14:00:00',
            updatedAt: '2026-09-30 14:00:00',
          ),
        );

    // Entrée de stock
    await database
        .into(database.stockEntries)
        .insert(
          StockEntriesCompanion.insert(
            uuid: 'test-stock-entry-001',
            supplierId: const Value(1),
            totalAmount: 50000,
            userId: 1,
            createdAt: '2026-09-30 14:00:00',
            updatedAt: '2026-09-30 14:00:00',
          ),
        );

    final entries = await database.select(database.stockEntries).get();

    expect(entries.length, 1);
    expect(entries.first.uuid, 'test-stock-entry-001');
    expect(entries.first.supplierId, 1);
    expect(entries.first.totalAmount, 50000);
    expect(entries.first.userId, 1);
  });
  test('Une ligne d’entrée de stock peut être créée et lue', () async {
    // 1. Créer l'utilisateur
    await database
        .into(database.users)
        .insert(
          UsersCompanion.insert(
            username: 'magasinier2',
            fullName: 'Magasinier Test',
            passwordHash: 'hash-test',
            role: 'patron',
            createdAt: '2026-09-30 15:00:00',
            updatedAt: '2026-09-30 15:00:00',
          ),
        );

    // 2. Créer le fournisseur
    await database
        .into(database.suppliers)
        .insert(
          SuppliersCompanion.insert(
            name: 'Fournisseur Test',
            phone: const Value('677222222'),
            address: const Value('Douala'),
            createdAt: '2026-09-30 15:00:00',
            updatedAt: '2026-09-30 15:00:00',
          ),
        );

    // 3. Créer le produit
    await database
        .into(database.products)
        .insert(
          ProductsCompanion.insert(
            uuid: 'test-product-stock-001',
            name: 'Coca-Cola',
            categoryId: const Value(null),
            barcode: const Value('111222333'),
            photoPath: const Value(null),
            purchasePrice: 500,
            salePrice: 700,
            stockQuantity: 0,
            alertThreshold: 5,
            createdAt: '2026-09-30 15:00:00',
            updatedAt: '2026-09-30 15:00:00',
          ),
        );

    // 4. Créer l'entrée de stock
    await database
        .into(database.stockEntries)
        .insert(
          StockEntriesCompanion.insert(
            uuid: 'test-stock-entry-002',
            supplierId: const Value(1),
            totalAmount: 10000,
            userId: 1,
            createdAt: '2026-09-30 15:00:00',
            updatedAt: '2026-09-30 15:00:00',
          ),
        );

    // 5. Créer la ligne d'entrée
    await database
        .into(database.stockEntryItems)
        .insert(
          StockEntryItemsCompanion.insert(
            stockEntryId: 1,
            productId: 1,
            quantity: 20,
            unitCost: 500,
            subtotal: 10000,
          ),
        );

    // 6. Lire les lignes
    final items = await database.select(database.stockEntryItems).get();

    // 7. Vérifier
    expect(items.length, 1);
    expect(items.first.stockEntryId, 1);
    expect(items.first.productId, 1);
    expect(items.first.quantity, 20);
    expect(items.first.unitCost, 500);
    expect(items.first.subtotal, 10000);
  });

  test('Un mouvement de stock peut être créé et lu', () async {
    // 1. Créer l'utilisateur
    await database
        .into(database.users)
        .insert(
          UsersCompanion.insert(
            username: 'stock-user',
            fullName: 'Utilisateur Stock',
            passwordHash: 'hash-test',
            role: 'patron',
            createdAt: '2026-09-30 16:00:00',
            updatedAt: '2026-09-30 16:00:00',
          ),
        );

    // 2. Créer le produit
    await database
        .into(database.products)
        .insert(
          ProductsCompanion.insert(
            uuid: 'test-product-movement-001',
            name: 'Coca-Cola',
            categoryId: const Value(null),
            barcode: const Value('444555666'),
            photoPath: const Value(null),
            purchasePrice: 500,
            salePrice: 700,
            stockQuantity: 20,
            alertThreshold: 5,
            createdAt: '2026-09-30 16:00:00',
            updatedAt: '2026-09-30 16:00:00',
          ),
        );

    // 3. Créer le mouvement
    await database
        .into(database.stockMovements)
        .insert(
          StockMovementsCompanion.insert(
            productId: 1,
            type: 'entree',
            quantity: 20,
            referenceType: const Value('stock_entry'),
            referenceId: const Value(1),
            userId: 1,
            createdAt: '2026-09-30 16:00:00',
          ),
        );

    // 4. Lire les mouvements
    final movements = await database.select(database.stockMovements).get();

    // 5. Vérifier
    expect(movements.length, 1);
    expect(movements.first.productId, 1);
    expect(movements.first.type, 'entree');
    expect(movements.first.quantity, 20);
    expect(movements.first.referenceType, 'stock_entry');
    expect(movements.first.referenceId, 1);
    expect(movements.first.userId, 1);
  });

  test('Un paramètre peut être créé et lu', () async {
    await database
        .into(database.settings)
        .insert(SettingsCompanion.insert(key: 'shop_name', value: 'StockPro'));

    final settings = await database.select(database.settings).get();

    expect(settings.length, 1);
    expect(settings.first.key, 'shop_name');
    expect(settings.first.value, 'StockPro');
  });
  test(
    'Une opération peut être ajoutée à la file de synchronisation',
    () async {
      await database
          .into(database.syncQueue)
          .insert(
            SyncQueueCompanion.insert(
              tableNam: 'products',
              recordUuid: 'test-product-sync-001',
              operation: 'insert',
              payload: '{"name":"Coca-Cola","stock_quantity":20}',
              createdAt: '2026-09-30 17:00:00',
            ),
          );

      final queue = await database.select(database.syncQueue).get();

      expect(queue.length, 1);
      expect(queue.first.tableNam, 'products');
      expect(queue.first.recordUuid, 'test-product-sync-001');
      expect(queue.first.operation, 'insert');
      expect(queue.first.payload, contains('Coca-Cola'));
      expect(queue.first.attempts, 0);
      expect(queue.first.syncedAt, equals(null));
    },
  );

  test('Un utilisateur peut être créé', () async {
    // 1. Créer l'utilisateur
    database
        .into(database.users)
        .insert(
          UsersCompanion.insert(
            username: 'test-user',
            fullName: 'Utilisateur Test',
            passwordHash: 'hash-test',
            role: 'patron',
            createdAt: '2026-09-30 13:00:00',
            updatedAt: '2026-09-30 13:00:00',
          ),
        );
    await database
        .into(database.suppliers)
        .insert(
          SuppliersCompanion.insert(
            name: 'Fournisseur Test',
            phone: const Value('677000000'),
            address: const Value('Douala'),
            createdAt: '2026-09-30 13:00:00',
            updatedAt: '2026-09-30 13:00:00',
          ),
        );

    // 2. Lire les utilisateurs
    final users = await database.select(database.users).get();

    // 3. Vérifier l'id retourné
    expect(users.length, 1);

    // 4. Vérifier l'utilisateur créé
    expect(users.length, 1);
    expect(users.first.id, 1);
    expect(users.first.username, 'test-user');
    expect(users.first.fullName, 'Utilisateur Test');
    expect(users.first.passwordHash, 'hash-test');
    expect(users.first.role, 'patron');

    // 5. Vérifier les dates
    expect(users.first.createdAt, isNotEmpty);
    expect(users.first.updatedAt, isNotEmpty);
  });
  test('Une ligne d’entrée de stock peut être ajoutée', () async {
    // 1. Créer le fournisseur
    await database
        .into(database.suppliers)
        .insert(
          SuppliersCompanion.insert(
            name: 'Fournisseur Test',
            phone: const Value('677000000'),
            address: const Value('Douala'),
            createdAt: '2026-09-30 13:00:00',
            updatedAt: '2026-09-30 13:00:00',
          ),
        );
    // 1. Créer l'utilisateur
    database
        .into(database.users)
        .insert(
          UsersCompanion.insert(
            username: 'test-user',
            fullName: 'Utilisateur Test',
            passwordHash: 'hash-test',
            role: 'patron',
            createdAt: '2026-09-30 13:00:00',
            updatedAt: '2026-09-30 13:00:00',
          ),
        );
    final supplier = await database.select(database.suppliers).get();

    // 3. Vérifier l'id retourné
    expect(supplier.length, 1);

    // 2. Créer l'entrée de stock
    await database
        .into(database.stockEntries)
        .insert(
          StockEntriesCompanion.insert(
            uuid: 'test-stock-entry-001',
            supplierId: const Value(1),
            totalAmount: 50000,
            userId: 1,
            createdAt: '2026-09-30 14:00:00',
            updatedAt: '2026-09-30 14:00:00',
          ),
        );
    final stockEntries = await database.select(database.stockEntries).get();

    // 3. Vérifier l'id retourné
    expect(stockEntries.length, 1);
    // creer une categorie
    await database
        .into(database.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Boissons',
            createdAt: '2026-09-30 10:00:00',
            updatedAt: '2026-09-30 10:00:00',
          ),
        );

    // 3. Créer le produit
    await database
        .into(database.products)
        .insert(
          ProductsCompanion.insert(
            uuid: 'test-product-001',
            name: 'Coca-Cola',
            categoryId: const Value(1),
            barcode: const Value('123456789'),
            photoPath: const Value(null),
            purchasePrice: 500,
            salePrice: 700,
            stockQuantity: 20,
            alertThreshold: 5,
            createdAt: '2026-09-30 10:00:00',
            updatedAt: '2026-09-30 10:00:00',
          ),
        );
    //
    final produit = await database.select(database.products).get();

    // 3. Vérifier l'id retourné
    expect(produit.length, 1);
    // 4. Créer la ligne d'entrée de stock
    await database
        .into(database.stockEntryItems)
        .insert(
          StockEntryItemsCompanion.insert(
            productId: 1, // <-- correction
            stockEntryId: 1,
            quantity: 10,
            unitCost: 1500,
            subtotal: 15000,
          ),
        );

    // 5. Lire les lignes
    final items = await database.select(database.stockEntryItems).get();

    // 6. Vérifier
    expect(items.length, 1);
    expect(items.first.stockEntryId, 1);
    expect(items.first.productId, 1);
    expect(items.first.quantity, 10);
    expect(items.first.unitCost, 1500);
    expect(items.first.subtotal, 15000);
  });

  test('Une ligne de vente peut être créée', () async {
    final userId = await database
        .into(database.users)
        .insert(
          UsersCompanion.insert(
            username: 'sale-user',
            fullName: 'Utilisateur Vente',
            passwordHash: 'hash-test',
            role: 'patron',
            createdAt: '2026-09-30 16:00:00',
            updatedAt: '2026-09-30 16:00:00',
          ),
        );

    final productId = await database
        .into(database.products)
        .insert(
          ProductsCompanion.insert(
            uuid: 'product-sale-001',
            name: 'Coca-Cola',
            categoryId: const Value(null),
            barcode: const Value('123456'),
            photoPath: const Value(null),
            purchasePrice: 500,
            salePrice: 700,
            stockQuantity: 20,
            alertThreshold: 5,
            createdAt: '2026-09-30 16:00:00',
            updatedAt: '2026-09-30 16:00:00',
          ),
        );

    final saleId = await database
        .into(database.sales)
        .insert(
          SalesCompanion.insert(
            amountPaid: 767,
            paymentMethod: 'aisiaus',
            paymentStatus: 'paye',
            uuid: 'sale-001',
            userId: userId,
            totalAmount: 1400,
            createdAt: '2026-09-30 16:00:00',
            updatedAt: '2026-09-30 16:00:00',
          ),
        );

    final saleIte = await database
        .into(database.saleItems)
        .insert(
          SaleItemsCompanion.insert(
            saleId: saleId,
            productId: productId,
            unitPrice: 700,
            quantity: 23,
            subtotal: 223,
          ),
        );

    final item = await database.select(database.saleItems).get();
    expect(item.length, 1);
    expect(item.first.saleId, 1);
    expect(item.first.productId, 1);
    expect(item.first.quantity, 23);
    expect(item.first.unitPrice, 700);
    expect(item.first.subtotal, 223);
  });

  test('Une ligne de vente peut être récupérée par son ID', () async {
    final userId = await database
        .into(database.users)
        .insert(
          UsersCompanion.insert(
            username: 'user-sale',
            fullName: 'Utilisateur',
            passwordHash: 'hash',
            role: 'patron',
            createdAt: '2026-09-30 16:00:00',
            updatedAt: '2026-09-30 16:00:00',
          ),
        );

    final productId = await database
        .into(database.products)
        .insert(
          ProductsCompanion.insert(
            uuid: 'product-001',
            name: 'Produit Test',
            categoryId: const Value(null),
            barcode: const Value('111111'),
            photoPath: const Value(null),
            purchasePrice: 500,
            salePrice: 1000,
            stockQuantity: 10,
            alertThreshold: 2,
            createdAt: '2026-09-30 16:00:00',
            updatedAt: '2026-09-30 16:00:00',
          ),
        );

    final saleId = await database
        .into(database.sales)
        .insert(
          SalesCompanion.insert(
            userId: userId,
            uuid: 'dsd',
            amountPaid: 1000,
            paymentMethod: 'especes',
            paymentStatus: 'paye',
            updatedAt: '2026-09-30 16:00:00',
            totalAmount: 1000,
            createdAt: '2026-09-30 16:00:00',
          ),
        );

    final itemId = await database
        .into(database.saleItems)
        .insert(
          SaleItemsCompanion.insert(
            saleId: saleId,
            productId: productId,
            quantity: 34,
            unitPrice: 34,
            subtotal: 34,
          ),
        );
  });


}
