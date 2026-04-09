import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'app_constants.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();

  factory LocationService() {
    return _instance;
  }

  LocationService._internal();

  LatLng? _currentLocation;
  final bool _isListening = false;

  LatLng? get currentLocation => _currentLocation;
  bool get isListening => _isListening;

  /// Verifica y solicita permisos de ubicación
  Future<bool> checkAndRequestPermissions() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        await Geolocator.openLocationSettings();
        return false;
      }

      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (e) {
      // silently fail
      return false;
    }
  }

  /// Obtiene la ubicación actual del usuario
  Future<LatLng?> getCurrentLocation() async {
    try {
      final hasPermission = await checkAndRequestPermissions();
      if (!hasPermission) {
        _currentLocation = defaultLocation;
        return _currentLocation;
      }

      final position = await Geolocator.getCurrentPosition(
        timeLimit: const Duration(seconds: 5),
      );

      _currentLocation = LatLng(position.latitude, position.longitude);
      return _currentLocation;
    } catch (e) {
      _currentLocation = defaultLocation;
      return _currentLocation;
    }
  }

  /// Actualiza manualmente la ubicación
  Future<void> updateLocation() async {
    await getCurrentLocation();
  }

  /// Comprueba si el servicio de ubicación está habilitado
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Obtiene una ubicación aproximada (usa defaultLocation si no hay permiso)
  LatLng getLastKnownLocation() {
    return _currentLocation ?? defaultLocation;
  }
}
