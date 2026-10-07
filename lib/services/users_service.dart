import 'package:drift/drift.dart';

import '../core/database/app_database.dart';

/// Service responsable de l'accès direct à la base de données Drift pour les utilisateurs.
class UsersService {
  final AppDatabase database;

  UsersService(this.database);

  /// Vérifie les identifiants et connecte un utilisateur actif.
  Future<User?> login(String username, String password) async {
    return await (database.select(database.users)
          ..where((user) =>
              user.username.equals(username) &
              user.passwordHash.equals(password) &
              user.isActive.equals(1)))
        .getSingleOrNull();
  }

  Future<int> createUser({
    required String username,
    required String fullName,
    required String passwordHash,
    required String role,
  }) async {
    return await database
        .into(database.users)
        .insert(
          UsersCompanion.insert(
            username: username,
            fullName: fullName,
            passwordHash: passwordHash,
            role: role,
            createdAt: DateTime.now().toIso8601String(),
            updatedAt: DateTime.now().toIso8601String(),
          ),
        );
  }

  Future<User?> findByUsername(String username) async {
    return await (database.select(
      database.users,
    )..where((user) => user.username.equals(username))).getSingleOrNull();
  }

  Future<User?> findById(int id) async {
    return await (database.select(
      database.users,
    )..where((user) => user.id.equals(id))).getSingleOrNull();
  }

  /// Filtrage des utilisateurs en temps réel
  Stream<List<User>> watchFilterUsers({
    String? name,
    String? searchQuery,
    bool ascending = true,
    String? role,
    String? fullName,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? limit,
    int? offset,
  }) {
    return _buildFilteredQuery(
      searchQuery: searchQuery,
      name: name,
      fullName: fullName,
      role: role,
      createdAt: createdAt,
      updatedAt: updatedAt,
      offset: offset,
      limit: limit,
      ascending: ascending,
    ).watch();
  }

  /// Filtrage des utilisateurs
  Future<List<User>> filterUsers({
    String? name,
    String? searchQuery,
    bool ascending = true,
    String? role,
    String? fullName,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? limit,
    int? offset,
  }) async {
    return await _buildFilteredQuery(
      searchQuery: searchQuery,
      name: name,
      fullName: fullName,
      role: role,
      createdAt: createdAt,
      updatedAt: updatedAt,
      offset: offset,
      limit: limit,
      ascending: ascending,
    ).get();
  }

  SimpleSelectStatement<$UsersTable, User> _buildFilteredQuery({
    DateTime? createdAt,
    DateTime? updatedAt,
    String? name,
    String? role,
    String? fullName,
    int? limit,
    int? offset,
    bool ascending = true,
    String? searchQuery,
  }) {
    final query = database.select(database.users);

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final cleanQuery = searchQuery.trim();
      query.where(
        (user) =>
            user.username.contains(cleanQuery) |
            user.fullName.contains(cleanQuery) |
            user.role.contains(cleanQuery),
      );
    }
    if (name != null && name.trim().isNotEmpty) {
      query.where((user) => user.username.contains(name.trim()));
    }
    if (role != null && role.trim().isNotEmpty) {
      query.where((user) => user.role.equals(role.trim()));
    }
    if (fullName != null && fullName.trim().isNotEmpty) {
      query.where((user) => user.fullName.contains(fullName.trim()));
    }
    if (createdAt != null) {
      query.where(
        (user) =>
            user.createdAt.isBiggerOrEqualValue(createdAt.toIso8601String()),
      );
    }
    if (updatedAt != null) {
      query.where(
        (user) =>
            user.updatedAt.isSmallerOrEqualValue(updatedAt.toIso8601String()),
      );
    }

    if (limit != null) {
      query.limit(limit, offset: offset);
    }

    return query;
  }
   Future<bool>  activerUser(int id) async {
    final updated = await (database.update(database.users)
              ..where((user) => user.id.equals(id)))
            .write(const UsersCompanion(isActive: Value(1)));
    return updated > 0;
   }
  Future<bool> deactivateUser(int id) async {
    final updated =
        await (database.update(database.users)
              ..where((user) => user.id.equals(id)))
            .write(const UsersCompanion(isActive: Value(0)));

    return updated > 0;
  }
}
