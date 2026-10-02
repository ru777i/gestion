import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_stock/core/database/app_database.dart';
import 'package:gestion_stock/core/database/database_provider.dart';
import 'package:gestion_stock/services/settings_service.dart';
import '../repositories/settings_repository.dart';

final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService(ref.watch(appDatabaseProvider));
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(settingsServiceProvider));
});

final settingStreamProvider = StreamProvider.family<String?, String>((ref, key) {
  final repository = ref.watch(settingsRepositoryProvider);
  return repository.watchSetting(key);
});
