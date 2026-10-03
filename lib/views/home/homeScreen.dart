import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_stock/providers/categories_provider.dart';
import 'package:gestion_stock/providers/products_provider.dart';
import 'package:gestion_stock/views/categories/categories_screen.dart';
import 'package:gestion_stock/views/products/products_sreen.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import '../../core/widgets/drawer.dart';
import 'home_content.dart';
import 'more_screen.dart';

class Homescreen extends ConsumerStatefulWidget {
  const Homescreen({super.key});

  @override
  ConsumerState<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends ConsumerState<Homescreen> {
  int currentIndex = 0;

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Theme.of(context).primaryColor,
            child: const Icon(Icons.inventory, size: 35, color: Colors.white),
          ),
          const SizedBox(width: 15),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'StockPro',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Gestion des produits',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
      ),
    );
  }




  final List<Widget> pages = const [
    HomeContent(),
    ProductsScreen(),
    CategoriesScreen(),
    MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(child: DrawerComponent()),
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(0.08)),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: GNav(
              selectedIndex: currentIndex,
              onTabChange: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
              rippleColor: Colors.grey[200]!,
              hoverColor: Colors.grey[100]!,
              gap: 8,
              activeColor: Colors.white,
              color: Colors.grey[600]!,
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              tabBackgroundColor: Theme.of(context).primaryColor,
              tabs: const [
                GButton(icon: Icons.home_rounded, text: 'Accueil'),
                GButton(icon: Icons.inventory_2_rounded, text: 'Produits'),
                GButton(icon: Icons.category_rounded, text: 'Catégories'),
                GButton(icon: Icons.more_horiz_rounded, text: 'Plus'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =====================================================
// CONTENU ACCUEIL (DASHBOARD)
// =====================================================

// =====================================================
// PAGE PLUS
// =====================================================
