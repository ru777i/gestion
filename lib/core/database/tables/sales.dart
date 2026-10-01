import 'package:drift/drift.dart';

import 'customers.dart';
import 'users.dart';

class Sales extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get uuid => text().unique()();

  IntColumn get customerId => integer()
      .named('customer_id')
      .nullable()
      .references(Customers, #id, onDelete: KeyAction.setNull)();

  IntColumn get totalAmount => integer()
      .named('total_amount')
      .check(totalAmount.isBiggerOrEqualValue(0))();

  IntColumn get amountPaid => integer()
      .named('amount_paid')
      .check(amountPaid.isBiggerOrEqualValue(0))();

  TextColumn get paymentMethod => text().named('payment_method')();

  TextColumn get paymentStatus => text().named('payment_status')();

  IntColumn get userId => integer().named('user_id').references(Users, #id)();

  TextColumn get createdAt => text().named('created_at')();

  TextColumn get updatedAt => text().named('updated_at')();
}
