import 'package:drift/drift.dart';

import '../core/database/app_database.dart';

/// Service gérant la persistance des fournisseurs dans Drift.
class SuppliersService {
  final AppDatabase database;

  SuppliersService(this.database);

  Future<int> createSupplier({
    required String name,
    String? phone,
    String? address,
  }) async {
    final now = DateTime.now().toIso8601String();

    return await database.into(database.suppliers).insert(
          SuppliersCompanion.insert(
            name: name,
            phone: Value(phone),
            address: Value(address),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<List<Supplier>> filterSuppliers({String? searchQuery}) async {
    return await _buildFilteredQuery(searchQuery: searchQuery).get();
  }

  Stream<List<Supplier>> watchFilteredSuppliers({String? searchQuery}) {
    return _buildFilteredQuery(searchQuery: searchQuery).watch();
  }

  SimpleSelectStatement<$SuppliersTable, Supplier> _buildFilteredQuery({
    String? searchQuery,
  }) {
    final query = database.select(database.suppliers);

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final clean = searchQuery.trim();
      query.where(
        (s) => s.name.contains(clean) | s.phone.contains(clean),
      );
    }

    return query;
  }

  Future<Supplier?> findById(int id) async {
    return await (database.select(database.suppliers)
          ..where((s) => s.id.equals(id)))
        .getSingleOrNull();
  }

  Future<bool> updateSupplier({
    required int id,
    String? name,
    String? phone,
    String? address,
  }) async {
    final now = DateTime.now().toIso8601String();

    final updated = await (database.update(database.suppliers)
          ..where((s) => s.id.equals(id)))
        .write(
      SuppliersCompanion(
        name: name != null ? Value(name) : const Value.absent(),
        phone: phone != null ? Value(phone) : const Value.absent(),
        address: address != null ? Value(address) : const Value.absent(),
        updatedAt: Value(now),
      ),
    );

    return updated > 0;
  }

  Future<int> deleteSupplier(int id) async {
    return await (database.delete(database.suppliers)
          ..where((s) => s.id.equals(id)))
        .go();
  }
}
