import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travel265/core/models/property_model.dart';
import 'package:travel265/core/models/amenity_model.dart';
import 'package:travel265/core/utils/logger.dart';
import 'package:uuid/uuid.dart';

class PropertyRepository {
  final SupabaseClient _client;
  final _uuid = const Uuid();

  PropertyRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  // ... (keep existing getProperties, getPropertyById methods) ...

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

      // Convert to PropertyModel (you may need a fromListingsMap factory)
      return PropertyModel(
        id: response['id'],
        hostId: response['host_id'],
        title: response['property_name'],
        description: response['description'],
        type: PropertyType.values.firstWhere((e) => e.name == response['property_type']),
        city: response['city'],
        region: response['region'],
        address: response['address'],
        latitude: response['latitude'],
        longitude: response['longitude'],
        pricePerNight: response['price_per_night'].toDouble(),
        maxGuests: response['max_guests'],
        bedrooms: response['bedrooms'],
        bathrooms: response['bathrooms'],
        amenities: List<String>.from(response['amenities']),
        imageUrls: List<String>.from(response['photos']),
        createdAt: DateTime.parse(response['created_at']),
      );
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
      final tempDir = await getTemporaryDirectory();

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