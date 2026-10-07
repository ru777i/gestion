import 'package:drift/drift.dart';

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get username => text().unique()();

  TextColumn get fullName => text().named('full_name')();

  TextColumn get passwordHash => text().named('password_hash')();

  TextColumn get role => text().check(
    role.isIn(const ['patron', 'vendeur', 'admin', 'user', 'caissier']),
  )();

  IntColumn get isActive => integer()
      .check(isActive.isIn(const [0, 1]))
      .withDefault(const Constant(1))();

  TextColumn get createdAt => text().named('created_at')();

  TextColumn get updatedAt => text().named('updated_at')();
}
