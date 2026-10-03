import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_stock/views/products/widgets/product_form.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import '../../core/database/app_database.dart';
import '../../providers/products_provider.dart';
import '../categories/categories_screen.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  void _onSearchChanged(String value) {
    ref.read(productFilterNotifierProvider.notifier).setSearchQuery(value);
  }

  Future<void> _deleteProduct(int id) async {
    final repository = ref.read(productsRepositoryProvider);
    await repository.deleteProduct(id);
  }

  Future<void> _createProduct() async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const ProductForm()));
  }

  Future<void> _updateProduct(Product product) async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => ProductForm(product: product)));
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(filteredProductsProvider);

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          'Mes produits',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        elevation: 10,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Rechercher un produit...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: productsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Erreur : $err')),
              data: (products) {
                if (products.isEmpty) {
                  return const Center(child: Text('Aucun produit trouvé'));
                }

                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: product.photoPath != null
                            ? FileImage(File(product.photoPath!))
                            : null,
                        child: product.photoPath == null
                            ? const Icon(Icons.inventory_2)
                            : null,
                      ),
                      title: Text(product.name),
                      subtitle: Text(
                        'Prix : ${product.salePrice} FCFA\n'
                        'Quantité : ${product.stockQuantity}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _updateProduct(product),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteProduct(product.id),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _createProduct,
        child: const Icon(Icons.add),
      ),
    );
  }
}
