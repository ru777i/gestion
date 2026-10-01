import 'package:drift/drift.dart';

import '../core/database/app_database.dart';

/// Service responsable de l'accès direct à la base de données Drift pour les catégories.
class CategoriesService {
  final AppDatabase database;

  CategoriesService(this.database);

  /// Insère une nouvelle catégorie en base de données.
  Future<int> createCategory({required String nom}) async {
    final now = DateTime.now().toIso8601String();

    return await database.into(database.categories).insert(
          CategoriesCompanion.insert(
            name: nom,
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  /// Récupère la liste des catégories filtrées (Future)
  Future<List<Category>> filterCategories({
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
    bool ascending = true,
    int? limit,
    int? offset,
  }) async {
    return await _buildFilteredQuery(
      searchQuery: searchQuery,
      startDate: startDate,
      endDate: endDate,
      ascending: ascending,
      limit: limit,
      offset: offset,
    ).get();
  }

  /// Diffuse un flux en temps réel des catégories filtrées (Stream)
  Stream<List<Category>> watchFilteredCategories({
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
    bool ascending = true,
    int? limit,
    int? offset,
  }) {
    return _buildFilteredQuery(
      searchQuery: searchQuery,
      startDate: startDate,
      endDate: endDate,
      ascending: ascending,
      limit: limit,
      offset: offset,
    ).watch();
  }

  /// Construit la requête SELECT paramétrée dans Drift
  SimpleSelectStatement<$CategoriesTable, Category> _buildFilteredQuery({
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
    bool ascending = true,
    int? limit,
    int? offset,
  }) {
    final query = database.select(database.categories);

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      query.where((c) => c.name.contains(searchQuery.trim()));
    }

    if (startDate != null) {
      final startIso = startDate.toIso8601String();
      query.where((c) => c.createdAt.isBiggerOrEqualValue(startIso));
    }

    if (endDate != null) {
      final endIso = endDate.toIso8601String();
      query.where((c) => c.createdAt.isSmallerOrEqualValue(endIso));
    }

    query.orderBy([
      (c) => OrderingTerm(
            expression: c.name,
            mode: ascending ? OrderingMode.asc : OrderingMode.desc,
          ),
    ]);

    if (limit != null) {
      query.limit(limit, offset: offset);
    }

    return query;
  }

  /// Recherche une catégorie par son ID
  Future<Category?> findById(int id) async {
    return await (database.select(database.categories)
          ..where((c) => c.id.equals(id)))
        .getSingleOrNull();
  }

  /// Recherche une catégorie par son nom
  Future<Category?> findByName(String nom) async {
    return await (database.select(database.categories)
          ..where((c) => c.name.equals(nom)))
        .getSingleOrNull();
  }

  /// Met à jour le nom d'une catégorie
  Future<bool> updateCategory(int id, {required String nom}) async {
    final now = DateTime.now().toIso8601String();

    final updatedRows = await (database.update(database.categories)
          ..where((c) => c.id.equals(id)))
        .write(
      CategoriesCompanion(
        name: Value(nom),
        updatedAt: Value(now),
      ),
    );

    return updatedRows > 0;
  }

  /// Supprime une catégorie par son ID
  Future<int> deleteCategory(int id) async {
    return await (database.delete(database.categories)
          ..where((c) => c.id.equals(id)))
        .go();
  }
}
