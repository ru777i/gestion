import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_stock/core/database/app_database.dart';
import 'package:gestion_stock/repositories/categories_repository.dart';
import 'package:gestion_stock/services/categories_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late CategoriesService service;
  late CategoriesRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    service = CategoriesService(database);
    repository = CategoriesRepository(service);
  });

  tearDown(() async {
    await database.close();
  });

  test('Créer et rechercher une catégorie', () async {
    final id = await repository.createCategory(nom: 'Électronique');
    final category = await repository.findById(id);

    expect(category, isNotNull);
    expect(category!.name, 'Électronique');

    final byName = await repository.findByName('Électronique');
    expect(byName, isNotNull);
    expect(byName!.id, id);
  });

  test('Mettre à jour et supprimer une catégorie', () async {
    final id = await repository.createCategory(nom: 'Alimentation');
    final updated = await repository.updateCategory(id, nom: 'Boissons et Nourriture');
    expect(updated, isTrue);

    final category = await repository.findById(id);
    expect(category!.name, 'Boissons et Nourriture');

    final deletedCount = await repository.deleteCategory(id);
    expect(deletedCount, 1);

    final deleted = await repository.findById(id);
    expect(deleted, isNull);
  });
}
