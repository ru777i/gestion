import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_stock/views/categories/categories_screen.dart';
import 'package:gestion_stock/views/home/home_content.dart';
import 'package:gestion_stock/views/home/more_screen.dart';
import 'package:gestion_stock/views/products/products_sreen.dart';
import 'package:gestion_stock/views/vente/vente_screen.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import '../../core/widgets/drawer.dart';

/// Écran d'accueil principal gérant le menu latéral et la navigation inférieure (GNav).
class Homescreen extends ConsumerStatefulWidget {
  const Homescreen({super.key});

  @override
  ConsumerState<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends ConsumerState<Homescreen> {
  int currentIndex = 0;

  // Liste des pages de l'application
  final List<Widget> pages = const [
    HomeContent(),
    ProductsScreen(),
    VenteScreen(),
    CategoriesScreen(),
    MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Drawer(child: DrawerComponent()),
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(0.08),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: GNav(
              selectedIndex: currentIndex,
              onTabChange: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
              rippleColor: Colors.grey[200]!,
              hoverColor: Colors.grey[100]!,
              gap: 6,
              activeColor: Colors.white,
              color: Colors.grey[600]!,
              iconSize: 22,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              tabBackgroundColor: Theme.of(context).primaryColor,
              tabs: const [
                GButton(
                  icon: Icons.home_rounded,
                  text: 'Accueil',
                ),
                GButton(
                  icon: Icons.inventory_2_rounded,
                  text: 'Produits',
                ),
                GButton(
                  icon: Icons.point_of_sale_rounded,
                  text: 'Ventes',
                ),
                GButton(
                  icon: Icons.category_rounded,
                  text: 'Catégories',
                ),
                GButton(
                  icon: Icons.more_horiz_rounded,
                  text: 'Plus',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
