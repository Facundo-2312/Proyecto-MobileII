import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'
    if (dart.library.html) 'package:foodfinder/google_maps_flutter_stub.dart';
import 'dart:async';
import 'app_constants.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  static const LocationSettings _locationSettings = LocationSettings(
    accuracy: LocationAccuracy.best,
    distanceFilter: 10,
  );

  factory LocationService() {
    return _instance;
  }

  LocationService._internal();

  LatLng? _currentLocation;
  Stream<LatLng>? _locationStream;

  LatLng? get currentLocation => _currentLocation;
  bool get isListening => _locationStream != null;

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
        desiredAccuracy: LocationAccuracy.best,
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

  Stream<LatLng> getLocationStream() {
    final existingStream = _locationStream;
    if (existingStream != null) {
      return existingStream;
    }

    final stream = Stream.fromFuture(checkAndRequestPermissions()).asyncExpand((
      hasPermission,
    ) {
      if (!hasPermission) {
        _currentLocation = defaultLocation;
        return Stream<LatLng>.value(defaultLocation);
      }

      return Geolocator.getPositionStream(
        locationSettings: _locationSettings,
      ).map((position) {
        final nextLocation = LatLng(position.latitude, position.longitude);
        _currentLocation = nextLocation;
        return nextLocation;
      });
    }).asBroadcastStream();

    _locationStream = stream;
    return stream;
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
