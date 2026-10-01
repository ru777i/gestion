import '../core/database/app_database.dart';
import '../services/settings_service.dart';

/// Repository pour la gestion des paramètres de l'application (Domaine / Métier)
class SettingsRepository {
  final SettingsService service;

  SettingsRepository(this.service);

  Future<void> setSetting(String key, String value) {
    return service.setSetting(key, value);
  }

  Future<String?> getSetting(String key) {
    return service.getSetting(key);
  }

  Stream<String?> watchSetting(String key) {
    return service.watchSetting(key);
  }

  Future<List<Setting>> getAllSettings() {
    return service.getAllSettings();
  }
}
