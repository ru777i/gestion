import '../core/database/app_database.dart';

/// Service gérant les paramètres applicatifs (clé / valeur) dans Drift.
class SettingsService {
  final AppDatabase database;

  SettingsService(this.database);

  Future<void> setSetting(String key, String value) async {
    await database.into(database.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: key,
            value: value,
          ),
        );
  }

  Future<String?> getSetting(String key) async {
    final setting = await (database.select(database.settings)
          ..where((s) => s.key.equals(key)))
        .getSingleOrNull();
    return setting?.value;
  }

  Stream<String?> watchSetting(String key) {
    return (database.select(database.settings)..where((s) => s.key.equals(key)))
        .watchSingleOrNull()
        .map((setting) => setting?.value);
  }

  Future<List<Setting>> getAllSettings() async {
    return await database.select(database.settings).get();
  }
}
