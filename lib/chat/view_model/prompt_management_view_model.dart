import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gka/shared/loading_view_model.dart';
import 'package:gka/utils/app_state.dart';
import '../model/prompt_management_models.dart';
import '../repo/prompt_management_repo.dart';

class PromptManagementViewModel extends LoadingViewModel {
  final PromptManagementRepository _repository;

  PromptManagementViewModel({required PromptManagementRepository repository})
      : _repository = repository;

  // Data
  List<PromptModel> _prompts = [];
  List<PromptCategoryModel> _categories = [];
  List<PromptHistoryModel> _promptHistory = [];
  PromptModel? _selectedPrompt;
  String? _selectedCategoryId;
  String _searchQuery = '';

  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController categoryNameController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  // Getters
  List<PromptModel> get prompts => _prompts;
  List<PromptCategoryModel> get categories => _categories;
  List<PromptHistoryModel> get promptHistory => _promptHistory;
  PromptModel? get selectedPrompt => _selectedPrompt;
  String? get selectedCategoryId => _selectedCategoryId;
  String get searchQuery => _searchQuery;

  // Filtered prompts based on search and category
  List<PromptModel> get filteredPrompts {
    var filtered = _prompts;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((prompt) =>
          prompt.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          prompt.content.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (prompt.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
      ).toList();
    }

    // Filter by category
    if (_selectedCategoryId != null && _selectedCategoryId!.isNotEmpty) {
      filtered = filtered.where((prompt) => prompt.categoryName == _selectedCategoryId).toList();
    }

    return filtered;
  }

  // Initialize data
  Future<void> initialize() async {
    isLoading = true;
    ;
    await Future.wait([
      loadPrompts(),
      loadCategories(),
    ]);
    isLoading = false;
    ;
  }

  // Load all prompts
  Future<void> loadPrompts() async {
    try {
      final response = await _repository.getAllPrompts();
      if (response.success && response.prompts != null) {
        _prompts = response.prompts!;
        notifyListeners();
      } else {
        _showError('Failed to load prompts: ${response.message}');
      }
    } catch (e) {
      _showError('Error loading prompts: ${e.toString()}');
    }
  }

  // Load categories
  Future<void> loadCategories() async {
    try {
      final response = await _repository.getCategories();
      if (response.success && response.categories != null) {
        _categories = response.categories!;
        notifyListeners();
      }
    } catch (e) {
      _showError('Error loading categories: ${e.toString()}');
    }
  }

  // Create new prompt
  Future<bool> createPrompt({
    required String name,
    required String content,
    String? description,
    String? categoryName,
  }) async {
    if (name.trim().isEmpty || content.trim().isEmpty) {
      _showError('Name and content are required');
      return false;
    }

    isLoading = true;
    ;
    try {
      final request = CreatePromptRequest(
        name: name.trim(),
        content: content.trim(),
        description: description?.trim(),
        categoryName: categoryName,
        createdBy: AppState.instance.userId,
      );

      final response = await _repository.createPrompt(request);

      if (response.success) {
        await loadPrompts(); // Refresh list
        clearForm();
        _showSuccess('Prompt created successfully');
        isLoading = false;
        ;
        return true;
      } else {
        _showError('Failed to create prompt: ${response.message}');
        isLoading = false;
        ;
        return false;
      }
    } catch (e) {
      _showError('Error creating prompt: ${e.toString()}');
      isLoading = false;
      ;
      return false;
    }
  }

  // Update existing prompt
  Future<bool> updatePrompt({
    required String name,
    required String content,
    String? changeDescription,
  }) async {
    if (name.trim().isEmpty || content.trim().isEmpty) {
      _showError('Name and content are required');
      return false;
    }

    isLoading = true;
    ;
    try {
      final request = UpdatePromptRequest(
        content: content.trim(),
        changedBy: AppState.instance.userId,
        changeDescription: changeDescription?.trim(),
      );

      final response = await _repository.updatePrompt(name, request);

      if (response.success) {
        await loadPrompts(); // Refresh list
        clearForm();
        _showSuccess('Prompt updated successfully');
        isLoading = false;
        ;
        return true;
      } else {
        _showError('Failed to update prompt: ${response.message}');
        isLoading = false;
        ;
        return false;
      }
    } catch (e) {
      _showError('Error updating prompt: ${e.toString()}');
      isLoading = false;
      ;
      return false;
    }
  }

