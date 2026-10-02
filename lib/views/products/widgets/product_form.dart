import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gestion_stock/core/database/app_database.dart';
import 'package:gestion_stock/core/widgets/barcode_scanner_sheet.dart';
import 'package:gestion_stock/core/widgets/image_picker.dart';
import 'package:gestion_stock/providers/categories_provider.dart';
import 'package:gestion_stock/providers/products_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart' show Category, Product;

class ProductForm extends ConsumerStatefulWidget {
  final Product? product;

  const ProductForm({super.key, this.product});

  @override
  ConsumerState<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends ConsumerState<ProductForm> {
  final _formKey = GlobalKey<FormState>();

  File? _image;

  late final TextEditingController _nameController;
  late final TextEditingController _barcodeController;
  late final TextEditingController _purchasePriceController;
  late final TextEditingController _salePriceController;
  late final TextEditingController _stockQuantityController;
  late final TextEditingController _alertThresholdController;

  Category? _selectedCategory;
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _isEditing = p != null;

    _nameController = TextEditingController(text: p?.name ?? '');
    _barcodeController = TextEditingController(text: p?.barcode ?? '');
    _purchasePriceController = TextEditingController(
      text: p != null ? p.purchasePrice.toString() : '',
    );
    _salePriceController = TextEditingController(
      text: p != null ? p.salePrice.toString() : '',
    );
    _stockQuantityController = TextEditingController(
      text: p != null ? p.stockQuantity.toString() : '',
    );
    _alertThresholdController = TextEditingController(
      text: p != null ? p.alertThreshold.toString() : '5',
    );

    if (p?.photoPath != null && p!.photoPath!.isNotEmpty) {
      _image = File(p.photoPath!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _barcodeController.dispose();
    _purchasePriceController.dispose();
    _salePriceController.dispose();
    _stockQuantityController.dispose();
    _alertThresholdController.dispose();
    super.dispose();
  }

  Future<void> _choisirImage() async {
    final selectedFile = await ImagePickerSheet.show(context);
    if (selectedFile != null) {
      setState(() {
        _image = selectedFile;
      });
    }
  }

  Future<void> _scanBarcode() async {
    final scannedCode = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const BarcodeScannerSheet(),
    );

    if (scannedCode != null && scannedCode.isNotEmpty) {
      setState(() {
        _barcodeController.text = scannedCode;
      });
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(productsRepositoryProvider);

      final name = _nameController.text.trim();
      final barcode = _barcodeController.text.trim();
      final purchasePrice = int.parse(_purchasePriceController.text.trim());
      final salePrice = int.parse(_salePriceController.text.trim());
      final stockQuantity = int.parse(_stockQuantityController.text.trim());
      final alertThreshold = int.parse(_alertThresholdController.text.trim());
      final photoPath = _image?.path;
      final categoryId = _selectedCategory?.id ?? widget.product?.categoryId;

      if (_isEditing) {
        await repository.updateProduct(
          id: widget.product!.id,
          name: name,
          barcode: barcode,
          purchasePrice: purchasePrice,
          salePrice: salePrice,
          stockQuantity: stockQuantity,
          alertThreshold: alertThreshold,
          categoryId: categoryId,
          photoPath: photoPath,
        );
      } else {
        final uuid = const Uuid().v4();
        await repository.createProduct(
          name: name,
          uuid: uuid,
          barcode: barcode,
          purchasePrice: purchasePrice,
          salePrice: salePrice,
          stockQuantity: stockQuantity,
          alertThreshold: alertThreshold,
          categoryId: categoryId,
          photoPath: photoPath,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Produit mis à jour avec succès'
                  : 'Produit créé avec succès',
            ),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : ${e.toString()}'),
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
    final categoriesAsync = ref.watch(filteredCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Modifier un produit' : 'Ajouter un produit',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.check),
            onPressed: _isLoading ? null : _saveProduct,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Photo de produit
                    Row(
                      children: [
                        if (_image != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.file(
                              _image!,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          )
                        else
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(
                              Icons.image,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextButton.icon(
                            onPressed: _choisirImage,
                            icon: const Icon(Icons.add_a_photo),
                            label: const Text('Ajouter / Modifier la photo'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Nom du produit
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom du produit',
                        hintText: 'Ex: Coca-Cola 50cl',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.shopping_bag),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Veuillez saisir un nom valide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Code barre
                    TextFormField(
                      controller: _barcodeController,
                      decoration: InputDecoration(
                        labelText: 'Code-barres',
                        hintText: 'Ex: 123456789',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.qr_code),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.qr_code_scanner),
                          onPressed: _scanBarcode,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Catégorie
                    categoriesAsync.when(
                      data: (categoriesList) {
                        if (_selectedCategory == null &&
                            widget.product?.categoryId != null) {
                          try {
                            _selectedCategory = categoriesList.firstWhere(
                              (c) => c.id == widget.product!.categoryId,
                            );
                          } catch (_) {}
                        }

                        return DropdownButtonFormField<Category>(
                          decoration: const InputDecoration(
                            labelText: 'Catégorie',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.category),
                          ),
                          value: _selectedCategory,
                          items: categoriesList.map((category) {
                            return DropdownMenuItem<Category>(
                              value: category,
                              child: Text(category.name),
                            );
                          }).toList(),
                          onChanged: (Category? newCat) {
                            setState(() {
                              _selectedCategory = newCat;
                            });
                          },
                        );
                      },
                      loading: () => const LinearProgressIndicator(),
                      error: (err, stack) => const Text(
                        'Erreur lors du chargement des catégories',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Prix d'achat & Prix de vente
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _purchasePriceController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Prix d\'achat',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.monetization_on_outlined),
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  int.tryParse(value.trim()) == null) {
                                return 'Prix invalide';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _salePriceController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Prix de vente',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.attach_money),
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  int.tryParse(value.trim()) == null) {
                                return 'Prix invalide';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Quantité & Seuil d'alerte
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _stockQuantityController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Quantité stock',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.inventory_2),
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  int.tryParse(value.trim()) == null) {
                                return 'Quantité invalide';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _alertThresholdController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Seuil d\'alerte',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.warning_amber),
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  int.tryParse(value.trim()) == null) {
                                return 'Seuil invalide';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Bouton Enregistrer
                    ElevatedButton.icon(
                      onPressed: _saveProduct,
                      icon: Icon(_isEditing ? Icons.save : Icons.add),
                      label: Text(
                        _isEditing
                            ? 'Enregistrer les modifications'
                            : 'Créer le produit',
                        style: const TextStyle(fontSize: 16),
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
                  ],
                ),
              ),
            ),
    );
  }
}
