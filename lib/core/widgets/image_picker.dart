import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Une feuille modale (BottomSheet) permettant de sélectionner une image
/// soit depuis la galerie, soit en prenant une photo avec la caméra.
///
/// Exemple d'utilisation :
/// ```dart
/// final File? imageFile = await ImagePickerSheet.show(context);
/// if (imageFile != null) {
///   // Traiter l'image sélectionnée
/// }
/// ```
class ImagePickerSheet extends StatelessWidget {
  const ImagePickerSheet({super.key});

  /// Ouvre le BottomSheet de sélection d'image (Galerie ou Caméra)
  /// et retourne le fichier [File] sélectionné ou `null`.
  static Future<File?> show(BuildContext context) async {
    return await showModalBottomSheet<File?>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const ImagePickerSheet(),
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final XFile? imageSelectionnee = await picker.pickImage(source: source);

    if (imageSelectionnee != null && context.mounted) {
      Navigator.pop(context, File(imageSelectionnee.path));
    } else if (context.mounted) {
      Navigator.pop(context, null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Wrap(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Choisir la source de l\'image',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blue),
              title: const Text('Galerie'),
              subtitle: const Text('Choisir une photo depuis la galerie'),
              onTap: () => _pickImage(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.green),
              title: const Text('Caméra'),
              subtitle: const Text('Prendre une photo avec l\'appareil'),
              onTap: () => _pickImage(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
  }
}
