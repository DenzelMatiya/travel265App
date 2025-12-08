

class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String? phone;
  final String? photoUrl;
  final String role;
  final DateTime joinedDate;
  final UserStats stats;
  final List<String> linkedAccounts;
  final NotificationSettings notificationSettings;
  final PaymentSettings paymentSettings;
  final bool? phoneVerified;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    this.phone,
    this.photoUrl,
    required this.role,
    required this.joinedDate,
    required this.stats,
    this.linkedAccounts = const [],
    required this.notificationSettings,
    required this.paymentSettings,
    this.phoneVerified,
  });

  UserProfile copyWith({
    String? uid,
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
    String? role,
    DateTime? joinedDate,
    UserStats? stats,
    List<String>? linkedAccounts,
    NotificationSettings? notificationSettings,
    PaymentSettings? paymentSettings,
    bool? phoneVerified,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      joinedDate: joinedDate ?? this.joinedDate,
      stats: stats ?? this.stats,
      linkedAccounts: linkedAccounts ?? this.linkedAccounts,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      paymentSettings: paymentSettings ?? this.paymentSettings,
      phoneVerified: phoneVerified ?? this.phoneVerified,
    );
  }
}

class UserStats {
  final int totalBookings;
  final int completedBookings;
  final double averageRating;
  final int reviewsCount;
  final int hostListings;

  UserStats({
    this.totalBookings = 0,
    this.completedBookings = 0,
    this.averageRating = 0.0,
    this.reviewsCount = 0,
    this.hostListings = 0,
  });
}

class NotificationSettings {
  final bool bookingNotifications;
  final bool messageNotifications;
  final bool promotionNotifications;
  final bool reviewNotifications;
  final bool calendarSyncNotifications;

  NotificationSettings({
    this.bookingNotifications = true,
    this.messageNotifications = true,
    this.promotionNotifications = true,
    this.reviewNotifications = true,
    this.calendarSyncNotifications = true,
  });
}

class PaymentSettings {
  final String defaultPaymentMethod;
  final bool savePaymentInfo;
  final String currency;

  PaymentSettings({
    this.defaultPaymentMethod = 'paychangu',
    this.savePaymentInfo = true,
    this.currency = 'MWK',
  });
}