import '../core/database/app_database.dart';
import '../services/customers_service.dart';

/// Repository pour la gestion des clients (Domaine / Métier)
class CustomersRepository {
  final CustomersService service;

  CustomersRepository(this.service);

  Future<int> createCustomer({
    required String name,
    String? phone,
    String? address,
    int creditLimit = 0,
    int currentCredit = 0,
  }) {
    return service.createCustomer(
      name: name,
      phone: phone,
      address: address,
      creditLimit: creditLimit,
      currentCredit: currentCredit,
    );
  }

  Future<List<Customer>> filterCustomers({String? searchQuery}) {
    return service.filterCustomers(searchQuery: searchQuery);
  }

  Stream<List<Customer>> watchFilteredCustomers({String? searchQuery}) {
    return service.watchFilteredCustomers(searchQuery: searchQuery);
  }

  Future<Customer?> findById(int id) {
    return service.findById(id);
  }

  Future<bool> updateCustomer({
    required int id,
    String? name,
    String? phone,
    String? address,
    int? creditLimit,
    int? currentCredit,
    int? isActive,
  }) {
    return service.updateCustomer(
      id: id,
      name: name,
      phone: phone,
      address: address,
      creditLimit: creditLimit,
      currentCredit: currentCredit,
      isActive: isActive,
    );
  }

  Future<int> deleteCustomer(int id) {
    return service.deleteCustomer(id);
  }
}
