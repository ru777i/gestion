import '../core/database/app_database.dart';
import '../services/categories_service.dart';

/// Repository pour la gestion des catégories (Domaine / Métier)
class CategoriesRepository {
  final CategoriesService service;

  CategoriesRepository(this.service);

  Future<int> createCategory({required String nom}) {
    return service.createCategory(nom: nom);
  }

  Future<List<Category>> filterCategories({
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
    bool ascending = true,
    int? limit,
    int? offset,
  }) {
    return service.filterCategories(
      searchQuery: searchQuery,
      startDate: startDate,
      endDate: endDate,
      ascending: ascending,
      limit: limit,
      offset: offset,
    );
  }

  Stream<List<Category>> watchFilteredCategories({
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
    bool ascending = true,
    int? limit,
    int? offset,
  }) {
    return service.watchFilteredCategories(
      searchQuery: searchQuery,
      startDate: startDate,
      endDate: endDate,
      ascending: ascending,
      limit: limit,
      offset: offset,
    );
  }

  Future<Category?> findById(int id) {
    return service.findById(id);
  }

  Future<Category?> findByName(String nom) {
    return service.findByName(nom);
  }

  Future<bool> updateCategory(int id, {required String nom}) {
    return service.updateCategory(id, nom: nom);
  }

  Future<int> deleteCategory(int id) {
    return service.deleteCategory(id);
  }
}
