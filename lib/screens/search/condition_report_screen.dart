// file class for writing the PDF to disk
// https://api.dart.dev/stable/dart-io/File-class.html
import 'dart:io';
// dart:typed_data -> Uint8List, the byte type returned by the pdf package
import 'dart:typed_data';
 
import 'package:flutter/material.dart';
 
// path_provider: finds a folder on the device we are allowed to write to.
// https://pub.dev/packages/path_provider
import 'package:path_provider/path_provider.dart';
 
// pdf: builds the PDF document (pdf = layout helpers, widgets = pw.* elements).
// https://pub.dev/packages/pdf
// https://pub.dev/documentation/pdf/latest/
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
 
// share_plus: opens the system share sheet so the saved PDF can be moved to
// Files/Drive, emailed, AirDropped, etc.
// https://pub.dev/packages/share_plus
// https://pub.dev/documentation/share_plus/latest/
import 'package:share_plus/share_plus.dart';
 
import '../../theme/app_theme.dart';
import '../../widgets/primary_button.dart';
import 'package:image_picker/image_picker.dart';
/// Fill out a simple report and export it as a PDF.

class ConditionReportScreen extends StatefulWidget {
  const ConditionReportScreen({
    super.key,
    this.examiner = '',
    this.artist = '',
    this.title = '',
  });
 
  final String examiner;
  final String artist;
  final String title;
 
  // General condition options come from the museum's condition report form

  static const conditions = [
    'Excellent',
    'Very Good',
    'Good',
    'Fair',
    'Poor',
    'Stable',
    'Unstable',
  ];
 
  static const issueOptions = [
    'Abrasions',
    'Broken',
    'Chipped',
    'Cracked',
    'Dirty',
    'Faded',
    'Holes/tears',
    'Missing pieces',
    'Mold/mildew',
    'Paint loss',
    'Scratches',
    'Stained',
    'Warped',
    'Water damage',
    'Other',
  ];
 
  @override
  State<ConditionReportScreen> createState() => _ConditionReportScreenState();
}
 
class _ConditionReportScreenState extends State<ConditionReportScreen> {
  // TextEditingController reads/sets the text in a TextField. It must be
  // disposed (see dispose below)
  // https://docs.flutter.dev/cookbook/forms/retrieve-input
  // https://api.flutter.dev/flutter/widgets/TextEditingController-class.html
  late final _artistController = TextEditingController(text: widget.artist);
  late final _titleController = TextEditingController(text: widget.title);
  final _mediumController = TextEditingController();
  final _notesController = TextEditingController();
 
  String? _condition;
  final Set<String> _issues = {};
  bool _isExporting = false;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
 
  @override
  void dispose() {
    _artistController.dispose();
    _titleController.dispose();
    _mediumController.dispose();
    _notesController.dispose();
    super.dispose();
  }
 
  String get _today {
    final d = DateTime.now();
    return '${d.month}/${d.day}/${d.year}';
  }

