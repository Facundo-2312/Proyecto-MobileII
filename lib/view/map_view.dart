import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import '../viewmodel/restaurant_viewmodel.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final viewModel = RestaurantViewModel();
  LatLng? userLocation;

  @override
  void initState() {
    super.initState();
    getLocation();
  }

  Future<void> getLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied) return;

    final position = await Geolocator.getCurrentPosition();

    setState(() {
      userLocation = LatLng(position.latitude, position.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    final restaurants = viewModel.getRestaurants();

    if (userLocation == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Mapa")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Mapa")),

      body: FlutterMap(
        options: MapOptions(
          initialCenter: userLocation!,
          initialZoom: 15,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.foodfinder',
          ),

          // 📍 Restaurantes
          MarkerLayer(
            markers: [
              ...restaurants.map((r) => Marker(
                    point: LatLng(r.lat, r.lng),
                    width: 60,
                    height: 60,
                    child: const Icon(Icons.location_on,
                        color: Colors.red, size: 30),
                  )),

              // 🔵 Usuario
              Marker(
                point: userLocation!,
                width: 60,
                height: 60,
                child: const Icon(Icons.person_pin_circle,
                    color: Colors.blue, size: 35),
              ),
            ],
          ),
        ],
      ),

      // 🔘 Botón centrar
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await getLocation();
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }
}