import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/database/app_database.dart';
import '../core/database/database_provider.dart';
import '../repositories/categories_repository.dart';
import '../services/categories_service.dart';

final categoriesServiceProvider = Provider<CategoriesService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return CategoriesService(db);
});

final categoriesRepositoryProvider = Provider<CategoriesRepository>((ref) {
  final service = ref.watch(categoriesServiceProvider);
  return CategoriesRepository(service);
});

class CategoryFilterState {
  final String searchQuery;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool ascending;

  const CategoryFilterState({
    this.searchQuery = '',
    this.startDate,
    this.endDate,
    this.ascending = true,
  });

  bool get hasActiveFilters =>
      searchQuery.trim().isNotEmpty ||
      startDate != null ||
      endDate != null ||
      !ascending;

  CategoryFilterState copyWith({
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
    bool? ascending,
    bool clearStartDate = false,
    bool clearEndDate = false,
  }) {
    return CategoryFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      ascending: ascending ?? this.ascending,
    );
  }
}

class CategoryFilterNotifier extends Notifier<CategoryFilterState> {
  @override
  CategoryFilterState build() => const CategoryFilterState();

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setDateRange(DateTime? start, DateTime? end) {
    state = state.copyWith(
      startDate: start,
      endDate: end,
      clearStartDate: start == null,
      clearEndDate: end == null,
    );
  }

  void setAscending(bool ascending) {
    state = state.copyWith(ascending: ascending);
  }

  void reset() {
    state = const CategoryFilterState();
  }
}

final categoryFilterNotifierProvider =
    NotifierProvider<CategoryFilterNotifier, CategoryFilterState>(
  CategoryFilterNotifier.new,
);

final filteredCategoriesProvider = StreamProvider<List<Category>>((ref) {
  final repository = ref.watch(categoriesRepositoryProvider);
  final filter = ref.watch(categoryFilterNotifierProvider);

  return repository.watchFilteredCategories(
    searchQuery: filter.searchQuery,
    startDate: filter.startDate,
    endDate: filter.endDate,
    ascending: filter.ascending,
  );
});
