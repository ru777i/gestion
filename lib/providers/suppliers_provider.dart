import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_stock/core/database/database_provider.dart';
import 'package:gestion_stock/services/suppliers_service.dart';
import '../repositories/suppliers_repository.dart';

final suppliersServiceProvider = Provider<SuppliersService>((ref) {
  return SuppliersService(ref.watch(appDatabaseProvider));
});

final suppliersRepositoryProvider = Provider<SuppliersRepository>((ref) {
  return SuppliersRepository(ref.watch(suppliersServiceProvider));
});
