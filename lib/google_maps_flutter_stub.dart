import 'package:flutter/material.dart';

class LatLng {
  final double latitude;
  final double longitude;
  const LatLng(this.latitude, this.longitude);
}

class CameraPosition {
  final LatLng target;
  final double zoom;
  const CameraPosition({required this.target, required this.zoom});
}

class CameraUpdate {
  const CameraUpdate._();

  static CameraUpdate newCameraPosition(CameraPosition position) =>
      const CameraUpdate._();
  static CameraUpdate newLatLngBounds(LatLngBounds bounds, double padding) =>
      const CameraUpdate._();
}

class LatLngBounds {
  final LatLng southwest;
  final LatLng northeast;
  const LatLngBounds({required this.southwest, required this.northeast});
}

class BitmapDescriptor {
  const BitmapDescriptor();
  static BitmapDescriptor defaultMarkerWithHue(double hue) =>
      const BitmapDescriptor();
  static const double hueBlue = 210.0;
  static const double hueOrange = 30.0;
}

class InfoWindow {
  final String? title;
  final String? snippet;
  const InfoWindow({this.title, this.snippet});
}

class MarkerId {
  final String value;
  const MarkerId(this.value);
}

class Marker {
  final MarkerId markerId;
  final LatLng position;
  final BitmapDescriptor? icon;
  final InfoWindow? infoWindow;
  final VoidCallback? onTap;
  const Marker({
    required this.markerId,
    required this.position,
    this.icon,
    this.infoWindow,
    this.onTap,
  });
}

class PolylineId {
  final String value;
  const PolylineId(this.value);
}

class Polyline {
  final PolylineId polylineId;
  final Color color;
  final int width;
  final List<LatLng> points;
  const Polyline({
    required this.polylineId,
    required this.color,
    required this.width,
    required this.points,
  });
}

class GoogleMapController {
  Future<void> animateCamera(CameraUpdate update) async {}
  void dispose() {}
}

class GoogleMap extends StatelessWidget {
  final void Function(GoogleMapController controller)? onMapCreated;
  final CameraPosition initialCameraPosition;
  final Set<Marker>? markers;
  final Set<Polyline>? polylines;
  final bool? myLocationEnabled;
  final bool? myLocationButtonEnabled;
  final bool? zoomControlsEnabled;

  const GoogleMap({
    super.key,
    this.onMapCreated,
    required this.initialCameraPosition,
    this.markers,
    this.polylines,
    this.myLocationEnabled,
    this.myLocationButtonEnabled,
    this.zoomControlsEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
