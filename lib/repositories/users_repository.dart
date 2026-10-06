import '../core/database/app_database.dart';
import '../core/utils/hash_util.dart';
import '../services/users_service.dart';

/// Repository de la couche Domaine/Métier gérant les utilisateurs.
/// Il dépend du UsersService pour les opérations d'accès aux données.
class UsersRepository {
  final UsersService service;

  UsersRepository(this.service);

  /// Authentifie un utilisateur en hachant d'abord le mot de passe en clair en SHA-256.
  Future<User?> login(String username, String password) {
    final hashedPassword = HashUtil.hashPassword(password);
    return service.login(username, hashedPassword);
  }

  /// Crée un utilisateur en hachant automatiquement son mot de passe en clair en SHA-256.
  Future<int> createUser({
    required String username,
    required String fullName,
    required String password,
    required String role,
  }) {
    final hashedPassword = HashUtil.hashPassword(password);
    return service.createUser(
      username: username,
      fullName: fullName,
      passwordHash: hashedPassword,
      role: role,
    );
  }

  Future<User?> findByUsername(String username) {
    return service.findByUsername(username);
  }

  Future<User?> findById(int id) {
    return service.findById(id);
  }

  Future<bool> deactivateUser(int id) {
    return service.deactivateUser(id);
  }
}
