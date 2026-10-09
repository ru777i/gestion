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

  Future<List<Sale>> findSalesBefore(DateTime date) {
    return service.findSalesBefore(date);
  }

  Future<List<Sale>> findSalesAfter(DateTime date) {
    return service.findSalesAfter(date);
  }

  Future<List<Sale>> findSalesOnDate(DateTime date) {
    return service.findSalesOnDate(date);
  }

  Future<List<Sale>> findSalesBetween(DateTime startDate, DateTime endDate) {
    return service.findSalesBetween(startDate, endDate);
  }

  Stream<List<Sale>> watchSales({int? customerId, int? userId}) {
    return service.watchSales(customerId: customerId, userId: userId);
  }

  Future<int> deleteSale(int id) {
    return service.deleteSale(id);
  }
}
