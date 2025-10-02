import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Report {
  final String id;
  final String userId;
  final String tipo;
  final int nivelPeligro;
  final Location ubicacion;
  final DateTime createdAt;
  final bool activo;
  final String? descripcion;

  Report({
    required this.id,
    required this.userId,
    required this.tipo,
    required this.nivelPeligro,
    required this.ubicacion,
    required this.createdAt,
    required this.activo,
    this.descripcion,
  });

  factory Report.fromMap(Map<String, dynamic> data, String id) {
    return Report(
      id: id,
      userId: data['userId'] ?? '',
      tipo: data['tipo'] ?? '',
      nivelPeligro: data['nivelPeligro'] ?? 1,
      ubicacion: Location.fromMap(data['ubicacion'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      activo: data['activo'] ?? true,
      descripcion: data['descripcion'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'tipo': tipo,
      'nivelPeligro': nivelPeligro,
      'ubicacion': ubicacion.toMap(),
      'createdAt': Timestamp.fromDate(createdAt),
      'activo': activo,
      'descripcion': descripcion,
    };
  }

  Color get colorPeligro {
    switch (nivelPeligro) {
      case 3:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 1:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String get textoPeligro {
    switch (nivelPeligro) {
      case 3:
        return 'ALTO PELIGRO';
      case 2:
        return 'PELIGRO MEDIO';
      case 1:
        return 'PELIGRO BAJO';
      default:
        return 'INFORMACIÓN';
    }
  }
}

class Location {
  final double lat;
  final double lng;
  final String? direccion;

  Location({required this.lat, required this.lng, this.direccion});

  factory Location.fromMap(Map<String, dynamic> data) {
    return Location(
      lat: data['lat'] ?? 0.0,
      lng: data['lng'] ?? 0.0,
      direccion: data['direccion'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lat': lat,
      'lng': lng,
      'direccion': direccion,
    };
  }
}
