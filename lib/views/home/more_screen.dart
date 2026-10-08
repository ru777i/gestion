import 'package:flutter/material.dart';

import '../../core/widgets/dialogs/app_dialog.dart';
import '../../core/widgets/section_title.dart';
import '../auth/login_screen.dart';
import '../auth/users_screen.dart';
import '../vente/historiqueVente.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Plus & Paramètres',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SizedBox(child: SectionTitle(title: 'Suivi'.toUpperCase())),
          Column(
            children: [
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Historique des ventes'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const Historiquevente()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.auto_graph_outlined),
                title: const Text('Rapports'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {},
              ),
            ],
          ),
          const Divider(),

          SizedBox(child: SectionTitle(title: 'Partenaires & Rôles'.toUpperCase())),
          Column(
            children: [
              ListTile(
                leading: const Icon(Icons.personal_injury_rounded),
                title: const Text('Fournisseurs'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.supervised_user_circle),
                title: const Text('Utilisateurs et Rôles'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const UsersScreen()),
                  );
                },
              ),
            ],
          ),
          const Divider(),

          SizedBox(child: SectionTitle(title: 'Système'.toUpperCase())),
          Column(
            children: [
              ListTile(
                leading: const Icon(Icons.cloud_outlined),
                title: const Text('Sauvegarde et Synchronisation'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Paramètres'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {},
              ),
            ],
          ),
          const Divider(),

          SizedBox(child: SectionTitle(title: 'Action'.toUpperCase())),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.red),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text(
              'Déconnexion',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              AppDialog.showConfirmation(
                isDanger: true,
                context: context,
                title: 'Déconnexion',
                message: 'Voulez-vous vraiment vous déconnecter ?',
                confirmText: 'Déconnexion',
                cancelText: 'Annuler',
                onConfirm: () {
                  Navigator.of(context).pop(); // Fermer la modale
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
                onCancel: () {
                  Navigator.of(context).pop(); // Fermer la modale
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
