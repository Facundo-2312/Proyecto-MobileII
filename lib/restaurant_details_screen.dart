import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'
    if (dart.library.html) 'package:foodfinder/google_maps_flutter_stub.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart' as latlng;
import 'package:url_launcher/url_launcher.dart';
import 'restaurant_model.dart';
import 'location_service.dart';

class RestaurantDetailsScreen extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantDetailsScreen({super.key, required this.restaurant});

  @override
  State<RestaurantDetailsScreen> createState() =>
      _RestaurantDetailsScreenState();
}

class _RestaurantDetailsScreenState extends State<RestaurantDetailsScreen> {
  GoogleMapController? mapController;
  final locationService = LocationService();

  bool isSimulating = false;
  List<LatLng> routePoints = [];
  Set<Polyline> polylines = {};
  LatLng? simulationLocation;
  LatLng? userLocation;

  @override
  void initState() {
    super.initState();
    _loadUserLocation();
  }

  Future<void> _loadUserLocation() async {
    final location = await locationService.getCurrentLocation();
    if (mounted) {
      setState(() {
        userLocation = location;
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _prepareRoute() {
    final start = userLocation ?? locationService.getLastKnownLocation();
    routePoints = _buildRoutePoints(start, widget.restaurant.location);
    polylines = {
      Polyline(
        polylineId: const PolylineId('route'),
        color: Colors.orange,
        width: 5,
        points: routePoints,
      ),
    };
    simulationLocation = start;
  }

  List<LatLng> _buildRoutePoints(
    LatLng start,
    LatLng end, {
    int segments = 12,
  }) {
    return List<LatLng>.generate(segments + 1, (index) {
      final t = index / segments;
      return LatLng(
        start.latitude + (end.latitude - start.latitude) * t,
        start.longitude + (end.longitude - start.longitude) * t,
      );
    });
  }

  Future<void> _startRouteSimulation() async {
    if (isSimulating) return;

    _prepareRoute();

    if (routePoints.isEmpty) {
      return;
    }

    setState(() {
      isSimulating = true;
    });

    for (final point in routePoints) {
      if (!mounted) return;
      if (mapController != null) {
        await mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: point, zoom: 15),
          ),
        );
      }
      if (!mounted) return;
      setState(() {
        simulationLocation = point;
      });
      await Future.delayed(const Duration(milliseconds: 450));
    }

    if (!mounted) return;
    setState(() {
      isSimulating = false;
    });
  }

  Future<void> _callRestaurant() async {
    final sanitizedNumber = widget.restaurant.phoneNumber.replaceAll(
      RegExp(r'[^0-9+]'),
      '',
    );
    final phoneUri = Uri(scheme: 'tel', path: sanitizedNumber);

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'No se pudo abrir el teléfono para ${widget.restaurant.phoneNumber}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.restaurant.name),
        elevation: 0,
        backgroundColor: Colors.orange,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 800;
          final currentLocation =
              simulationLocation ??
              userLocation ??
              locationService.getLastKnownLocation();
          final distance = widget.restaurant.getDistanceInKm(currentLocation);

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeader(distance),
                              const SizedBox(height: 24),
                              _buildInfoCards(distance),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(child: _buildMapCard(currentLocation, true)),
                      ],
                    )
                  else ...[
                    _buildHeader(distance),
                    const SizedBox(height: 24),
                    _buildInfoCards(distance),
                    const SizedBox(height: 24),
                    _buildMapCard(currentLocation, false),
                  ],
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(double distance) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: 250,
          color: Colors.grey[300],
          child: Image.network(
            widget.restaurant.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[300],
                child: const Icon(Icons.restaurant, size: 80),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.restaurant.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.restaurant.type,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.orange[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 28),
                const SizedBox(height: 4),
                Text(
                  '${widget.restaurant.rating}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Descripción',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          widget.restaurant.description,
          style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildInfoCards(double distance) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoCard(
          icon: Icons.location_on,
          title: 'Ubicación',
          subtitle: widget.restaurant.address,
          color: Colors.red,
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          icon: Icons.phone,
          title: 'Teléfono',
          subtitle: widget.restaurant.phoneNumber,
          color: Colors.blue,
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          icon: Icons.directions,
          title: 'Distancia',
          subtitle: '${distance.toStringAsFixed(2)} km de tu ubicación',
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildMapCard(LatLng currentLocation, bool isWide) {
    if (kIsWeb) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: isWide ? 440 : 300,
          child: fm.FlutterMap(
            options: fm.MapOptions(
              initialCenter: latlng.LatLng(
                widget.restaurant.location.latitude,
                widget.restaurant.location.longitude,
              ),
              initialZoom: 15,
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
                      widget.restaurant.location.latitude,
                      widget.restaurant.location.longitude,
                    ),
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 36,
                    ),
                  ),
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
                ],
              ),
            ],
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: isWide ? 440 : 300,
        child: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: widget.restaurant.location,
            zoom: 15,
          ),
          markers: {
            Marker(
              markerId: MarkerId(widget.restaurant.id),
              position: widget.restaurant.location,
              infoWindow: InfoWindow(
                title: widget.restaurant.name,
                snippet: widget.restaurant.type,
              ),
            ),
            Marker(
              markerId: const MarkerId('user'),
              position: currentLocation,
              infoWindow: const InfoWindow(title: 'Tu ubicación'),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueBlue,
              ),
            ),
          },
          polylines: polylines,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        SizedBox(
          width: 260,
          child: ElevatedButton.icon(
            onPressed: _startRouteSimulation,
            icon: const Icon(Icons.directions_walk),
            label: Text(isSimulating ? 'Simulando...' : 'Simular trayecto'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        SizedBox(
          width: 220,
          child: ElevatedButton.icon(
            onPressed: _callRestaurant,
            icon: const Icon(Icons.phone),
            label: const Text('Llamar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
