//lib/core/repositories/property_repository.dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travel265/core/models/property_model.dart';
import 'package:travel265/core/utils/logger.dart';
import 'package:uuid/uuid.dart';

class PropertyRepository {
  final SupabaseClient _client;
  final _uuid = const Uuid();

  PropertyRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  /// **GET ALL PROPERTIES** - This method was missing
  Future<List<PropertyModel>> getProperties({
    String? city,
    PropertyType? type,
  }) async {
    try {
      var query = _client.from('listings').select('*');

      // Apply filters if provided
      if (city != null && city.isNotEmpty) {
        query = query.eq('city', city);
      }
      if (type != null) {
        query = query.eq('property_type', type.name);
      }

      final response = await query;

      // Convert each item to PropertyModel
      final properties = (response as List)
          .map((item) => _propertyFromMap(item))
          .toList();

      return properties;
    } catch (e, stackTrace) {
      logger.e('Get properties failed', error: e, stackTrace: stackTrace);
      throw Exception('Failed to load properties: $e');
    }
  }

  /// **GET PROPERTY BY ID** - This method was missing
  Future<PropertyModel> getPropertyById(String propertyId) async {
    try {
      final response = await _client
          .from('listings')
          .select('*')
          .eq('id', propertyId)
          .single();

      return _propertyFromMap(response);
    } catch (e, stackTrace) {
      logger.e('Get property by ID failed', error: e, stackTrace: stackTrace);
      throw Exception('Property not found: $e');
    }
  }

  /// **Helper method to convert map to PropertyModel**
  PropertyModel _propertyFromMap(Map<String, dynamic> map) {
    return PropertyModel(
      id: map['id'],
      hostId: map['host_id'],
      title: map['property_name'],
      description: map['description'],
      type: PropertyType.values.firstWhere(
            (e) => e.name == map['property_type'],
        orElse: () => PropertyType.apartment, // default fallback
      ),
      city: map['city'],
      region: map['region'],
      address: map['address'],
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      pricePerNight: (map['price_per_night'] as num).toDouble(),
      maxGuests: map['max_guests'],
      bedrooms: map['bedrooms'],
      bathrooms: map['bathrooms'],
      amenities: List<String>.from(map['amenities'] ?? []),
      imageUrls: List<String>.from(map['photos'] ?? []),
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  /// **NEW: Create property with image uploads**
  Future<PropertyModel> createProperty({
    required String hostId,
    required String title,
    required String description,
    required PropertyType type,
    required String city,
    required String region,
    required String address,
    required double latitude,
    required double longitude,
    required double pricePerNight,
    required int maxGuests,
    required int bedrooms,
    required int bathrooms,
    required List<String> amenities,
    required List<String> imageUrls,
    String? houseRules,
    bool providesBreakfast = false,
    bool isSelfCatering = false,
    bool isDraft = false,
  }) async {
    try {
      final propertyId = _uuid.v4();

      // Save to Supabase 'listings' table
      final response = await _client.from('listings').insert({
        'id': propertyId,
        'host_id': hostId,
        'property_name': title,
        'property_type': type.name,
        'description': description,
        'city': city,
        'region': region,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'price_per_night': pricePerNight,
        'max_guests': maxGuests,
        'bedrooms': bedrooms,
        'bathrooms': bathrooms,
        'amenities': amenities,
        'photos': imageUrls,
        'house_rules': houseRules,
        'provides_breakfast': providesBreakfast,
        'is_self_catering': isSelfCatering,
        'is_active': !isDraft,
        'is_draft': isDraft,
        'created_at': DateTime.now().toIso8601String(),
      }).select().single();

      return _propertyFromMap(response);
    } catch (e, stackTrace) {
      logger.e('Property creation failed', error: e, stackTrace: stackTrace);
      throw Exception('Failed to create property: $e');
    }
  }

  /// **NEW: Upload images to Supabase Storage**
  Future<List<String>> uploadPropertyImages({
    required String hostId,
    required String propertyId,
    required List<File> imageFiles,
  }) async {
    try {
      final List<String> downloadUrls = [];
      await getTemporaryDirectory();

      for (int i = 0; i < imageFiles.length; i++) {
        final fileName = 'image_${i + 1}.jpg';
        final filePath = 'hosts/$hostId/listings/$propertyId/$fileName';

        // Upload to Supabase Storage
        await _client.storage.from('host-listing-photos').upload(
          filePath,
          imageFiles[i],
          fileOptions: const FileOptions(upsert: true),
        );

        // Get public URL
        final publicUrl = _client.storage.from('host-listing-photos').getPublicUrl(filePath);
        downloadUrls.add(publicUrl);
      }

      logger.i('✅ Uploaded ${downloadUrls.length} images');
      return downloadUrls;
    } catch (e, stackTrace) {
      logger.e('Image upload failed', error: e, stackTrace: stackTrace);
      throw Exception('Failed to upload images: $e');
    }
  }
}