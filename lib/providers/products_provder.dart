import 'package:gestion_stock/core/database/database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_stock/services/products_service.dart';

import '../repositories/products_repository.dart';

final productsServiceProvider= Provider<ProductsService>((ref) {
  return ProductsService(ref.watch(appDatabaseProvider));
});
final productsRepositoryProvider = Provider<ProductsRepository>((ref) {
  return ProductsRepository(ref.watch(productsServiceProvider));
});

