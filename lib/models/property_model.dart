import 'package:flutter/material.dart';
import 'package:travel265/models/property_models.dart'; // Import the supporting models

class Property {
  final String id;
  final String title;
  final String description;
  final String type;
  final String location;
  final double rating;
  final int reviewCount;
  final int pricePerNight;
  final int guests;
  final int bedrooms;
  final int beds;
  final int bathrooms;
  final List<String> images;
  final Host host;
  final List<Amenity> amenities;
  final List<HouseRule> houseRules;
  final List<Review> reviews;
  final String nearestLandmark;
  final String distanceFromLandmark;
  final String locationDescription;
  final bool isFavorite;
  final List<Availability> availability;
  final PricingSettings pricingSettings;
  final BookingSettings bookingSettings;
  final String calendarSyncUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  Property({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.location,
    required this.rating,
    required this.reviewCount,
    required this.pricePerNight,
    required this.guests,
    required this.bedrooms,
    required this.beds,
    required this.bathrooms,
    required this.images,
    required this.host,
    required this.amenities,
    required this.houseRules,
    required this.reviews,
    required this.nearestLandmark,
    required this.distanceFromLandmark,
    required this.locationDescription,
    required this.isFavorite,
    required this.availability,
    required this.pricingSettings,
    required this.bookingSettings,
    required this.calendarSyncUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });

  // Helper methods
  bool isAvailable(DateTime date) {
    final availability = this.availability.firstWhere(
          (avail) => _isSameDay(avail.date, date),
      orElse: () => Availability(date: date, isAvailable: false, price: pricePerNight),
    );
    return availability.isAvailable;
  }

  int getPriceForDate(DateTime date) {
    final availability = this.availability.firstWhere(
          (avail) => _isSameDay(avail.date, date),
      orElse: () => Availability(date: date, isAvailable: true, price: pricePerNight),
    );
    return availability.price ?? pricePerNight;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }
}

class PricingSettings {
  final int basePrice;
  final int weekendPrice;
  final int monthlyDiscount; // percentage
  final int weeklyDiscount; // percentage
  final int cleaningFee;
  final int securityDeposit;
  final List<SpecialPrice> specialPrices;

  PricingSettings({
    required this.basePrice,
    this.weekendPrice = 0,
    this.monthlyDiscount = 0,
    this.weeklyDiscount = 0,
    this.cleaningFee = 0,
    this.securityDeposit = 0,
    this.specialPrices = const [],
  });
}

class SpecialPrice {
  final DateTime startDate;
  final DateTime endDate;
  final int price;

  SpecialPrice({
    required this.startDate,
    required this.endDate,
    required this.price,
  });
}

class BookingSettings {
  final int minNights;
  final int maxNights;
  final int advanceNotice; // hours
  final int preparationTime; // hours between bookings
  final bool requireDeposit;
  final int depositPercentage;
  final bool instantBooking;
  final List<String> blockedDates;

  BookingSettings({
    this.minNights = 1,
    this.maxNights = 30,
    this.advanceNotice = 24,
    this.preparationTime = 24,
    this.requireDeposit = true,
    this.depositPercentage = 50,
    this.instantBooking = false,
    this.blockedDates = const [],
  });
}