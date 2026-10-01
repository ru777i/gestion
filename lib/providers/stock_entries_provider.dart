import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_stock/core/database/database_provider.dart';
import 'package:gestion_stock/services/stock_entries_service.dart';
import '../repositories/stock_entries_repository.dart';

final stockEntriesServiceProvider = Provider<StockEntriesService>((ref) {
  return StockEntriesService(ref.watch(appDatabaseProvider));
});

final stockEntriesRepositoryProvider = Provider<StockEntriesRepository>((ref) {
  return StockEntriesRepository(ref.watch(stockEntriesServiceProvider));
});
