
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/database/database_provider.dart';
import '../repositories/sales_dashboard_repository.dart';


final salesDashboardRepositoryProvider =
Provider<SalesDashboardRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);

  return SalesDashboardRepository(database);
});

final currentWeekGrossRevenueProvider =
FutureProvider<int>((ref) {
  final repository = ref.watch(
    salesDashboardRepositoryProvider,
  );

  return repository.getCurrentWeekGrossRevenue();
});