import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'
    if (dart.library.html) 'package:foodfinder/google_maps_flutter_stub.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart' as latlng;
import 'dart:async';
import 'restaurant_model.dart';
import 'location_service.dart';
import 'restaurant_service.dart';
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
  final fm.MapController webMapController = fm.MapController();
  final locationService = LocationService();
  final restaurantService = RestaurantService();
  int _routeRequestId = 0;
  StreamSubscription<LatLng>? _locationSubscription;
  bool _hasCenteredOnUser = false;
  double _webZoom = 14;

  LatLng? userLocation;
  List<Restaurant> nearbyRestaurants = [];
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  Restaurant? selectedRestaurant;
  List<LatLng> routePoints = [];
  List<RouteOption> routeOptions = [];
  bool isLoading = true;
  String? selectedRestaurantId;
  bool showList = false;

  // Variables para navegación y simulación de GPS
  bool isNavigating = false;
  RouteInfo? currentRouteInfo;
  int selectedRouteOptionIndex = 0;
  bool _locationPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      final hasLocationPermission =
          await locationService.checkAndRequestPermissions();
      await restaurantService.initialize();
      final initialLocation = await locationService.getCurrentLocation();

      if (!mounted) return;

      final effectiveLocation =
          initialLocation ?? locationService.getLastKnownLocation();

      setState(() {
        _locationPermissionGranted = hasLocationPermission;
        userLocation = effectiveLocation;
        nearbyRestaurants = restaurantService.getNearbyRestaurants(
          effectiveLocation,
        );
        markers = _buildMarkers();
        isLoading = false;
      });

      _startLocationTracking();
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

  void _startLocationTracking() {
    _locationSubscription?.cancel();
    _locationSubscription = locationService.getLocationStream().listen(
      (nextLocation) {
        _handleLocationUpdate(nextLocation);
      },
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('Error al escuchar ubicación: $error');
        debugPrintStack(stackTrace: stackTrace);
      },
    );
  }

  Future<void> _handleLocationUpdate(LatLng nextLocation) async {
    final previousLocation = userLocation;
    final movedEnoughToRefreshRoute =
        previousLocation == null ||
        RouteService.calculateDistance(previousLocation, nextLocation) >= 0.02;

    if (!mounted) return;

    setState(() {
      userLocation = nextLocation;
      nearbyRestaurants = restaurantService.getNearbyRestaurants(nextLocation);
      markers = _buildMarkers();
      isLoading = false;
    });

    _centerMapOnUser(nextLocation, force: !_hasCenteredOnUser || isNavigating);

    if (selectedRestaurant != null &&
        (routePoints.isEmpty || movedEnoughToRefreshRoute || isNavigating)) {
      await _updateRouteTo(selectedRestaurant!, startLocation: nextLocation);
    }
  }

  Future<void> _updateLocation() async {
    setState(() => isLoading = true);

    final hasLocationPermission =
        await locationService.checkAndRequestPermissions();
    final nextLocation = await locationService.getCurrentLocation();
    final effectiveLocation =
        nextLocation ?? locationService.getLastKnownLocation();
    if (mounted) {
      setState(() {
        _locationPermissionGranted = hasLocationPermission;
      });
    }
    await _handleLocationUpdate(effectiveLocation);
  }

  List<Restaurant> _restaurantsForDisplay() {
    final currentLocation =
        userLocation ?? locationService.getLastKnownLocation();
    return nearbyRestaurants.isEmpty
        ? restaurantService.getNearbyRestaurants(currentLocation)
        : nearbyRestaurants;
  }

  Set<Marker> _buildMarkers() {
    final baseUserLocation = userLocation;
    if (baseUserLocation == null) {
      return {};
    }

    final newMarkers = <Marker>{};

    newMarkers.add(
      Marker(
        markerId: const MarkerId('user_location'),
        position: baseUserLocation,
        infoWindow: InfoWindow(
          title: isNavigating ? 'Tu ubicación en tiempo real' : 'Tu ubicación',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );

    final restaurantsToMark = _restaurantsForDisplay();

    for (var restaurant in restaurantsToMark) {
      newMarkers.add(
        Marker(
          markerId: MarkerId(restaurant.id),
          position: restaurant.location,
          infoWindow: InfoWindow(
            title: restaurant.name,
            snippet: restaurant.type,
          ),
          onTap: () {
            _selectRestaurant(restaurant);
          },
        ),
      );
    }

    return newMarkers;
  }

  Future<void> _selectRestaurant(Restaurant restaurant) async {
    setState(() {
      selectedRestaurantId = restaurant.id;
    });
    await _updateRouteTo(restaurant);
  }

  Future<void> _updateRouteTo(
    Restaurant restaurant, {
    LatLng? startLocation,
  }) async {
    final origin = startLocation ?? userLocation;
    if (origin == null) return;

    final requestId = ++_routeRequestId;
    final routePath = await RouteService.fetchRoute(
      origin,
      restaurant.location,
    );

    if (!mounted || requestId != _routeRequestId) {
      return;
    }

    setState(() {
      final nextSelectedIndex =
          selectedRouteOptionIndex < routePath.options.length
          ? selectedRouteOptionIndex
          : 0;
      final activeOption = routePath.options[nextSelectedIndex];

      selectedRestaurant = restaurant;
      routeOptions = routePath.options;
      selectedRouteOptionIndex = nextSelectedIndex;
      routePoints = activeOption.points;
      currentRouteInfo = activeOption.info;
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
      markers = _buildMarkers();
    });

    _updateRouteTo(selectedRestaurant!);
  }

  void _stopNavigation() {
    setState(() {
      isNavigating = false;
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
      routeOptions = [];
      polylines = {};
      currentRouteInfo = null;
      selectedRouteOptionIndex = 0;
    });
  }

  void _selectRouteOption(int index) {
    if (index < 0 || index >= routeOptions.length) {
      return;
    }

    final option = routeOptions[index];
    setState(() {
      selectedRouteOptionIndex = index;
      routePoints = option.points;
      currentRouteInfo = option.info;
      polylines = {
        Polyline(
          polylineId: const PolylineId('route'),
          color: Colors.orange,
          width: 5,
          points: routePoints,
        ),
      };
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
      _centerMapOnUser(userLocation!, force: true);
    }
  }

  void _centerMapOnUser(LatLng target, {bool force = false}) {
    if (kIsWeb) {
      if (_hasCenteredOnUser && !force) {
        return;
      }

      webMapController.move(
        latlng.LatLng(target.latitude, target.longitude),
        _webZoom,
      );
      _hasCenteredOnUser = true;
      return;
    }

    if (mapController == null) {
      return;
    }

    if (_hasCenteredOnUser && !force) {
      return;
    }

    mapController!.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: target, zoom: 14)),
    );
    _hasCenteredOnUser = true;
  }

  void _zoomWebMap(double delta) {
    if (!kIsWeb) {
      return;
    }

    final nextZoom = (_webZoom + delta).clamp(4.0, 19.0);
    final center = webMapController.camera.center;

    setState(() {
      _webZoom = nextZoom;
    });

    webMapController.move(center, _webZoom);
  }

  void _recenterWebMap() {
    final currentLocation =
        userLocation ?? locationService.getLastKnownLocation();

    if (kIsWeb) {
      webMapController.move(
        latlng.LatLng(currentLocation.latitude, currentLocation.longitude),
        _webZoom,
      );
      return;
    }

    _centerMapOnUser(currentLocation, force: true);
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
                        restaurants: _restaurantsForDisplay(),
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
      final currentLocation =
          userLocation ?? locationService.getLastKnownLocation();
      final restaurantsToShow = _restaurantsForDisplay();

      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(0),
            child: fm.FlutterMap(
              mapController: webMapController,
              options: fm.MapOptions(
                initialCenter: latlng.LatLng(
                  currentLocation.latitude,
                  currentLocation.longitude,
                ),
                initialZoom: _webZoom,
                onPositionChanged: (camera, hasGesture) {
                  final nextZoom = camera.zoom;
                  if (nextZoom != null && _webZoom != nextZoom) {
                    setState(() {
                      _webZoom = nextZoom;
                    });
                  }
                },
              ),
              children: [
                fm.TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                    ...restaurantsToShow.map((restaurant) {
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
                            _selectRestaurant(restaurant);
                          },
                          child: Icon(
                            Icons.location_on,
                            color: isSelected ? Colors.red : Colors.orange,
                            size: isSelected ? 44 : 36,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
                if (routePoints.isNotEmpty)
                  fm.PolylineLayer(
                    polylines: [
                      fm.Polyline(
                        points: routePoints
                            .map(
                              (point) => latlng.LatLng(
                                point.latitude,
                                point.longitude,
                              ),
                            )
                            .toList(),
                        color: Colors.orange,
                        strokeWidth: 5,
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Positioned(right: 16, top: 16, child: _buildWebZoomControls()),
        ],
      );
    }

    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: userLocation ?? locationService.getLastKnownLocation(),
        zoom: 14,
      ),
      markers: markers,
      polylines: polylines,
      myLocationEnabled: _locationPermissionGranted,
      myLocationButtonEnabled: _locationPermissionGranted,
      zoomControlsEnabled: false,
    );
  }

  Widget _buildWebZoomControls() {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(14),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () => _zoomWebMap(1),
            icon: const Icon(Icons.add),
            tooltip: 'Acercar',
          ),
          SizedBox(
            width: 36,
            child: Divider(height: 1, thickness: 1, color: Colors.grey[300]),
          ),
          IconButton(
            onPressed: () => _zoomWebMap(-1),
            icon: const Icon(Icons.remove),
            tooltip: 'Alejar',
          ),
          SizedBox(
            width: 36,
            child: Divider(height: 1, thickness: 1, color: Colors.grey[300]),
          ),
          IconButton(
            onPressed: _recenterWebMap,
            icon: const Icon(Icons.my_location),
            tooltip: 'Centrar en mi ubicación',
          ),
        ],
      ),
    );
  }

  Widget _buildSidePanel() {
    final restaurantsToShow = _restaurantsForDisplay();
    final sidePanelItems = <Widget>[
      if (selectedRestaurant != null && userLocation != null)
        _buildSelectedRestaurantPanel(),
      if (selectedRestaurant != null && userLocation != null)
        const SizedBox(height: 12),
      if (selectedRestaurant == null)
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Selecciona un local para ver a cuánto estás y cómo llegar en tiempo real.',
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ),
      if (selectedRestaurant == null) const SizedBox(height: 12),
      Text(
        'Locales disponibles (${restaurantsToShow.length})',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 12),
    ];

    if (restaurantsToShow.isEmpty) {
      sidePanelItems.add(
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'No hay restaurantes disponibles.',
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ),
      );
    } else {
      for (final restaurant in restaurantsToShow) {
        final distance = userLocation != null
            ? restaurant.getDistanceInKm(userLocation!)
            : 0.0;
        sidePanelItems.add(_buildSidePanelRestaurantCard(restaurant, distance));
        sidePanelItems.add(const SizedBox(height: 12));
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(left: BorderSide(color: Colors.grey[300]!)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Restaurantes cercanos',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Toca una tarjeta para ver el local, a cuánto estás y cómo llegar.',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                children: sidePanelItems,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedRestaurantPanel() {
    final restaurant = selectedRestaurant!;
    final currentLocation = userLocation!;
    final liveDistanceKm = restaurant.getDistanceInKm(currentLocation);
    final liveDistanceText = '${liveDistanceKm.toStringAsFixed(1)} km';
    final activeRouteOption = routeOptions.isNotEmpty
        ? routeOptions[selectedRouteOptionIndex]
        : null;
    final remainingDistanceText =
        currentRouteInfo?.distanceText ?? liveDistanceText;

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              restaurant.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(restaurant.address, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 12),
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
                    children: [
                      const Icon(
                        Icons.storefront,
                        color: Colors.orange,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Local seleccionado · ${restaurant.type}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricChip(
                          icon: Icons.location_on,
                          label: 'Distancia',
                          value: liveDistanceText,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildMetricChip(
                          icon: Icons.schedule,
                          label: 'Tiempo',
                          value:
                              currentRouteInfo?.durationText ?? 'Calculando...',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Estás a $remainingDistanceText de tu destino.',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isNavigating
                        ? 'La ruta se actualiza con tu ubicación en tiempo real.'
                        : 'Pulsa "Cómo llegar" para seguir la ruta desde tu ubicación actual.',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            if (routeOptions.length > 1) ...[
              const SizedBox(height: 12),
              const Text(
                'Trayectos disponibles',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (int index = 0; index < routeOptions.length; index++)
                    _buildRouteOptionChip(routeOptions[index], index),
                ],
              ),
            ],
            if (activeRouteOption != null &&
                activeRouteOption.steps.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Cómo llegar',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...activeRouteOption.steps.take(4).map(_buildRouteStepTile),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _toggleNavigation,
                    icon: Icon(
                      isNavigating ? Icons.stop_circle : Icons.navigation,
                    ),
                    label: Text(
                      isNavigating ? 'Detener navegación' : 'Cómo llegar',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isNavigating
                          ? Colors.red
                          : Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _clearRoute,
                  color: Colors.grey[700],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteOptionChip(RouteOption option, int index) {
    final isSelected = index == selectedRouteOptionIndex;

    return InkWell(
      onTap: () => _selectRouteOption(index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.orange
                : Colors.orange.withValues(alpha: 0.35),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              option.label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${option.info.distanceText} · ${option.info.durationText}',
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteStepTile(RouteStep step) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.alt_route, size: 16, color: Colors.orange),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.instruction,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${step.distanceText} · ${step.durationText}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                ),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidePanelRestaurantCard(Restaurant restaurant, double distance) {
    final isSelected = selectedRestaurantId == restaurant.id;

    return Card(
      margin: EdgeInsets.zero,
      elevation: isSelected ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Colors.orange : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _selectRestaurant(restaurant),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      restaurant.imageUrl,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 72,
                          height: 72,
                          color: Colors.grey[300],
                          child: const Icon(Icons.restaurant),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          restaurant.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          restaurant.type,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange[700],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          restaurant.address,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text(
                    '${distance.toStringAsFixed(1)} km',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.star, size: 16, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text('${restaurant.rating}'),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => _selectRestaurant(restaurant),
                    icon: const Icon(Icons.navigation, size: 16),
                    label: const Text('Cómo llegar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomPanel() {
    final restaurantsToShow = _restaurantsForDisplay();

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
                color: Colors.grey[700],
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
                                        '${selectedRestaurant!.getDistanceInKm(userLocation!).toStringAsFixed(1)} km',
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
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Text(
                                    'Tu ubicación y la ruta se actualizan en tiempo real.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                    ),
                                  ),
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
                          isNavigating ? Icons.stop_circle : Icons.navigation,
                        ),
                        label: Text(
                          isNavigating
                              ? 'Detener navegación'
                              : 'Iniciar navegación',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isNavigating
                              ? Colors.red
                              : Colors.orange,
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
                            style: TextStyle(color: Colors.grey[700]),
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
    _locationSubscription?.cancel();
    mapController?.dispose();
    super.dispose();
  }
}
