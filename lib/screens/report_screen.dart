import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:saferoad/models/report.dart';
import 'package:saferoad/services/firestore_service.dart';
import 'package:saferoad/services/maps_service.dart';
import 'package:saferoad/services/storage_service.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  String _selectedType = 'Accidente';
  int _selectedDangerLevel = 1;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      _selectedImage = image;
    });
  }

  Future<void> _submitReport() async {
    if (_formKey.currentState!.validate()) {
      final firestoreService = Provider.of<FirestoreService>(context, listen: false);
      final storageService = Provider.of<StorageService>(context, listen: false);
      final mapsService = Provider.of<MapsService>(context, listen: false);

      try {
        // Obtener ubicación actual
        final location = await mapsService.getCurrentLocation();
        
        // Subir imagen si existe
        String? imageUrl;
        if (_selectedImage != null) {
          imageUrl = await storageService.uploadReportImage(_selectedImage!);
        }

        // Crear reporte
        final report = Report(
          id: '', // Se generará automáticamente
          userId: firestoreService.currentUserId,
          tipo: _selectedType,
          nivelPeligro: _selectedDangerLevel,
          ubicacion: loc.Location(
            lat: location.latitude,
            lng: location.longitude,
          ),
          fotoUrl: imageUrl,
          createdAt: DateTime.now(),
          activo: true,
        );

        await firestoreService.addReport(report);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reporte enviado correctamente')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar reporte: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Reporte')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedType,
                items: const [
                  DropdownMenuItem(value: 'Accidente', child: Text('Accidente')),
                  DropdownMenuItem(value: 'Obra sin señalizar', child: Text('Obra sin señalizar')),
                  DropdownMenuItem(value: 'Animal suelto', child: Text('Animal suelto')),
                  DropdownMenuItem(value: 'Semáforo roto', child: Text('Semáforo roto')),
                  DropdownMenuItem(value: 'Calle cortada', child: Text('Calle cortada')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Tipo de reporte'),
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
                decoration: const InputDecoration(labelText: 'Nivel de peligro'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción (opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              _selectedImage == null
                  ? ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Tomar Foto'),
                    )
                  : Column(
                      children: [
                        Image.file(
                          File(_selectedImage!.path),
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                        TextButton(
                          onPressed: _pickImage,
                          child: const Text('Cambiar Foto'),
                        ),
                      ],
                    ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitReport,
                child: const Text('Enviar Reporte'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}