import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'condition_report.dart';
import 'report_repository.dart';

class FirestoreReportRepository implements ReportRepository {
  FirestoreReportRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  static const int maxPhotoBytes = 900 * 1024;

  CollectionReference<Map<String, dynamic>> get _reports =>
      _db.collection('conditionReports');

  CollectionReference<Map<String, dynamic>> get _photos =>
      _db.collection('conditionReportPhotos');

  @override
  Stream<List<ConditionReport>> watchReports() {
    return _reports
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_fromDoc).toList());
  }

  ConditionReport _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final createdAt = data['createdAt'];
    return ConditionReport.fromMap(doc.id, {
      ...data,
      'createdAt': createdAt is Timestamp ? createdAt.toDate() : null,
    });
  }

  @override
  Future<String> saveReport(ConditionReport report, {Uint8List? photo}) async {
    if (photo != null && photo.length > maxPhotoBytes) {
      throw const ReportException(
        'The photo is too large to save. Please take it again.',
      );
    }

    final reportDoc = _reports.doc();
    final data = report.toMap();
    data['hasPhoto'] = photo != null;
    final batch = _db.batch();
    batch.set(reportDoc, data);
    if (photo != null) {
      batch.set(_photos.doc(reportDoc.id), {
        'photo': Blob(photo),
        'createdByUid': report.createdByUid,
      });
    }

    try {
      await batch.commit();
    } on FirebaseException catch (e) {
      throw ReportException(_messageFor(e.code));
    }
    return reportDoc.id;
  }

  @override
  Future<Uint8List?> loadPhoto(String reportId) async {
    try {
      final snapshot = await _photos.doc(reportId).get();
      final photo = snapshot.data()?['photo'];
      return photo is Blob ? photo.bytes : null;
    } on FirebaseException catch (e) {
      throw ReportException(_messageFor(e.code));
    }
  }

  static String _messageFor(String code) {
    switch (code) {
      case 'permission-denied':
        return "You don't have permission to do that. "
            '(Are the Firestore rules published?)';
      case 'unavailable':
        return 'No internet connection. Check your connection and try again.';
      default:
        return 'Something went wrong ($code). Please try again.';
    }
  }
}
