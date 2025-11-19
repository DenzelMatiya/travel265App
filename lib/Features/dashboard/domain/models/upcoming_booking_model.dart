import 'package:equatable/equatable.dart';

class UpcomingBooking extends Equatable {
  final String id;
  final String propertyTitle;
  final DateTime checkIn;
  final DateTime checkOut;
  final String guestName;
  final double totalPrice;

  const UpcomingBooking({
    required this.id,
    required this.propertyTitle,
    required this.checkIn,
    required this.checkOut,
    required this.guestName,
    required this.totalPrice,
  });

  factory UpcomingBooking.fromJson(Map<String, dynamic> json) {
    return UpcomingBooking(
      id: json['id'] ?? '',
      propertyTitle: json['properties']['title'] ?? 'Unknown Property',
      checkIn: DateTime.parse(json['check_in']),
      checkOut: DateTime.parse(json['check_out']),
      guestName: json['guests']['full_name'] ?? 'Guest',
      totalPrice: (json['total_price'] ?? 0).toDouble(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    propertyTitle,
    checkIn,
    checkOut,
    guestName,
    totalPrice,
  ];
}