// lib/core/services/services.dart - Centralized Service Exports

library services;

/// Barrel file for service classes.
///
/// Import this single file to access all services:
/// ```dart
/// import 'package:travel265/core/services/services.dart';
/// ```

// 🔐 Authentication & User Management
export 'auth_service.dart';

// 🌐 External API Service (Stripe, Maps, etc.)
export 'api_service.dart';

// 🏠 Property Management
//export 'property_service.dart';

// 📤 File Storage (TODO: Implement file upload/download)
// export 'storage_service.dart';

// 📅 Booking & Reservations (TODO: Create)
// export 'booking_service.dart';

// 💳 Payments & Payouts (TODO: Create)
// export 'payment_service.dart';

// 🗺️ Location & Maps (TODO: Create)
// export 'location_service.dart';

// 🔔 Push Notifications (TODO: Create)
// export 'notification_service.dart';