import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../utils/app_state.dart';
import 'package:gka/utils/common_constants.dart' as constants;
import '../model/prompt_management_models.dart';

abstract class PromptManagementRepository {
  Future<PromptManagementResponse> getAllPrompts();
  Future<PromptManagementResponse> getPrompt(String promptName);
  Future<PromptManagementResponse> createPrompt(CreatePromptRequest request);
  Future<PromptManagementResponse> updatePrompt(String promptName, UpdatePromptRequest request);
  Future<PromptManagementResponse> deletePrompt(String promptName);
  Future<PromptManagementResponse> getPromptHistory(String promptName);
  Future<PromptManagementResponse> refreshCache();
  Future<PromptManagementResponse> getCategories();
  Future<PromptManagementResponse> createCategory(String name, String? description);
  Future<PromptManagementResponse> migratePrompts();
  Future<PromptManagementResponse> healthCheck();
}

class PromptManagementRepositoryImpl extends PromptManagementRepository {
  
  // Use the existing base URL from constants
  
  Map<String, String> get _headers => {
    constants.headerContentType: constants.headerJson,
    'Authorization': 'Bearer ${AppState.instance.token}', // Add if you use auth tokens
  };

  @override
  Future<PromptManagementResponse> getAllPrompts() async {
    final url = '${constants.baseUrl}api/v1/prompts';
    debugPrint('PromptRepo: Fetching all prompts from: $url');
    debugPrint('PromptRepo: Headers: $_headers');
    
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      );
      
      debugPrint('PromptRepo: getAllPrompts response - Status: ${response.statusCode}');
      debugPrint('PromptRepo: getAllPrompts response - Body: ${response.body}');
      
      final result = PromptManagementResponse.fromJson(jsonDecode(response.body));
      debugPrint('PromptRepo: getAllPrompts parsed - Success: ${result.success}, Prompts count: ${result.prompts?.length ?? 0}');
      
      return result;
    } catch (e) {
      debugPrint('PromptRepo: getAllPrompts error: $e');
      return PromptManagementResponse(
        statusCode: 500,
        success: false,
        message: 'Failed to fetch prompts: ${e.toString()}',
      );
    }
  }

  @override
  Future<PromptManagementResponse> getPrompt(String promptName) async {
    try {
      final response = await http.get(
        Uri.parse('${constants.baseUrl}api/v1/prompts/$promptName'),
        headers: _headers,
      );
      
      return PromptManagementResponse.fromJson(jsonDecode(response.body));
    } catch (e) {
      return PromptManagementResponse(
        statusCode: 500,
        success: false,
        message: 'Failed to fetch prompt: ${e.toString()}',
      );
    }
  }

  @override
  Future<PromptManagementResponse> createPrompt(CreatePromptRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('${constants.baseUrl}api/v1/prompts'),
        headers: _headers,
        body: jsonEncode(request.toJson()),
      );
      
      return PromptManagementResponse.fromJson(jsonDecode(response.body));
    } catch (e) {
      return PromptManagementResponse(
        statusCode: 500,
        success: false,
        message: 'Failed to create prompt: ${e.toString()}',
      );
    }
  }

  @override
  Future<PromptManagementResponse> updatePrompt(String promptName, UpdatePromptRequest request) async {
    try {
      final response = await http.put(
        Uri.parse('${constants.baseUrl}api/v1/prompts/$promptName'),
        headers: _headers,
        body: jsonEncode(request.toJson()),
      );
      
      return PromptManagementResponse.fromJson(jsonDecode(response.body));
    } catch (e) {
      return PromptManagementResponse(
        statusCode: 500,
        success: false,
        message: 'Failed to update prompt: ${e.toString()}',
      );
    }
  }

  @override
  Future<PromptManagementResponse> deletePrompt(String promptName) async {
    try {
      final response = await http.delete(
        Uri.parse('${constants.baseUrl}api/v1/prompts/$promptName'),
        headers: _headers,
      );
      
      return PromptManagementResponse.fromJson(jsonDecode(response.body));
    } catch (e) {
      return PromptManagementResponse(
        statusCode: 500,
        success: false,
        message: 'Failed to delete prompt: ${e.toString()}',
      );
    }
  }

  @override
  Future<PromptManagementResponse> getPromptHistory(String promptName) async {
    try {
      final response = await http.get(
        Uri.parse('${constants.baseUrl}api/v1/prompts/$promptName/history'),
        headers: _headers,
      );
      
      return PromptManagementResponse.fromJson(jsonDecode(response.body));
    } catch (e) {
      return PromptManagementResponse(
        statusCode: 500,
        success: false,
        message: 'Failed to fetch prompt history: ${e.toString()}',
      );
    }
  }

  @override
  Future<PromptManagementResponse> refreshCache() async {
    try {
      final response = await http.post(
        Uri.parse('${constants.baseUrl}api/v1/prompts/refresh-cache'),
        headers: _headers,
      );
      
      return PromptManagementResponse.fromJson(jsonDecode(response.body));
    } catch (e) {
      return PromptManagementResponse(
        statusCode: 500,
        success: false,
        message: 'Failed to refresh cache: ${e.toString()}',
      );
    }
  }

  @override
  Future<PromptManagementResponse> getCategories() async {
    final url = '${constants.baseUrl}api/v1/prompts/categories';
    debugPrint('PromptRepo: Fetching categories from: $url');
    
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      );
      
      debugPrint('PromptRepo: getCategories response - Status: ${response.statusCode}');
      debugPrint('PromptRepo: getCategories response - Body: ${response.body}');
      
      final result = PromptManagementResponse.fromJson(jsonDecode(response.body));
      debugPrint('PromptRepo: getCategories parsed - Success: ${result.success}, Categories count: ${result.categories?.length ?? 0}');
      
      return result;
    } catch (e) {
      debugPrint('PromptRepo: getCategories error: $e');
      return PromptManagementResponse(
        statusCode: 500,
        success: false,
        message: 'Failed to fetch categories: ${e.toString()}',
      );
    }
  }

  @override
  Future<PromptManagementResponse> createCategory(String name, String? description) async {
    try {
      final response = await http.post(
        Uri.parse('${constants.baseUrl}api/v1/prompts/categories'),
        headers: _headers,
        body: jsonEncode({
          'name': name,
          'description': description,
        }),
      );
      
      return PromptManagementResponse.fromJson(jsonDecode(response.body));
    } catch (e) {
      return PromptManagementResponse(
        statusCode: 500,
        success: false,
        message: 'Failed to create category: ${e.toString()}',
      );
    }
  }

  @override
  Future<PromptManagementResponse> migratePrompts() async {
    try {
      final response = await http.post(
        Uri.parse('${constants.baseUrl}api/v1/prompts/migrate'),
        headers: _headers,
      );
      
      return PromptManagementResponse.fromJson(jsonDecode(response.body));
    } catch (e) {
      return PromptManagementResponse(
        statusCode: 500,
        success: false,
        message: 'Failed to migrate prompts: ${e.toString()}',
      );
    }
  }

  @override
  Future<PromptManagementResponse> healthCheck() async {
    try {
      final response = await http.get(
        Uri.parse('${constants.baseUrl}api/v1/prompts/health'),
        headers: _headers,
      );
      
      return PromptManagementResponse.fromJson(jsonDecode(response.body));
    } catch (e) {
      return PromptManagementResponse(
        statusCode: 500,
        success: false,
        message: 'Health check failed: ${e.toString()}',
      );
    }
  }
}