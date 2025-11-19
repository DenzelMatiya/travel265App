import 'package:equatable/equatable.dart';

class HostStats extends Equatable {
  final int activeListings;
  final double monthlyRevenue;
  final double occupancyRate;
  final int upcomingBookings;

  const HostStats({
    required this.activeListings,
    required this.monthlyRevenue,
    required this.occupancyRate,
    required this.upcomingBookings,
  });

  factory HostStats.fromJson(Map<String, dynamic> json) {
    return HostStats(
      activeListings: json['active_listings'] ?? 0,
      monthlyRevenue: (json['monthly_revenue'] ?? 0).toDouble(),
      occupancyRate: (json['occupancy_rate'] ?? 0).toDouble(),
      upcomingBookings: json['upcoming_bookings'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [
    activeListings,
    monthlyRevenue,
    occupancyRate,
    upcomingBookings,
  ];
}