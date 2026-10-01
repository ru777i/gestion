import 'package:drift/drift.dart';

import 'products.dart';
import 'stock_entries.dart';

class StockEntryItems extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get stockEntryId => integer()
      .named('stock_entry_id')
      .references(
    StockEntries,
    #id,
    onDelete: KeyAction.cascade,
  )();

  IntColumn get productId => integer()
      .named('product_id')
      .references(
    Products,
    #id,
  )();

  IntColumn get quantity =>
      integer().check(quantity.isBiggerThanValue(0))();

  IntColumn get unitCost =>
      integer().named('unit_cost').check(unitCost.isBiggerOrEqualValue(0))();

  IntColumn get subtotal =>
      integer().check(subtotal.isBiggerOrEqualValue(0))();
}