import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gka/utils/common_constants.dart' as constants;
import '../view_model/prompt_management_view_model.dart';
import '../model/prompt_management_models.dart';
import '../repo/prompt_management_repo.dart';
import 'prompt_dialogs.dart';

class PromptManagementView extends StatefulWidget {
  const PromptManagementView({Key? key}) : super(key: key);

  @override
  State<PromptManagementView> createState() => _PromptManagementViewState();
}

class _PromptManagementViewState extends State<PromptManagementView>
    with TickerProviderStateMixin {
  late PromptManagementViewModel _viewModel;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _viewModel = PromptManagementViewModel(
      repository: PromptManagementRepositoryImpl(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PromptManagementViewModel>(
      create: (_) => _viewModel,
      child: Consumer<PromptManagementViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: Colors.grey[50],
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 220,
                    floating: false,
                    pinned: true,
                    elevation: 0,
                    centerTitle: true,
                    backgroundColor: Theme.of(context).primaryColor,
                    title: const Text(
                      'Prompt Management',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        padding: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Theme.of(context).primaryColor,
                              Theme.of(context).primaryColor.withOpacity(0.8),
                            ],
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.psychology,
                              size: 40,
                              color: Colors.white70,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${viewModel.prompts.length} Prompts Available',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    bottom: TabBar(
                      controller: _tabController,
                      indicatorColor: Colors.white,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white70,
                      tabs: const [
                        Tab(icon: Icon(Icons.list), text: 'Prompts'),
                        Tab(icon: Icon(Icons.category), text: 'Categories'),
                        Tab(icon: Icon(Icons.settings), text: 'Settings'),
                      ],
                    ),
                  )
                ];
              },
              body: viewModel.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildPromptsTab(context, viewModel),
                        _buildCategoriesTab(context, viewModel),
                        _buildSettingsTab(context, viewModel),
                      ],
                    ),
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => _showCreatePromptDialog(context, viewModel),
              icon: const Icon(Icons.add),
              label: const Text('New Prompt'),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          );
        },
      ),
    );
  }

  Widget _buildPromptsTab(BuildContext context, PromptManagementViewModel viewModel) {
    return Column(
      children: [
        // Search and Filter Bar
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              TextField(
                controller: viewModel.searchController,
                onChanged: viewModel.updateSearchQuery,
                decoration: InputDecoration(
                  hintText: 'Search prompts by name or content...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                  suffixIcon: viewModel.searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: viewModel.clearSearch,
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              const SizedBox(height: 16),
              // Category Filter
              if (viewModel.categories.isNotEmpty)
                DropdownButtonFormField<String>(
                  value: viewModel.selectedCategoryId,
                  decoration: InputDecoration(
                    labelText: 'Filter by Category',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            ],
          ),
        ),
        // Prompts List
        Expanded(
          child: viewModel.filteredPrompts.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 80), // Extra bottom padding for FAB
                  itemCount: viewModel.filteredPrompts.length,
                  itemBuilder: (context, index) {
                    final prompt = viewModel.filteredPrompts[index];
                    return _buildPromptCard(context, viewModel, prompt);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPromptCard(BuildContext context, PromptManagementViewModel viewModel, PromptModel prompt) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showPromptDetailsDialog(context, viewModel, prompt),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      prompt.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      switch (value) {
                        case 'edit':
                          _showEditPromptDialog(context, viewModel, prompt);
                          break;
                        case 'history':
                          _showPromptHistory(context, viewModel, prompt);
                          break;
                        case 'delete':
                          _showDeleteConfirmation(context, viewModel, prompt);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'history',
                        child: Row(
                          children: [
                            Icon(Icons.history),
                            SizedBox(width: 8),
                            Text('History'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (prompt.description != null && prompt.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  prompt.description!,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Text(
                  prompt.content,
                  style: const TextStyle(
                    fontSize: 13,
                    fontFamily: 'monospace',
                    height: 1.4,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (prompt.categoryName != null)
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Theme.of(context).primaryColor.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          prompt.categoryName!,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Created ${_formatDate(prompt.createdAt)}',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesTab(BuildContext context, PromptManagementViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.add_circle, color: Colors.green),
              title: const Text('Create New Category'),
              subtitle: const Text('Organize your prompts with categories'),
              onTap: () => _showCreateCategoryDialog(context, viewModel),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: viewModel.categories.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.category, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No categories yet',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        Text(
                          'Create your first category to organize prompts',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: viewModel.categories.length,
                    itemBuilder: (context, index) {
                      final category = viewModel.categories[index];
                      final promptCount = viewModel.prompts
                          .where((p) => p.categoryName == category.name)
                          .length;
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundColor: Theme.of(context).primaryColor,
                            child: Text(
                              category.name.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            category.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (category.description != null && category.description!.isNotEmpty)
                                  Text(
                                    category.description!,
                                    style: TextStyle(color: Colors.grey[600]),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                const SizedBox(height: 4),
                                Text(
                                  '$promptCount prompts',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.arrow_forward_ios, size: 16),
                            onPressed: () {
                              viewModel.setSelectedCategory(category.name);
                              _tabController.animateTo(0);
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab(BuildContext context, PromptManagementViewModel viewModel) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text('Refresh Cache'),
                subtitle: const Text('Reload all prompts from server'),
                onTap: () => viewModel.refreshCache(),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.backup),
                title: const Text('Migrate Prompts'),
                subtitle: const Text('Import existing prompts from old system'),
                onTap: () => _showMigrateConfirmation(context, viewModel),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Statistics',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildStatRow('Total Prompts', '${viewModel.prompts.length}'),
                _buildStatRow('Categories', '${viewModel.categories.length}'),
                _buildStatRow('Active Prompts', '${viewModel.prompts.where((p) => p.isActive).length}'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.psychology_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No prompts found',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          Text(
            'Create your first prompt to get started',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showCreatePromptDialog(BuildContext context, PromptManagementViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => CreatePromptDialog(viewModel: viewModel),
    );
  }

  void _showEditPromptDialog(BuildContext context, PromptManagementViewModel viewModel, PromptModel prompt) {
    viewModel.selectPrompt(prompt);
    showDialog(
      context: context,
      builder: (context) => EditPromptDialog(viewModel: viewModel, prompt: prompt),
    );
  }

  void _showPromptDetailsDialog(BuildContext context, PromptManagementViewModel viewModel, PromptModel prompt) {
    showDialog(
      context: context,
      builder: (context) => PromptDetailsDialog(prompt: prompt),
    );
  }

  void _showDeleteConfirmation(BuildContext context, PromptManagementViewModel viewModel, PromptModel prompt) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Prompt'),
        content: Text('Are you sure you want to delete "${prompt.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await viewModel.deletePrompt(prompt.name);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCreateCategoryDialog(BuildContext context, PromptManagementViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => CreateCategoryDialog(viewModel: viewModel),
    );
  }

  void _showPromptHistory(BuildContext context, PromptManagementViewModel viewModel, PromptModel prompt) {
    showDialog(
      context: context,
      builder: (context) => PromptHistoryDialog(prompt: prompt),
    );
  }

  void _showMigrateConfirmation(BuildContext context, PromptManagementViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Migrate Prompts'),
        content: const Text('This will import existing prompts from the old system. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await viewModel.migratePrompts();
            },
            child: const Text('Migrate'),
          ),
        ],
      ),
    );
  }
}
