import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_stock/core/database/app_database.dart';
import 'package:gestion_stock/providers/products_provder.dart';
import 'package:gestion_stock/views/vente/panier_screen.dart';

import '../../providers/sale_items_provider.dart';

class VenteScreen extends ConsumerStatefulWidget {
  const VenteScreen({super.key});

  @override
  ConsumerState<VenteScreen> createState() => _VenteScreenState();
}

class _VenteScreenState extends ConsumerState<VenteScreen> {
  SearchController _searchController = SearchController();
  void _onSearchChanged(String value) {
    // Met à jour la requête de recherche dans le Notifier Riverpod des filtres de produits
    ref.read(productFilterNotifierProvider.notifier).setSearchQuery(value);
  }
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final produits = ref.watch(productsFilteredProvider);
    final panier = ref.read(panierNotifierProvider.notifier);
    final paniers = ref.watch(panierNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 10,
        title: Text("Mouvelle ventre"),
        leading: Icon(Icons.perm_media_rounded),
        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const PanierScreen(),
                    ),
                  );
                },
              ),

              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${paniers.length}',
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
        ],
      ),
      body: Column(
        children: [
          Row(children: [
            SearchAnchor(
              searchController: _searchController,
                builder: (context, controller){
                  return SearchBar(
                    controller: controller,
                    hintText: 'Rechercher un produit ',
                    leading: const Icon(
                    Icons.search,
                    size: 20,
                      color: Color(0xFF6F7B80),
                    ),
                    elevation: const WidgetStatePropertyAll(0),
                    backgroundColor: WidgetStatePropertyAll(Colors.white),
                    padding: const WidgetStatePropertyAll(
                      EdgeInsets.symmetric(horizontal: 16)

                    ),
                    onTap: (){
                      controller.openView();
                    },
                    onChanged: (text){
                      _onSearchChanged(text);
                      controller.openView();
                    },
                    trailing: [
                      if (controller.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 20, color: Colors.grey),
                          onPressed: () {
                            controller.clear();
                            _onSearchChanged('');
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
        }
                  ),
                const SizedBox(height: 9),


          ]),

        ],
      ),
    );
  }
}
