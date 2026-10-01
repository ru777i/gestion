import '../core/database/app_database.dart';
import '../services/users_service.dart';

/// Repository de la couche Domaine/Métier gérant les utilisateurs.
/// Il dépend du UsersService pour les opérations d'accès aux données.
class UsersRepository {
  final UsersService service;

  UsersRepository(this.service);

  Future<int> createUser({
    required String username,
    required String fullName,
    required String passwordHash,
    required String role,
  }) {
    return service.createUser(
      username: username,
      fullName: fullName,
      passwordHash: passwordHash,
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
