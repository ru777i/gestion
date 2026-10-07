import 'package:flutter/material.dart';

class AppDialog {
  static Future<bool?> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onCancel,
    VoidCallback? onConfirm,
    String confirmText = 'Confirmer',
    String cancelText = 'Annuler',
    bool isDanger = false,
  }) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              if (onCancel != null) {
                onCancel();
              } else {
                Navigator.pop(context, false);
              }
            },
            child: Text(cancelText),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDanger ? Colors.red : Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              if (onConfirm != null) {
                onConfirm();
              } else {
                Navigator.pop(context, true);
              }
            },
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
}
