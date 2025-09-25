class Report {
  final String id;
  final String userId;
  final String tipo;
  final int nivelPeligro;
  final Location ubicacion;
  final String? fotoUrl;
  final DateTime createdAt;
  final bool activo;

  Report({
    required this.id,
    required this.userId,
    required this.tipo,
    required this.nivelPeligro,
    required this.ubicacion,
    this.fotoUrl,
    required this.createdAt,
    required this.activo,
  });

  factory Report.fromMap(Map<String, dynamic> data, String id) {
    return Report(
      id: id,
      userId: data['userId'] ?? '',
      tipo: data['tipo'] ?? '',
      nivelPeligro: data['nivelPeligro'] ?? 1,
      ubicacion: Location.fromMap(data['ubicacion'] ?? {}),
      fotoUrl: data['fotoUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      activo: data['activo'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'tipo': tipo,
      'nivelPeligro': nivelPeligro,
      'ubicacion': ubicacion.toMap(),
      'fotoUrl': fotoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'activo': activo,
    };
  }

  Color get colorPeligro {
    switch (nivelPeligro) {
      case 3: return Colors.red;
      case 2: return Colors.orange;
      case 1: return Colors.green;
      default: return Colors.grey;
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