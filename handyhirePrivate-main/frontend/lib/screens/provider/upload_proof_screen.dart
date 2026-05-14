import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import 'payment_success_screen.dart';

class UploadProofScreen extends StatefulWidget {
  const UploadProofScreen({super.key});

  @override
  State<UploadProofScreen> createState() => _UploadProofScreenState();
}

class _UploadProofScreenState extends State<UploadProofScreen> {
  bool _photoUploaded = false;
  String _uploadSource = '';

  void _simulateUpload(String source) {
    setState(() {
      _photoUploaded = true;
      _uploadSource = source;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Photo uploaded from $source successfully!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _removePhoto() {
    setState(() {
      _photoUploaded = false;
      _uploadSource = '';
    });
  }

  void _verifyAndContinue() {
    if (!_photoUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please upload a photo before continuing!'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const PaymentSuccessScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Upload Proof',
            style: TextStyle(
                color: AppColors.text, fontSize: 22, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                  color: AppColors.secondary, borderRadius: BorderRadius.circular(14)),
              child: Column(
                children: [
                  const Icon(Icons.camera_alt, color: AppColors.accent, size: 36),
                  const SizedBox(height: 10),
                  const Text('Upload Proof of Completed Work',
                      style: TextStyle(
                          color: AppColors.text,
                          fontSize: 17,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text(
                    'Please take or upload a clear photo showing\nthe completed job before proceeding.',
                    style: TextStyle(
                        color: AppColors.text.withOpacity(0.6), fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _photoUploaded
                      ? AppColors.success
                      : AppColors.accent.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: _photoUploaded
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle,
                            color: AppColors.success, size: 70),
                        const SizedBox(height: 12),
                        const Text('Photo Uploaded!',
                            style: TextStyle(
                                color: AppColors.success,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text('Source: $_uploadSource',
                            style: TextStyle(
                                color: AppColors.text.withOpacity(0.6),
                                fontSize: 13)),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: _removePhoto,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.danger.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.danger, width: 1),
                            ),
                            child: const Text('Remove Photo',
                                style: TextStyle(
                                    color: AppColors.danger,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined,
                            color: AppColors.accent.withOpacity(0.5), size: 65),
                        const SizedBox(height: 12),
                        Text('No photo selected yet',
                            style: TextStyle(
                                color: AppColors.text.withOpacity(0.4),
                                fontSize: 14)),
                      ],
                    ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () => _simulateUpload('Camera'),
                      icon: const Icon(Icons.camera_alt, size: 20),
                      label: const Text('Take Photo',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.background,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () => _simulateUpload('Gallery'),
                      icon: const Icon(Icons.photo_library, size: 20),
                      label: const Text('Gallery',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: AppColors.text,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: AppColors.accent, width: 2),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _verifyAndContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _photoUploaded ? AppColors.success : AppColors.secondary,
                  foregroundColor: _photoUploaded
                      ? AppColors.text
                      : AppColors.text.withOpacity(0.4),
                  shape:
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _photoUploaded ? Icons.check_circle : Icons.lock_outline,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _photoUploaded
                          ? 'Confirm Job Completion'
                          : 'Upload Photo to Continue',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
