import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:saferoad/models/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> createUserWithEmailAndPassword(
    String email,
    String password,
    String nombre,
    String? apellido,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        UserModel newUser = UserModel(
          uid: user.uid,
          email: email,
          nombre: nombre,
          apellido: apellido,
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
          estado: 'Activo',
          configAccessibilidad: AccessibilityConfig(
            sonido: true,
            textoGrande: false,
            vibracion: true,
          ),
        );

        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
        return newUser;
      }
      return null;
    } catch (e) {
      throw Exception('Error al crear usuario: $e');
    }
  }

  Future<UserModel?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'lastLogin': Timestamp.now(),
        });

        DocumentSnapshot doc =
            await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          return UserModel.fromMap(doc.data() as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Error al iniciar sesión: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;
}
