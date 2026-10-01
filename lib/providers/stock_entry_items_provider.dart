import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_stock/core/database/database_provider.dart';
import '../repositories/stock_entry_items_repository.dart';

final stockEntryItemsRepositoryProvider = Provider<StockEntryItemsRepository>((ref) {
  return StockEntryItemsRepository(ref.watch(appDatabaseProvider));
});
