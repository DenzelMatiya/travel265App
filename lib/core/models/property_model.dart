import 'package:equatable/equatable.dart';

enum PropertyType { apartment, house, villa, cottage, hotel, lodge }
enum PropertyStatus { active, inactive, pending }

class PropertyModel extends Equatable {
  final String id;
  final String hostId;
  final String title;
  final String description;
  final PropertyType type;
  final String city;
  final String region;
  final String address;
  final double latitude;
  final double longitude;
  final double pricePerNight;
  final String currency;
  final int maxGuests;
  final int bedrooms;
  final int bathrooms;
  final List<String> amenities;
  final List<String> imageUrls;
  final double rating;
  final int reviewCount;
  final PropertyStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Extra UI fields
  final bool isFavorite;
  final String? locationDescription;
  final String? nearestLandmark;
  final double? distanceFromLandmark;
  final List<Map<String, dynamic>> reviews;
  final List<String>? houseRules;

  final Map<String, dynamic>? host;

  const PropertyModel({
    required this.id,
    required this.hostId,
    required this.title,
    required this.description,
    required this.type,
    required this.city,
    required this.region,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.pricePerNight,
    this.currency = 'MWK',
    required this.maxGuests,
    required this.bedrooms,
    required this.bathrooms,
    this.amenities = const [],
    this.imageUrls = const [],
    this.rating = 0.0,
    this.reviewCount = 0,
    this.status = PropertyStatus.active,
    required this.createdAt,
    this.updatedAt,
    this.isFavorite = false,
    this.locationDescription,
    this.nearestLandmark,
    this.distanceFromLandmark,
    this.reviews = const [],
    this.houseRules,
    this.host,
  });

  factory PropertyModel.fromMap(Map<String, dynamic> map) {
    // Safe typed cast helper
    T? cast<T>(dynamic value) => value is T ? value : null;

    // Safe list-of-string converter
    List<String> safeStringList(dynamic value) {
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
      return [];
    }

    return PropertyModel(
      id: map['id']?.toString() ?? '',
      hostId: map['host_id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      type: PropertyType.values.firstWhere(
            (e) => e.name == map['type'],
        orElse: () => PropertyType.house,
      ),
      city: map['city']?.toString() ?? '',
      region: map['region']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      pricePerNight: (map['price_per_night'] as num?)?.toDouble() ?? 0.0,
      currency: map['currency']?.toString() ?? 'MWK',
      maxGuests: cast<int>(map['max_guests']) ?? 0,
      bedrooms: cast<int>(map['bedrooms']) ?? 0,
      bathrooms: cast<int>(map['bathrooms']) ?? 0,
      amenities: safeStringList(map['amenities']),
      imageUrls: safeStringList(map['image_urls']),
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: cast<int>(map['review_count']) ?? 0,
      status: PropertyStatus.values.firstWhere(
            (e) => e.name == map['status'],
        orElse: () => PropertyStatus.active,
      ),
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
      map['updated_at'] != null ? DateTime.tryParse(map['updated_at'].toString()) : null,

      // Extra fields
      isFavorite: map['is_favorite'] == true,
      locationDescription: cast<String>(map['location_description']),
      nearestLandmark: cast<String>(map['nearest_landmark']),
      distanceFromLandmark:
      (map['distance_from_landmark'] as num?)?.toDouble(),
      houseRules: map['house_rules'] is List
          ? safeStringList(map['house_rules'])
          : null,
      reviews: map['reviews'] is List
          ? List<Map<String, dynamic>>.from(
        (map['reviews'] as List).whereType<Map<String, dynamic>>(),
      )
          : [],
      host: map['host'] is Map
          ? Map<String, dynamic>.from(map['host'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'host_id': hostId,
      'title': title,
      'description': description,
      'type': type.name,
      'city': city,
      'region': region,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'price_per_night': pricePerNight,
      'currency': currency,
      'max_guests': maxGuests,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'amenities': amenities,
      'image_urls': imageUrls,
      'rating': rating,
      'review_count': reviewCount,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),

      // Extra
      'is_favorite': isFavorite,
      'location_description': locationDescription,
      'nearest_landmark': nearestLandmark,
      'distance_from_landmark': distanceFromLandmark,
      'house_rules': houseRules,
      'reviews': reviews,
      'host': host,
    };
  }

  @override
  List<Object?> get props => [id];

  String get displayPrice => "$currency ${pricePerNight.toStringAsFixed(0)}";
  String get locationLabel => "$city, $region";
}
