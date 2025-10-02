import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saferoad/screens/report_screen.dart';
import 'package:saferoad/screens/profile_screen.dart';
import 'package:saferoad/services/firestore_service.dart';
import 'package:saferoad/models/report.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  int _currentIndex = 0;
  List<Report> _reports = [];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  void _loadReports() async {
    final firestoreService =
        Provider.of<FirestoreService>(context, listen: false);
    final reports = await firestoreService.getActiveReports();
    setState(() {
      _reports = reports;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SafeRoad'),
        backgroundColor: const Color(0xFF0066CC),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReports,
          ),
        ],
      ),
      body: _buildCurrentScreen(),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: _showCruceSeguroDialog,
              child: const Icon(Icons.directions_walk),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
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

  Widget _buildCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return _buildMapScreen();
      case 1:
        return const ReportScreen();
      case 2:
        return const ProfileScreen();
      default:
        return _buildMapScreen();
    }
  }

  Widget _buildMapScreen() {
    return Column(
      children: [
        // Mapa simulado
        Container(
          height: 300,
          color: Colors.grey[200],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.map, size: 50, color: Colors.grey),
                const SizedBox(height: 10),
                const Text('Mapa en Desarrollo'),
                const SizedBox(height: 5),
                Text('${_reports.length} reportes activos'),
              ],
            ),
          ),
        ),

        // Lista de reportes
        Expanded(
          child: _reports.isEmpty
              ? const Center(
                  child: Text('No hay reportes activos'),
                )
              : ListView.builder(
                  itemCount: _reports.length,
                  itemBuilder: (context, index) {
                    final report = _reports[index];
                    return _buildReportCard(report);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildReportCard(Report report) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        leading: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: report.colorPeligro,
            shape: BoxShape.circle,
          ),
        ),
        title: Text(report.tipo),
        subtitle: Text(report.descripcion ?? 'Sin descripción'),
        trailing: Text(report.textoPeligro),
      ),
    );
  }

  void _showCruceSeguroDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cruzar Seguro'),
          content: const Text('¿Desea solicitar un cruce seguro?'),
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
    final firestoreService =
        Provider.of<FirestoreService>(context, listen: false);
    try {
      await firestoreService.addCrossRequest('semaforo_simulado');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Solicitud enviada. Espere la confirmación.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
