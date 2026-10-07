import 'package:flutter/material.dart';

import '../../core/widgets/dialogs/app_dialog.dart';
import '../../core/widgets/section_title.dart';
import '../auth/login_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Plus',
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
                title: const Text('Historiques de vente'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {},
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

          SizedBox(child: SectionTitle(title: 'Partenaires'.toUpperCase())),
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
              // const Divider(),
              ListTile(
                leading: const Icon(Icons.supervised_user_circle),
                title: const Text('Utilisateurs et Roles'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {},
              ),
            ],
          ),
          const Divider(),

          SizedBox(child: SectionTitle(title: 'Systemes'.toUpperCase())),
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
              // const Divider(),
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
              style: TextStyle(color: Colors.red),
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
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
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
