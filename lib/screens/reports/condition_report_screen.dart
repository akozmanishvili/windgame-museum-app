import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../auth/app_user.dart';
import '../../reports/condition_report.dart';
import '../../reports/report_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/primary_button.dart';

class ConditionReportScreen extends StatefulWidget {
  const ConditionReportScreen({
    super.key,
    required this.user,
    required this.reportRepository,
    this.artist = '',
    this.title = '',
  });

  final AppUser user;
  final ReportRepository reportRepository;
  final String artist;
  final String title;

  static const saveButtonKey = Key('condition_report_save');

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
  late final _artistController = TextEditingController(text: widget.artist);
  late final _titleController = TextEditingController(text: widget.title);
  final _mediumController = TextEditingController();
  final _notesController = TextEditingController();

  String? _condition;
  final Set<String> _issues = {};
  bool _isSaving = false;
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
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 70,
      );

      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Unable to access camera: $e')));
      }
    }
  }

  Future<void> _saveReport() async {
    if (_condition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a general condition.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final photo = await _imageFile?.readAsBytes();
      final report = ConditionReport(
        artist: _artistController.text.trim(),
        title: _titleController.text.trim(),
        medium: _mediumController.text.trim(),
        condition: _condition!,
        issues: _issues.toList(),
        notes: _notesController.text.trim(),
        createdAt: DateTime.now(),
        createdByUid: widget.user.uid,
        createdByName: widget.user.greetingName,
        createdByEmail: widget.user.email,
        hasPhoto: photo != null,
      );
      await widget.reportRepository.saveReport(report, photo: photo);

      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Report saved.')));
      Navigator.of(context).pop();
    } on ReportException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
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
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Notes',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _takePicture,
              icon: const Icon(Icons.camera_alt),
              label: const Text('TAKE PHOTO'),
            ),

            const SizedBox(height: 16),

            if (_imageFile != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.file(_imageFile!, height: 250, fit: BoxFit.cover),
              ),
              const SizedBox(height: 20),
            ],

            // Saves to Firestore
            PrimaryButton(
              key: ConditionReportScreen.saveButtonKey,
              label: 'SAVE REPORT',
              isLoading: _isSaving,
              onPressed: _saveReport,
            ),
          ],
        ),
      ),
    );
  }
}
