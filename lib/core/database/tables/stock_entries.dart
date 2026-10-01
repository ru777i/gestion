import 'package:drift/drift.dart';

import 'suppliers.dart';
import 'users.dart';

class StockEntries extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get uuid => text().unique()();

  IntColumn get supplierId => integer()
      .named('supplier_id')
      .nullable()
      .references(
    Suppliers,
    #id,
    onDelete: KeyAction.setNull,
  )();

  IntColumn get totalAmount => integer()
      .named('total_amount')
      .check(totalAmount.isBiggerOrEqualValue(0))();

  IntColumn get userId => integer()
      .named('user_id')
      .references(
    Users,
    #id,
  )();

  TextColumn get createdAt => text().named('created_at')();

  TextColumn get updatedAt => text().named('updated_at')();
}