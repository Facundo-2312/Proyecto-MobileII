import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart'
    if (dart.library.html) 'package:foodfinder/google_maps_flutter_stub.dart';
import 'package:http/http.dart' as http;

class RoutePath {
  final List<LatLng> points;
  final RouteInfo info;

  RoutePath({required this.points, required this.info});
}

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
  static final Random _random = Random();
  static final Uri _routingBaseUri = Uri.parse(
    'https://router.project-osrm.org/route/v1/driving/',
  );

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

  static RouteInfo routeInfoFromMetrics({
    required double distanceKm,
    required int estimatedMinutes,
  }) {
    return RouteInfo(
      distanceKm: distanceKm,
      estimatedMinutes: estimatedMinutes,
      durationText: _formatDuration(estimatedMinutes),
      distanceText: '${distanceKm.toStringAsFixed(1)} km',
    );
  }

  static Future<RoutePath> fetchRoute(LatLng start, LatLng end) async {
    final fallbackPoints = generateRoutePoints(start, end);
    final fallbackInfo = getRouteInfo(start, end);

    try {
      final routeUri = _routingBaseUri.replace(
        path:
            '${_routingBaseUri.path}${start.longitude},${start.latitude};${end.longitude},${end.latitude}',
        queryParameters: const {
          'overview': 'full',
          'geometries': 'geojson',
          'alternatives': 'false',
          'steps': 'false',
        },
      );

      final response = await http.get(routeUri).timeout(
        const Duration(seconds: 8),
      );

      if (response.statusCode != 200) {
        return RoutePath(points: fallbackPoints, info: fallbackInfo);
      }

      final decoded = jsonDecode(response.body);
      final routes = decoded['routes'];

      if (routes is! List || routes.isEmpty) {
        return RoutePath(points: fallbackPoints, info: fallbackInfo);
      }

      final firstRoute = routes.first;
      final geometry = firstRoute['geometry'];
      final coordinates = geometry['coordinates'];

      if (coordinates is! List || coordinates.length < 2) {
        return RoutePath(points: fallbackPoints, info: fallbackInfo);
      }

      final points = coordinates
          .whereType<List>()
          .where((coordinate) => coordinate.length >= 2)
          .map(
            (coordinate) => LatLng(
              (coordinate[1] as num).toDouble(),
              (coordinate[0] as num).toDouble(),
            ),
          )
          .toList();

      if (points.length < 2) {
        return RoutePath(points: fallbackPoints, info: fallbackInfo);
      }

      final distanceKm = ((firstRoute['distance'] as num?)?.toDouble() ?? 0) /
          1000;
      final estimatedMinutes =
          (((firstRoute['duration'] as num?)?.toDouble() ?? 0) / 60).round();

      return RoutePath(
        points: points,
        info: routeInfoFromMetrics(
          distanceKm: distanceKm > 0 ? distanceKm : fallbackInfo.distanceKm,
          estimatedMinutes: estimatedMinutes > 0
              ? estimatedMinutes
              : fallbackInfo.estimatedMinutes,
        ),
      );
    } on TimeoutException {
      return RoutePath(points: fallbackPoints, info: fallbackInfo);
    } catch (_) {
      return RoutePath(points: fallbackPoints, info: fallbackInfo);
    }
  }

  /// Genera puntos intermedios para simular una ruta con GPS
  static List<LatLng> generateRoutePoints(
    LatLng start,
    LatLng end, {
    int segmentSteps = 10,
  }) {
    final points = <LatLng>[];

    for (int i = 0; i <= segmentSteps; i++) {
      final t = i / segmentSteps;

      // Interpolación lineal con pequeña variación para simular caminos reales
      final lat = start.latitude + (end.latitude - start.latitude) * t;
      final lng = start.longitude + (end.longitude - start.longitude) * t;

      // Agregar pequeña variación para que parezca más realista
      final variation = i > 0 && i < segmentSteps
          ? _random.nextDouble() * 0.0002
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

  static LatLng interpolateAlongRoute(List<LatLng> points, double progress) {
    if (points.isEmpty) {
      throw ArgumentError('Route points cannot be empty');
    }

    if (points.length == 1) {
      return points.first;
    }

    final clampedProgress = progress.clamp(0.0, 1.0);
    if (clampedProgress == 0.0) return points.first;
    if (clampedProgress == 1.0) return points.last;

    final segmentDistances = <double>[];
    double totalDistance = 0;

    for (int index = 0; index < points.length - 1; index++) {
      final segmentDistance = calculateDistance(points[index], points[index + 1]);
      segmentDistances.add(segmentDistance);
      totalDistance += segmentDistance;
    }

    if (totalDistance == 0) {
      return points.first;
    }

    final targetDistance = totalDistance * clampedProgress;
    double traversedDistance = 0;

    for (int index = 0; index < segmentDistances.length; index++) {
      final segmentDistance = segmentDistances[index];
      final nextDistance = traversedDistance + segmentDistance;

      if (targetDistance <= nextDistance) {
        final segmentProgress = segmentDistance == 0
            ? 0.0
            : (targetDistance - traversedDistance) / segmentDistance;
        final start = points[index];
        final end = points[index + 1];

        return LatLng(
          start.latitude + (end.latitude - start.latitude) * segmentProgress,
          start.longitude + (end.longitude - start.longitude) * segmentProgress,
        );
      }

      traversedDistance = nextDistance;
    }

    return points.last;
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
}
