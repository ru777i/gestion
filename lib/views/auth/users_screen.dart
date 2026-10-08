import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_stock/core/widgets/dialogs/app_dialog.dart';
import 'package:gestion_stock/views/auth/register_screen.dart';
import 'package:gestion_stock/views/home/homeScreen.dart';

import '../../core/database/app_database.dart';
import '../../providers/users_provider.dart';
import '../home/more_screen.dart';

/// Écran de gestion et de recherche des utilisateurs.
class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  final SearchController _searchController = SearchController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    ref.read(userFilterNotifierProvider.notifier).setSearchQuery(value);
  }

  Future<void> _reactiverUser(int id) async {
    final succes = await ref.read(usersRepositoryProvider).activerUser(id);
    if (succes && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Utilisateur activé avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _deactivateUser(int id) async {
    final success = await ref.read(usersRepositoryProvider).deactivateUser(id);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Utilisateur désactivé avec succès'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _confirmDeleteUser(User user) async {
    final confirm = await AppDialog.showConfirmation(
      context: context,
      title: 'Supprimer l\'utilisateur',
      message:
          'Voulez-vous vraiment supprimer définitivement "${user.fullName}" (@${user.username}) ?',
      confirmText: 'Supprimer',
      cancelText: 'Annuler',
      isDanger: true,
    );

    if (confirm == true && mounted) {
      final success = await ref
          .read(usersRepositoryProvider)
          .deleteUser(user.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Utilisateur "${user.username}" supprimé avec succès',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(filteredUsersProvider);

    return Scaffold(
      appBar: AppBar(
        // leading: IconButton(
        //   onPressed: () {
        //     Navigator.pushAndRemoveUntil(
        //       context,
        //       MaterialPageRoute(builder: (context) => const Homescreen()),
        //           (route) => false,
        //     );
        //   },
        //   icon: const Icon(Icons.keyboard_backspace),
        // ),
        title: const Text(
          'Gestion des Utilisateurs',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Ajouter un utilisateur',
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => RegisterScreen()));
            },
            icon: const Icon(Icons.person_add_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche intelligente (SearchAnchor)
          Container(
            color: const Color(0xFFF1F4F5),
            padding: const EdgeInsets.all(12),
            child: SearchAnchor(
              searchController: _searchController,
              builder: (context, controller) {
                return SearchBar(
                  controller: controller,
                  hintText: 'Rechercher un utilisateur...',
                  leading: const Icon(Icons.search, color: Color(0xFF6F7B80)),
                  backgroundColor: const WidgetStatePropertyAll(Colors.white),
                  elevation: const WidgetStatePropertyAll(0),
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
                    if (controller.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(
                          Icons.clear,
                          size: 20,
                          color: Colors.grey,
                        ),
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
                final repository = ref.read(usersRepositoryProvider);
                final results = await repository.filterUsers(
                  searchQuery: query,
                );

                if (results.isEmpty) {
                  return [
                    const ListTile(
                      title: Text('Aucun utilisateur trouvé'),
                      leading: Icon(Icons.info_outline),
                    ),
                  ];
                }

                return results.take(5).map((user) {
                  return ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: Text(user.fullName),
                    subtitle: Text('@${user.username} • Rôle : ${user.role}'),
                    onTap: () {
                      controller.closeView(user.username);
                      _onSearchChanged(user.username);
                    },
                  );
                }).toList();
              },
            ),
          ),
          const SizedBox(height: 8),

          // Liste des utilisateurs
          Expanded(
            child: usersAsync.when(
              data: (users) {
                if (users.isEmpty) {
                  return const Center(
                    child: Text('Aucun utilisateur enregistré'),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(12),

                  itemCount: users.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final isActive = user.isActive == 1;

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
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RegisterScreen(user: user),
                              ),
                            );
                          },
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: isActive
                                ? Colors.teal.shade100
                                : Colors.grey.shade300,
                            child: Icon(
                              Icons.person,
                              color: isActive
                                  ? Colors.teal.shade800
                                  : Colors.grey,
                            ),
                          ),
                          title: Text(
                            user.fullName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            '@${user.username}  •  Rôle : ${user.role.toUpperCase()}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              isActive
                                  ? IconButton(
                                      tooltip: 'Désactiver',
                                      icon: const Icon(
                                        Icons.block,
                                        color: Colors.orange,
                                      ),
                                      onPressed: () => _deactivateUser(user.id),
                                    )
                                  : ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        backgroundColor: const Color(
                                          0xFF08796C,
                                        ),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      onPressed: () => _reactiverUser(user.id),
                                      child: const Text(
                                        'Activer',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                              IconButton(
                                tooltip: 'Supprimer définitivement',
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                onPressed: () => _confirmDeleteUser(user),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              error: (error, stackTrace) =>
                  Center(child: Text('Erreur : $error')),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }
}
