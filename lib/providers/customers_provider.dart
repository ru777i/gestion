import 'package:gestion_stock/core/database/database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_stock/services/customers_service.dart';

import '../repositories/customers_repository.dart';
final customersServiceProvider= Provider<CustomersService>((ref) {
  return CustomersService(ref.watch(appDatabaseProvider));
});
final CustomersRepositoryProvider = Provider<CustomersRepository>((ref) {
  return CustomersRepository(ref.watch(customersServiceProvider));
});

