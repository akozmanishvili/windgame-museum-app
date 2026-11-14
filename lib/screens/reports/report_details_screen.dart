import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../reports/condition_report.dart';
import '../../reports/report_pdf.dart';
import '../../reports/report_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/primary_button.dart';

typedef PdfExporter = Future<void> Function(
  ConditionReport report, {
  Uint8List? photo,
});

class ReportDetailsScreen extends StatefulWidget {
  const ReportDetailsScreen({
    super.key,
    required this.report,
    required this.reportRepository,
    this.exportPdf = shareReportPdf,
  });

  final ConditionReport report;
  final ReportRepository reportRepository;

  final PdfExporter exportPdf;

  static const exportButtonKey = Key('report_details_export');

  @override
  State<ReportDetailsScreen> createState() => _ReportDetailsScreenState();
}

class _ReportDetailsScreenState extends State<ReportDetailsScreen> {
  late final Future<Uint8List?> _photo = widget.report.hasPhoto
      ? widget.reportRepository.loadPhoto(widget.report.id)
      : Future.value(null);

  bool _isExporting = false;

  Future<void> _export() async {
    setState(() => _isExporting = true);
    try {
      Uint8List? photo;
      try {
        photo = await _photo;
      } on ReportException {
        photo = null;
      }
      await widget.exportPdf(widget.report, photo: photo);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not create PDF: $e')));
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final report = widget.report;
    final textTheme = Theme.of(context).textTheme;
    final labelStyle = textTheme.titleMedium?.copyWith(color: AppColors.orange);

    Widget field(String label, String value) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: labelStyle),
            const SizedBox(height: 4),
            Text(value.isEmpty ? '-' : value, style: textTheme.bodyLarge),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Condition report')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(report.displayTitle, style: textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(
              'by ${report.createdByName} (${report.createdByEmail}) '
              'on ${report.dateLabel}',
              style: textTheme.bodyMedium?.copyWith(color: AppColors.mutedText),
            ),
            const SizedBox(height: 24),
            if (report.hasPhoto) ...[
              _PhotoView(photo: _photo),
              const SizedBox(height: 24),
            ],
            field('General condition', report.condition),
            field('Artist', report.artist),
            field('Medium', report.medium),
            field(
              'Structure / surface issues',
              report.issues.isEmpty
                  ? 'None selected'
                  : report.issues.join(', '),
            ),
            field('Notes', report.notes),
            const SizedBox(height: 8),
            PrimaryButton(
              key: ReportDetailsScreen.exportButtonKey,
              label: 'EXPORT PDF',
              isLoading: _isExporting,
              onPressed: _export,
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoView extends StatelessWidget {
  const _PhotoView({required this.photo});

  final Future<Uint8List?> photo;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: photo,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox(
            height: 250,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final bytes = snapshot.data;
        if (snapshot.hasError || bytes == null) {
          return const Text(
            "Couldn't load the photo.",
            style: TextStyle(color: AppColors.mutedText),
          );
        }
        return ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.memory(bytes, height: 250, fit: BoxFit.cover),
        );
      },
    );
  }
}
