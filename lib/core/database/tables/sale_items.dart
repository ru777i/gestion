import 'package:drift/drift.dart';

import 'products.dart';
import 'sales.dart';

class SaleItems extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get saleId => integer()
      .named('sale_id')
      .references(Sales, #id, onDelete: KeyAction.cascade)();

  IntColumn get productId =>
      integer().named('product_id').references(Products, #id)();

  IntColumn get quantity => integer().check(quantity.isBiggerThanValue(0))();

  IntColumn get unitPrice =>
      integer().named('unit_price').check(unitPrice.isBiggerOrEqualValue(0))();

  IntColumn get subtotal => integer().check(subtotal.isBiggerOrEqualValue(0))();
}
