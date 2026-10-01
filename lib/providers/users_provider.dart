import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/database/app_database.dart';
import '../core/database/database_provider.dart';
import '../repositories/users_repository.dart';
import '../services/users_service.dart';

final usersServiceProvider = Provider<UsersService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return UsersService(db);
});

final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  final service = ref.watch(usersServiceProvider);
  return UsersRepository(service);
});

class UserFilterState {
  final String searchQuery;
  final String? role;
  final String? userName;
  final String? fullName;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool ascending;

  const UserFilterState({
    this.searchQuery = '',
    this.role,
    this.userName,
    this.fullName,
    this.createdAt,
    this.updatedAt,
    this.ascending = true,
  });

  bool get hasActiveFilters =>
      searchQuery.trim().isNotEmpty ||
      (role != null && role!.trim().isNotEmpty) ||
      !ascending;

  UserFilterState copyWith({
    String? searchQuery,
    String? role,
    String? userName,
    String? fullName,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? ascending,
    bool clearRole = false,
  }) {
    return UserFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      role: clearRole ? null : (role ?? this.role),
      ascending: ascending ?? this.ascending,
      userName: userName ?? this.userName,
      fullName: fullName ?? this.fullName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class UserFilterNotifier extends Notifier<UserFilterState> {
  @override
  UserFilterState build() => const UserFilterState();

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setRole(String? role) {
    state = state.copyWith(role: role, clearRole: role == null);
  }

  void setAscending(bool ascending) {
    state = state.copyWith(ascending: ascending);
  }

  void reset() {
    state = const UserFilterState();
  }
}

final userFilterNotifierProvider =
    NotifierProvider<UserFilterNotifier, UserFilterState>(
      UserFilterNotifier.new,
    );

final filteredUsersProvider = StreamProvider<List<User>>((ref) {
  final service = ref.watch(usersServiceProvider);
  final filter = ref.watch(userFilterNotifierProvider);

  return service.watchFilterUsers(
    searchQuery: filter.searchQuery,
    role: filter.role,
    ascending: filter.ascending,
  );
});
