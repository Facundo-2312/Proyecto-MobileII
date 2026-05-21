import 'package:google_maps_flutter/google_maps_flutter.dart'
    if (dart.library.html) 'package:foodfinder/google_maps_flutter_stub.dart';
import 'restaurant_model.dart';
import 'app_constants.dart';

class RestaurantService {
  static final RestaurantService _instance = RestaurantService._internal();

  factory RestaurantService() {
    return _instance;
  }

  RestaurantService._internal();

  late List<Restaurant> _restaurants;
  bool _isInitialized = false;

  /// Inicializa automáticamente si no está ya hecho
  void _ensureInitialized() {
    if (_isInitialized) return;

    _restaurants = mockRestaurants
        .map((data) => Restaurant.fromJson(data))
        .toList();

    _isInitialized = true;
  }

  /// Inicializa el servicio con datos mock (async compatible)
  Future<void> initialize() async {
    _ensureInitialized();
  }

  /// Obtiene todos los restaurantes
  List<Restaurant> getAllRestaurants() {
    _ensureInitialized();
    return _restaurants;
  }

  /// Obtiene restaurantes cercanos ordenados por distancia
  List<Restaurant> getNearbyRestaurants(
    LatLng userLocation, {
    double radiusKm = searchRadiusKm,
  }) {
    _ensureInitialized();

    final sortedByDistance = List<Restaurant>.from(_restaurants);
    sortedByDistance.sort((a, b) {
      final distA = a.getDistanceInKm(userLocation);
      final distB = b.getDistanceInKm(userLocation);
      return distA.compareTo(distB);
    });

    final nearby = sortedByDistance.where((restaurant) {
      final distance = restaurant.getDistanceInKm(userLocation);
      return distance <= radiusKm;
    }).toList();

    if (nearby.isEmpty) {
      return sortedByDistance.take(5).toList();
    }

    return nearby;
  }

  /// Busca restaurantes por nombre o tipo
  List<Restaurant> searchRestaurants(String query) {
    _ensureInitialized();

    final searchLower = query.toLowerCase();
    return _restaurants
        .where(
          (restaurant) =>
              restaurant.name.toLowerCase().contains(searchLower) ||
              restaurant.type.toLowerCase().contains(searchLower),
        )
        .toList();
  }

  /// Obtiene un restaurante por ID
  Restaurant? getRestaurantById(String id) {
    _ensureInitialized();

    try {
      return _restaurants.firstWhere((restaurant) => restaurant.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Obtiene los restaurantes ordenados por rating
  List<Restaurant> getTopRatedRestaurants({int limit = 5}) {
    _ensureInitialized();

    final sorted = List<Restaurant>.from(_restaurants);
    sorted.sort((a, b) => b.rating.compareTo(a.rating));
    return sorted.take(limit).toList();
  }

  /// Obtiene restaurantes por tipo
  List<Restaurant> getRestaurantsByType(String type) {
    _ensureInitialized();

    return _restaurants
        .where(
          (restaurant) => restaurant.type.toLowerCase() == type.toLowerCase(),
        )
        .toList();
  }
}
