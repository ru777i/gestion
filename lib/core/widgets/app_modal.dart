import 'package:flutter/material.dart';

class AppModal extends StatelessWidget {
  final String title;
  final Widget child;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool showActions;

  const AppModal({
    super.key,
    required this.title,
    required this.child,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Contenu
            child,

            if (showActions) ...[
              const SizedBox(height: 24),

              // Boutons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (cancelText != null)
                    TextButton(
                      onPressed: onCancel ??
                              () => Navigator.pop(context),
                      child: Text(cancelText!),
                    ),

                  const SizedBox(width: 8),

                  if (confirmText != null)
                    ElevatedButton(
                      onPressed: onConfirm,
                      child: Text(confirmText!),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}




/*
showAppModal(
  context: context,
  title: 'Ajouter un produit',
  cancelText: 'Annuler',
  confirmText: 'Ajouter',
  onConfirm: () {
    // Ajouter le produit
    Navigator.pop(context);
  },
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      TextField(
        decoration: InputDecoration(
          labelText: 'Nom du produit',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),

      const SizedBox(height: 16),

      TextField(
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: 'Prix',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),

      const SizedBox(height: 16),

      TextField(
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: 'Quantité',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    ],
  ),
);
 */
//