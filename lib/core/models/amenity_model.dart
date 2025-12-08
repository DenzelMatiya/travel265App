// lib/core/models/amenity_model.dart - DEFENSIVE VERSION

// 🚨 CRITICAL: If you see "Undefined name 'Icons'" errors:
// Run: flutter clean && flutter pub get && flutter analyze
// This is NOT a code issue - it's Flutter SDK not being recognized.

import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

/// 🛎️ **Amenity Model**
///
/// Represents a property amenity with:
/// - Unique ID (for indexing)
/// - Display name (for UI)
/// - Icon (for visual representation)
///
/// **Usage:**
/// ```dart
/// final amenities = Amenity.standardAmenities;
/// amenities.forEach((a) => print('${a.id}: ${a.name} ${a.icon}'));
/// ```
class Amenity extends Equatable {
  final String id;
  final String name;
  final IconData icon;

  const Amenity({
    required this.id,
    required this.name,
    required this.icon,
  });

  /// 🎯 **Standard Amenities for Travel265**
  ///
  /// **IMPORTANT:** This is a `const` list - cannot be modified at runtime.
  /// For dynamic amenities (from API), create a separate list.
  static const List<Amenity> standardAmenities = [
    Amenity(id: 'wifi', name: 'Wifi', icon: Icons.wifi_outlined),
    Amenity(id: 'ac', name: 'Air Conditioning', icon: Icons.ac_unit_outlined),
    Amenity(id: 'pool', name: 'Pool', icon: Icons.pool_outlined),
    Amenity(id: 'parking', name: 'Parking', icon: Icons.local_parking_outlined),
    Amenity(id: 'kitchen', name: 'Kitchen', icon: Icons.kitchen_outlined),
    Amenity(id: 'tv', name: 'TV', icon: Icons.tv_outlined),
    Amenity(id: 'washer', name: 'Washer', icon: Icons.local_laundry_service_outlined),
    Amenity(id: 'dryer', name: 'Dryer', icon: Icons.local_laundry_service_outlined),
    Amenity(id: 'heating', name: 'Heating', icon: Icons.thermostat_outlined),
    Amenity(id: 'elevator', name: 'Elevator', icon: Icons.elevator_outlined),
    Amenity(id: 'gym', name: 'Gym', icon: Icons.fitness_center_outlined),
    Amenity(id: 'breakfast', name: 'Breakfast', icon: Icons.restaurant_outlined),
  ];

  // ✅ CORRECT: Equality based on ID only (business logic)
  // If you want full property equality, add name and icon to props.
  @override
  List<Object?> get props => [id];

  /// 📋 **Convert to Map** (useful for Supabase storage)
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    // IconData cannot be JSON-serialized, so we store the icon name
    'icon_name': _getIconName(icon),
  };

  /// 🎨 **Get icon name** (for Supabase storage)
  String _getIconName(IconData icon) {
    // Map IconData back to its name for storage
    // This is a simplified version - you may want a full mapping
    if (icon == Icons.wifi_outlined) return 'wifi';
    if (icon == Icons.ac_unit_outlined) return 'ac';
    if (icon == Icons.pool_outlined) return 'pool';
    // Add more mappings as needed
    return 'help_outline'; // fallback
  }

  /// 🎯 **Create from Map** (from Supabase)
  factory Amenity.fromMap(Map<String, dynamic> map) {
    // Map icon name back to IconData
    IconData icon = Icons.help_outline; // Default fallback
    switch (map['icon_name']) {
      case 'wifi':
        icon = Icons.wifi_outlined;
        break;
      case 'ac':
        icon = Icons.ac_unit_outlined;
        break;
      case 'pool':
        icon = Icons.pool_outlined;
        break;
    // Add more cases as needed
    }

    return Amenity(
      id: map['id'] as String,
      name: map['name'] as String,
      icon: icon,
    );
  }
}