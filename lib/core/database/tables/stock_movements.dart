import 'package:drift/drift.dart';

import 'products.dart';
import 'users.dart';

class StockMovements extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get productId => integer()
      .named('product_id')
      .references(
    Products,
    #id,
  )();

  TextColumn get type => text()();

  IntColumn get quantity =>
      integer().check(quantity.isBiggerThanValue(0))();

  TextColumn get referenceType =>
      text().named('reference_type').nullable()();

  IntColumn get referenceId =>
      integer().named('reference_id').nullable()();

  IntColumn get userId => integer()
      .named('user_id')
      .references(
    Users,
    #id,
  )();

  TextColumn get createdAt => text().named('created_at')();
}