import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_stock/core/database/app_database.dart';
import 'package:gestion_stock/core/database/database_provider.dart';

import '../repositories/sale_items_repository.dart';

/// Repository des éléments de vente
final saleItemsRepositoryProvider = Provider<SaleItemsRepository>((ref) {
  return SaleItemsRepository(ref.watch(appDatabaseProvider));
});

/// Provider du panier
final panierNotifierProvider =
    NotifierProvider<PanierNotifier, List<SaleItemFilter>>(PanierNotifier.new);

/// Notifier qui gère le panier
class PanierNotifier extends Notifier<List<SaleItemFilter>> {
  @override
  List<SaleItemFilter> build() {
    return [];
  }

  /// Vérifie si un produit existe déjà dans le panier
  bool containsProduct(int productId) {
    return state.any((item) => item.productId == productId);
  }

  /// Ajoute un produit au panier
  void addProduct(Product product) {
    // Évite d'ajouter deux fois le même produit
    if (containsProduct(product.id)) {
      return;
    }

    final saleItem = SaleItemFilter(
      productId: product.id,
      quantity: 1,
      unitPrice: product.salePrice,
      subtotal: product.salePrice,
    );

    state = [...state, saleItem];
  }

  /// Ajoute directement un SaleItem
  void addSaleItem({
    int? id,
    int? saleId,
    required int productId,
    required int quantity,
    required int unitPrice,
  }) {
    final saleItem = SaleItemFilter(
      id: id,
      saleId: saleId,
      productId: productId,
      quantity: quantity,
      unitPrice: unitPrice,
      subtotal: quantity * unitPrice,
    );

    state = [...state, saleItem];
  }

  /// Supprime un produit du panier grâce à son ID
  void removeProduct(int productId) {
    state = state.where((item) => item.productId != productId).toList();
  }

  /// Supprime un SaleItem
  void removeSaleItem(SaleItemFilter saleItem) {
    state = state.where((item) => item != saleItem).toList();
  }

  /// Modifie la quantité d'un produit
  void updateQuantity(int productId, int newQuantity) {
    // Une quantité doit être supérieure à zéro
    if (newQuantity <= 0) {
      removeProduct(productId);
      return;
    }

    state = [
      for (final item in state)
        if (item.productId == productId)
          item.copyWith(
            quantity: newQuantity,
            subtotal: newQuantity * (item.unitPrice ?? 0),
          )
        else
          item,
    ];
  }

  /// Augmente la quantité d'un produit
  void incrementQuantity(int productId) {
    final item = state.cast<SaleItemFilter?>().firstWhere(
      (item) => item?.productId == productId,
      orElse: () => null,
    );

    if (item == null) {
      return;
    }

    final currentQuantity = item.quantity ?? 0;

    updateQuantity(productId, currentQuantity + 1);
  }

  /// Diminue la quantité d'un produit
  void decrementQuantity(int productId) {
    final item = state.cast<SaleItemFilter?>().firstWhere(
      (item) => item?.productId == productId,
      orElse: () => null,
    );

    if (item == null) {
      return;
    }

    final currentQuantity = item.quantity ?? 0;

    updateQuantity(productId, currentQuantity - 1);
  }

  /// Vide complètement le panier
  void clear() {
    state = [];
  }

  /// Nombre de produits différents dans le panier
  int get itemCount => state.length;

  /// Nombre total d'articles
  int get totalQuantity {
    return state.fold(0, (total, item) => total + (item.quantity ?? 0));
  }

  /// Montant total du panier
  int get totalAmount {
    return state.fold(0, (total, item) => total + (item.subtotal ?? 0));
  }
}

/// Modèle utilisé temporairement pour représenter
/// un élément du panier avant son enregistrement en base.
class SaleItemFilter {
  final int? id;
  final int? saleId;
  final int? productId;
  final int? quantity;
  final int? unitPrice;
  final int? subtotal;

  const SaleItemFilter({
    this.id,
    this.saleId,
    this.productId,
    this.quantity,
    this.unitPrice,
    this.subtotal,
  });

  SaleItemFilter copyWith({
    int? id,
    int? saleId,
    int? productId,
    int? quantity,
    int? unitPrice,
    int? subtotal,
  }) {
    return SaleItemFilter(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      subtotal: subtotal ?? this.subtotal,
    );
  }
}