  Future<void> _takePicture() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to access camera: $e'),
          ),
        );
      }
    }
  }
 
  Future<void> _exportPdf() async {
    // Required field check (form can't be submitted without a
    // condition level).
    // SnackBar: https://docs.flutter.dev/cookbook/design/snackbars
    if (_condition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a general condition.')),
      );
      return;
    }
 
    setState(() => _isExporting = true);
    try {
      final bytes = await _buildPdf();
 
      // Save the PDF to a real file on the device.
      // getTemporaryDirectory: https://pub.dev/documentation/path_provider/latest/path_provider/getTemporaryDirectory.html
      // Reading/writing files guide:
      // https://docs.flutter.dev/cookbook/persistence/reading-writing-files
      final dir = await getTemporaryDirectory();
      final stamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${dir.path}/condition_report_$stamp.pdf');
      await file.writeAsBytes(bytes, flush: true);
 
      // Open the share sheet (share_plus 11+ API: SharePlus.instance.share).
      // https://pub.dev/documentation/share_plus/latest/
      // The sheet lets the file be saved to Files/Drive, emailed, AirDropped...
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], text: 'Condition report'),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not create PDF: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }
 
  // Builds the PDF in memory and returns its bytes.
  // pw.Document / pw.MultiPage / pw.Text / pw.Bullet are documented at
  // https://pub.dev/documentation/pdf/latest/widgets/widgets-library.html
  // (MultiPage automatically continues onto a new page if the content is long)
  Future<Uint8List> _buildPdf() async {
    final doc = pw.Document();
    String orDash(String s) => s.trim().isEmpty ? '—' : s.trim();
 
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
          pw.Text('Date: $_today'),
          pw.Text('Examiner: ${orDash(widget.examiner)}'),
          pw.Text('Artist: ${orDash(_artistController.text)}'),
          pw.Text('Title: ${orDash(_titleController.text)}'),
          pw.Text('Medium: ${orDash(_mediumController.text)}'),
          pw.SizedBox(height: 12),
          pw.Text(
            'General condition: $_condition',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'Structure / surface issues:',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          if (_issues.isEmpty)
            pw.Text('None selected')
          else
            ..._issues.map((i) => pw.Bullet(text: i)),
          pw.SizedBox(height: 12),
          pw.Text(
            'Notes:',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(orDash(_notesController.text)),
        ],
      ),
    );
 
    return doc.save();
  }


 
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
 
    return Scaffold(
      appBar: AppBar(title: const Text('Condition report')),
      body: SafeArea(

        child: ListView(
          padding: const EdgeInsets.all(20),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            Text('Date: $_today', style: textTheme.bodyMedium),
            const SizedBox(height: 16),
            TextField(
              controller: _artistController,
              decoration: const InputDecoration(labelText: 'Artist'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _mediumController,
              decoration: const InputDecoration(labelText: 'Medium'),
            ),
            const SizedBox(height: 28),
            Text(
              'General condition (required*)',
              style: textTheme.titleMedium?.copyWith(color: AppColors.orange),
            ),
            const SizedBox(height: 8),
            // ChoiceChip = pick exactly one option.
            // https://api.flutter.dev/flutter/material/ChoiceChip-class.html
            // Wrap lays chips out in rows: https://api.flutter.dev/flutter/widgets/Wrap-class.html
            Wrap(
              spacing: 8,
              children: [
                for (final c in ConditionReportScreen.conditions)
                  ChoiceChip(
                    label: Text(c),
                    selected: _condition == c,
                    onSelected: (s) =>
                        setState(() => _condition = s ? c : null),
                  ),
              ],
            ),
            const SizedBox(height: 28),
            Text(
              'Structure / surface (select all that apply)',
              style: textTheme.titleMedium?.copyWith(color: AppColors.orange),
            ),
            const SizedBox(height: 8),
            // FilterChip = toggle any number of options on/off.
            // https://api.flutter.dev/flutter/material/FilterChip-class.html
            Wrap(
              spacing: 8,
              children: [
                for (final i in ConditionReportScreen.issueOptions)
                  FilterChip(
                    label: Text(i),
                    selected: _issues.contains(i),
                    onSelected: (s) =>
                        setState(() => s ? _issues.add(i) : _issues.remove(i)),
                  ),
              ],
            ),
            const SizedBox(height: 28),
            // TODO (later): camera photos via image_picker.
            // https://pub.dev/packages/image_picker
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Notes',
                alignLabelWithHint: true,
              ),
            ),
            OutlinedButton.icon(
                onPressed: _takePicture,
                icon: const Icon(Icons.camera_alt),
                label: const Text('TAKE PHOTO'),
              ),

              const SizedBox(height: 16),

              if (_imageFile != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.file(
                    _imageFile!,
                    height: 250,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20),
              ],

            // Save button. Later: add Firestore/Storage submit here.
            PrimaryButton(
              label: 'SAVE AS PDF',
              isLoading: _isExporting,
              onPressed: _exportPdf,
            ),
          ],
        ),
      ),
    );
  }
}
 