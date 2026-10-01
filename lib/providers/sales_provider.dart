import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_stock/core/database/database_provider.dart';
import 'package:gestion_stock/services/sales_service.dart';
import '../repositories/sales_repository.dart';

final salesServiceProvider = Provider<SalesService>((ref) {
  return SalesService(ref.watch(appDatabaseProvider));
});

final salesRepositoryProvider = Provider<SalesRepository>((ref) {
  return SalesRepository(ref.watch(salesServiceProvider));
});
