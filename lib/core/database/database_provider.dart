import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';

/// Provider offrant l'instance unique de AppDatabase avec fermeture automatique lors de la suppression du provider contextuel.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});
