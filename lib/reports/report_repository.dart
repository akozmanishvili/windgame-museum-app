import 'dart:typed_data';

import 'condition_report.dart';

abstract class ReportRepository {
  Stream<List<ConditionReport>> watchReports();

  Future<String> saveReport(ConditionReport report, {Uint8List? photo});

  Future<Uint8List?> loadPhoto(String reportId);
}

class ReportException implements Exception {
  const ReportException(this.message);

  final String message;

  @override
  String toString() => message;
}
