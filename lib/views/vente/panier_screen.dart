import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_stock/core/database/app_database.dart';
import 'package:gestion_stock/providers/products_provider.dart';
import 'package:gestion_stock/providers/sale_items_provider.dart';
import 'package:gestion_stock/views/vente/widgets/valider_vente_sheet.dart';

class PanierScreen extends ConsumerStatefulWidget {
  const PanierScreen({super.key});

  @override
  ConsumerState<PanierScreen> createState() => _PanierScreenState();
}

class _PanierScreenState extends ConsumerState<PanierScreen> {
  @override
  Widget build(BuildContext context) {
    final paniers = ref.watch(panierNotifierProvider);
    final productsAsync = ref.watch(filteredProductsProvider);
    final panierNotifier = ref.read(panierNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Panier de vente',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          if (paniers.isNotEmpty)
            IconButton(
              tooltip: 'Vider le panier',
              onPressed: () {
                panierNotifier.clear();
              },
              icon: const Icon(Icons.delete_sweep, color: Colors.red),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: paniers.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 70,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Votre panier est vide',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : productsAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, __) =>
                        const Center(child: Text('Erreur de chargement')),
                    data: (productsList) {
                      return ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: paniers.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = paniers[index];

                          // Product match
                          Product? product;
                          try {
                            product = productsList.firstWhere(
                              (p) => p.id == item.productId,
                            );
                          } catch (_) {}

                          final productName =
                              product?.name ?? 'Produit #${item.productId}';

                          return Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.1),
                                child: Icon(
                                  Icons.inventory_2_outlined,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              title: Text(
                                productName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                'PU: ${item.unitPrice ?? 0} FCFA',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      panierNotifier
                                          .decrementQuantity(item.productId!);
                                    },
                                  ),
                                  Text(
                                    '${item.quantity ?? 0}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.add_circle_outline,
                                      color: Colors.green,
                                    ),
                                    onPressed: () {
                                      panierNotifier
                                          .incrementQuantity(item.productId!);
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${item.subtotal ?? 0} FCFA',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                        ),
                      ),
                    );
                        },
                      );
                    },
                  ),
          ),

          // Récapitulatif et Bouton Valider la Vente
          if (paniers.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total à payer :',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${panierNotifier.totalAmount} FCFA',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          final navigator = Navigator.of(context);
                          final success = await ValiderVenteSheet.show(context);
                          if (success == true) {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Vente enregistrée avec succès !'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            navigator.pop();
                          }
                        },
                        icon: const Icon(Icons.check_circle),
                        label: const Text(
                          'Valider la Vente',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
