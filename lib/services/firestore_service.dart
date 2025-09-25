import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:saferoad/models/report.dart';
import 'package:saferoad/models/user.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get currentUserId => _auth.currentUser?.uid ?? '';

  Future<void> addReport(Report report) async {
    await _firestore.collection('reports').add(report.toMap());
  }

  Future<List<Report>> getUserReports() async {
    final snapshot = await _firestore
        .collection('reports')
        .where('userId', isEqualTo: currentUserId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Report.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<UserModel?> getUserData(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }

  Future<void> updateUserAccessibility(String userId, AccessibilityConfig config) async {
    await _firestore.collection('users').doc(userId).update({
      'configAccessibilidad': config.toMap(),
    });
  }
}