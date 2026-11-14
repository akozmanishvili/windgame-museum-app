import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import 'condition_report.dart';

Future<Uint8List> buildReportPdf(ConditionReport report, {Uint8List? photo}) {
  final doc = pw.Document();
  String orDash(String s) => s.trim().isEmpty ? '-' : s.trim();
  final bold = pw.TextStyle(fontWeight: pw.FontWeight.bold);

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.letter,
      margin: const pw.EdgeInsets.all(40),
      build: (_) => [
        pw.Text(
          'Windgate Museum of Art - Condition Report',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.Divider(),
        pw.Text('Date: ${report.dateLabel}'),
        pw.Text(
          'Examiner: ${orDash(report.createdByName)} (${report.createdByEmail})',
        ),
        pw.Text('Artist: ${orDash(report.artist)}'),
        pw.Text('Title: ${orDash(report.title)}'),
        pw.Text('Medium: ${orDash(report.medium)}'),
        pw.SizedBox(height: 12),
        pw.Text('General condition: ${report.condition}', style: bold),
        pw.SizedBox(height: 12),
        pw.Text('Structure / surface issues:', style: bold),
        if (report.issues.isEmpty)
          pw.Text('None selected')
        else
          ...report.issues.map((i) => pw.Bullet(text: i)),
        pw.SizedBox(height: 12),
        pw.Text('Notes:', style: bold),
        pw.Text(orDash(report.notes)),
        if (photo != null) ...[
          pw.SizedBox(height: 16),
          pw.Text('Photo:', style: bold),
          pw.SizedBox(height: 8),
          pw.Image(pw.MemoryImage(photo), height: 300, fit: pw.BoxFit.contain),
        ],
      ],
    ),
  );

  return doc.save();
}

String reportFileName(ConditionReport report) {
  final safeTitle = report.displayTitle
      .replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');
  final d = report.createdAt;
  final date =
      '${d.year}-${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
  return 'condition_report_${safeTitle}_$date.pdf';
}

Future<void> shareReportPdf(ConditionReport report, {Uint8List? photo}) async {
  final bytes = await buildReportPdf(report, photo: photo);

  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/${reportFileName(report)}');
  await file.writeAsBytes(bytes, flush: true);

  await SharePlus.instance.share(
    ShareParams(
      files: [XFile(file.path)],
      text: 'Condition report: ${report.displayTitle}',
    ),
  );
}
