import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math' as math;

class Restaurant {
  final String id;
  final String name;
  final String type;
  final LatLng location;
  final double rating;
  final String imageUrl;
  final String address;
  final String phoneNumber;
  final String description;

  Restaurant({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    required this.rating,
    required this.imageUrl,
    required this.address,
    required this.phoneNumber,
    required this.description,
  });

  /// Calcula la distancia al usuario en kilómetros usando la fórmula de Haversine
  double getDistanceInKm(LatLng userLocation) {
    const double earthRadiusKm = 6371;

    final double dLat = _toRadians(location.latitude - userLocation.latitude);
    final double dLng = _toRadians(location.longitude - userLocation.longitude);

    final double a = (math.sin(dLat / 2) * math.sin(dLat / 2)) +
        (math.cos(_toRadians(userLocation.latitude)) *
            math.cos(_toRadians(location.latitude)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2));

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _toRadians(double degree) {
    return degree * math.pi / 180;
  }

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      location: LatLng(
        json['latitude'] as double,
        json['longitude'] as double,
      ),
      rating: (json['rating'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      address: json['address'] as String,
      phoneNumber: json['phoneNumber'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'rating': rating,
      'imageUrl': imageUrl,
      'address': address,
      'phoneNumber': phoneNumber,
      'description': description,
    };
  }
}
