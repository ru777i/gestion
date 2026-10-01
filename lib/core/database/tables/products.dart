import 'package:drift/drift.dart';

import 'categories.dart';

class Products extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get uuid => text().unique()();

  TextColumn get name => text()();

  IntColumn get categoryId => integer()
      .named('category_id')
      .nullable()
      .references(Categories, #id, onDelete: KeyAction.setNull)();

  TextColumn get barcode => text().unique().withDefault(const Constant(''))();

  TextColumn get photoPath => text().named('photo_path').nullable()();

  IntColumn get purchasePrice => integer()
      .named('purchase_price')
      .check(purchasePrice.isBiggerOrEqualValue(0))();

  IntColumn get salePrice =>
      integer().named('sale_price').check(salePrice.isBiggerOrEqualValue(0))();

  IntColumn get stockQuantity => integer()
      .named('stock_quantity')
      .check(stockQuantity.isBiggerOrEqualValue(0))();

  IntColumn get alertThreshold => integer()
      .named('alert_threshold')
      .check(alertThreshold.isBiggerOrEqualValue(0))();

  IntColumn get isActive => integer()
      .named('is_active')
      .check(isActive.isIn(const [0, 1]))
      .withDefault(const Constant(1))();

  TextColumn get createdAt => text().named('created_at')();

  TextColumn get updatedAt => text().named('updated_at')();
}
