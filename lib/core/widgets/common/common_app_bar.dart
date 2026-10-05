import 'package:flutter/material.dart';

class CommonAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showMenu;
  final bool showBackButton;

  const CommonAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showMenu = true,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget? leadingWidget = leading;

    // Bouton retour
    if (leadingWidget == null && showBackButton) {
      leadingWidget = IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(Icons.arrow_back),
      );
    }

    // Bouton menu pour le Drawer
    if (leadingWidget == null && showMenu) {
      leadingWidget = Builder(
        builder: (context) {
          return IconButton(
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            icon: const Icon(Icons.menu),
          );
        },
      );
    }

    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      leading: leadingWidget,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(
    kToolbarHeight,
  );
}

/*
==================================================
EXEMPLES D'UTILISATION
==================================================

1. AppBar simple :

Scaffold(
  appBar: const CommonAppBar(
    title: 'Accueil',
  ),
  body: const HomeScreen(),
);


2. Avec des actions :

Scaffold(
  appBar: CommonAppBar(
    title: 'Produits',
    actions: [
      IconButton(
        onPressed: () {},
        icon: const Icon(Icons.search),
      ),
      IconButton(
        onPressed: () {},
        icon: const Icon(Icons.more_vert),
      ),
    ],
  ),
  body: const ProductsScreen(),
);


3. Avec un bouton retour :

Scaffold(
  appBar: const CommonAppBar(
    title: 'Détails du produit',
    showMenu: false,
    showBackButton: true,
  ),
  body: const ProductDetailsScreen(),
);


4. Avec un leading personnalisé :

Scaffold(
  appBar: CommonAppBar(
    title: 'Produits',
    showMenu: false,
    leading: IconButton(
      onPressed: () {},
      icon: const Icon(Icons.close),
    ),
  ),
  body: const ProductsScreen(),
);

==================================================
*/