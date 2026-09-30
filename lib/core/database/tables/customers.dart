import 'package:drift/drift.dart';

class Customers extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text()();

  TextColumn get phone => text().nullable()();

  TextColumn get address => text().nullable()();

  IntColumn get creditLimit => integer()
      .named('credit_limit')
      .check(creditLimit.isBiggerOrEqualValue(0))();

  IntColumn get currentCredit => integer()
      .named('current_credit')
      .check(currentCredit.isBiggerOrEqualValue(0))();

  IntColumn get isActive => integer()
      .named('is_active')
      .check(isActive.isIn(const [0, 1]))
      .withDefault(const Constant(1))();

  TextColumn get createdAt => text().named('created_at')();

  TextColumn get updatedAt => text().named('updated_at')();
}