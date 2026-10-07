import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_stock/core/database/app_database.dart';
import 'package:gestion_stock/providers/users_provider.dart';

class AuthState {
  final User? currentUser;
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.currentUser,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? currentUser,
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    bool clearUser = false,
  }) {
    return AuthState(
      currentUser: clearUser ? null : (currentUser ?? this.currentUser),
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  /// Tente de connecter un utilisateur avec son nom d'utilisateur et son mot de passe.
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = ref.read(usersRepositoryProvider);
      final user = await repository.login(username.trim(), password.trim());

      if (user != null) {
        state = state.copyWith(
          currentUser: user,
          isAuthenticated: true,
          isLoading: false,
          error: null,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
          error: 'Nom d\'utilisateur ou mot de passe incorrect.',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        error: 'Erreur de connexion : ${e.toString()}',
      );
      return false;
    }
  }

  /// Vérifie si un utilisateur est actuellement authentifié.

  Future<int> register(
    String username,
    String fullNam,
    String password,
    String role,
  ) async {
    final repository = ref.read(usersRepositoryProvider);
   return repository.createUser(
      username: username,
      fullName: fullNam,
      password: password,
      role: role,
    );
  }

  bool get isAuthenticated => state.isAuthenticated;

  /// Déconnecte l'utilisateur actuellement authentifié.
  void logout() {
    state = const AuthState();
  }
}

/// Provider global pour gérer l'authentification dans toute l'application.
final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
