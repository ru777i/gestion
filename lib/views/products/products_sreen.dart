import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_stock/views/products/widgets/product_form.dart';

import '../../core/database/app_database.dart';
import '../../providers/products_provider.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  void _onSearchChanged(String value) {
    ref.read(productFilterNotifierProvider.notifier).setSearchQuery(value);
  }

  // creation d un produit avec les données du formulaire

  // suppression d un produit
  Future<void> _deleteProduct(int id) async {
    final reposirory = ref.read(productsRepositoryProvider);
    reposirory.deleteProduct(id);
  }

  Future<void> _createProduct() async {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => ProductForm()));
  }

  Future<void> _updateProduct(Product product) async {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => ProductForm(product: product)));
  }

  // mise a jour des informations d un produit

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(filteredProductsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes produits'),
        elevation: 20,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            );
          },
        ),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.sd_card_alert)),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.production_quantity_limits),
          ),
        ],
      ),
      body: productsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),

        error: (err, stack) => Center(
          child: Text('Erreur : $err'),
        ),

        data: (products) {
          if (products.isEmpty) {
            return const Center(
              child: Text('Aucun produit trouvé'),
            );
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
                trailing:  Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue,),
                      onPressed: () {
                        _updateProduct(product);},
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red,),
                      onPressed: () {
                    _deleteProduct(product.id);
                      },
                    ),
                  ],
                ),
                subtitle: Text(
                  'Prix : ${product.salePrice} FCFA\n'
                      'Quantité : ${product.stockQuantity}',
                ),
                );

            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {_createProduct();},
        child: Icon(Icons.add),
      ),
    );
  }
}
