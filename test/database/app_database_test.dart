import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_stock/core/database/app_database.dart';

void main() {
  test('La base StockPro peut être ouverte', () async {
    final database = AppDatabase();

    await database.close();
  });
}