
import 'package:drift/drift.dart';

import '../core/database/app_database.dart';



class SalesDashboardRepository {
  final AppDatabase db;

  SalesDashboardRepository(this.db);

  /// Chiffre d'affaires brut de la semaine courante.
  /// La semaine commence le lundi à 00 h 00.
  Future<int> getCurrentWeekGrossRevenue() async {
    final now = DateTime.now();

    // Premier jour de la semaine : lundi à minuit.
    final start = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));

    // Borne de fin exclusive : lundi suivant à minuit.
    final end = start.add(const Duration(days: 7));

    final totalExpression = db.sales.totalAmount.sum();

    final query = db.selectOnly(db.sales)
      ..addColumns([totalExpression])
      ..where(
        db.sales.createdAt.isBiggerOrEqualValue(
          start.toIso8601String(),
        ) &
        db.sales.createdAt.isSmallerThanValue(
          end.toIso8601String(),
        ),
      );

    final row = await query.getSingle();

    return row.read(totalExpression) ?? 0;
  }
}