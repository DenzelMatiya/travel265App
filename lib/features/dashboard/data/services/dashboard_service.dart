//lib/features/dashboard/data/services/dashboard_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travel265/core/services/auth_service.dart';
import 'package:travel265/features/dashboard/domain/models/host_stats_model.dart';
import 'package:travel265/features/dashboard/domain/models/upcoming_booking_model.dart';
import 'package:travel265/core/utils/logger.dart';

class DashboardService {
  DashboardService._internal();
  static final DashboardService _instance = DashboardService._internal();
  factory DashboardService() => _instance;
  static DashboardService get instance => _instance;
  final SupabaseClient _client = Supabase.instance.client;

  Future<HostStats> getHostStats() async {
    final userId = AuthService.instance.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');
    logger.i('?? Fetching host stats for user: ');
    final response = await _client.rpc('get_host_stats', params: {'host_id': userId});
    final data = response is List ? (response.firstOrNull ?? {}) : response;
    return HostStats.fromJson(data as Map<String, dynamic>);
  }

  Future<List<UpcomingBooking>> getUpcomingBookings() async {
    final userId = AuthService.instance.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');
    logger.i('?? Fetching upcoming bookings for host: ');
    final response = await _client.from('bookings').select('''
        id, properties!inner(title), guests!inner(full_name), check_in, check_out, total_price, status
      ''').eq('properties.host_id', userId).gte('check_in', DateTime.now().toIso8601String()).order('check_in', ascending: true).limit(5);
    return (response as List).map((json) => UpcomingBooking.fromJson(json as Map<String, dynamic>)).toList();
  }
}
