import '../core/database/app_database.dart';
import '../core/utils/hash_util.dart';
import '../services/users_service.dart';

/// Repository de la couche Domaine/Métier gérant les utilisateurs.
/// Il dépend du UsersService pour les opérations d'accès aux données.
class UsersRepository {
  final UsersService service;

  UsersRepository(this.service);

  /// Authentifie un utilisateur en vérifiant son existence, son statut et son mot de passe haché.
  Future<User?> login(String username, String password) async {
    final user = await service.findByUsername(username.trim());
    if (user == null) {
      return null;
    }
    if (user.isActive != 1) {
      throw Exception('Ce compte utilisateur a été désactivé.');
    }

    final hashedPassword = HashUtil.hashPassword(password);
    if (user.passwordHash != hashedPassword) {
      return null;
    }

    return user;
  }

  /// Active un utilisateur désactivé.
  Future<bool> activerUser(int id) {
    return service.activerUser(id);
  }

  /// Supprime définitivement un utilisateur.
  Future<bool> deleteUser(int id) {
    return service.deleteUser(id);
  }

  /// Crée un utilisateur après vérification de l'unicité du nom d'utilisateur.
  Future<int> createUser({
    required String username,
    required String fullName,
    required String password,
    required String role,
  }) async {
    final existingUser = await service.findByUsername(username.trim());
    if (existingUser != null) {
      throw Exception(
        'Le nom d\'utilisateur "${username.trim()}" est déjà utilisé.',
      );
    }

    final hashedPassword = HashUtil.hashPassword(password);
    return service.createUser(
      username: username.trim(),
      fullName: fullName.trim(),
      passwordHash: hashedPassword,
      role: role,
    );
  }

  Future<List<User>> filterUsers({
    String? searchQuery,
    String? role,
    bool ascending = true,
  }) {
    return service.filterUsers(
      searchQuery: searchQuery,
      role: role,
      ascending: ascending,
    );
  }

  Future<User?> findByUsername(String username) {
    return service.findByUsername(username.trim());
  }

  Future<User?> findById(int id) {
    return service.findById(id);
  }

  /// Met à jour les informations d'un utilisateur et optionnellement son mot de passe haché.
  Future<bool> updateUser({
    required int id,
    String? fullname,
    required String username,
    required String role,
    String? passwordHash,
  }) async {
    String? hashedPassword;

    if (passwordHash != null && passwordHash.trim().isNotEmpty) {
      hashedPassword = HashUtil.hashPassword(passwordHash.trim());
    }

    return await service.updateUser(
      id: id,
      fullName: fullname,
      username: username,
      role: role,
      passwordHash: hashedPassword,
    );
  }

  Future<bool> deactivateUser(int id) {
    return service.deactivateUser(id);
  }
}
