import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/prompt_management_view_model.dart';
import '../model/prompt_management_models.dart';
import '../repo/prompt_management_repo.dart';

class PromptSelectionWidget extends StatefulWidget {
  final Function(PromptModel) onPromptSelected;
  final PromptModel? selectedPrompt;

  const PromptSelectionWidget({
    Key? key,
    required this.onPromptSelected,
    this.selectedPrompt,
  }) : super(key: key);

  @override
  State<PromptSelectionWidget> createState() => _PromptSelectionWidgetState();
}

class _PromptSelectionWidgetState extends State<PromptSelectionWidget> {
  late PromptManagementViewModel _viewModel;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _viewModel = PromptManagementViewModel(
      repository: PromptManagementRepositoryImpl(),
    );
    _viewModel.initialize();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PromptManagementViewModel>(
      create: (_) => _viewModel,
      child: Consumer<PromptManagementViewModel>(
        builder: (context, viewModel, child) {
          return Card(
            margin: const EdgeInsets.all(8),
            child: ExpansionTile(
              leading: const Icon(Icons.psychology),
              title: Text(
                widget.selectedPrompt != null
                    ? 'Selected: ${widget.selectedPrompt!.name}'
                    : 'Select a Prompt',
              ),
              subtitle: widget.selectedPrompt != null
                  ? Text(
                      widget.selectedPrompt!.description ?? 'No description',
                      style: TextStyle(color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  : const Text('Choose from available prompts'),
              children: [
                if (viewModel.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (viewModel.prompts.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No prompts available'),
                  )
                else
                  Container(
                    constraints: const BoxConstraints(maxHeight: 300),
                    child: Column(
                      children: [
                        // Search Bar
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: TextField(
                            controller: viewModel.searchController,
                            onChanged: viewModel.updateSearchQuery,
                            decoration: InputDecoration(
                              hintText: 'Search prompts...',
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: viewModel.searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: viewModel.clearSearch,
                                    )
                                  : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ),
                        // Category Filter
                        if (viewModel.categories.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: DropdownButtonFormField<String>(
                              value: viewModel.selectedCategoryId,
                              decoration: InputDecoration(
                                labelText: 'Filter by Category',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              items: [
                                const DropdownMenuItem<String>(
                                  value: null,
                                  child: Text('All Categories'),
                                ),
                                ...viewModel.categories.map((category) =>
                                    DropdownMenuItem<String>(
                                      value: category.name,
                                      child: Text(category.name),
                                    ),
                                ),
                              ],
                              onChanged: viewModel.setSelectedCategory,
                            ),
                          ),
                        const SizedBox(height: 8),
                        // Prompts List
                        Expanded(
                          child: ListView.builder(
                            itemCount: viewModel.filteredPrompts.length,
                            itemBuilder: (context, index) {
                              final prompt = viewModel.filteredPrompts[index];
                              final isSelected = widget.selectedPrompt?.id == prompt.id;
                              
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isSelected
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey[300],
                                  child: Icon(
                                    Icons.psychology,
                                    color: isSelected ? Colors.white : Colors.grey[600],
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  prompt.name,
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (prompt.description != null && prompt.description!.isNotEmpty)
                                      Text(
                                        prompt.description!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    Text(
                                      prompt.content,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                        fontFamily: 'monospace',
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (prompt.categoryName != null)
                                      Chip(
                                        label: Text(
                                          prompt.categoryName!,
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    if (isSelected)
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                      ),
                                  ],
                                ),
                                onTap: () {
                                  widget.onPromptSelected(prompt);
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class PromptQuickSelectionWidget extends StatefulWidget {
  final Function(PromptModel) onPromptSelected;
  final PromptModel? selectedPrompt;

  const PromptQuickSelectionWidget({
    Key? key,
    required this.onPromptSelected,
    this.selectedPrompt,
  }) : super(key: key);

  @override
  State<PromptQuickSelectionWidget> createState() => _PromptQuickSelectionWidgetState();
}

class _PromptQuickSelectionWidgetState extends State<PromptQuickSelectionWidget> {
  late PromptManagementViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = PromptManagementViewModel(
      repository: PromptManagementRepositoryImpl(),
    );
    _viewModel.initialize();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PromptManagementViewModel>(
      create: (_) => _viewModel,
      child: Consumer<PromptManagementViewModel>(
        builder: (context, viewModel, child) {
          return Container(
            height: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.psychology, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Quick Prompts',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      if (widget.selectedPrompt != null)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            // Clear selection - you might want to pass null or default prompt
                          },
                          tooltip: 'Clear selection',
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: viewModel.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : viewModel.prompts.isEmpty
                          ? const Center(child: Text('No prompts available'))
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: viewModel.prompts.take(10).length, // Show max 10 for quick access
                              itemBuilder: (context, index) {
                                final prompt = viewModel.prompts[index];
                                final isSelected = widget.selectedPrompt?.id == prompt.id;
                                
                                return Container(
                                  width: 150,
                                  margin: const EdgeInsets.only(right: 8),
                                  child: InkWell(
                                    onTap: () => widget.onPromptSelected(prompt),
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Theme.of(context).primaryColor.withOpacity(0.1)
                                            : Colors.grey[100],
                                        borderRadius: BorderRadius.circular(8),
                                        border: isSelected
                                            ? Border.all(color: Theme.of(context).primaryColor)
                                            : null,
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  prompt.name,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                    color: isSelected
                                                        ? Theme.of(context).primaryColor
                                                        : null,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              if (isSelected)
                                                Icon(
                                                  Icons.check_circle,
                                                  color: Theme.of(context).primaryColor,
                                                  size: 16,
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Expanded(
                                            child: Text(
                                              prompt.content,
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey[600],
                                                fontFamily: 'monospace',
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}