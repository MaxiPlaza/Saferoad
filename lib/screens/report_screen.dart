import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saferoad/models/report.dart';
import 'package:saferoad/services/firestore_service.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _descriptionController = TextEditingController();
  String _selectedType = 'Accidente';
  int _selectedDangerLevel = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Reporte'),
        backgroundColor: const Color(0xFF0066CC),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedType,
              items: const [
                DropdownMenuItem(value: 'Accidente', child: Text('Accidente')),
                DropdownMenuItem(
                    value: 'Obra sin señalizar',
                    child: Text('Obra sin señalizar')),
                DropdownMenuItem(
                    value: 'Animal suelto', child: Text('Animal suelto')),
                DropdownMenuItem(
                    value: 'Semáforo roto', child: Text('Semáforo roto')),
                DropdownMenuItem(
                    value: 'Calle cortada', child: Text('Calle cortada')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Tipo de reporte',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _selectedDangerLevel,
              items: const [
                DropdownMenuItem(value: 1, child: Text('Bajo (Verde)')),
                DropdownMenuItem(value: 2, child: Text('Medio (Amarillo)')),
                DropdownMenuItem(value: 3, child: Text('Alto (Rojo)')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedDangerLevel = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Nivel de peligro',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
                border: OutlineInputBorder(),
                hintText: 'Describe lo que está sucediendo...',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitReport,
              child: const Text('Enviar Reporte'),
            ),
          ],
        ),
      ),
    );
  }

  void _submitReport() async {
    final firestoreService =
        Provider.of<FirestoreService>(context, listen: false);

    try {
      // Ubicación simulada (Buenos Aires)
      final location = Location(
        lat: -34.6037,
        lng: -58.3816,
        direccion: 'Ubicación simulada',
      );

      final report = Report(
        id: '',
        userId: firestoreService.currentUserId,
        tipo: _selectedType,
        nivelPeligro: _selectedDangerLevel,
        ubicacion: location,
        createdAt: DateTime.now(),
        activo: true,
        descripcion: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
      );

      await firestoreService.addReport(report);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reporte enviado correctamente')),
      );

      // Limpiar formulario
      _descriptionController.clear();
      setState(() {
        _selectedType = 'Accidente';
        _selectedDangerLevel = 1;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar reporte: $e')),
      );
    }
  }
}
