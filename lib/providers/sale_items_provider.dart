import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_stock/core/database/database_provider.dart';
import '../repositories/sale_items_repository.dart';

final saleItemsRepositoryProvider = Provider<SaleItemsRepository>((ref) {
  return SaleItemsRepository(ref.watch(appDatabaseProvider));
});
