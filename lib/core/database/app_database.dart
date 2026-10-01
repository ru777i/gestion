import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';


import 'tables/credit_payments.dart';
import 'tables/customers.dart';
import 'tables/products.dart';
import 'tables/sale_items.dart';
import 'tables/sales.dart';
import 'tables/settings.dart';
import 'tables/stock_entries.dart';
import 'tables/stock_entry_items.dart';
import 'tables/stock_movements.dart';
import 'tables/suppliers.dart';
import 'tables/sync_queue.dart';
import 'tables/users.dart';
import 'tables/categories.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Products,
    Customers,
    Sales,
    SaleItems,
    CreditPayments,
    Suppliers,
    StockEntries,
    StockEntryItems,
    StockMovements,
    Settings,
    SyncQueue,
    Categories,
    Users
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      beforeOpen: (OpeningDetails details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'stockpro');
}