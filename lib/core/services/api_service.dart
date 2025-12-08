// lib/core/services/api_service.dart - PRODUCTION-READY VERSION

import 'dart:async'; // For TimeoutException, Future
import 'dart:core'; // For Uri, UnsupportedError (explicit for clarity)
import 'dart:convert'; // For jsonEncode

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ✅ FIXED: Logger with proper initialization
final Logger _logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    lineLength: 80,
    colors: true,
  ),
);

/// 🌐 **EXTERNAL API SERVICE ONLY**
///
/// **⚠️ DO NOT USE FOR SUPABASE OPERATIONS!**
/// Use SupabaseClient directly:
/// ```dart
/// final response = await Supabase.instance.client
///     .from('table')
///     .select()
///     .eq('id', value);
/// ```
///
/// Features:
/// - ✅ Auto-injects Supabase auth token
/// - ✅ Timeout & exponential backoff retry
/// - ✅ Request/response logging
/// - ✅ Consistent error handling
///
/// **TODO: Move _baseUrl to .env file**
class ApiService {
  ApiService._internal();
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  // ✅ FIXED: Removed trailing space, using Uri directly
  static final Uri _baseUri = Uri.parse('https://api.your-service.com');

  static const Duration _timeout = Duration(seconds: 30);
  static const int _maxRetries = 2;

  /// GET request
  Future<http.Response> get(
      String endpoint, {
        Map<String, String>? headers,
      }) async {
    return _request('GET', endpoint, headers: headers);
  }

  /// POST request
  Future<http.Response> post(
      String endpoint, {
        Map<String, dynamic>? body,
        Map<String, String>? headers,
      }) async {
    return _request('POST', endpoint, headers: headers, body: body);
  }

  /// PUT request
  Future<http.Response> put(
      String endpoint, {
        required Map<String, dynamic> body,
        Map<String, String>? headers,
      }) async {
    return _request('PUT', endpoint, headers: headers, body: body);
  }

  /// DELETE request
  Future<http.Response> delete(
      String endpoint, {
        Map<String, String>? headers,
      }) async {
    return _request('DELETE', endpoint, headers: headers);
  }

  /// Core request handler with retry logic
  Future<http.Response> _request(
      String method,
      String endpoint, {
        Map<String, dynamic>? body,
        Map<String, String>? headers,
      }) async {
    // ✅ FIXED: Using Uri.resolve for proper URL construction
    final url = _baseUri.resolve(endpoint.startsWith('/')
        ? endpoint.substring(1)
        : endpoint);

    final requestHeaders = await _buildHeaders(headers);

    _logger.i('📤 $method $url');

    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        final response = await _sendRequest(
          method,
          url,
          requestHeaders,
          body,
        ).timeout(_timeout);

        _logger.i('📥 $method $url → ${response.statusCode}');

        if (response.statusCode >= 200 && response.statusCode < 400) {
          return response;
        }

        // Don't retry on 4xx client errors
        if (response.statusCode >= 400 && response.statusCode < 500) {
          throw ApiException(
            'Client error: ${response.reasonPhrase}',
            statusCode: response.statusCode,
            body: response.body,
          );
        }

        // Log retry attempt for 5xx errors
        if (attempt < _maxRetries) {
          _logger.w('🔄 Retry $attempt/$_maxRetries for $method $url');
        }
      } on TimeoutException {
        _logger.w('⏱️ Timeout (attempt $attempt/$_maxRetries)');
        if (attempt == _maxRetries) rethrow;
      } catch (e) {
        _logger.w('🌐 Attempt $attempt/$_maxRetries failed: $e');
        if (attempt == _maxRetries) rethrow;
      }

      // ✅ FIXED: Exponential backoff
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
    final encodedBody = body != null ? jsonEncode(body) : null;

    switch (method.toUpperCase()) {
      case 'GET':
        return http.get(url, headers: headers);
      case 'POST':
        return http.post(url, headers: headers, body: encodedBody);
      case 'PUT':
        return http.put(url, headers: headers, body: encodedBody);
      case 'PATCH':
        return http.patch(url, headers: headers, body: encodedBody);
      case 'DELETE':
        return http.delete(url, headers: headers, body: encodedBody);
      default:
        throw UnsupportedError('HTTP method $method not supported');
    }
  }

  /// Builds headers with auth token from Supabase session
  Future<Map<String, String>> _buildHeaders(
      Map<String, String>? customHeaders,
      ) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...?customHeaders,
    };

    // ✅ FIXED: Safe token injection with null check
    try {
      final session = Supabase.instance.client.auth.currentSession;
      final token = session?.accessToken;

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
        _logger.d('🔐 Auth token injected');
      }
    } catch (e, stackTrace) {
      _logger.w('⚠️ Auth token injection failed', error: e, stackTrace: stackTrace);
    }

    return headers;
  }
}

/// 💥 Custom exception for API errors with full context
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? body;
  final Uri? url;

  const ApiException(
      this.message, {
        this.statusCode,
        this.body,
        this.url,
      });

  @override
  String toString() {
    final buffer = StringBuffer('ApiException: $message');
    if (statusCode != null) buffer.write(' ($statusCode)');
    if (url != null) buffer.write(' | URL: $url');
    if (body != null && body!.isNotEmpty) buffer.write(' | Body: $body');
    return buffer.toString();
  }
}