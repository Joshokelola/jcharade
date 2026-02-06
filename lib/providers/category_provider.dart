import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../data/predefined_categories.dart';
import '../services/storage_service.dart';

/// Provider for managing all categories (predefined + custom)
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final storageService = StorageService.instance;
  await storageService.init();

  final customCategories = await storageService.loadCustomCategories();
  final allCategories = [...PredefinedCategories.all, ...customCategories];

  return allCategories;
});

/// Provider for custom categories only
final customCategoriesProvider =
    NotifierProvider<CustomCategoriesNotifier, AsyncValue<List<Category>>>(() {
      return CustomCategoriesNotifier();
    });

/// Notifier for managing custom categories
class CustomCategoriesNotifier extends Notifier<AsyncValue<List<Category>>> {
  final _storageService = StorageService.instance;

  @override
  AsyncValue<List<Category>> build() {
    _loadCustomCategories();
    return const AsyncValue.loading();
  }

  Future<void> _loadCustomCategories() async {
    try {
      await _storageService.init();
      final categories = await _storageService.loadCustomCategories();
      state = AsyncValue.data(categories);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Add a new custom category
  Future<bool> addCategory(Category category) async {
    try {
      final success = await _storageService.addCustomCategory(category);
      if (success) {
        await _loadCustomCategories();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  /// Update an existing custom category
  Future<bool> updateCategory(Category category) async {
    try {
      final success = await _storageService.updateCustomCategory(category);
      if (success) {
        await _loadCustomCategories();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  /// Delete a custom category
  Future<bool> deleteCategory(String categoryId) async {
    try {
      final success = await _storageService.deleteCustomCategory(categoryId);
      if (success) {
        await _loadCustomCategories();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  /// Refresh categories from storage
  Future<void> refresh() async {
    await _loadCustomCategories();
  }
}
