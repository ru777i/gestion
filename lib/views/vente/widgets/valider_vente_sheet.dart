import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_stock/core/database/app_database.dart';
import 'package:gestion_stock/providers/customers_provider.dart';
import 'package:gestion_stock/providers/sale_items_provider.dart';
import 'package:gestion_stock/providers/sales_provider.dart';
import 'package:uuid/uuid.dart';

/// ModalBottomSheet permettant de finaliser et valider la vente.
class ValiderVenteSheet extends ConsumerStatefulWidget {
  const ValiderVenteSheet({super.key});

  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const ValiderVenteSheet(),
    );
  }

  @override
  ConsumerState<ValiderVenteSheet> createState() => _ValiderVenteSheetState();
}

class _ValiderVenteSheetState extends ConsumerState<ValiderVenteSheet> {
  Customer? _selectedCustomer;
  String _paymentMethod = 'Espèces';
  late final TextEditingController _amountPaidController;
  bool _isLoading = false;

  final List<String> _paymentMethods = [
    'Espèces',
    'Mobile Money',
    'Carte Bancaire',
    'Crédit',
  ];

  @override
  void initState() {
    super.initState();
    final total = ref.read(panierNotifierProvider.notifier).totalAmount;
    _amountPaidController = TextEditingController(text: total.toString());
  }

  @override
  void dispose() {
    _amountPaidController.dispose();
    super.dispose();
  }

  Future<void> _confirmSale() async {
    final panierNotifier = ref.read(panierNotifierProvider.notifier);
    final items = ref.read(panierNotifierProvider);

    if (items.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final totalAmount = panierNotifier.totalAmount;
      final amountPaid =
          int.tryParse(_amountPaidController.text.trim()) ?? totalAmount;

      String paymentStatus = 'paid';
      if (amountPaid == 0) {
        paymentStatus = 'unpaid';
      } else if (amountPaid < totalAmount) {
        paymentStatus = 'partial';
      }

      final salesRepo = ref.read(salesRepositoryProvider);
      final uuid = const Uuid().v4();

      await salesRepo.createSaleWithItems(
        uuid: uuid,
        customerId: _selectedCustomer?.id,
        totalAmount: totalAmount,
        amountPaid: amountPaid,
        paymentMethod: _paymentMethod,
        paymentStatus: paymentStatus,
        userId: 1,
        items: items,
      );

      panierNotifier.clear();

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la validation : $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalAmount = ref.watch(panierNotifierProvider.notifier).totalAmount;
    final customersAsync = ref.watch(filteredCustomersProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Valider la Vente',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 12),

            // Montant Total
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Montant Total :',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '$totalAmount FCFA',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Choix du client (Optionnel)
            customersAsync.when(
              data: (customersList) {
                return DropdownButtonFormField<Customer>(
                  decoration: const InputDecoration(
                    labelText: 'Client (Optionnel)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  value: _selectedCustomer,
                  items: [
                    const DropdownMenuItem<Customer>(
                      value: null,
                      child: Text('Client de passage'),
                    ),
                    ...customersList.map((customer) {
                      return DropdownMenuItem<Customer>(
                        value: customer,
                        child: Text(customer.name),
                      );
                    }),
                  ],
                  onChanged: (Customer? customer) {
                    setState(() {
                      _selectedCustomer = customer;
                    });
                  },
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const SizedBox(),
            ),
            const SizedBox(height: 16),

            // Mode de paiement
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Mode de paiement',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.payment),
              ),
              value: _paymentMethod,
              items: _paymentMethods.map((method) {
                return DropdownMenuItem<String>(
                  value: method,
                  child: Text(method),
                );
              }).toList(),
              onChanged: (String? newMethod) {
                if (newMethod != null) {
                  setState(() {
                    _paymentMethod = newMethod;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Montant payé
            TextFormField(
              controller: _amountPaidController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Montant versé (FCFA)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),
            const SizedBox(height: 24),

            // Bouton de confirmation
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _confirmSale,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check_circle_outline),
              label: Text(
                _isLoading ? 'Enregistrement...' : 'Confirmer et Régler',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
