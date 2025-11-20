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
  final String region; // Malawi region (Northern, Central, Southern)
  final String address;
  final double latitude;
  final double longitude;
  final double pricePerNight;
  final String currency; // MWK, USD
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
  });

  // Factory for Supabase data
  factory PropertyModel.fromMap(Map<String, dynamic> map) {
    return PropertyModel(
      id: map['id'] as String,
      hostId: map['host_id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      type: PropertyType.values.firstWhere(
            (e) => e.name == map['type'],
        orElse: () => PropertyType.house,
      ),
      city: map['city'] as String,
      region: map['region'] as String,
      address: map['address'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      pricePerNight: (map['price_per_night'] as num).toDouble(),
      currency: map['currency'] as String? ?? 'MWK',
      maxGuests: map['max_guests'] as int,
      bedrooms: map['bedrooms'] as int,
      bathrooms: map['bathrooms'] as int,
      amenities: List<String>.from(map['amenities'] ?? []),
      imageUrls: List<String>.from(map['image_urls'] ?? []),
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: map['review_count'] as int? ?? 0,
      status: PropertyStatus.values.firstWhere(
            (e) => e.name == map['status'],
        orElse: () => PropertyStatus.active,
      ),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
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
    };
  }

  @override
  List<Object?> get props => [id];

  // Computed properties
  String get displayPrice => '$currency ${pricePerNight.toStringAsFixed(0)}';

  String get locationLabel => '$city, $region';
}