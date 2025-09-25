import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:saferoad/models/report.dart';
import 'package:saferoad/models/traffic_light.dart';
import 'package:saferoad/models/location.dart' as loc;

class MapsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Los servicios de ubicación están desactivados.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Los permisos de ubicación fueron denegados.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Los permisos de ubicación fueron denegados permanentemente.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<List<Report>> getActiveReports() async {
    final snapshot = await _firestore
        .collection('reports')
        .where('activo', isEqualTo: true)
        .get();

    return snapshot.docs
        .map((doc) => Report.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<List<TrafficLight>> getTrafficLights() async {
    final snapshot = await _firestore.collection('traffic_lights').get();

    return snapshot.docs
        .map((doc) => TrafficLight.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> requestSafeCrossing() async {
    final position = await getCurrentLocation();
    
    // Encontrar semáforo más cercano
    final lights = await getTrafficLights();
    TrafficLight? closestLight;
    double minDistance = double.maxFinite;

    for (final light in lights) {
      final distance = _calculateDistance(
        position.latitude,
        position.longitude,
        light.ubicacion.lat,
        light.ubicacion.lng,
      );

      if (distance < minDistance) {
        minDistance = distance;
        closestLight = light;
      }
    }

    if (closestLight != null && minDistance < 100) { // 100 metros
      await _firestore.collection('cross_requests').add({
        'userId': 'current_user_id', // Debe obtenerse del auth
        'semaforoId': closestLight.id,
        'timestamp': Timestamp.now(),
        'estado': 'pendiente',
      });
    } else {
      throw Exception('No hay semáforos cercanos');
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371e3; // metros
    final lat1Rad = lat1 * pi / 180;
    final lat2Rad = lat2 * pi / 180;
    final deltaLat = (lat2 - lat1) * pi / 180;
    final deltaLon = (lon2 - lon1) * pi / 180;

    final a = sin(deltaLat / 2) * sin(deltaLat / 2) +
        cos(lat1Rad) * cos(lat2Rad) *
        sin(deltaLon / 2) * sin(deltaLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }
}