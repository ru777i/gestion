import 'package:drift/drift.dart';

import '../core/database/app_database.dart';

/// Service gérant la création et le suivi des mouvements de stock dans Drift.
class StockMovementsService {
  final AppDatabase database;

  StockMovementsService(this.database);

  Future<int> createMovement({
    required int productId,
    required String type,
    required int quantity,
    String? referenceType,
    int? referenceId,
    required int userId,
  }) async {
    final now = DateTime.now().toIso8601String();

    return await database.into(database.stockMovements).insert(
          StockMovementsCompanion.insert(
            productId: productId,
            type: type,
            quantity: quantity,
            referenceType: Value(referenceType),
            referenceId: Value(referenceId),
            userId: userId,
            createdAt: now,
          ),
        );
  }

  Stream<List<StockMovement>> watchMovementsByProduct(int productId) {
    return (database.select(database.stockMovements)
          ..where((m) => m.productId.equals(productId)))
        .watch();
  }

  Future<List<StockMovement>> getMovementsByProduct(int productId) async {
    return await (database.select(database.stockMovements)
          ..where((m) => m.productId.equals(productId)))
        .get();
  }
}
