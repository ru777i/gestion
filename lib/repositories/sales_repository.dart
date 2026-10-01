import '../core/database/app_database.dart';
import '../services/sales_service.dart';

/// Repository pour la gestion des ventes (Domaine / Métier)
class SalesRepository {
  final SalesService service;

  SalesRepository(this.service);

  Future<int> createSaleWithItems({
    required String uuid,
    int? customerId,
    required int totalAmount,
    required int amountPaid,
    required String paymentMethod,
    required String paymentStatus,
    required int userId,
    required List<SaleItemsCompanion> items,
  }) {
    return service.createSaleWithItems(
      uuid: uuid,
      customerId: customerId,
      totalAmount: totalAmount,
      amountPaid: amountPaid,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus,
      userId: userId,
      items: items,
    );
  }

  Future<Sale?> findById(int id) {
    return service.findById(id);
  }

  Future<List<SaleItem>> findItemsBySaleId(int saleId) {
    return service.findItemsBySaleId(saleId);
  }

  Stream<List<Sale>> watchSales({int? customerId, int? userId}) {
    return service.watchSales(customerId: customerId, userId: userId);
  }

  Future<int> deleteSale(int id) {
    return service.deleteSale(id);
  }
}
