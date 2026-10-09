import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_stock/core/database/app_database.dart';
import 'package:gestion_stock/providers/products_provder.dart';
import 'package:gestion_stock/providers/sales_provider.dart';
import 'package:gestion_stock/views/vente/widgets/sale_filter_dialog.dart';

/// Écran d'affichage et de consultation de l'historique des ventes.
class Historiquevente extends ConsumerStatefulWidget {
  const Historiquevente({super.key});

  @override
  ConsumerState<Historiquevente> createState() => _HistoriqueventeState();
}

class _HistoriqueventeState extends ConsumerState<Historiquevente> {
  final SearchController _searchController = SearchController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openFilterDialog() async {
    final currentFilter = ref.read(saleFilterNotifierProvider);
    final result = await SaleFilterDialog.show(
      context,
      initialState: currentFilter,
    );

    if (result != null) {
      final notifier = ref.read(saleFilterNotifierProvider.notifier);
      notifier.setDate(result.startDate, result.endDate);
      notifier.setAscending(result.ascending);
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'payé':
        return Colors.green;
      case 'partial':
      case 'partiel':
        return Colors.orange;
      case 'unpaid':
      case 'impayé':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return 'Payé';
      case 'partial':
        return 'Partiel';
      case 'unpaid':
        return 'Impayé';
      default:
        return status;
    }
  }

  void _showSaleDetailsModal(Sale sale) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          final repository = ref.read(salesRepositoryProvider);

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Vente #${sale.id}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Text(
                  'UUID : ${sale.uuid}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Date : ${_formatDateString(sale.createdAt)}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text('Mode de paiement : ${sale.paymentMethod}'),
                const SizedBox(height: 12),
                const Divider(),
                const Text(
                  'Articles achetés',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),

                Expanded(
                  child: FutureBuilder<List<SaleItem>>(
                    future: repository.findItemsBySaleId(sale.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Erreur : ${snapshot.error}'),
                        );
                      }

                      final items = snapshot.data ?? [];
                      if (items.isEmpty) {
                        return const Center(
                          child: Text('Aucun article trouvé'),
                        );
                      }

                      return ListView.separated(
                        controller: scrollController,
                        itemCount: items.length,
                        separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = items[index];

                          return FutureBuilder<Product?>(
                            future: ref
                                .read(productsRepositoryProvider)
                                .findById(item.productId),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text('Chargement du produit...'),
                                );
                              }

                              if (snapshot.hasError) {
                                return const ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text('Erreur de chargement du produit'),
                                );
                              }

                              final product = snapshot.data;

                              if (product == null) {
                                return const ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text('Produit introuvable'),
                                );
                              }

                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(product.name),
                                subtitle: Text(
                                  'Quantité : ${item.quantity}  •  '
                                      'PU : ${item.unitPrice} FCFA',
                                ),
                                trailing: Text(
                                  '${item.subtotal} FCFA',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
                const Divider(),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total :',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${sale.totalAmount} FCFA',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filterState = ref.watch(saleFilterNotifierProvider);
    final salesAsync = ref.watch(salesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Historique des Ventes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              filterState.ascending
                  ? Icons.arrow_upward
                  : Icons.arrow_downward,
            ),
            tooltip: filterState.ascending
                ? 'Ordre : Plus ancien'
                : 'Ordre : Plus récent',
            onPressed: () {
              ref
                  .read(saleFilterNotifierProvider.notifier)
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
              if (filterState.hasActiveFilters)
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
          // Barre de recherche
          Container(
            color: const Color(0xFFF1F4F5),
            padding: const EdgeInsets.all(12),
            child: SearchAnchor(
              searchController: _searchController,
              builder: (context, controller) {
                return SearchBar(
                  controller: controller,
                  hintText: 'Rechercher une vente par UUID, mode...',
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
                    setState(() {
                      _searchQuery = text.trim();
                    });
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
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      ),
                  ],
                );
              },
              suggestionsBuilder: (context, controller) async {
                final query = controller.text.trim().toLowerCase();
                final sales = salesAsync.value ?? [];
                final results = sales.where((s) {
                  return s.uuid.toLowerCase().contains(query) ||
                      s.paymentMethod.toLowerCase().contains(query) ||
                      s.paymentStatus.toLowerCase().contains(query);
                }).toList();

                if (results.isEmpty) {
                  return [
                    const ListTile(
                      title: Text('Aucune vente trouvée'),
                      leading: Icon(Icons.info_outline),
                    ),
                  ];
                }

                return results.take(5).map((sale) {
                  return ListTile(
                    leading: const Icon(Icons.receipt_long),
                    title: Text('Vente #${sale.id} • ${sale.totalAmount} FCFA'),
                    subtitle: Text('UUID : ${sale.uuid}'),
                    onTap: () {
                      controller.closeView(sale.uuid);
                      _showSaleDetailsModal(sale);
                    },
                  );
                }).toList();
              },
            ),
          ),

          // Chips de filtres actifs
          if (filterState.hasActiveFilters)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  if (filterState.startDate != null ||
                      filterState.endDate != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        avatar: const Icon(Icons.date_range, size: 16),
                        label: const Text('Filtre par date actif'),
                        onDeleted: () {
                          ref
                              .read(saleFilterNotifierProvider.notifier)
                              .setDate(null, null);
                        },
                      ),
                    ),
                  ActionChip(
                    avatar: const Icon(Icons.refresh, size: 16),
                    label: const Text('Réinitialiser tout'),
                    onPressed: () {
                      ref.read(saleFilterNotifierProvider.notifier).reset();
                    },
                  ),
                ],
              ),
            ),

          const SizedBox(height: 8),

          // Liste des ventes
          Expanded(
            child: salesAsync.when(
              data: (sales) {
                var displayList = sales;
                if (_searchQuery.isNotEmpty) {
                  displayList = sales.where((s) {
                    return s.uuid.toLowerCase().contains(_searchQuery) ||
                        s.paymentMethod.toLowerCase().contains(_searchQuery) ||
                        s.paymentStatus.toLowerCase().contains(_searchQuery);
                  }).toList();
                }

                if (displayList.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Aucune vente enregistrée',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: displayList.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final sale = displayList[index];
                    final statusColor = _getStatusColor(sale.paymentStatus);
                    final statusLabel = _getStatusLabel(sale.paymentStatus);

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
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context)
                                .primaryColor
                                .withOpacity(0.1),
                            child: Icon(
                              Icons.receipt_long,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Vente #${sale.id}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '${sale.totalAmount} FCFA',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _formatDateString(sale.createdAt),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Chip(
                                      visualDensity: VisualDensity.compact,
                                      padding: EdgeInsets.zero,
                                      label: Text(
                                        statusLabel,
                                        style: TextStyle(
                                          color: statusColor,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      backgroundColor:
                                          statusColor.withOpacity(0.1),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Mode : ${sale.paymentMethod}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                           onTap: () => _showSaleDetailsModal(sale),
                        ),
                      ),
                    );
                  },
                );
              },
              error: (error, stack) =>
                  Center(child: Text('Erreur : $error')),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }
}
