import '../core/database/app_database.dart';
import '../services/suppliers_service.dart';

/// Repository pour la gestion des fournisseurs (Domaine / Métier)
class SuppliersRepository {
  final SuppliersService service;

  SuppliersRepository(this.service);

  Future<int> createSupplier({
    required String name,
    String? phone,
    String? address,
  }) {
    return service.createSupplier(
      name: name,
      phone: phone,
      address: address,
    );
  }

  Future<List<Supplier>> filterSuppliers({String? searchQuery}) {
    return service.filterSuppliers(searchQuery: searchQuery);
  }

  Stream<List<Supplier>> watchFilteredSuppliers({String? searchQuery}) {
    return service.watchFilteredSuppliers(searchQuery: searchQuery);
  }

  Future<Supplier?> findById(int id) {
    return service.findById(id);
  }

  Future<bool> updateSupplier({
    required int id,
    String? name,
    String? phone,
    String? address,
  }) {
    return service.updateSupplier(
      id: id,
      name: name,
      phone: phone,
      address: address,
    );
  }

  Future<int> deleteSupplier(int id) {
    return service.deleteSupplier(id);
  }
}
