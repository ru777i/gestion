import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_stock/providers/categories_provider.dart';
import 'package:gestion_stock/views/products/widgets/product_form.dart';

import '../../core/database/app_database.dart';
import '../../core/widgets/barcode_scanner_sheet.dart';
import '../../providers/products_provider.dart';

/// Écran d'affichage, de filtrage et de gestion des produits.
class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  // Catégorie actuellement sélectionnée pour le filtre visuel des puces (Chips)
  String selectedCategory = 'Tous';

  // Contrôleur pour la recherche intelligente avec autocomplétion (SearchAnchor / SearchBar)
  final SearchController _searchController = SearchController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // ACTION : MISE À JOUR DE LA RECHERCHE TEXTUELLE
  // ============================================================
  void _onSearchChanged(String value) {
    // Met à jour la requête de recherche dans le Notifier Riverpod des filtres de produits
    ref.read(productFilterNotifierProvider.notifier).setSearchQuery(value);
  }

  // ============================================================
  // ACTION : SÉLECTION D'UNE CATÉGORIE POUR LE FILTRAGE
  // ============================================================
  Future<void> _selectCategory(String category) async {
    // Met à jour l'état local pour refléter visuellement la puce sélectionnée
    setState(() {
      selectedCategory = category;
    });

    if (category == 'Tous') {
      // Réinitialise le filtre par catégorie dans le state global
      ref.read(productFilterNotifierProvider.notifier).setCategory(null);
      return;
    }

    // Recherche l'ID de la catégorie par son nom pour appliquer le filtre Drift
    final categorie = await ref
        .read(categoriesRepositoryProvider)
        .findByName(category);

    if (categorie != null) {
      ref
          .read(productFilterNotifierProvider.notifier)
          .setCategory(categorie.id);
    }
  }

  // ============================================================
  // ACTION : SUPPRESSION D'UN PRODUIT
  // ============================================================
  Future<void> _deleteProduct(int id) async {
    final repository = ref.read(productsRepositoryProvider);
    // Supprime le produit de la base de données via le repository
    await repository.deleteProduct(id);
  }

  // ============================================================
  // ACTION : NAVIGATION VERS LE FORMULAIRE DE CRÉATION
  // ============================================================
  Future<void> _createProduct() async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const ProductForm()));
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
        _searchController.text=scannedCode;
      });
    }
  }

  // ============================================================
  // ACTION : NAVIGATION VERS LE FORMULAIRE DE MODIFICATION
  // ============================================================
  Future<void> _updateProduct(Product product) async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => ProductForm(product: product)));
  }

  // ============================================================
  // CONSTRUCTION DE L'INTERFACE UTILISATEUR (BUILD)
  // ============================================================
  @override
  Widget build(BuildContext context) {
    // Écoute le StreamProvider filtré des produits en temps réel
    final productsAsync = ref.watch(filteredProductsProvider);

    // Flux des catégories pour alimenter la barre de filtres horizontale
    final categoriesStream = ref
        .watch(categoriesRepositoryProvider)
        .watchFilteredCategories();

    return Scaffold(
      // ----------------------------------------------------------
      // BARRE D'APPLICATION (APP BAR)
      // ----------------------------------------------------------
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
                // Ouvre le menu latéral (Drawer)
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        elevation: 0,
      ),

      // ----------------------------------------------------------
      // CORPS DE LA PAGE (BODY)
      // ----------------------------------------------------------
      body: Column(
        children: [
          // --------------------------------------------------------
          // EN-TÊTE : RECHERCHE INTELLIGENTE + FILTRES HORIZONTAUX
          // --------------------------------------------------------
          Container(
            color: const Color(0xFFF1F4F5),
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              children: [
                // Barre de recherche intelligente avec autocomplétion (Material 3 SearchAnchor)
                SearchAnchor(
                  searchController: _searchController,
                  builder: (context, controller) {
                    return SearchBar(
                      controller: controller,
                      hintText: 'Rechercher un produit...',
                      leading: const Icon(
                        Icons.search,
                        size: 20,
                        color: Color(0xFF6F7B80),
                      ),

                      elevation: const WidgetStatePropertyAll(0),
                      backgroundColor: const WidgetStatePropertyAll(
                        Colors.white,
                      ),
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

                const SizedBox(height: 9),

                // Liste horizontale des puces (Chips) de catégories
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
                            // Bouton par défaut "Tous"
                            _buildCategoryButton('Tous'),
                            // Puces pour chaque catégorie existante
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

          // --------------------------------------------------------
          // GRILLE DES PRODUITS
          // --------------------------------------------------------
          Expanded(
            child: productsAsync.when(
              // État de chargement
              loading: () {
                return const Center(child: CircularProgressIndicator());
              },
              // État d'erreur
              error: (err, stack) {
                return Center(child: Text('Erreur : $err'));
              },
              // État de succès avec données
              data: (products) {
                if (products.isEmpty) {
                  return const Center(child: Text('Aucun produit trouvé'));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.58,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];

                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image du produit ou espace réservé
                          SizedBox(
                            width: double.infinity,
                            height: 110,
                            child: product.photoPath != null
                                ? Image.file(
                                    File(product.photoPath!),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return _buildProductPlaceholder();
                                    },
                                  )
                                : _buildProductPlaceholder(),
                          ),

                          // Informations textuelles du produit
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${product.salePrice} FCFA',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Stock : ${product.stockQuantity}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: product.stockQuantity <= 5
                                          ? Colors.orange
                                          : Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Barre d'actions (Modifier / Supprimer)
                          const Divider(height: 1),
                          SizedBox(
                            height: 45,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                  tooltip: 'Modifier',
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    color: Colors.blue,
                                    size: 20,
                                  ),
                                  onPressed: () => _updateProduct(product),
                                ),
                                IconButton(
                                  tooltip: 'Supprimer',
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  onPressed: () => _deleteProduct(product.id),
                                ),
                              ],
                            ),
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

      // ----------------------------------------------------------
      // BOUTON FLOTTANT D'AJOUT (FAB)
      // ----------------------------------------------------------
      floatingActionButton: FloatingActionButton(
        onPressed: _createProduct,
        child: const Icon(Icons.add),
      ),
    );
  }

  // ==============================================================
  // WIDGET : BOUTON DE FILTRE DE CATÉGORIE
  // ==============================================================
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
              color: isSelected
                  ? const Color(0xFF08796C)
                  : Colors.grey.shade300,
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

  // ==============================================================
  // WIDGET : PLACEHOLDER DE L'IMAGE PRODUIT
  // ==============================================================
  Widget _buildProductPlaceholder() {
    return Container(
      color: Colors.grey[100],
      child: const Center(
        child: Icon(Icons.inventory_2_outlined, size: 40, color: Colors.grey),
      ),
    );
  }
}
