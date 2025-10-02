import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saferoad/services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _sonido = true;
  bool _textoGrande = false;
  bool _vibracion = true;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: const Color(0xFF0066CC),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Información del Usuario',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Email: ${user?.email ?? "No disponible"}'),
                  Text('Estado: Activo'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Configuración de Accesibilidad',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: const Text('Sonido'),
                    value: _sonido,
                    onChanged: (value) {
                      setState(() {
                        _sonido = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Texto Grande'),
                    value: _textoGrande,
                    onChanged: (value) {
                      setState(() {
                        _textoGrande = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Vibración'),
                    value: _vibracion,
                    onChanged: (value) {
                      setState(() {
                        _vibracion = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Apoyar SafeRoad',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('Esta es una versión gratuita de la aplicación.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Versión gratuita - Sin donaciones')),
                      );
                    },
                    child: const Text('Información de Donaciones'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              await authService.signOut();
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}
