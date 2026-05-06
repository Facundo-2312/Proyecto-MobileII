import 'package:flutter/material.dart';

import 'featured_restaurants.dart';
import 'restaurant_model.dart';
import 'restaurant_details_screen.dart';
import 'restaurant_service.dart';

class LocationSearchScreen extends StatelessWidget {
  const LocationSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final restaurants = resolveFeaturedRiveraRestaurants(
      RestaurantService().getAllRestaurants(),
    );

    return _FeatureScaffold(
      title: 'Búsqueda por ubicación',
      description:
          'Restaurantes seleccionados de Rivera ordenados por distancia.',
      actionLabel: 'Abrir mapa interactivo',
      onActionPressed: () => Navigator.pushNamed(context, '/map'),
      child: _RestaurantList(
        restaurants: restaurants,
        trailingBuilder: (restaurant) {
          final metrics = featuredRiveraMetricsFor(restaurant);
          return Text(
            '${(metrics?.distanceKm ?? 0).toStringAsFixed(1)} km',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.orange,
            ),
          );
        },
      ),
    );
  }
}

class RatingsScreen extends StatelessWidget {
  const RatingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final restaurants = resolveFeaturedRiveraRestaurants(
      RestaurantService().getAllRestaurants(),
    );

    return _FeatureScaffold(
      title: 'Calificaciones',
      description: 'Los restaurantes destacados de Rivera con sus puntuaciones.',
      actionLabel: 'Explorar productos',
      onActionPressed: () => Navigator.pushNamed(context, '/products'),
      child: _RestaurantList(
        restaurants: restaurants,
        trailingBuilder: (restaurant) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 18),
            const SizedBox(width: 4),
            Text(
              restaurant.rating.toStringAsFixed(1),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class FastDeliveryScreen extends StatelessWidget {
  const FastDeliveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final restaurants = resolveFeaturedRiveraRestaurants(
      RestaurantService().getAllRestaurants(),
    );

    return _FeatureScaffold(
      title: 'Entrega rápida',
      description: 'Opciones destacadas de Rivera con entrega estimada más corta.',
      actionLabel: 'Ver mis pedidos',
      onActionPressed: () => Navigator.pushNamed(context, '/orders'),
      child: _RestaurantList(
        restaurants: restaurants,
        trailingBuilder: (restaurant) {
          final metrics = featuredRiveraMetricsFor(restaurant);
          return Text(
            '${metrics?.deliveryMinutes ?? 0} min',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.orange,
            ),
          );
        },
      ),
    );
  }
}

class _FeatureScaffold extends StatelessWidget {
  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback onActionPressed;
  final Widget child;

  const _FeatureScaffold({
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onActionPressed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.orange.withValues(alpha: 0.08),
            child: Text(
              description,
              style: const TextStyle(fontSize: 15),
            ),
          ),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onActionPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(
              actionLabel,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RestaurantList extends StatelessWidget {
  final List<Restaurant> restaurants;
  final Widget Function(Restaurant restaurant) trailingBuilder;

  const _RestaurantList({
    required this.restaurants,
    required this.trailingBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: restaurants.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final restaurant = restaurants[index];
        return Card(
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              restaurant.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text('${restaurant.type} · ${restaurant.address}'),
            ),
            trailing: trailingBuilder(restaurant),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => RestaurantDetailsScreen(restaurant: restaurant),
              ),
            ),
          ),
        );
      },
    );
  }
}
