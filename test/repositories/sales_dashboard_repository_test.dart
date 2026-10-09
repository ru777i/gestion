import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gestion_stock/core/database/app_database.dart';
import 'package:gestion_stock/repositories/sales_dashboard_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late SalesDashboardRepository repository;
  late int testUserId;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    repository = SalesDashboardRepository(database);

    testUserId = await database.into(database.users).insert(
          UsersCompanion.insert(
            username: 'dashboard_user',
            fullName: 'Dashboard User',
            passwordHash: 'hash',
            role: 'patron',
            createdAt: DateTime.now().toIso8601String(),
            updatedAt: DateTime.now().toIso8601String(),
          ),
        );
  });

  tearDown(() async {
    await database.close();
  });

  test('Retourne 0 quand aucune vente n’est enregistrée', () async {
    final revenue = await repository.getCurrentWeekGrossRevenue();
    expect(revenue, 0);
  });

  test('Calcule le chiffre d’affaires brut des ventes de la semaine courante', () async {
    final now = DateTime.now();

    // Vente 1 : Aujourd'hui (dans la semaine courante)
    await database.into(database.sales).insert(
          SalesCompanion.insert(
            uuid: 'sale-today-1',
            totalAmount: 5000,
            amountPaid: 5000,
            paymentMethod: 'Espèces',
            paymentStatus: 'paid',
            userId: testUserId,
            createdAt: now.toIso8601String(),
            updatedAt: now.toIso8601String(),
          ),
        );

    // Vente 2 : Aujourd'hui (dans la semaine courante)
    await database.into(database.sales).insert(
          SalesCompanion.insert(
            uuid: 'sale-today-2',
            totalAmount: 3500,
            amountPaid: 3500,
            paymentMethod: 'Mobile Money',
            paymentStatus: 'paid',
            userId: testUserId,
            createdAt: now.toIso8601String(),
            updatedAt: now.toIso8601String(),
          ),
        );

    final revenue = await repository.getCurrentWeekGrossRevenue();
    expect(revenue, 8500);
  });

  test('Exclut les ventes réalisées en dehors de la semaine courante', () async {
    final now = DateTime.now();

    // Vente dans la semaine courante
    await database.into(database.sales).insert(
          SalesCompanion.insert(
            uuid: 'sale-this-week',
            totalAmount: 4000,
            amountPaid: 4000,
            paymentMethod: 'Espèces',
            paymentStatus: 'paid',
            userId: testUserId,
            createdAt: now.toIso8601String(),
            updatedAt: now.toIso8601String(),
          ),
        );

    // Vente hors de la semaine courante (il y a 10 jours)
    final pastDate = now.subtract(const Duration(days: 10));
    await database.into(database.sales).insert(
          SalesCompanion.insert(
            uuid: 'sale-past-week',
            totalAmount: 10000,
            amountPaid: 10000,
            paymentMethod: 'Espèces',
            paymentStatus: 'paid',
            userId: testUserId,
            createdAt: pastDate.toIso8601String(),
            updatedAt: pastDate.toIso8601String(),
          ),
        );

    final revenue = await repository.getCurrentWeekGrossRevenue();
    expect(revenue, 4000);
  });
}
