import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gestion_stock/core/database/app_database.dart';
import 'package:gestion_stock/repositories/users_repository.dart';
import 'package:gestion_stock/services/users_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late UsersService service;
  late UsersRepository repository;

  setUp(() {
    database = AppDatabase(
      NativeDatabase.memory(),
    );

    service = UsersService(database);
    repository = UsersRepository(service);
  });

  tearDown(() async {
    await database.close();
  });

  test('Un utilisateur peut être créé', () async {
    final id = await repository.createUser(
      username: 'admin',
      fullName: 'Administrateur',
      password: 'hash-test-123',
      role: 'patron',
    );

    final user = await repository.findById(id);

    expect(user, isNotNull);
    expect(user!.username, 'admin');
    expect(user.fullName, 'Administrateur');
    expect(user.role, 'patron');
    expect(user.isActive, 1);
  });

  test('Connexion utilisateur valide et invalide avec hachage', () async {
    await repository.createUser(
      username: 'patron1',
      fullName: 'Boss',
      password: 'pass123',
      role: 'patron',
    );

    final loggedUser = await repository.login('patron1', 'pass123');
    expect(loggedUser, isNotNull);
    expect(loggedUser!.username, 'patron1');

    final wrongPass = await repository.login('patron1', 'badpass');
    expect(wrongPass, isNull);

    final wrongUser = await repository.login('unknown', 'pass123');
    expect(wrongUser, isNull);
  });

  test('Un utilisateur peut être recherché par nomUtilisateur', () async {
    await repository.createUser(
      username: 'vendeur1',
      fullName: 'Jean Dupont',
      password: 'hash-vendeur',
      role: 'vendeur',
    );

    final user = await repository.findByUsername('vendeur1');

    expect(user, isNotNull);
    expect(user!.username, 'vendeur1');
    expect(user.fullName, 'Jean Dupont');
    expect(user.role, 'vendeur');
  });

  test('Une recherche avec un nomUtilisateur inexistant retourne null', () async {
    final user = await repository.findByUsername('inexistant');

    expect(user, isNull);
  });

  test('Mettre à jour les informations d’un utilisateur sans modifier son mot de passe', () async {
    final id = await repository.createUser(
      username: 'vendeur_old',
      fullName: 'Ancien Nom',
      password: 'secret123',
      role: 'vendeur',
    );

    final success = await repository.updateUser(
      id: id,
      username: 'vendeur_modifie',
      fullname: 'Nouveau Nom',
      role: 'admin',
    );

    expect(success, isTrue);

    final updatedUser = await repository.findById(id);
    expect(updatedUser, isNotNull);
    expect(updatedUser!.username, 'vendeur_modifie');
    expect(updatedUser.fullName, 'Nouveau Nom');
    expect(updatedUser.role, 'admin');

    // Le mot de passe initial doit être conservé et toujours fonctionnel
    final loginResult = await repository.login('vendeur_modifie', 'secret123');
    expect(loginResult, isNotNull);
  });

  test('Mettre à jour le mot de passe d’un utilisateur', () async {
    final id = await repository.createUser(
      username: 'vendeur_pass',
      fullName: 'Jean Pass',
      password: 'ancien_pass',
      role: 'vendeur',
    );

    final success = await repository.updateUser(
      id: id,
      username: 'vendeur_pass',
      fullname: 'Jean Pass',
      role: 'vendeur',
      passwordHash: 'nouveau_pass',
    );

    expect(success, isTrue);

    // Connexion avec l'ancien mot de passe échoue
    final oldLogin = await repository.login('vendeur_pass', 'ancien_pass');
    expect(oldLogin, isNull);

    // Connexion avec le nouveau mot de passe réussit
    final newLogin = await repository.login('vendeur_pass', 'nouveau_pass');
    expect(newLogin, isNotNull);
  });

  test('La mise à jour d’un utilisateur inexistant retourne false', () async {
    final result = await repository.updateUser(
      id: 9999,
      username: 'inexistant',
      role: 'vendeur',
    );

    expect(result, isFalse);
  });

  test('Un utilisateur peut être désactivé', () async {
    final id = await repository.createUser(
      username: 'vendeur2',
      fullName: 'Paul Martin',
      password: 'hash-paul',
      role: 'vendeur',
    );

    final result = await repository.deactivateUser(id);

    expect(result, isTrue);

    final user = await repository.findById(id);

    expect(user, isNotNull);
    expect(user!.isActive, 0);
  });

  test('La désactivation d’un utilisateur inexistant retourne false', () async {
    final result = await repository.deactivateUser(999);
    expect(result, isFalse);
  });
}
