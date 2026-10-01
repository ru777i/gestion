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
      passwordHash: 'hash-test-123',
      role: 'patron',
    );

    final user = await repository.findById(id);

    expect(user, isNotNull);
    expect(user!.username, 'admin');
    expect(user.fullName, 'Administrateur');
    expect(user.passwordHash, 'hash-test-123');
    expect(user.role, 'patron');
    expect(user.isActive, 1);
  });

  test('Un utilisateur peut être recherché par nomUtilisateur', () async {
    await repository.createUser(
      username: 'vendeur1',
      fullName: 'Jean Dupont',
      passwordHash: 'hash-vendeur',
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

  test('Un utilisateur peut être désactivé', () async {
    final id = await repository.createUser(
      username: 'vendeur2',
      fullName: 'Paul Martin',
      passwordHash: 'hash-paul',
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
