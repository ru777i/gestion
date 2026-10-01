import 'package:drift/drift.dart';

class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get tableNam => text().named('table_name')();

  TextColumn get recordUuid => text().named('record_uuid')();

  TextColumn get operation => text().check(
    operation.isIn(const [
      'insert',
      'update',
      'delete',
    ]),
  )();

  TextColumn get payload => text()();

  IntColumn get attempts =>
      integer().withDefault(const Constant(0))();

  TextColumn get createdAt => text().named('created_at')();

  TextColumn get syncedAt => text().named('synced_at').nullable()();
}