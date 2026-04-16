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

    final nearby = _restaurants.where((restaurant) {
      final distance = restaurant.getDistanceInKm(userLocation);
      return distance <= radiusKm;
    }).toList();

    if (nearby.isEmpty) {
      return _generateFictitiousRestaurants(userLocation);
    }

    nearby.sort((a, b) {
      final distA = a.getDistanceInKm(userLocation);
      final distB = b.getDistanceInKm(userLocation);
      return distA.compareTo(distB);
    });

    return nearby;
  }

  List<Restaurant> _generateFictitiousRestaurants(LatLng userLocation) {
    final names = [
      'Local Ficticio 1',
      'Bistró Ficticio',
      'Cafetería Ficticia',
      'Food Truck Ficticio',
      'Punto de Comida Ficticio',
    ];

    final types = [
      'Cafetería',
      'Comida Rápida',
      'Internacional',
      'Vegano',
      'Postres',
    ];

    final offsets = [
      [0.0035, 0.0025],
      [-0.0030, -0.0020],
      [0.0020, -0.0030],
      [-0.0025, 0.0030],
      [0.0015, 0.0015],
    ];

    return List<Restaurant>.generate(names.length, (index) {
      final offset = offsets[index % offsets.length];
      final position = LatLng(
        userLocation.latitude + offset[0],
        userLocation.longitude + offset[1],
      );
      return Restaurant(
        id: 'ficticio_${index + 1}',
        name: names[index],
        type: types[index],
        location: position,
        rating: 4.0 + (index * 0.1),
        imageUrl:
            'https://via.placeholder.com/300x200?text=${Uri.encodeComponent(names[index])}',
        address: 'Calle Falsa ${100 + index}, Cerca de ti',
        phoneNumber: '+598 99 000 00${index + 1}',
        description:
            'Local ficticio generado cerca de tu ubicación para mostrar opciones en el mapa.',
      );
    });
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
