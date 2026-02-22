import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/experience_state.dart';
import '../../services/consent_service.dart';
import '../../widgets/gradient_button.dart';

// Replace with your actual privacy policy URL
const _privacyPolicyUrl = 'https://sites.google.com/view/rebeauty-privacy-policy';

class PhotoUploadScreen extends StatelessWidget {
  const PhotoUploadScreen({super.key});

  /// Returns true if the user has (or just gave) consent.
  Future<bool> _ensureConsent(BuildContext context) async {
    if (await ConsentService.hasConsented()) return true;
    if (!context.mounted) return false;
    final granted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _ConsentDialog(l10n: context.read<ExperienceState>().l10n),
    );
    return granted == true;
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final consented = await _ensureConsent(context);
    if (!consented || !context.mounted) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile != null && context.mounted) {
      final state = context.read<ExperienceState>();
      final bytes = await pickedFile.readAsBytes();
      state.setPhotoBytes(bytes);
      if (!kIsWeb) {
        state.setPhoto(File(pickedFile.path));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ExperienceState>();
    final l10n = state.l10n;
    final hasPhoto = state.selectedPhotoBytes != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF1A1D3E)),
          onPressed: () => state.setAiStep(1),
        ),
        title: Text(
          '2/4',
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
                child: hasPhoto
                    ? _PhotoPreview(
                        photoBytes: state.selectedPhotoBytes!,
                        onRemove: () {
                          state.setPhotoBytes(null);
                          state.setPhoto(null);
                        },
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
              if (hasPhoto)
                GradientButton(
                  text: l10n.tr('next'),
                  icon: Icons.arrow_forward_rounded,
                  onPressed: () => state.setAiStep(3),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Consent Dialog
// ─────────────────────────────────────────────────────────────────────────────

class _ConsentDialog extends StatelessWidget {
  final dynamic l10n;
  const _ConsentDialog({required this.l10n});

  Future<void> _openPrivacyPolicy() async {
    final uri = Uri.parse(_privacyPolicyUrl);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.privacy_tip_outlined,
                      color: Color(0xFF6C63FF), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.tr('consentTitle'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1D3E),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              l10n.tr('consentIntro'),
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            // Table
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FE),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _ConsentRow(
                    label: l10n.tr('consentCollectedData'),
                    value: l10n.tr('consentCollectedDataValue'),
                    isFirst: true,
                  ),
                  _ConsentRow(
                    label: l10n.tr('consentRecipient'),
                    value: l10n.tr('consentRecipientValue'),
                  ),
                  _ConsentRow(
                    label: l10n.tr('consentPurpose'),
                    value: l10n.tr('consentPurposeValue'),
                  ),
                  _ConsentRow(
                    label: l10n.tr('consentRetention'),
                    value: l10n.tr('consentRetentionValue'),
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Privacy policy link
            GestureDetector(
              onTap: _openPrivacyPolicy,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.open_in_new,
                      size: 14, color: Color(0xFF6C63FF)),
                  const SizedBox(width: 4),
                  Text(
                    l10n.tr('consentPrivacyPolicy'),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6C63FF),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(l10n.tr('consentDecline')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () async {
                      await ConsentService.setConsent(true);
                      if (context.mounted) Navigator.pop(context, true);
                    },
                    child: Text(
                      l10n.tr('consentAgree'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ConsentRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isFirst;
  final bool isLast;

  const _ConsentRow({
    required this.label,
    required this.value,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: Colors.grey.shade200)),
        borderRadius: isFirst
            ? const BorderRadius.vertical(top: Radius.circular(12))
            : isLast
                ? const BorderRadius.vertical(bottom: Radius.circular(12))
                : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF1A1D3E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Photo Preview
// ─────────────────────────────────────────────────────────────────────────────

class _PhotoPreview extends StatelessWidget {
  final Uint8List photoBytes;
  final VoidCallback onRemove;

  const _PhotoPreview({required this.photoBytes, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.memory(
              photoBytes,
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

// ─────────────────────────────────────────────────────────────────────────────
// Upload Area
// ─────────────────────────────────────────────────────────────────────────────

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
