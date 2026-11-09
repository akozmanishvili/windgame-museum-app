import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_theme.dart';
import '../../widgets/primary_button.dart';
import '../search/condition_report_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({
    super.key,
    required this.examiner,
  });

  final String examiner;

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _picker = ImagePicker();

  File? _imageFile;
  bool _isLoading = false;

  Future<void> _takePicture() async {
    setState(() => _isLoading = true);

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
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _continueToReport() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ConditionReportScreen(
          examiner: widget.examiner,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Artwork Photo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _imageFile == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.camera_alt_outlined,
                    size: 90,
                    color: AppColors.orange,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Take a photo of the artwork',
                    style: textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Capture a clear image before completing the condition report.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.mutedText,
                    ),
                  ),
                  const SizedBox(height: 32),

                  PrimaryButton(
                    label: 'SNAP PHOTO',
                    isLoading: _isLoading,
                    onPressed: _takePicture,
                  ),
                ],
              )
            : ListView(
                children: [
                  Text(
                    'Photo Preview',
                    style: textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.file(
                      _imageFile!,
                      fit: BoxFit.cover,
                    ),
                  ),

                  const SizedBox(height: 24),

                  OutlinedButton(
                    onPressed: _takePicture,
                    child: const Text('RETAKE PHOTO'),
                  ),

                  const SizedBox(height: 16),

                  PrimaryButton(
                    label: 'CONTINUE TO REPORT',
                    onPressed: _continueToReport,
                  ),
                ],
              ),
      ),
    );
  }
}