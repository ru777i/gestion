import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_stock/core/database/app_database.dart';
import 'package:gestion_stock/core/database/database_provider.dart';
import 'package:gestion_stock/providers/products_provider.dart';

import '../repositories/sale_items_repository.dart';

/// Repository des éléments de vente
final saleItemsRepositoryProvider = Provider<SaleItemsRepository>((ref) {
  return SaleItemsRepository(ref.watch(appDatabaseProvider));
});

/// Provider du panier
final panierNotifierProvider =
    NotifierProvider<PanierNotifier, List<SaleItemsCompanion>>(PanierNotifier.new);

/// Notifier qui gère le panier
class PanierNotifier extends Notifier<List<SaleItemsCompanion>> {
  @override
  List<SaleItemsCompanion> build() {
    return [];
  }

  /// Vérifie si un produit existe déjà dans le panier
  bool containsProduct(int productId) {
    return state.any((item) => item.productId.value == productId);
  }

  /// Ajoute un produit au panier si le stock est suffisant
  String? addProduct(Product product) {
    if (product.stockQuantity <= 0) {
      return 'Le produit "${product.name}" est en rupture de stock.';
    }

    if (containsProduct(product.id)) {
      return 'Le produit est déjà dans le panier.';
    }

    final saleItem = SaleItemsCompanion.insert(
      saleId: 0,
      productId: product.id,
      quantity: 1,
      unitPrice: product.salePrice,
      subtotal: product.salePrice,
    );

    state = [...state, saleItem];
    return null;
  }

  /// Supprime un produit du panier grâce à son ID
  void removeProduct(int productId) {
    state = state.where((item) => item.productId.value != productId).toList();
  }

  /// Modifie la quantité d'un produit
  void updateQuantity(int productId, int newQuantity) {
    if (newQuantity <= 0) {
      removeProduct(productId);
      return;
    }

    state = [
      for (final item in state)
        if (item.productId.value == productId)
          item.copyWith(
            quantity: Value(newQuantity),
            subtotal: Value(newQuantity * item.unitPrice.value),
          )
        else
          item,
    ];
  }

  /// Augmente la quantité d'un produit en vérifiant le stock disponible
  Future<String?> incrementQuantity(int productId) async {
    final item = state.cast<SaleItemsCompanion?>().firstWhere(
      (item) => item?.productId.value == productId,
      orElse: () => null,
    );

    if (item == null) {
      return null;
    }

    final currentQuantity = item.quantity.value;
    final produit = await ref.read(productsRepositoryProvider).findById(productId);

    if (produit != null && produit.stockQuantity <= currentQuantity) {
      return 'Stock insuffisant pour ${produit.name} (Stock disponible : ${produit.stockQuantity})';
    }

    updateQuantity(productId, currentQuantity + 1);
    return null;
  }

  /// Diminue la quantité d'un produit
  void decrementQuantity(int productId) {
    final item = state.cast<SaleItemsCompanion?>().firstWhere(
      (item) => item?.productId.value == productId,
      orElse: () => null,
    );

    if (item == null) {
      return;
    }

    final currentQuantity = item.quantity.value;
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
    return state.fold(0, (total, item) => total + item.quantity.value);
  }

  /// Montant total du panier
  int get totalAmount {
    return state.fold(0, (total, item) => total + item.subtotal.value);
  }
}
