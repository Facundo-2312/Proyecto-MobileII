import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart'
    if (dart.library.html) 'package:foodfinder/google_maps_flutter_stub.dart';
import 'package:http/http.dart' as http;

class RoutePath {
  final List<LatLng> points;
  final RouteInfo info;
  final List<RouteOption> options;

  RoutePath({required this.points, required this.info, required this.options});
}

class RouteStep {
  final String instruction;
  final String distanceText;
  final String durationText;

  RouteStep({
    required this.instruction,
    required this.distanceText,
    required this.durationText,
  });
}

class RouteOption {
  final String label;
  final List<LatLng> points;
  final RouteInfo info;
  final List<RouteStep> steps;

  RouteOption({
    required this.label,
    required this.points,
    required this.info,
    required this.steps,
  });
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
    final fallbackOption = RouteOption(
      label: 'Ruta principal',
      points: fallbackPoints,
      info: fallbackInfo,
      steps: [
        RouteStep(
          instruction: 'Dirígete hacia tu destino',
          distanceText: fallbackInfo.distanceText,
          durationText: fallbackInfo.durationText,
        ),
      ],
    );

    try {
      final routeUri = _routingBaseUri.replace(
        path:
            '${_routingBaseUri.path}${start.longitude},${start.latitude};${end.longitude},${end.latitude}',
        queryParameters: const {
          'overview': 'full',
          'geometries': 'geojson',
          'alternatives': 'true',
          'steps': 'true',
        },
      );

      final response = await http
          .get(routeUri)
          .timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) {
        return RoutePath(
          points: fallbackPoints,
          info: fallbackInfo,
          options: [fallbackOption],
        );
      }

      final decoded = jsonDecode(response.body);
      final routes = decoded['routes'];

      if (routes is! List || routes.isEmpty) {
        return RoutePath(
          points: fallbackPoints,
          info: fallbackInfo,
          options: [fallbackOption],
        );
      }

      final options = <RouteOption>[];

      for (int index = 0; index < routes.length; index++) {
        final route = routes[index];
        if (route is! Map<String, dynamic>) {
          continue;
        }

        final points = _parseRoutePoints(route);
        if (points.length < 2) {
          continue;
        }

        final distanceKm =
            ((route['distance'] as num?)?.toDouble() ?? 0) / 1000;
        final estimatedMinutes =
            (((route['duration'] as num?)?.toDouble() ?? 0) / 60).round();
        final info = routeInfoFromMetrics(
          distanceKm: distanceKm > 0 ? distanceKm : fallbackInfo.distanceKm,
          estimatedMinutes: estimatedMinutes > 0
              ? estimatedMinutes
              : fallbackInfo.estimatedMinutes,
        );

        options.add(
          RouteOption(
            label: index == 0 ? 'Más rápida' : 'Alternativa ${index + 1}',
            points: points,
            info: info,
            steps: _parseRouteSteps(route, info),
          ),
        );
      }

      if (options.isEmpty) {
        return RoutePath(
          points: fallbackPoints,
          info: fallbackInfo,
          options: [fallbackOption],
        );
      }

      return RoutePath(
        points: options.first.points,
        info: options.first.info,
        options: options,
      );
    } on TimeoutException {
      return RoutePath(
        points: fallbackPoints,
        info: fallbackInfo,
        options: [fallbackOption],
      );
    } catch (_) {
      return RoutePath(
        points: fallbackPoints,
        info: fallbackInfo,
        options: [fallbackOption],
      );
    }
  }

  static List<LatLng> _parseRoutePoints(Map<String, dynamic> route) {
    final geometry = route['geometry'];
    if (geometry is! Map<String, dynamic>) {
      return const [];
    }

    final coordinates = geometry['coordinates'];
    if (coordinates is! List || coordinates.length < 2) {
      return const [];
    }

    return coordinates
        .whereType<List>()
        .where((coordinate) => coordinate.length >= 2)
        .map(
          (coordinate) => LatLng(
            (coordinate[1] as num).toDouble(),
            (coordinate[0] as num).toDouble(),
          ),
        )
        .toList();
  }

  static List<RouteStep> _parseRouteSteps(
    Map<String, dynamic> route,
    RouteInfo fallbackInfo,
  ) {
    final legs = route['legs'];
    if (legs is! List || legs.isEmpty) {
      return [
        RouteStep(
          instruction: 'Dirígete hacia tu destino',
          distanceText: fallbackInfo.distanceText,
          durationText: fallbackInfo.durationText,
        ),
      ];
    }

    final steps = <RouteStep>[];

    for (final leg in legs.whereType<Map<String, dynamic>>()) {
      final rawSteps = leg['steps'];
      if (rawSteps is! List) {
        continue;
      }

      for (final step in rawSteps.whereType<Map<String, dynamic>>()) {
        final distanceMeters = (step['distance'] as num?)?.toDouble() ?? 0;
        final durationSeconds = (step['duration'] as num?)?.toDouble() ?? 0;
        steps.add(
          RouteStep(
            instruction: _buildInstruction(step),
            distanceText: _formatDistance(distanceMeters / 1000),
            durationText: _formatDuration((durationSeconds / 60).round()),
          ),
        );
      }
    }

    return steps.isEmpty
        ? [
            RouteStep(
              instruction: 'Dirígete hacia tu destino',
              distanceText: fallbackInfo.distanceText,
              durationText: fallbackInfo.durationText,
            ),
          ]
        : steps.take(5).toList();
  }

  static String _buildInstruction(Map<String, dynamic> step) {
    final maneuver = step['maneuver'];
    final name = (step['name'] as String?)?.trim() ?? '';
    final maneuverType = maneuver is Map<String, dynamic>
        ? (maneuver['type'] as String?)?.trim() ?? ''
        : '';
    final modifier = maneuver is Map<String, dynamic>
        ? (maneuver['modifier'] as String?)?.trim() ?? ''
        : '';

    switch (maneuverType) {
      case 'depart':
        return name.isEmpty ? 'Sal desde tu ubicación' : 'Sal por $name';
      case 'arrive':
        return 'Llegarás a tu destino';
      case 'turn':
        final turnLabel = _translateModifier(modifier);
        return name.isEmpty ? 'Gira $turnLabel' : 'Gira $turnLabel hacia $name';
      case 'new name':
      case 'continue':
        return name.isEmpty ? 'Continúa recto' : 'Continúa por $name';
      case 'merge':
        return name.isEmpty ? 'Incorpórate a la vía' : 'Incorpórate a $name';
      case 'roundabout':
        return name.isEmpty ? 'Toma la rotonda' : 'Toma la rotonda hacia $name';
      default:
        return name.isEmpty ? 'Sigue el trayecto' : 'Sigue por $name';
    }
  }

  static String _translateModifier(String modifier) {
    switch (modifier) {
      case 'left':
        return 'a la izquierda';
      case 'right':
        return 'a la derecha';
      case 'slight left':
        return 'levemente a la izquierda';
      case 'slight right':
        return 'levemente a la derecha';
      case 'sharp left':
        return 'pronunciado a la izquierda';
      case 'sharp right':
        return 'pronunciado a la derecha';
      case 'straight':
        return 'recto';
      default:
        return 'por la vía indicada';
    }
  }

  static String _formatDistance(double distanceKm) {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()} m';
    }

    return '${distanceKm.toStringAsFixed(1)} km';
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
      final segmentDistance = calculateDistance(
        points[index],
        points[index + 1],
      );
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
