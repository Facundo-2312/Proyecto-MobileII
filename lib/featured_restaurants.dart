import 'package:google_maps_flutter/google_maps_flutter.dart'
    if (dart.library.html) 'package:foodfinder/google_maps_flutter_stub.dart';

import 'restaurant_model.dart';

class FeaturedRestaurantMetrics {
  final String name;
  final double distanceKm;
  final int deliveryMinutes;

  const FeaturedRestaurantMetrics({
    required this.name,
    required this.distanceKm,
    required this.deliveryMinutes,
  });
}

const LatLng featuredRiveraCenter = LatLng(-30.9050, -55.5360);

const List<FeaturedRestaurantMetrics> featuredRiveraMetrics = [
  FeaturedRestaurantMetrics(
    name: 'Gardel Restaurante e Parrillada',
    distanceKm: 4.0,
    deliveryMinutes: 7,
  ),
  FeaturedRestaurantMetrics(
    name: 'Lo de Beto',
    distanceKm: 3.9,
    deliveryMinutes: 7,
  ),
  FeaturedRestaurantMetrics(
    name: 'Benedetto Steakhouse',
    distanceKm: 3.4,
    deliveryMinutes: 6,
  ),
  FeaturedRestaurantMetrics(
    name: 'Morano Restaurant',
    distanceKm: 3.8,
    deliveryMinutes: 7,
  ),
  FeaturedRestaurantMetrics(
    name: 'La Perdiz',
    distanceKm: 4.5,
    deliveryMinutes: 8,
  ),
];

List<Restaurant> resolveFeaturedRiveraRestaurants(List<Restaurant> restaurants) {
  final metricsByName = {
    for (final metrics in featuredRiveraMetrics) metrics.name: metrics,
  };

  final selected = restaurants
      .where((restaurant) => metricsByName.containsKey(restaurant.name))
      .toList();

  selected.sort((left, right) {
    final leftIndex = featuredRiveraMetrics.indexWhere(
      (metrics) => metrics.name == left.name,
    );
    final rightIndex = featuredRiveraMetrics.indexWhere(
      (metrics) => metrics.name == right.name,
    );
    return leftIndex.compareTo(rightIndex);
  });

  return selected;
}

FeaturedRestaurantMetrics? featuredRiveraMetricsFor(Restaurant restaurant) {
  for (final metrics in featuredRiveraMetrics) {
    if (metrics.name == restaurant.name) {
      return metrics;
    }
  }

  return null;
}

bool isFeaturedRiveraRestaurant(Restaurant restaurant) {
  return featuredRiveraMetricsFor(restaurant) != null;
}