  // Delete prompt
  Future<bool> deletePrompt(String promptName) async {
    isLoading = true;
    ;
    try {
      final response = await _repository.deletePrompt(promptName);

      if (response.success) {
        await loadPrompts(); // Refresh list
        _showSuccess('Prompt deleted successfully');
        isLoading = false;
        ;
        return true;
      } else {
        _showError('Failed to delete prompt: ${response.message}');
        isLoading = false;
        ;
        return false;
      }
    } catch (e) {
      _showError('Error deleting prompt: ${e.toString()}');
      isLoading = false;
      ;
      return false;
    }
  }

  // Load prompt history
  Future<void> loadPromptHistory(String promptName) async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await _repository.getPromptHistory(promptName);
      if (response.success && response.history != null) {
        _promptHistory = response.history!;
        _showSuccess('Loaded ${response.history!.length} history items');
      } else {
        _showError('Failed to load prompt history: ${response.message}');
      }
    } catch (e) {
      _showError('Error loading prompt history: ${e.toString()}');
    }
    isLoading = false;
    notifyListeners();
  }

  // Create new category
  Future<bool> createCategory({
    required String name,
    String? description,
  }) async {
    if (name.trim().isEmpty) {
      _showError('Category name is required');
      return false;
    }

    isLoading = true;
    ;
    try {
      final response =
          await _repository.createCategory(name.trim(), description?.trim());

      if (response.success) {
        await loadCategories(); // Refresh categories
        _showSuccess('Category created successfully');
        isLoading = false;
        ;
        return true;
      } else {
        _showError('Failed to create category: ${response.message}');
        isLoading = false;
        ;
        return false;
      }
    } catch (e) {
      _showError('Error creating category: ${e.toString()}');
      isLoading = false;
      ;
      return false;
    }
  }

  // Select prompt for editing
  void selectPrompt(PromptModel prompt) {
    _selectedPrompt = prompt;
    nameController.text = prompt.name;
    contentController.text = prompt.content;
    descriptionController.text = prompt.description ?? '';
    notifyListeners();
  }

  // Set selected category
  void setSelectedCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  // Update search query
  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Clear search
  void clearSearch() {
    _searchQuery = '';
    searchController.clear();
    notifyListeners();
  }

  // Clear form
  void clearForm() {
    nameController.clear();
    contentController.clear();
    descriptionController.clear();
    categoryNameController.clear();
    _selectedPrompt = null;
    notifyListeners();
  }

  // Refresh cache
  Future<void> refreshCache() async {
    isLoading = true;
    ;
    try {
      final response = await _repository.refreshCache();
      if (response.success) {
        await loadPrompts();
        _showSuccess('Cache refreshed successfully');
      } else {
        _showError('Failed to refresh cache: ${response.message}');
      }
    } catch (e) {
      _showError('Error refreshing cache: ${e.toString()}');
    }
    isLoading = false;
    ;
  }

  // Migrate existing prompts
  Future<void> migratePrompts() async {
    isLoading = true;
    ;
    try {
      final response = await _repository.migratePrompts();
      if (response.success) {
        await loadPrompts();
        _showSuccess('Prompts migrated successfully');
      } else {
        _showError('Failed to migrate prompts: ${response.message}');
      }
    } catch (e) {
      _showError('Error migrating prompts: ${e.toString()}');
    }
    isLoading = false;
    ;
  }

  // Helper methods
  void _showError(String message) {
    debugPrint('Error: $message');
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 3,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void _showSuccess(String message) {
    debugPrint('Success: $message');
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    contentController.dispose();
    descriptionController.dispose();
    categoryNameController.dispose();
    searchController.dispose();
    super.dispose();
  }
}