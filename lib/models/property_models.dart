import 'package:flutter/material.dart';

class Amenity {
  final String id;
  final String name;
  final IconData icon;

  const Amenity({
    required this.id,
    required this.name,
    required this.icon,
  });
}

class HouseRule {
  final String id;
  final String description;
  final IconData icon;

  const HouseRule({
    required this.id,
    required this.description,
    required this.icon,
  });
}

class Review {
  final String id;
  final String userName;
  final String? userPhoto;
  final double rating;
  final String comment;
  final DateTime date;

  Review({
    required this.id,
    required this.userName,
    this.userPhoto,
    required this.rating,
    required this.comment,
    required this.date,
  });
}

class Availability {
  final DateTime date;
  final bool isAvailable;
  final int? price;

  Availability({
    required this.date,
    required this.isAvailable,
    this.price,
  });
}

class Host {
  final String id;
  final String name;
  final String photoUrl;
  final bool isSuperhost;
  final int hostingSince;
  final double responseRate;
  final String responseTime;
  final String about;

  Host({
    required this.id,
    required this.name,
    required this.photoUrl,
    required this.isSuperhost,
    required this.hostingSince,
    required this.responseRate,
    required this.responseTime,
    required this.about,
  });
}

// Add this to your property_models.dart or create a new calendar_models.dart file

class CalendarEvent {
  final String id;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final String eventType; // 'booking', 'blocked', 'maintenance'
  final String? notes;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.eventType,
    this.notes,
  });
}