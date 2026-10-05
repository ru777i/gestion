import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final String userName;
  final String userEmail;
  final Widget? userAvatar;
  final VoidCallback? onLogout;

  final VoidCallback? onHome;
  final VoidCallback? onProducts;
  final VoidCallback? onCategories;
  final VoidCallback? onSales;
  final VoidCallback? onProfile;
  final VoidCallback? onNotifications;
  final VoidCallback? onSettings;
  final VoidCallback? onHelp;
  final VoidCallback? onAbout;

  final String? notificationBadge;

  const AppDrawer({
    super.key,
    this.userName = 'Utilisateur',
    this.userEmail = 'email@example.com',
    this.userAvatar,
    this.onLogout,
    this.onHome,
    this.onProducts,
    this.onCategories,
    this.onSales,
    this.onProfile,
    this.onNotifications,
    this.onSettings,
    this.onHelp,
    this.onAbout,
    this.notificationBadge,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildSectionTitle('PRINCIPAL'),

                  _buildMenuItem(
                    icon: Icons.home_outlined,
                    title: 'Accueil',
                    onTap: () {
                      Navigator.pop(context);
                      onHome?.call();
                    },
                  ),

                  _buildMenuItem(
                    icon: Icons.inventory_2_outlined,
                    title: 'Produits',
                    onTap: () {
                      Navigator.pop(context);
                      onProducts?.call();
                    },
                  ),

                  _buildMenuItem(
                    icon: Icons.category_outlined,
                    title: 'Catégories',
                    onTap: () {
                      Navigator.pop(context);
                      onCategories?.call();
                    },
                  ),

                  _buildMenuItem(
                    icon: Icons.shopping_cart_outlined,
                    title: 'Ventes',
                    onTap: () {
                      Navigator.pop(context);
                      onSales?.call();
                    },
                  ),

                  _buildSectionTitle('MON COMPTE'),

                  _buildMenuItem(
                    icon: Icons.person_outline,
                    title: 'Profil',
                    onTap: () {
                      Navigator.pop(context);
                      onProfile?.call();
                    },
                  ),

                  _buildMenuItem(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    badge: notificationBadge,
                    onTap: () {
                      Navigator.pop(context);
                      onNotifications?.call();
                    },
                  ),

                  _buildSectionTitle('AUTRES'),

                  _buildMenuItem(
                    icon: Icons.settings_outlined,
                    title: 'Paramètres',
                    onTap: () {
                      Navigator.pop(context);
                      onSettings?.call();
                    },
                  ),

                  _buildMenuItem(
                    icon: Icons.help_outline,
                    title: 'Aide',
                    onTap: () {
                      Navigator.pop(context);
                      onHelp?.call();
                    },
                  ),

                  _buildMenuItem(
                    icon: Icons.info_outline,
                    title: 'À propos',
                    onTap: () {
                      Navigator.pop(context);
                      onAbout?.call();
                    },
                  ),
                ],
              ),
            ),

            const Divider(),

            _buildMenuItem(
              icon: Icons.logout,
              title: 'Déconnexion',
              iconColor: Colors.red,
              textColor: Colors.red,
              onTap: () {
                Navigator.pop(context);
                onLogout?.call();
              },
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          userAvatar ??
              const CircleAvatar(
                radius: 30,
                child: Icon(
                  Icons.person,
                  size: 32,
                ),
              ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  userEmail,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
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

  // ============================================================
  // MENU ITEM
  // ============================================================

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    String? badge,
    Color? iconColor,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? Colors.black87,
      ),

      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),

      trailing: badge != null
          ? Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          badge,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      )
          : null,

      onTap: onTap,
    );
  }
}

/*
============================================================
EXEMPLES D'UTILISATION
============================================================

1. Drawer simple
------------------------------------------------------------

Scaffold(
  drawer: const AppDrawer(),

  body: const Center(
    child: Text('Accueil'),
  ),
);


2. Drawer avec informations utilisateur
------------------------------------------------------------

Scaffold(
  drawer: AppDrawer(
    userName: 'Jean Dupont',
    userEmail: 'jean@example.com',
  ),

  body: const Center(
    child: Text('Accueil'),
  ),
);


3. Drawer avec navigation
------------------------------------------------------------

Scaffold(
  drawer: AppDrawer(
    onHome: () {
      print('Accueil');
    },

    onProducts: () {
      print('Produits');
    },

    onCategories: () {
      print('Catégories');
    },

    onSales: () {
      print('Ventes');
    },

    onProfile: () {
      print('Profil');
    },

    onSettings: () {
      print('Paramètres');
    },
  ),

  body: const Center(
    child: Text('Accueil'),
  ),
);


4. Drawer avec badge de notification
------------------------------------------------------------

Scaffold(
  drawer: AppDrawer(
    notificationBadge: '3',

    onNotifications: () {
      print('Notifications');
    },
  ),

  body: const Center(
    child: Text('Accueil'),
  ),
);


5. Drawer avec déconnexion
------------------------------------------------------------

Scaffold(
  drawer: AppDrawer(
    onLogout: () {
      print('Déconnexion');
    },
  ),

  body: const Center(
    child: Text('Accueil'),
  ),
);


6. Drawer complet
------------------------------------------------------------

Scaffold(
  appBar: const CommonAppBar(
    title: 'Gestion Stock',
  ),

  drawer: AppDrawer(
    userName: 'Jean Dupont',
    userEmail: 'jean@example.com',
    notificationBadge: '5',

    onHome: () {
      print('Accueil');
    },

    onProducts: () {
      print('Produits');
    },

    onCategories: () {
      print('Catégories');
    },

    onSales: () {
      print('Ventes');
    },

    onProfile: () {
      print('Profil');
    },

    onNotifications: () {
      print('Notifications');
    },

    onSettings: () {
      print('Paramètres');
    },

    onHelp: () {
      print('Aide');
    },

    onAbout: () {
      print('À propos');
    },

    onLogout: () {
      print('Déconnexion');
    },
  ),

  body: const Center(
    child: Text('Gestion Stock'),
  ),
);

============================================================
*/