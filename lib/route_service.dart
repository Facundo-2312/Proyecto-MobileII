import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart'
    if (dart.library.html) 'package:foodfinder/google_maps_flutter_stub.dart';

class RouteInfo {
  final double distanceKm;
  final int estimatedMinutes;
  final String durationText;
  final String distanceText;

  RouteInfo({
    required this.distanceKm,
    required this.estimatedMinutes,
    required this.durationText,
    required this.distanceText,
  });
}

class RouteService {
  // Velocidad promedio simulada en km/h
  static const double averageSpeed = 40.0;

  /// Calcula la distancia entre dos puntos usando la fórmula de Haversine
  /// Retorna la distancia en kilómetros
  static double calculateDistance(LatLng start, LatLng end) {
    const earthRadiusKm = 6371.0;

    final dLat = _toRadians(end.latitude - start.latitude);
    final dLon = _toRadians(end.longitude - start.longitude);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(start.latitude)) *
            cos(_toRadians(end.latitude)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  /// Calcula la información completa de la ruta
  static RouteInfo getRouteInfo(LatLng start, LatLng end) {
    final distanceKm = calculateDistance(start, end);

    // Ajustar distancia: sumar ~30% por caminos curvilíneos
    final adjustedDistanceKm = distanceKm * 1.3;

    // Calcular tiempo estimado en minutos
    final estimatedMinutes = ((adjustedDistanceKm / averageSpeed) * 60).round();

    final durationText = _formatDuration(estimatedMinutes);
    final distanceText = '${adjustedDistanceKm.toStringAsFixed(1)} km';

    return RouteInfo(
      distanceKm: adjustedDistanceKm,
      estimatedMinutes: estimatedMinutes,
      durationText: durationText,
      distanceText: distanceText,
    );
  }

  /// Genera puntos intermedios para simular una ruta con GPS
  static List<LatLng> generateRoutePoints(
    LatLng start,
    LatLng end, {
    int segmentSteps = 10,
  }) {
    final points = <LatLng>[];
    random = Random();

    for (int i = 0; i <= segmentSteps; i++) {
      final t = i / segmentSteps;

      // Interpolación lineal con pequeña variación para simular caminos reales
      final lat = start.latitude + (end.latitude - start.latitude) * t;
      final lng = start.longitude + (end.longitude - start.longitude) * t;

      // Agregar pequeña variación para que parezca más realista
      final variation = i > 0 && i < segmentSteps
          ? random.nextDouble() * 0.0002
          : 0;

      points.add(LatLng(lat + variation, lng + variation));
    }

    return points;
  }

  /// Interpola un punto entre start y end basado en el progreso (0.0 a 1.0)
  static LatLng interpolatePosition(LatLng start, LatLng end, double progress) {
    progress = progress.clamp(0.0, 1.0);

    return LatLng(
      start.latitude + (end.latitude - start.latitude) * progress,
      start.longitude + (end.longitude - start.longitude) * progress,
    );
  }

  /// Convierte grados a radianes
  static double _toRadians(double degrees) => degrees * pi / 180.0;

  /// Formatea la duración en minutos a texto legible
  static String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    } else {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      if (mins == 0) {
        return '${hours}h';
      } else {
        return '${hours}h ${mins}min';
      }
    }
  }

  static late Random random;
}
