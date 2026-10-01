import 'package:drift/drift.dart';

import 'customers.dart';

class CreditPayments extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get customerId => integer()
      .named('customer_id')
      .references(
    Customers,
    #id,
    onDelete: KeyAction.cascade,
  )();

  IntColumn get amount =>
      integer().check(amount.isBiggerThanValue(0))();

  TextColumn get paymentMethod => text().named('payment_method')();

  TextColumn get notes => text().nullable()();

  TextColumn get createdAt => text().named('created_at')();
}