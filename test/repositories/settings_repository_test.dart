import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_stock/core/database/app_database.dart';
import 'package:gestion_stock/repositories/settings_repository.dart';
import 'package:gestion_stock/services/settings_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late SettingsService service;
  late SettingsRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    service = SettingsService(database);
    repository = SettingsRepository(service);
  });

  tearDown(() async {
    await database.close();
  });

  test('Définir et récupérer un paramètre', () async {
    await repository.setSetting('theme', 'dark');

    final value = await repository.getSetting('theme');
    expect(value, 'dark');

    await repository.setSetting('theme', 'light');
    final updatedValue = await repository.getSetting('theme');
    expect(updatedValue, 'light');

    final all = await repository.getAllSettings();
    expect(all.length, 1);
  });
}
