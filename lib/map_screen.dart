import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'
    if (dart.library.html) 'package:foodfinder/google_maps_flutter_stub.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart' as latlng;
import 'dart:async';
import 'restaurant_model.dart';
import 'app_constants.dart';
import 'location_service.dart';
import 'restaurant_service.dart';
import 'restaurant_marker_popup.dart';
import 'restaurant_list_widget.dart';
import 'restaurant_details_screen.dart';
import 'route_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  final locationService = LocationService();
  final restaurantService = RestaurantService();

  LatLng? userLocation;
  List<Restaurant> nearbyRestaurants = [];
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  Restaurant? selectedRestaurant;
  List<LatLng> routePoints = [];
  bool isLoading = true;
  String? selectedRestaurantId;
  bool showList = false;

  // Variables para navegación y simulación de GPS
  bool isNavigating = false;
  double navigationProgress = 0.0;
  LatLng? simulatedUserLocation;
  Timer? navigationTimer;
  RouteInfo? currentRouteInfo;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await restaurantService.initialize();
      await _updateLocation();
    } catch (e, stackTrace) {
      debugPrint('Error al inicializar mapa: $e');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _updateLocation() async {
    final location = await locationService.getCurrentLocation();
    if (!mounted) return;

    final effectiveLocation = location ?? defaultLocation;

    // Obtener restaurantes cercanos
    final nearby = restaurantService.getNearbyRestaurants(effectiveLocation);
    
    // Si no hay cercanos, traer todos
    final restaurantsToLoad = nearby.isNotEmpty 
        ? nearby 
        : restaurantService.getAllRestaurants();

    setState(() {
      userLocation = effectiveLocation;
      nearbyRestaurants = restaurantsToLoad;
      markers = _buildMarkers();
      isLoading = false;
    });

    if (mapController != null) {
      mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: effectiveLocation, zoom: 14),
        ),
      );
    }
  }
  void _updateMarkers() {
    if (!mounted) {
      return;
    }

    setState(() {
      markers = _buildMarkers();
    });
  }

  Set<Marker> _buildMarkers() {
    if (userLocation == null) {
      return {};
    }

    final currentLocation = simulatedUserLocation ?? userLocation!;
    final newMarkers = <Marker>{};

    newMarkers.add(
      Marker(
        markerId: const MarkerId('user_location'),
        position: currentLocation,
        infoWindow: InfoWindow(
          title: isNavigating ? 'Navegando...' : 'Tu ubicación',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );

    final restaurantsToMark = nearbyRestaurants.isEmpty
        ? restaurantService.getAllRestaurants()
        : nearbyRestaurants;

    for (var restaurant in restaurantsToMark) {
      final distance = restaurant.getDistanceInKm(currentLocation);

      newMarkers.add(
        Marker(
          markerId: MarkerId(restaurant.id),
          position: restaurant.location,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange,
          ),
          infoWindow: InfoWindow(
            title: restaurant.name,
            snippet: restaurant.type,
          ),
          onTap: () {
            setState(() {
              selectedRestaurantId = restaurant.id;
            });
            _showRestaurantPopup(restaurant, distance);
          },
        ),
      );
    }

    return newMarkers;
  }

  void _showRestaurantPopup(Restaurant restaurant, double distance) {
    _updateRouteTo(restaurant);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: RestaurantMarkerPopup(
          restaurant: restaurant,
          distance: distance,
          onNavigate: () {
            Navigator.of(context).pop();
            _toggleNavigation();
          },
          onDetails: () {
            Navigator.of(context).pop();
            _navigateToDetails(restaurant);
          },
        ),
      ),
    );
  }

  void _updateRouteTo(Restaurant restaurant) {
    if (userLocation == null) return;

    final route = _buildRoutePoints(userLocation!, restaurant.location);
    final routeInfo = RouteService.getRouteInfo(userLocation!, restaurant.location);

    setState(() {
      selectedRestaurant = restaurant;
      routePoints = route;
      currentRouteInfo = routeInfo;
      polylines = {
        Polyline(
          polylineId: const PolylineId('route'),
          color: Colors.orange,
          width: 5,
          points: routePoints,
        ),
      };
    });

    if (mapController != null && routePoints.length >= 2) {
      final bounds = _createBounds(routePoints);
      mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
    }
  }

  void _startNavigation() {
    if (selectedRestaurant == null || userLocation == null) return;

    setState(() {
      isNavigating = true;
      navigationProgress = 0.0;
      simulatedUserLocation = userLocation;
      markers = _buildMarkers();
    });

    // Simular actualización de GPS cada 500ms
    navigationTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      final nextProgress = navigationProgress + 0.01;

      if (nextProgress >= 1.0) {
        _stopNavigation();
        return;
      }

      final nextLocation = RouteService.interpolatePosition(
        userLocation!,
        selectedRestaurant!.location,
        nextProgress,
      );

      setState(() {
        navigationProgress = nextProgress;
        simulatedUserLocation = nextLocation;
        markers = _buildMarkers();
      });
    });
  }

  void _stopNavigation() {
    navigationTimer?.cancel();
    setState(() {
      isNavigating = false;
      navigationProgress = 0.0;
      simulatedUserLocation = null;
      markers = _buildMarkers();
    });
  }

  void _toggleNavigation() {
    if (isNavigating) {
      _stopNavigation();
    } else {
      _startNavigation();
    }
  }

  void _clearRoute() {
    _stopNavigation();
    setState(() {
      selectedRestaurant = null;
      routePoints = [];
      polylines = {};
      currentRouteInfo = null;
    });
  }

  List<LatLng> _buildRoutePoints(
    LatLng start,
    LatLng end, {
    int segments = 10,
  }) {
    return List<LatLng>.generate(segments + 1, (index) {
      final t = index / segments;
      return LatLng(
        start.latitude + (end.latitude - start.latitude) * t,
        start.longitude + (end.longitude - start.longitude) * t,
      );
    });
  }

  LatLngBounds _createBounds(List<LatLng> points) {
    final latitudes = points.map((p) => p.latitude);
    final longitudes = points.map((p) => p.longitude);
    final south = latitudes.reduce((a, b) => a < b ? a : b);
    final north = latitudes.reduce((a, b) => a > b ? a : b);
    final west = longitudes.reduce((a, b) => a < b ? a : b);
    final east = longitudes.reduce((a, b) => a > b ? a : b);

    return LatLngBounds(
      southwest: LatLng(south, west),
      northeast: LatLng(north, east),
    );
  }

  void _navigateToDetails(Restaurant restaurant) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RestaurantDetailsScreen(restaurant: restaurant),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (userLocation != null) {
      mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: userLocation!, zoom: 14),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FoodFinder'),
        backgroundColor: Colors.orange,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              setState(() => isLoading = true);
              await _updateLocation();
            },
            tooltip: 'Actualizar ubicación',
          ),
          IconButton(
            icon: Icon(showList ? Icons.map : Icons.list),
            onPressed: () {
              setState(() => showList = !showList);
            },
            tooltip: 'Cambiar vista',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 800;
                if (isWide) {
                  return Row(
                    children: [
                      Expanded(child: _buildMapContent()),
                      SizedBox(width: 360, child: _buildSidePanel()),
                    ],
                  );
                }

                return showList
                    ? RestaurantListWidget(
                        restaurants: nearbyRestaurants.isEmpty
                            ? restaurantService.getAllRestaurants()
                            : nearbyRestaurants,
                        onRefresh: _updateLocation,
                        onTap: _navigateToDetails,
                      )
                    : _buildMapContent();
              },
            ),
      floatingActionButton: !kIsWeb && !showList && !isLoading
          ? FloatingActionButton(
              onPressed: _updateLocation,
              backgroundColor: Colors.orange,
              child: const Icon(Icons.my_location),
            )
          : null,
      bottomSheet: !kIsWeb && !showList && !isLoading
          ? _buildBottomPanel()
          : null,
    );
  }

  Widget _buildMapContent() {
    if (kIsWeb) {
      final currentLocation = userLocation ?? defaultLocation;
      final restaurantsToShow = nearbyRestaurants.isEmpty
          ? restaurantService.getNearbyRestaurants(currentLocation)
          : nearbyRestaurants;

      return ClipRRect(
        borderRadius: BorderRadius.circular(0),
        child: fm.FlutterMap(
          options: fm.MapOptions(
            initialCenter: latlng.LatLng(
              currentLocation.latitude,
              currentLocation.longitude,
            ),
            initialZoom: 14,
          ),
          children: [
            fm.TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
              userAgentPackageName: 'com.example.foodfinder',
            ),
            fm.MarkerLayer(
              markers: [
                fm.Marker(
                  width: 40,
                  height: 40,
                  point: latlng.LatLng(
                    currentLocation.latitude,
                    currentLocation.longitude,
                  ),
                  child: const Icon(
                    Icons.person_pin_circle,
                    color: Colors.blue,
                    size: 36,
                  ),
                ),
                ...restaurantsToShow.map(
                  (restaurant) {
                    final isSelected = restaurant.id == selectedRestaurantId;
                    return fm.Marker(
                      width: isSelected ? 46 : 40,
                      height: isSelected ? 46 : 40,
                      point: latlng.LatLng(
                        restaurant.location.latitude,
                        restaurant.location.longitude,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          final distance = userLocation != null
                              ? restaurant.getDistanceInKm(userLocation!)
                              : 0.0;
                          _showRestaurantPopup(restaurant, distance);
                        },
                        child: Icon(
                          Icons.location_on,
                          color: isSelected ? Colors.red : Colors.orange,
                          size: isSelected ? 44 : 36,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            if (routePoints.isNotEmpty)
              fm.PolylineLayer(
                polylines: [
                  fm.Polyline(
                    points: routePoints
                        .map(
                          (point) =>
                              latlng.LatLng(point.latitude, point.longitude),
                        )
                        .toList(),
                    color: Colors.orange,
                    strokeWidth: 5,
                  ),
                ],
              ),
          ],
        ),
      );
    }

    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: userLocation ?? const LatLng(40.4168, -3.7038),
        zoom: 14,
      ),
      markers: markers,
      polylines: polylines,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
    );
  }

  Widget _buildSidePanel() {
    final restaurantsToShow = nearbyRestaurants.isEmpty
        ? restaurantService.getAllRestaurants()
        : nearbyRestaurants;

    return SafeArea(
      child: Container(
        color: Colors.grey[100],
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Restaurantes cercanos',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    nearbyRestaurants.isEmpty
                        ? 'No hay restaurantes dentro del radio. Mostrando restaurantes ordenados por distancia.'
                        : 'Toca una tarjeta para ver detalles y trazar la ruta.',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            if (selectedRestaurant != null && userLocation != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedRestaurant!.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          selectedRestaurant!.address,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        // Información de la ruta
                        if (currentRouteInfo != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          color: Colors.orange,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          currentRouteInfo!.distanceText,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.schedule,
                                          color: Colors.orange,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          currentRouteInfo!.durationText,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                if (isNavigating)
                                  Column(
                                    children: [
                                      const SizedBox(height: 12),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: navigationProgress,
                                          minHeight: 6,
                                          backgroundColor: Colors.grey[300],
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            Colors.orange[700]!,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Progreso: ${(navigationProgress * 100).toStringAsFixed(0)}%',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.orange,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _toggleNavigation,
                                icon: Icon(
                                  isNavigating
                                      ? Icons.stop_circle
                                      : Icons.navigation,
                                ),
                                label: Text(
                                  isNavigating
                                      ? 'Detener navegación'
                                      : 'Cómo llegar',
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isNavigating
                                      ? Colors.red
                                      : Colors.orange,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  _clearRoute();
                                });
                              },
                              color: Colors.grey[700],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: restaurantsToShow.isEmpty
                    ? Center(
                        child: Text(
                          'No hay restaurantes disponibles.',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      )
                    : ListView.builder(
                        itemCount: restaurantsToShow.length,
                        itemBuilder: (context, index) {
                          final restaurant = restaurantsToShow[index];
                          final distance = userLocation != null
                              ? restaurant.getDistanceInKm(userLocation!)
                              : 0.0;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildRestaurantCard(restaurant, distance),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomPanel() {
    final restaurantsToShow = nearbyRestaurants.isEmpty
        ? restaurantService.getAllRestaurants()
        : nearbyRestaurants;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (selectedRestaurant != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ruta seleccionada',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (currentRouteInfo != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedRestaurant!.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        color: Colors.orange,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        currentRouteInfo!.distanceText,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.schedule,
                                        color: Colors.orange,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        currentRouteInfo!.durationText,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (isNavigating)
                                Column(
                                  children: [
                                    const SizedBox(height: 12),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: navigationProgress,
                                        minHeight: 6,
                                        backgroundColor: Colors.grey[300],
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Colors.orange[700]!,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Progreso: ${(navigationProgress * 100).toStringAsFixed(0)}%',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        )
                      else
                        Text(
                          '${selectedRestaurant!.name} • ${selectedRestaurant!.getDistanceInKm(userLocation!).toStringAsFixed(2)} km',
                          style: const TextStyle(fontSize: 14),
                        ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _toggleNavigation,
                        icon: Icon(
                          isNavigating
                              ? Icons.stop_circle
                              : Icons.navigation,
                        ),
                        label: Text(
                          isNavigating
                              ? 'Detener navegación'
                              : 'Iniciar navegación',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isNavigating ? Colors.red : Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),

                Text(
                  'Restaurantes cercanos (${restaurantsToShow.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 180,
                  child: restaurantsToShow.isEmpty
                      ? Center(
                          child: Text(
                            'No hay restaurantes disponibles.',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: restaurantsToShow.length,
                          itemBuilder: (context, index) {
                            final restaurant = restaurantsToShow[index];
                            final distance = userLocation != null
                                ? restaurant.getDistanceInKm(userLocation!)
                                : 0.0;

                            return _buildRestaurantCard(restaurant, distance);
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantCard(Restaurant restaurant, double distance) {
    return GestureDetector(
      onTap: () {
        // Marcar como seleccionado y mostrar ruta
        setState(() {
          selectedRestaurantId = restaurant.id;
        });
        _updateRouteTo(restaurant);
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selectedRestaurantId == restaurant.id 
              ? Colors.orange 
              : Colors.grey[300]!,
            width: selectedRestaurantId == restaurant.id ? 2 : 1,
          ),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(11),
              ),
              child: Image.network(
                restaurant.imageUrl,
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 100,
                    color: Colors.grey[300],
                    child: const Icon(Icons.restaurant),
                  );
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          restaurant.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          restaurant.type,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.orange[700],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 12,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${restaurant.rating}',
                              style: const TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                        Text(
                          '${distance.toStringAsFixed(1)}km',
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    navigationTimer?.cancel();
    mapController?.dispose();
    super.dispose();
  }
}
