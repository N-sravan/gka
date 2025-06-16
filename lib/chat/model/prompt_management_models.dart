import 'package:flutter/material.dart';

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
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: json['updated_at'] != null ? _parseDateTime(json['updated_at']) : null,
      isActive: json['is_active'] ?? true,
    );
  }

  static DateTime _parseDateTime(dynamic dateStr) {
    if (dateStr == null) return DateTime.now();
    try {
      final dateString = dateStr.toString();
      debugPrint('Parsing date: $dateString');
      
      // Handle GMT format: "Mon, 09 Jun 2025 05:59:53 GMT"
      if (dateString.contains('GMT')) {
        // Remove GMT and day of week
        final cleanDate = dateString
            .replaceAll(' GMT', '')
            .replaceAll(RegExp(r'^\w+, '), '');
        debugPrint('Cleaned date: $cleanDate');
        
        // Parse manually: "09 Jun 2025 05:59:53"
        final parts = cleanDate.split(' ');
        if (parts.length >= 4) {
          final day = int.parse(parts[0]);
          final month = _monthNameToNumber(parts[1]);
          final year = int.parse(parts[2]);
          final timeParts = parts[3].split(':');
          final hour = int.parse(timeParts[0]);
          final minute = int.parse(timeParts[1]);
          final second = int.parse(timeParts[2]);
          
          return DateTime(year, month, day, hour, minute, second);
        }
      }
      
      // Try standard ISO format
      return DateTime.parse(dateString);
    } catch (e) {
      debugPrint('Error parsing date: $dateStr - $e');
      return DateTime.now();
    }
  }
  
  static int _monthNameToNumber(String monthName) {
    switch (monthName.toLowerCase()) {
      case 'jan': return 1;
      case 'feb': return 2;
      case 'mar': return 3;
      case 'apr': return 4;
      case 'may': return 5;
      case 'jun': return 6;
      case 'jul': return 7;
      case 'aug': return 8;
      case 'sep': return 9;
      case 'oct': return 10;
      case 'nov': return 11;
      case 'dec': return 12;
      default: return 1;
    }
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
      createdAt: PromptModel._parseDateTime(json['created_at']),
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
    debugPrint('PromptHistoryModel.fromJson: $json');
    return PromptHistoryModel(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      promptName: json['prompt_name'] ?? '',
      content: json['content'] ?? '',
      changedBy: json['changed_by'],
      changeDescription: json['change_description'],
      createdAt: json['created_at'] != null ? PromptModel._parseDateTime(json['created_at']) : DateTime.now(),
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
    debugPrint('PromptManagementResponse.fromJson: $json');
    
    List<PromptModel>? prompts;
    List<PromptCategoryModel>? categories;
    List<PromptHistoryModel>? history;
    String? message;
    
    try {
      if (json['response'] is List) {
        final responseList = json['response'] as List;
        if (responseList.isNotEmpty) {
          final firstItem = responseList[0];
          
          // Check if it's history (has 'change_description' or 'changed_by' field)
          if (firstItem['change_description'] != null || firstItem['changed_by'] != null) {
            history = responseList.map((item) => PromptHistoryModel.fromJson(item)).toList();
            debugPrint('Parsed ${history.length} history items');
          }
          // Check if it's categories (has 'description' field but not 'content')
          else if (firstItem['description'] != null && firstItem['content'] == null) {
            categories = responseList.map((item) => PromptCategoryModel.fromJson(item)).toList();
            debugPrint('Parsed ${categories.length} categories');
          }
          // Check if it's prompts (has 'content' field and other prompt-specific fields)
          else if (firstItem['content'] != null && (firstItem['name'] != null || firstItem['category_name'] != null)) {
            prompts = responseList.map((item) => PromptModel.fromJson(item)).toList();
            debugPrint('Parsed ${prompts.length} prompts');
          }
        }
      } else if (json['response'] is Map<String, dynamic>) {
        final responseMap = json['response'] as Map<String, dynamic>;
        if (responseMap['message'] != null) {
          message = responseMap['message'];
        }
      }
    } catch (e) {
      debugPrint('Error parsing response: $e');
    }
    
    final statusCode = json['statuscode'] ?? json['statusCode'] ?? 0;
    
    return PromptManagementResponse(
      prompts: prompts,
      categories: categories,
      history: history,
      message: message,
      statusCode: statusCode,
      success: statusCode >= 200 && statusCode < 300,
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