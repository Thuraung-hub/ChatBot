import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

class ApiService {
  // ============ CONFIGURATION ============
  // Change this to your actual backend URL
  static const String baseUrl = 'https://your-api.com/api';
  
  // Add your API key/token if needed
  static const String apiKey = 'your-api-key-here';

  static final ApiService _instance = ApiService._internal();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal();

  // ============ GET REQUEST ============
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final url = Uri.parse('$baseUrl/$endpoint');
      debugPrint('🔵 GET: $url');
      
      final response = await http.get(
        url,
        headers: _getHeaders(),
      ).timeout(const Duration(seconds: 30));

      debugPrint('📦 Response: ${response.statusCode}');
      return _handleResponse(response);
    } catch (e) {
      debugPrint('❌ Error: $e');
      throw _handleError(e);
    }
  }

  // ============ POST REQUEST ============
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/$endpoint');
      debugPrint('🔵 POST: $url');
      debugPrint('📤 Body: $body');
      
      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      debugPrint('📦 Response: ${response.statusCode}');
      return _handleResponse(response);
    } catch (e) {
      debugPrint('❌ Error: $e');
      throw _handleError(e);
    }
  }

  // ============ PUT REQUEST ============
  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/$endpoint');
      debugPrint('🔵 PUT: $url');
      debugPrint('📤 Body: $body');
      
      final response = await http.put(
        url,
        headers: _getHeaders(),
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      debugPrint('📦 Response: ${response.statusCode}');
      return _handleResponse(response);
    } catch (e) {
      debugPrint('❌ Error: $e');
      throw _handleError(e);
    }
  }

  // ============ DELETE REQUEST ============
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final url = Uri.parse('$baseUrl/$endpoint');
      debugPrint('🔵 DELETE: $url');
      
      final response = await http.delete(
        url,
        headers: _getHeaders(),
      ).timeout(const Duration(seconds: 30));

      debugPrint('📦 Response: ${response.statusCode}');
      return _handleResponse(response);
    } catch (e) {
      debugPrint('❌ Error: $e');
      throw _handleError(e);
    }
  }

  // ============ HEADERS ============
  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };
  }

  // ============ HANDLE RESPONSE ============
  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = response.body.isEmpty ? '{}' : response.body;
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(body);
    } else if (response.statusCode == 401) {
      throw 'Unauthorized - Login required';
    } else if (response.statusCode == 404) {
      throw 'Resource not found';
    } else if (response.statusCode == 500) {
      throw 'Server error - try again later';
    } else {
      throw 'Error: ${response.statusCode} - $body';
    }
  }

  // ============ ERROR HANDLING ============
  String _handleError(dynamic error) {
    if (error.toString().contains('TimeoutException')) {
      return 'Request timeout - check your connection';
    }
    if (error.toString().contains('SocketException')) {
      return 'Network error - check internet connection';
    }
    return error.toString();
  }
}
