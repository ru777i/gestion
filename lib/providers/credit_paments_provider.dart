import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_stock/services/credit_payments_service.dart';
import 'package:gestion_stock/core/database/database_provider.dart';

import '../repositories/credit_payments_repository.dart';
final creditPaymentsServiceProvider = Provider<CreditPaymentsService>((ref) {
  return CreditPaymentsService(ref.watch(appDatabaseProvider));
});
final creditPaymentsRepositoryProvider = Provider<CreditPaymentsRepository>((ref) {
  return CreditPaymentsRepository(ref.watch(creditPaymentsServiceProvider));
});