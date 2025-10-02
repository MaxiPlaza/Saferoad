import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:saferoad/models/report.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get currentUserId => _auth.currentUser?.uid ?? '';

  Future<void> addReport(Report report) async {
    await _firestore.collection('reports').add(report.toMap());
  }

  Future<List<Report>> getActiveReports() async {
    try {
      final snapshot = await _firestore
          .collection('reports')
          .where('activo', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => Report.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting reports: $e');
      return [];
    }
  }

  Future<void> addCrossRequest(String semaforoId) async {
    await _firestore.collection('cross_requests').add({
      'userId': currentUserId,
      'semaforoId': semaforoId,
      'timestamp': Timestamp.now(),
      'estado': 'pendiente',
    });
  }

  Stream<QuerySnapshot> getReportsStream() {
    return _firestore
        .collection('reports')
        .where('activo', isEqualTo: true)
        .snapshots();
  }
}
