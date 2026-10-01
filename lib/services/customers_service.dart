import 'package:drift/drift.dart';

import '../core/database/app_database.dart';

/// Service gérant la persistance des clients dans Drift.
class CustomersService {
  final AppDatabase database;

  CustomersService(this.database);

  Future<int> createCustomer({
    required String name,
    String? phone,
    String? address,
    int creditLimit = 0,
    int currentCredit = 0,
  }) async {
    final now = DateTime.now().toIso8601String();

    return await database.into(database.customers).insert(
          CustomersCompanion.insert(
            name: name,
            phone: Value(phone),
            address: Value(address),
            creditLimit: creditLimit,
            currentCredit: currentCredit,
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<List<Customer>> filterCustomers({String? searchQuery}) async {
    return await _buildFilteredQuery(searchQuery: searchQuery).get();
  }

  Stream<List<Customer>> watchFilteredCustomers({String? searchQuery}) {
    return _buildFilteredQuery(searchQuery: searchQuery).watch();
  }

  SimpleSelectStatement<$CustomersTable, Customer> _buildFilteredQuery({
    String? searchQuery,
  }) {
    final query = database.select(database.customers);

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final clean = searchQuery.trim();
      query.where(
        (c) => c.name.contains(clean) | c.phone.contains(clean),
      );
    }

    return query;
  }

  Future<Customer?> findById(int id) async {
    return await (database.select(database.customers)
          ..where((c) => c.id.equals(id)))
        .getSingleOrNull();
  }

  Future<bool> updateCustomer({
    required int id,
    String? name,
    String? phone,
    String? address,
    int? creditLimit,
    int? currentCredit,
    int? isActive,
  }) async {
    final now = DateTime.now().toIso8601String();

    final updated = await (database.update(database.customers)
          ..where((c) => c.id.equals(id)))
        .write(
      CustomersCompanion(
        name: name != null ? Value(name) : const Value.absent(),
        phone: phone != null ? Value(phone) : const Value.absent(),
        address: address != null ? Value(address) : const Value.absent(),
        creditLimit:
            creditLimit != null ? Value(creditLimit) : const Value.absent(),
        currentCredit: currentCredit != null
            ? Value(currentCredit)
            : const Value.absent(),
        isActive: isActive != null ? Value(isActive) : const Value.absent(),
        updatedAt: Value(now),
      ),
    );

    return updated > 0;
  }

  Future<int> deleteCustomer(int id) async {
    return await (database.delete(database.customers)
          ..where((c) => c.id.equals(id)))
        .go();
  }
}
