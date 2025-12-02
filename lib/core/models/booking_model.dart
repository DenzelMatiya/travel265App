//lib/core/models/booking_model.dart
import 'package:equatable/equatable.dart';
import 'package:travel265/core/models/property_model.dart';

enum BookingStatus { pending, confirmed, cancelled, completed }

class BookingModel extends Equatable {
  final String id;
  final String propertyId;
  final String guestId;
  final DateTime checkIn;
  final DateTime checkOut;
  final int numberOfGuests;
  final double totalPrice;
  final String currency;
  final BookingStatus status;
  final String? specialRequests;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final PropertyModel property; // Add this line

  const BookingModel({
    required this.id,
    required this.propertyId,
    required this.guestId,
    required this.checkIn,
    required this.checkOut,
    required this.numberOfGuests,
    required this.totalPrice,
    this.currency = 'MWK',
    this.status = BookingStatus.pending,
    this.specialRequests,
    required this.createdAt,
    this.updatedAt,
    required this.property, // Add this line
  });

  // Factory method to create from map
  factory BookingModel.fromMap(Map<String, dynamic> map, PropertyModel property) {
    return BookingModel(
      id: map['id'] as String,
      propertyId: map['property_id'] as String,
      guestId: map['guest_id'] as String,
      checkIn: DateTime.parse(map['check_in'] as String),
      checkOut: DateTime.parse(map['check_out'] as String),
      numberOfGuests: map['number_of_guests'] as int,
      totalPrice: (map['total_price'] as num).toDouble(),
      currency: map['currency'] as String? ?? 'MWK',
      status: BookingStatus.values.firstWhere(
            (e) => e.name == map['status'],
        orElse: () => BookingStatus.pending,
      ),
      specialRequests: map['special_requests'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at'] as String) : null,
      property: property, // Add this line
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'property_id': propertyId,
      'guest_id': guestId,
      'check_in': checkIn.toIso8601String(),
      'check_out': checkOut.toIso8601String(),
      'number_of_guests': numberOfGuests,
      'total_price': totalPrice,
      'currency': currency,
      'status': status.name,
      'special_requests': specialRequests,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id];
}