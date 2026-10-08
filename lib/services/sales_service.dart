import 'package:drift/drift.dart';

import '../core/database/app_database.dart';

/// Service gérant la persistance des ventes et des lignes de vente dans Drift.
class SalesService {
  final AppDatabase database;

  SalesService(this.database);

  /// Crée une vente complète avec ses lignes de vente associées dans une transaction
  Future<int> createSaleWithItems({
    required String uuid,
    int? customerId,
    required int totalAmount,
    required int amountPaid,
    required String paymentMethod,
    required String paymentStatus,
    required int userId,
    required List<SaleItemsCompanion> items,
  }) async {
    return await database.transaction(() async {
      final now = DateTime.now().toIso8601String();

      final saleId = await database.into(database.sales).insert(
            SalesCompanion.insert(
              uuid: uuid,
              customerId: Value(customerId),
              totalAmount: totalAmount,
              amountPaid: amountPaid,
              paymentMethod: paymentMethod,
              paymentStatus: paymentStatus,
              userId: userId,
              createdAt: now,
              updatedAt: now,
            ),
          );

      for (final item in items) {
        await database.into(database.saleItems).insert(
              item.copyWith(saleId: Value(saleId)),
            );
      }

      return saleId;
    });
  }

  Future<Sale?> findById(int id) async {
    return await (database.select(database.sales)
          ..where((s) => s.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<SaleItem>> findItemsBySaleId(int saleId) async {
    return await (database.select(database.saleItems)
          ..where((item) => item.saleId.equals(saleId)))
        .get();
  }
  Future<List<Sale>> findSalesBefore(DateTime date) {
    return (database.select(database.sales)
      ..where((sale) => sale.createdAt.isSmallerThanValue(date.toIso8601String())))
        .get();
  }
Future<List<Sale>> findSalesAfter(DateTime date) {
  return (database.select(database.sales)
    ..where((sale) => sale.createdAt.isBiggerThanValue(date.toIso8601String())))
      .get();
}
  Future<List<Sale>> findSalesOnDate(DateTime date) {
    final start = DateTime(
      date.year,
      date.month,
      date.day,
    );

    final end = start.add(const Duration(days: 1));

    return (database.select(database.sales)
      ..where(
            (sale) =>
        sale.createdAt.isBiggerOrEqualValue(start.toIso8601String()) &
        sale.createdAt.isSmallerThanValue(end.toIso8601String()),
      ))
        .get();
  }
  Future<List<Sale>> findSalesBetween(
      DateTime startDate,
      DateTime endDate,
      ) {
    return (database.select(database.sales)
      ..where(
            (sale) =>
        sale.createdAt.isBiggerOrEqualValue(startDate.toIso8601String()) &
        sale.createdAt.isSmallerOrEqualValue(endDate.toIso8601String()),
      ))
        .get();
  }

  Stream<List<Sale>> watchSales({int? customerId, int? userId, DateTime? created_at}) {
    final query = database.select(database.sales);
    if (customerId != null) {
      query.where((s) => s.customerId.equals(customerId));
    }
    if (created_at != null) {
      query.where((s) => s.createdAt.equals(created_at.toIso8601String()));
    }
    if (userId != null) {
      query.where((s) => s.userId.equals(userId));
    }
    return query.watch();
  }

  Future<int> deleteSale(int id) async {
    return await (database.delete(database.sales)
          ..where((s) => s.id.equals(id)))
        .go();
  }
}
