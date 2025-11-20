import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travel265/core/models/booking_model.dart';
import 'package:travel265/core/utils/logger.dart';

/// Handles all booking operations
class BookingRepository {
  final SupabaseClient _client;

  BookingRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  /// Create new booking
  Future<BookingModel> createBooking(BookingModel booking) async {
    try {
      // Check availability first
      await _checkAvailability(booking.propertyId, booking.checkIn, booking.checkOut);

      final response = await _client
          .from('bookings')
          .insert(booking.toMap())
          .select()
          .single();

      logger.i('✅ Booking created: ${booking.id}');
      return BookingModel.fromMap(response);
    } catch (e, stackTrace) {
      logger.e('Booking creation failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Check if property is available for dates
  Future<void> _checkAvailability(
      String propertyId,
      DateTime checkIn,
      DateTime checkOut,
      ) async {
    final overlappingBookings = await _client
        .from('bookings')
        .select()
        .eq('property_id', propertyId)
        .neq('status', 'cancelled')
        .or('check_in.lte.${checkOut.toIso8601String()},check_out.gte.${checkIn.toIso8601String()}');

    if (overlappingBookings.isNotEmpty) {
      throw Exception('Property is not available for selected dates');
    }
  }

  /// Get user's bookings
  Future<List<BookingModel>> getUserBookings(String userId) async {
    try {
      final response = await _client
          .from('bookings')
          .select('*, properties(*)')
          .eq('guest_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((e) => BookingModel.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      logger.e('Bookings fetch failed', error: e, stackTrace: stackTrace);
      throw Exception('Failed to fetch bookings: $e');
    }
  }

  /// Update booking status
  Future<BookingModel> updateBookingStatus(String id, String status) async {
    try {
      final response = await _client
          .from('bookings')
          .update({'status': status})
          .eq('id', id)
          .select()
          .single();

      return BookingModel.fromMap(response);
    } catch (e, stackTrace) {
      logger.e('Booking update failed', error: e, stackTrace: stackTrace);
      throw Exception('Failed to update booking: $e');
    }
  }
}