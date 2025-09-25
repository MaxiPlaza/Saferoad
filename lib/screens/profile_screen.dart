import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saferoad/services/auth_service.dart';
import 'package:saferoad/services/mercadopago_service.dart';
import 'package:saferoad/models/user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final mercadopagoService = Provider.of<MercadoPagoService>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: StreamBuilder<UserModel?>(
        stream: authService.user,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final user = snapshot.data;
          if (user == null) {
            return const Center(child: Text('Usuario no autenticado'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildUserInfo(user),
              const SizedBox(height: 24),
              _buildDonationSection(mercadopagoService),
              const SizedBox(height: 24),
              _buildSettingsSection(user),
              const SizedBox(height: 24),
              _buildLogoutButton(authService),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUserInfo(UserModel user) {
    return Card(
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
            Text('Nombre: ${user.nombre} ${user.apellido ?? ""}'),
            Text('Email: ${user.email}'),
            Text('Estado: ${user.estado}'),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationSection(MercadoPagoService mercadopagoService) {
    return Card(
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
            const Text('Realiza una donación para ayudar a mantener la aplicación.'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _startDonation(mercadopagoService, 100),
                    child: const Text('\$100'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _startDonation(mercadopagoService, 500),
                    child: const Text('\$500'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _startDonation(mercadopagoService, 1000),
                    child: const Text('\$1000'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(UserModel user) {
    return Card(
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
              value: user.configAccessibilidad.sonido,
              onChanged: (value) {
                // Actualizar configuración
              },
            ),
            SwitchListTile(
              title: const Text('Texto Grande'),
              value: user.configAccessibilidad.textoGrande,
              onChanged: (value) {
                // Actualizar configuración
              },
            ),
            SwitchListTile(
              title: const Text('Vibración'),
              value: user.configAccessibilidad.vibracion,
              onChanged: (value) {
                // Actualizar configuración
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(AuthService authService) {
    return ElevatedButton(
      onPressed: () async {
        await authService.signOut();
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      },
      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
      child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white)),
    );
  }

  void _startDonation(MercadoPagoService mercadopagoService, double amount) async {
    try {
      await mercadopagoService.startDonation(amount, 'Donación SafeRoad');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al iniciar donación: $e')),
      );
    }
  }
}