import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

class Amenity extends Equatable {
  final String id;
  final String name;
  final IconData icon;

  const Amenity({
    required this.id,
    required this.name,
    required this.icon,
  });

  // Standard amenities for Travel265
  static const List<Amenity> standardAmenities = [
    Amenity(id: 'wifi', name: 'Wifi', icon: Icons.wifi),
    Amenity(id: 'ac', name: 'Air Conditioning', icon: Icons.ac_unit),
    Amenity(id: 'pool', name: 'Pool', icon: Icons.pool),
    Amenity(id: 'parking', name: 'Parking', icon: Icons.local_parking),
    Amenity(id: 'kitchen', name: 'Kitchen', icon: Icons.kitchen),
    Amenity(id: 'tv', name: 'TV', icon: Icons.tv),
    Amenity(id: 'washer', name: 'Washer', icon: Icons.local_laundry_service),
    Amenity(id: 'dryer', name: 'Dryer', icon: Icons.local_laundry_service),
    Amenity(id: 'heating', name: 'Heating', icon: Icons.thermostat),
    Amenity(id: 'elevator', name: 'Elevator', icon: Icons.elevator),
    Amenity(id: 'gym', name: 'Gym', icon: Icons.fitness_center),
    Amenity(id: 'breakfast', name: 'Breakfast', icon: Icons.restaurant),
  ];

  @override
  List<Object?> get props => [id];
}