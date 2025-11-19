// lib/models/host_models.dart

class HostStats {
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
}

class UpcomingBooking {
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
      propertyTitle: json['property_title'] ?? 'Unknown Property',
      checkIn: DateTime.parse(json['check_in']),
      checkOut: DateTime.parse(json['check_out']),
      guestName: json['guest_name'] ?? 'Guest',
      totalPrice: (json['total_price'] ?? 0).toDouble(),
    );
  }
}