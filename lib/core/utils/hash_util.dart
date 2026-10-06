import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Utilitaire pour le hachage sécurisé des mots de passe.
class HashUtil {
  /// Hache un mot de passe en clair en SHA-256.
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
