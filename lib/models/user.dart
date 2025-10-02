import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String nombre;
  final String? apellido;
  final DateTime createdAt;
  final DateTime lastLogin;
  final String estado;
  final AccessibilityConfig configAccessibilidad;

  UserModel({
    required this.uid,
    required this.email,
    required this.nombre,
    this.apellido,
    required this.createdAt,
    required this.lastLogin,
    required this.estado,
    required this.configAccessibilidad,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      nombre: data['nombre'] ?? '',
      apellido: data['apellido'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastLogin: (data['lastLogin'] as Timestamp).toDate(),
      estado: data['estado'] ?? 'Activo',
      configAccessibilidad:
          AccessibilityConfig.fromMap(data['configAccessibilidad'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'nombre': nombre,
      'apellido': apellido,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': Timestamp.fromDate(lastLogin),
      'estado': estado,
      'configAccessibilidad': configAccessibilidad.toMap(),
    };
  }
}

class AccessibilityConfig {
  final bool sonido;
  final bool textoGrande;
  final bool vibracion;

  AccessibilityConfig({
    required this.sonido,
    required this.textoGrande,
    required this.vibracion,
  });

  factory AccessibilityConfig.fromMap(Map<String, dynamic> data) {
    return AccessibilityConfig(
      sonido: data['sonido'] ?? true,
      textoGrande: data['textoGrande'] ?? false,
      vibracion: data['vibracion'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sonido': sonido,
      'textoGrande': textoGrande,
      'vibracion': vibracion,
    };
  }
}
