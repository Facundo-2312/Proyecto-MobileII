import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'restaurant_model.dart';
import 'location_service.dart';
import 'restaurant_service.dart';
import 'restaurant_marker_popup.dart';
import 'restaurant_list_widget.dart';
import 'restaurant_details_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  final locationService = LocationService();
  final restaurantService = RestaurantService();

  LatLng? userLocation;
  List<Restaurant> nearbyRestaurants = [];
  Set<Marker> markers = {};
  bool isLoading = true;
  String? selectedRestaurantId;
  bool showList = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await restaurantService.initialize();
      await _updateLocation();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateLocation() async {
    final location = await locationService.getCurrentLocation();
    if (location != null && mounted) {
      setState(() {
        userLocation = location;
        nearbyRestaurants =
            restaurantService.getNearbyRestaurants(location);
        _updateMarkers();
        isLoading = false;
      });

      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: location,
            zoom: 14,
          ),
        ),
      );
        }
  }

  void _updateMarkers() {
    if (userLocation == null) return;

    final newMarkers = <Marker>{};

    newMarkers.add(
      Marker(
        markerId: const MarkerId('user_location'),
        position: userLocation!,
        infoWindow: const InfoWindow(title: 'Tu ubicación'),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueBlue,
        ),
      ),
    );

    for (var restaurant in nearbyRestaurants) {
      final distance = restaurant.getDistanceInKm(userLocation!);

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

    setState(() {
      markers = newMarkers;
    });
  }

  void _showRestaurantPopup(Restaurant restaurant, double distance) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: RestaurantMarkerPopup(
          restaurant: restaurant,
          distance: distance,
          onTap: () {
            Navigator.of(context).pop();
            _navigateToDetails(restaurant);
          },
        ),
      ),
    );
  }

  void _navigateToDetails(Restaurant restaurant) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RestaurantDetailsScreen(
          restaurant: restaurant,
        ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (userLocation != null) {
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: userLocation!,
            zoom: 14,
          ),
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
            icon: Icon(
              showList ? Icons.map : Icons.list,
            ),
            onPressed: () {
              setState(() => showList = !showList);
            },
            tooltip: 'Cambiar vista',
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.orange,
              ),
            )
          : showList
              ? RestaurantListWidget(
                  restaurants: nearbyRestaurants,
                  onRefresh: _updateLocation,
                  onTap: _navigateToDetails,
                )
              : GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: userLocation ??
                        const LatLng(40.4168, -3.7038),
                    zoom: 14,
                  ),
                  markers: markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                ),
      floatingActionButton: !showList && !isLoading
          ? FloatingActionButton(
              onPressed: _updateLocation,
              backgroundColor: Colors.orange,
              child: const Icon(Icons.my_location),
            )
          : null,
      bottomSheet: !showList && !isLoading ? _buildBottomPanel() : null,
    );
  }

  Widget _buildBottomPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(20)),
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
                Text(
                  'Restaurantes cercanos (${nearbyRestaurants.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 180,
                  child: nearbyRestaurants.isEmpty
                      ? Center(
                          child: Text(
                            'No hay restaurantes cercanos',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: nearbyRestaurants.length,
                          itemBuilder: (context, index) {
                            final restaurant =
                                nearbyRestaurants[index];
                            final distance = restaurant
                                .getDistanceInKm(userLocation!);

                            return _buildRestaurantCard(
                              restaurant,
                              distance,
                            );
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

  Widget _buildRestaurantCard(
      Restaurant restaurant, double distance) {
    return GestureDetector(
      onTap: () => _navigateToDetails(restaurant),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey[300]!,
          ),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(11)),
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
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
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
                              style: const TextStyle(
                                fontSize: 10,
                              ),
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
    mapController.dispose();
    super.dispose();
  }
}
