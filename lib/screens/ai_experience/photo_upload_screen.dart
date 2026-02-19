import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/experience_state.dart';
import '../../widgets/gradient_button.dart';

class PhotoUploadScreen extends StatelessWidget {
  const PhotoUploadScreen({super.key});

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile != null && context.mounted) {
      context.read<ExperienceState>().setPhoto(File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ExperienceState>();
    final l10n = state.l10n;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF1A1D3E)),
          onPressed: () => state.setAiStep(0),
        ),
        title: Text(
          '1/3',
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                l10n.tr('photoUploadTitle'),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1D3E),
                ),
              ),
              const SizedBox(height: 32),
              // Photo preview or upload area
              Expanded(
                child: state.selectedPhoto != null
                    ? _PhotoPreview(
                        photo: state.selectedPhoto!,
                        onRemove: () => state.setPhoto(null),
                      )
                    : _PhotoUploadArea(
                        onCamera: () =>
                            _pickImage(context, ImageSource.camera),
                        onGallery: () =>
                            _pickImage(context, ImageSource.gallery),
                        l10n: l10n,
                      ),
              ),
              const SizedBox(height: 24),
              if (state.selectedPhoto != null)
                GradientButton(
                  text: l10n.tr('next'),
                  icon: Icons.arrow_forward_rounded,
                  onPressed: () => state.setAiStep(2),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoPreview extends StatelessWidget {
  final File photo;
  final VoidCallback onRemove;

  const _PhotoPreview({required this.photo, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.file(
              photo,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }
}

class _PhotoUploadArea extends StatelessWidget {
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final dynamic l10n;

  const _PhotoUploadArea({
    required this.onCamera,
    required this.onGallery,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Camera option
        _UploadOption(
          icon: Icons.camera_alt_rounded,
          label: l10n.tr('takePhoto'),
          color: const Color(0xFF6C63FF),
          onTap: onCamera,
        ),
        const SizedBox(height: 16),
        // Gallery option
        _UploadOption(
          icon: Icons.photo_library_rounded,
          label: l10n.tr('chooseFromGallery'),
          color: const Color(0xFF4ECDC4),
          onTap: onGallery,
        ),
      ],
    );
  }
}

class _UploadOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _UploadOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: color),
          ],
        ),
      ),
    );
  }
}
