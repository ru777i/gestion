import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../providers/categories_provider.dart';
import 'widgets/category_filter_dialog.dart';
import 'widgets/category_form_dialog.dart';

/// Écran principal pour afficher, rechercher, filtrer et gérer les catégories.
class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    ref.read(categoryFilterNotifierProvider.notifier).setSearchQuery(value);
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(categoryFilterNotifierProvider.notifier).setSearchQuery('');
  }

  Future<void> _openFilterDialog() async {
    final currentFilter = ref.read(categoryFilterNotifierProvider);
    final result = await CategoryFilterDialog.show(
      context,
      initialState: currentFilter,
    );

    if (result != null) {
      final notifier = ref.read(categoryFilterNotifierProvider.notifier);
      notifier.setDateRange(result.startDate, result.endDate);
      notifier.setAscending(result.ascending);
    }
  }

  Future<void> _addCategory() async {
    final nom = await CategoryFormDialog.show(context);
    if (nom != null && nom.isNotEmpty && mounted) {
      try {
        final repository = ref.read(categoriesRepositoryProvider);
        await repository.createCategory(nom: nom);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Catégorie "$nom" créée avec succès')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la création : $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _editCategory(Category category) async {
    final newNom = await CategoryFormDialog.show(context, category: category);
    if (newNom != null &&
        newNom.isNotEmpty &&
        newNom != category.name &&
        mounted) {
      try {
        final repository = ref.read(categoriesRepositoryProvider);
        final success = await repository.updateCategory(
          category.id,
          nom: newNom,
        );
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Catégorie mise à jour en "$newNom"')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la modification : $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteCategory(Category category) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Voulez-vous vraiment supprimer la catégorie "${category.name}" ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        final repository = ref.read(categoriesRepositoryProvider);
        await repository.deleteCategory(category.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Catégorie "${category.name}" supprimée')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la suppression : $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  String _formatDateString(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filterState = ref.watch(categoryFilterNotifierProvider);
    final categoriesAsync = ref.watch(filteredCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Gestion des Catégories',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 10,
        actions: [
          IconButton(
            icon: Icon(
              filterState.ascending
                  ? Icons.sort_by_alpha
                  : Icons.sort_by_alpha_outlined,
            ),
            tooltip: 'Inverser le tri',
            onPressed: () {
              ref
                  .read(categoryFilterNotifierProvider.notifier)
                  .setAscending(!filterState.ascending);
            },
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                tooltip: 'Filtres avancés',
                onPressed: _openFilterDialog,
              ),
              if (filterState.startDate != null || filterState.endDate != null)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Rechercher une catégorie...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          if (filterState.hasActiveFilters)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                children: [
                  if (filterState.searchQuery.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Chip(
                        label: Text('Recherche: "${filterState.searchQuery}"'),
                        onDeleted: _clearSearch,
                      ),
                    ),
                  if (filterState.startDate != null ||
                      filterState.endDate != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Chip(
                        avatar: const Icon(Icons.date_range, size: 16),
                        label: const Text('Filtre par date actif'),
                        onDeleted: () {
                          ref
                              .read(categoryFilterNotifierProvider.notifier)
                              .setDateRange(null, null);
                        },
                      ),
                    ),
                  ActionChip(
                    avatar: const Icon(Icons.refresh, size: 16),
                    label: const Text('Réinitialiser tout'),
                    onPressed: () {
                      _searchController.clear();
                      ref.read(categoryFilterNotifierProvider.notifier).reset();
                    },
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: categoriesAsync.when(
              data: (categories) {
                if (categories.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.category_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          filterState.hasActiveFilters
                              ? 'Aucune catégorie ne correspond à vos filtres'
                              : 'Aucune catégorie enregistrée',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (filterState.hasActiveFilters)
                          TextButton(
                            onPressed: () {
                              _searchController.clear();
                              ref
                                  .read(categoryFilterNotifierProvider.notifier)
                                  .reset();
                            },
                            child: const Text('Effacer les filtres'),
                          ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: categories.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          category.name.isNotEmpty
                              ? category.name[0].toUpperCase()
                              : '?',
                        ),
                      ),
                      title: Text(
                        category.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Créée le ${_formatDateString(category.createdAt)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            tooltip: 'Modifier',
                            onPressed: () => _editCategory(category),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Supprimer',
                            onPressed: () => _deleteCategory(category),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) =>
                  Center(child: Text('Erreur de chargement: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'categories_fab',
        onPressed: _addCategory,
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle catégorie'),
      ),
    );
  }
}
