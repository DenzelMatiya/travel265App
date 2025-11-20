// lib/core/services/api_service.dart

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// TODO: Move to lib/core/utils/logger.dart
final _logger = Logger(printer: PrettyPrinter(methodCount: 0));

/// ⚠️ **FOR EXTERNAL APIs ONLY** (Stripe, Google Maps, etc.)
/// 
/// **DO NOT USE THIS FOR SUPABASE OPERATIONS!**
/// Use SupabaseClient directly instead:
/// ```dart
/// final client = Supabase.instance.client;
/// final data = await client.from('bookings').select();
/// ```
/// 
/// features:
/// - Auto-injects Supabase auth token
/// - Timeout & retry logic
/// - Request/response logging
/// - Consistent error handling
/// 
/// **TODO: Add `http: ^1.2.0` to pubspec.yaml**
class ApiService {
  ApiService._internal();
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  // TODO: Move to .env file: https://pub.dev/packages/flutter_dotenv
  static const String _baseUrl = 'https://api.your-service.com'; // ✅ FIXED: Removed trailing space

  static const Duration _timeout = Duration(seconds: 30);
  static const int _maxRetries = 2;

  /// GET request
  Future<http.Response> get(String endpoint, {Map<String, String>? headers}) {
    return _request('GET', endpoint, headers: headers);
  }

  /// POST request
  Future<http.Response> post(
      String endpoint, {
        Map<String, dynamic>? body,
        Map<String, String>? headers,
      }) {
    return _request('POST', endpoint, headers: headers, body: body);
  }

  /// PUT request
  Future<http.Response> put(
      String endpoint, {
        required Map<String, dynamic> body,
        Map<String, String>? headers,
      }) {
    return _request('PUT', endpoint, headers: headers, body: body);
  }

  /// DELETE request
  Future<http.Response> delete(String endpoint, {Map<String, String>? headers}) {
    return _request('DELETE', endpoint, headers: headers);
  }

  /// Core request handler with retry logic
  Future<http.Response> _request(
      String method,
      String endpoint, {
        Map<String, dynamic>? body,
        Map<String, String>? headers,
      }) async {
    final url = Uri.parse('$_baseUrl${endpoint.startsWith('/') ? '' : '/'}$endpoint');
    final requestHeaders = await _buildHeaders(headers);

    _logger.i('📤 $method $url');

    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        final response = await _sendRequest(method, url, requestHeaders, body)
            .timeout(_timeout);

        _logger.i('📥 $method $url → ${response.statusCode}');

        if (response.statusCode >= 200 && response.statusCode < 400) {
          return response;
        }

        // Don't retry on 4xx errors
        if (response.statusCode >= 400 && response.statusCode < 500) {
          break;
        }
      } on TimeoutException {
        _logger.w('⏱️ Timeout (attempt $attempt/$_maxRetries)');
        if (attempt == _maxRetries) rethrow;
      } catch (e) {
        _logger.w('🌐 Attempt $attempt/$_maxRetries failed: $e');
        if (attempt == _maxRetries) rethrow;
      }

      // Exponential backoff
      if (attempt < _maxRetries) {
        await Future.delayed(Duration(seconds: attempt * 2));
      }
    }

    throw ApiException('Request failed after $_maxRetries attempts');
  }

  Future<http.Response> _sendRequest(
      String method,
      Uri url,
      Map<String, String> headers,
      Map<String, dynamic>? body,
      ) async {
    switch (method) {
      case 'GET':
        return http.get(url, headers: headers);
      case 'POST':
        return http.post(url, headers: headers, body: jsonEncode(body));
      case 'PUT':
        return http.put(url, headers: headers, body: jsonEncode(body));
      case 'DELETE':
        return http.delete(url, headers: headers);
      default:
        throw UnsupportedError('HTTP method $method not supported');
    }
  }

  /// Builds headers with auth token from Supabase session
  Future<Map<String, String>> _buildHeaders(Map<String, String>? customHeaders) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      ...?customHeaders,
    };

    // Auto-inject Supabase auth token if available
    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session?.accessToken != null) {
        headers['Authorization'] = 'Bearer ${session!.accessToken}';
      }
    } catch (e) {
      _logger.w('auth token injection failed: $e');
    }

    return headers;
  }
}

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? body;

  const ApiException(this.message, {this.statusCode, this.body});

  @override
  String toString() => 'ApiException: $message${statusCode != null ? ' ($statusCode)' : ''}';
}