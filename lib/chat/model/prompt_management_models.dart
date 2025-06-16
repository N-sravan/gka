class PromptModel {
  final String id;
  final String name;
  final String content;
  final String? description;
  final String? categoryName;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  PromptModel({
    required this.id,
    required this.name,
    required this.content,
    this.description,
    this.categoryName,
    this.createdBy,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  factory PromptModel.fromJson(Map<String, dynamic> json) {
    return PromptModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      content: json['content'] ?? '',
      description: json['description'],
      categoryName: json['category_name'],
      createdBy: json['created_by'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'content': content,
      'description': description,
      'category_name': categoryName,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_active': isActive,
    };
  }
}

class PromptCategoryModel {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;

  PromptCategoryModel({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
  });

  factory PromptCategoryModel.fromJson(Map<String, dynamic> json) {
    return PromptCategoryModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class PromptHistoryModel {
  final String id;
  final String promptName;
  final String content;
  final String? changedBy;
  final String? changeDescription;
  final DateTime createdAt;

  PromptHistoryModel({
    required this.id,
    required this.promptName,
    required this.content,
    this.changedBy,
    this.changeDescription,
    required this.createdAt,
  });

  factory PromptHistoryModel.fromJson(Map<String, dynamic> json) {
    return PromptHistoryModel(
      id: json['id']?.toString() ?? '',
      promptName: json['prompt_name'] ?? '',
      content: json['content'] ?? '',
      changedBy: json['changed_by'],
      changeDescription: json['change_description'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class PromptManagementResponse {
  final List<PromptModel>? prompts;
  final PromptModel? prompt;
  final List<PromptCategoryModel>? categories;
  final List<PromptHistoryModel>? history;
  final String? message;
  final int statusCode;
  final bool success;

  PromptManagementResponse({
    this.prompts,
    this.prompt,
    this.categories,
    this.history,
    this.message,
    required this.statusCode,
    required this.success,
  });

  factory PromptManagementResponse.fromJson(Map<String, dynamic> json) {
    return PromptManagementResponse(
      prompts: json['response'] is List 
          ? (json['response'] as List).map((item) => PromptModel.fromJson(item)).toList()
          : null,
      prompt: json['response'] is Map<String, dynamic> && json['response']['content'] != null
          ? PromptModel.fromJson(json['response'])
          : null,
      categories: json['response'] is List && json['response'].isNotEmpty && json['response'][0]['name'] != null
          ? (json['response'] as List).map((item) => PromptCategoryModel.fromJson(item)).toList()
          : null,
      history: json['response'] is List && json['response'].isNotEmpty && json['response'][0]['prompt_name'] != null
          ? (json['response'] as List).map((item) => PromptHistoryModel.fromJson(item)).toList()
          : null,
      message: json['response'] is Map<String, dynamic> ? json['response']['message'] : null,
      statusCode: json['statuscode'] ?? json['statusCode'] ?? 0,
      success: (json['statuscode'] ?? json['statusCode'] ?? 0) >= 200 && (json['statuscode'] ?? json['statusCode'] ?? 0) < 300,
    );
  }
}

class CreatePromptRequest {
  final String name;
  final String content;
  final String? description;
  final String? categoryName;
  final String? createdBy;

  CreatePromptRequest({
    required this.name,
    required this.content,
    this.description,
    this.categoryName,
    this.createdBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'content': content,
      'description': description,
      'category_name': categoryName,
      'created_by': createdBy,
    };
  }
}

class UpdatePromptRequest {
  final String content;
  final String? changedBy;
  final String? changeDescription;

  UpdatePromptRequest({
    required this.content,
    this.changedBy,
    this.changeDescription,
  });

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'changed_by': changedBy,
      'change_description': changeDescription,
    };
  }
}