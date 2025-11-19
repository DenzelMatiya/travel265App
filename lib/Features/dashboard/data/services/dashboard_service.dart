// lib/features/dashboard/data/services/dashboard_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travel265/core/services/auth_service.dart';
import 'package:travel265/features/dashboard/domain/models/host_stats_model.dart';
import 'package:travel265/features/dashboard/domain/models/upcoming_booking_model.dart';
import 'package:travel265/core/utils/logger.dart'; // ✅ Use centralized logger

/// Handles all dashboard-specific data operations for hosts.
class DashboardService {
  DashboardService._internal();
  static final DashboardService _instance = DashboardService._internal();
  factory DashboardService() => _instance;
  static DashboardService get instance => _instance;

  final SupabaseClient _client = Supabase.instance.client;

  /// Fetches host statistics from the `get_host_stats` RPC.
  /// **REQUIRED**: Run the SQL below in Supabase SQL Editor
  Future<HostStats> getHostStats() async {
    try {
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      logger.i('📊 Fetching host stats for user: $userId');

      final response = await _client.rpc(
        'get_host_stats',
        params: {'host_id': userId},
      );

      // Handle both List and Map responses
      final data = response is List ? (response.firstOrNull ?? {}) : response;

      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response format from RPC');
      }

      return HostStats.fromJson(data);
    } catch (e, stackTrace) {
      logger.e('❌ Failed to fetch host stats', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Fetches the next 5 upcoming bookings for the authenticated host.
  Future<List<UpcomingBooking>> getUpcomingBookings() async {
    try {
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      logger.i('📅 Fetching upcoming bookings for host: $userId');

      final response = await _client
          .from('bookings')
          .select('''
            id,
            properties!inner(title, address),
            guests!inner(full_name),
            check_in,
            check_out,
            total_price,
            status
          ''')
          .eq('properties.host_id', userId)
          .gte('check_in', DateTime.now().toIso8601String())
          .order('check_in', ascending: true)
          .limit(5);

      if (response is! List) {
        logger.w('⚠️ Unexpected response type for bookings: ${response.runtimeType}');
        return [];
      }

      return response
          .map((json) => UpcomingBooking.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      logger.e('❌ Failed to fetch upcoming bookings', error: e, stackTrace: stackTrace);
      return []; // Graceful degradation
    }
  }

  /// Fetches today's bookings (check-in or check-out).
  Future<List<UpcomingBooking>> getTodaysBookings() async {
    try {
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final today = DateTime.now();
      final todayStr = today.toIso8601String().split('T').first;

      logger.i('📅 Fetching today\'s bookings for host: $userId');

      final response = await _client
          .from('bookings')
          .select('''
            id,
            properties!inner(title, address),
            guests!inner(full_name),
            check_in,
            check_out,
            total_price,
            status
          ''')
          .eq('properties.host_id', userId)
          .or('check_in.eq.$todayStr,check_out.eq.$todayStr')
          .order('check_in', ascending: true);

      if (response is! List) {
        logger.w('⚠️ Unexpected response type for today\'s bookings: ${response.runtimeType}');
        return [];
      }

      return response
          .map((json) => UpcomingBooking.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      logger.e('❌ Failed to fetch today\'s bookings', error: e, stackTrace: stackTrace);
      return [];
    }
  }
}