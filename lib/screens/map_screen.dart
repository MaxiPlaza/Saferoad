import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:saferoad/models/report.dart';
import 'package:saferoad/models/traffic_light.dart';
import 'package:saferoad/services/maps_service.dart';
import 'package:saferoad/services/notification_service.dart';
import 'package:saferoad/screens/report_screen.dart';
import 'package:saferoad/screens/profile_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  final Map<String, Marker> _markers = {};
  final Map<String, Circle> _circles = {};
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadMarkers();
    _setupNotifications();
  }

  void _loadMarkers() async {
    final mapsService = Provider.of<MapsService>(context, listen: false);
    
    // Cargar reportes
    final reports = await mapsService.getActiveReports();
    for (Report report in reports) {
      final marker = Marker(
        markerId: MarkerId('report_${report.id}'),
        position: LatLng(report.ubicacion.lat, report.ubicacion.lng),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          _getMarkerHue(report.nivelPeligro),
        ),
        infoWindow: InfoWindow(
          title: report.tipo,
          snippet: 'Nivel de peligro: ${report.nivelPeligro}',
        ),
      );
      _markers[marker.markerId.value] = marker;

      // Agregar círculo de peligro
      final circle = Circle(
        circleId: CircleId('circle_${report.id}'),
        center: LatLng(report.ubicacion.lat, report.ubicacion.lng),
        radius: report.nivelPeligro * 100, // Radio proporcional al peligro
        fillColor: report.colorPeligro.withOpacity(0.2),
        strokeColor: report.colorPeligro,
        strokeWidth: 2,
      );
      _circles[circle.circleId.value] = circle;
    }

    // Cargar semáforos
    final trafficLights = await mapsService.getTrafficLights();
    for (TrafficLight light in trafficLights) {
      final marker = Marker(
        markerId: MarkerId('light_${light.id}'),
        position: LatLng(light.ubicacion.lat, light.ubicacion.lng),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          _getLightHue(light.estado),
        ),
        infoWindow: InfoWindow(
          title: 'Semáforo',
          snippet: 'Estado: ${light.estado}',
        ),
      );
      _markers[marker.markerId.value] = marker;
    }

    setState(() {});
  }

  double _getMarkerHue(int nivelPeligro) {
    switch (nivelPeligro) {
      case 3: return BitmapDescriptor.hueRed;
      case 2: return BitmapDescriptor.hueOrange;
      case 1: return BitmapDescriptor.hueGreen;
      default: return BitmapDescriptor.hueBlue;
    }
  }

  double _getLightHue(String estado) {
    switch (estado) {
      case 'rojo': return BitmapDescriptor.hueRed;
      case 'amarillo': return BitmapDescriptor.hueYellow;
      case 'verde': return BitmapDescriptor.hueGreen;
      default: return BitmapDescriptor.hueBlue;
    }
  }

  void _setupNotifications() {
    final notificationService = Provider.of<NotificationService>(context, listen: false);
    notificationService.initialize();
    notificationService.setupProximityAlerts();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onCruceSeguroPressed() {
    _showCruceSeguroDialog();
  }

  void _showCruceSeguroDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cruzar Seguro'),
          content: const Text('¿Desea solicitar un cruce seguro? El semáforo más cercano se pondrá en rojo para los vehículos.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                _requestCrossing();
                Navigator.pop(context);
              },
              child: const Text('Solicitar'),
            ),
          ],
        );
      },
    );
  }

  void _requestCrossing() async {
    final mapsService = Provider.of<MapsService>(context, listen: false);
    try {
      await mapsService.requestSafeCrossing();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitud enviada. Espere la confirmación.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SafeRoad'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Navegar a notificaciones
            },
          ),
        ],
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: const CameraPosition(
          target: LatLng(-34.6037, -58.3816), // Buenos Aires por defecto
          zoom: 14,
        ),
        markers: _markers.values.toSet(),
        circles: _circles.values.toSet(),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onCruceSeguroPressed,
        child: const Icon(Icons.directions_walk),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ReportScreen()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Mapa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report),
            label: 'Reportar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}