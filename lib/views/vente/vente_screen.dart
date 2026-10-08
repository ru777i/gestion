import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_stock/core/widgets/dialogs/scafold_mesage.dart';
import 'package:gestion_stock/providers/categories_provider.dart';
import 'package:gestion_stock/providers/products_provider.dart';
import 'package:gestion_stock/views/vente/panier_screen.dart';

import '../../core/widgets/barcode_scanner_sheet.dart';
import '../../providers/sale_items_provider.dart';

class VenteScreen extends ConsumerStatefulWidget {
  const VenteScreen({super.key});

  @override
  ConsumerState<VenteScreen> createState() => _VenteScreenState();
}

class _VenteScreenState extends ConsumerState<VenteScreen> {
  final SearchController _searchController = SearchController();
  String selectedCategory = 'Tous';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  Future<void> _scanBarcode() async {
    final scannedCode = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const BarcodeScannerSheet(),
    );

    if (scannedCode != null && scannedCode.isNotEmpty) {
      setState(() {
        _onSearchChanged(scannedCode);
        _searchController.text = scannedCode;
      });
    }
  }
  void _onSearchChanged(String value) {
    ref.read(productFilterNotifierProvider.notifier).setSearchQuery(value);
  }

  Future<void> _selectCategory(String category) async {
    setState(() {
      selectedCategory = category;
    });

    if (category == 'Tous') {
      ref.read(productFilterNotifierProvider.notifier).setCategory(null);
      return;
    }

    final categorie = await ref
        .read(categoriesRepositoryProvider)
        .findByName(category);

    if (categorie != null) {
      ref.read(productFilterNotifierProvider.notifier).setCategory(categorie.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(filteredProductsProvider);
    final categoriesStream = ref
        .watch(categoriesRepositoryProvider)
        .watchFilteredCategories();
    final panierItems = ref.watch(panierNotifierProvider);
    final panierNotifier = ref.read(panierNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Nouvelle Vente',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                tooltip: 'Voir le panier',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const PanierScreen(),
                    ),
                  );
                },
              ),
              if (panierItems.isNotEmpty)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${panierNotifier.totalQuantity}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Recherche et Filtres
          Container(
            color: const Color(0xFFF1F4F5),
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Column(
              children: [
                SearchAnchor(
                  searchController: _searchController,
                  builder: (context, controller) {
                    return SearchBar(
                      controller: controller,
                      hintText: 'Rechercher un produit à vendre...',
                      leading: const Icon(
                        Icons.search,
                        size: 20,
                        color: Color(0xFF6F7B80),
                      ),
                      elevation: const WidgetStatePropertyAll(0),
                      backgroundColor:
                          const WidgetStatePropertyAll(Colors.white),
                      padding: const WidgetStatePropertyAll(
                        EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onTap: () {
                        controller.openView();
                      },
                      onChanged: (text) {
                        _onSearchChanged(text);
                        controller.openView();
                      },
                      trailing: [
                        controller.text.isNotEmpty
                            ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            size: 20,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            controller.clear();
                            _onSearchChanged('');
                          },
                        )
                            : IconButton(
                          icon: Icon(Icons.qr_code_2),
                          onPressed: () {
                            _scanBarcode();
                          },
                        ),
                      ],
                    );
                  },
                  suggestionsBuilder: (context, controller) async {
                    final query = controller.text;
                    final repository = ref.read(productsRepositoryProvider);
                    final results = await repository.filterProducts(
                      searchQuery: query,
                    );

                    if (results.isEmpty) {
                      return [
                        const ListTile(
                          title: Text('Aucun produit trouvé'),
                          leading: Icon(Icons.info_outline),
                        ),
                      ];
                    }

                    return results.take(5).map((product) {
                      return ListTile(
                        leading: const Icon(Icons.inventory_2_outlined),
                        title: Text(product.name),
                        subtitle: Text(
                          'Prix : ${product.salePrice} FCFA | Stock : ${product.stockQuantity}',
                        ),
                        onTap: () {
                          controller.closeView(product.name);
                          _onSearchChanged(product.name);
                        },
                      );
                    }).toList();
                  },
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 38,
                  child: StreamBuilder(
                    stream: categoriesStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox();
                      }

                      final categories = snapshot.data ?? [];

                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildCategoryButton('Tous'),
                            ...categories.map((category) {
                              return _buildCategoryButton(category.name);
                            }),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Liste des produits en ListTile
          Expanded(
            child: productsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Erreur : $err')),
              data: (products) {
                if (products.isEmpty) {
                  return const Center(
                    child: Text('Aucun produit disponible en stock'),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: products.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final isInCart = panierNotifier.containsProduct(product.id);

                    return Card(
                      elevation: 1,
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: product.photoPath != null
                                ? Image.file(
                                    File(product.photoPath!),
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Container(
                                      width: 50,
                                      height: 50,
                                      color: Colors.grey[200],
                                      child: const Icon(
                                        Icons.inventory_2_outlined,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: 50,
                                    height: 50,
                                    color: Colors.grey[200],
                                    child: const Icon(
                                      Icons.inventory_2_outlined,
                                      color: Colors.grey,
                                    ),
                                  ),
                          ),
                          title: Text(
                            product.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              '${product.salePrice} FCFA  •  Stock : ${product.stockQuantity}',
                              style: TextStyle(
                                fontSize: 13,
                                color: product.stockQuantity <= 5
                                    ? Colors.orange
                                    : Colors.grey[700],
                              ),
                            ),
                          ),
                          trailing: isInCart
                              ? ElevatedButton.icon(
                                  onPressed: () {
                                    panierNotifier.removeProduct(product.id);
                                    ScaffoldMessage.showInfo(
                                      context,
                                      '${product.name} retiré du panier',
                                    );
                                  },
                                  icon: const Icon(Icons.remove_shopping_cart, size: 16),
                                  label: const Text('Retirer'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red.shade100,
                                    foregroundColor: Colors.red.shade800,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                )
                              : ElevatedButton.icon(
                                  onPressed: () {
                                    final error = panierNotifier.addProduct(product);
                                    if (error != null) {
                                      ScaffoldMessage.showError(context, error);
                                    } else {
                                      ScaffoldMessage.showSuccess(
                                        context,
                                        '${product.name} ajouté au panier',
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.add_shopping_cart, size: 16),
                                  label: const Text('Ajouter'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF08796C),
                                    foregroundColor: Colors.white,
                                    elevation: 1,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: panierItems.isNotEmpty
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${panierNotifier.totalQuantity} article(s)',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                        Text(
                          '${panierNotifier.totalAmount} FCFA',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const PanierScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.shopping_cart_checkout),
                      label: const Text('Voir le Panier'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildCategoryButton(String category) {
    final bool isSelected = selectedCategory == category;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => _selectCategory(category),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF08796C) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? const Color(0xFF08796C) : Colors.grey.shade300,
            ),
          ),
          child: Text(
            category,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xFF4F5A5F),
            ),
          ),
        ),
      ),
    );
  }
}
