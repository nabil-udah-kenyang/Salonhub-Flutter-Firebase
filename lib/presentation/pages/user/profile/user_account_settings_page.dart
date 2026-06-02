import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/image_base64_utils.dart';
import '../../../controllers/auth_controller.dart';

class UserAccountSettingsPage extends StatefulWidget {
  const UserAccountSettingsPage({super.key});

  @override
  State<UserAccountSettingsPage> createState() => _UserAccountSettingsPageState();
}

class _UserAccountSettingsPageState extends State<UserAccountSettingsPage> {
  final AuthController _authController = Get.find<AuthController>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  final ImagePicker _picker = ImagePicker();
  XFile? _photoFile;
  String _photoSource = '';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = _authController.currentUser.value;
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _photoSource = user?.photoUrl ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = _authController.currentUser.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Akun Saya'),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        foregroundColor: AppTheme.textPrimaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickPhoto,
                child: _buildPhotoPreview(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _pickPhoto,
                icon: const Icon(Icons.photo_library_outlined, size: 18),
                label: const Text('Pilih Foto Profil'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: AppTheme.primaryColor.withValues(alpha: 0.35)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildLabel('Nama Lengkap'),
            _buildInput(
              _nameController,
              hintText: 'Masukkan nama lengkap',
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            _buildLabel('Email'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Text(
                user?.email ?? '-'.tr,
                style: AppTheme.bodyText1,
              ),
            ),
            const SizedBox(height: 16),
            _buildLabel('Nomor Telepon'),
            _buildInput(
              _phoneController,
              hintText: 'Contoh: 0812xxxxxxx',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Simpan Perubahan',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: AppTheme.bodyText1.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildInput(
    TextEditingController controller, {
    required String hintText,
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextInputType keyboardType = TextInputType.text,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      textCapitalization: textCapitalization,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: AppTheme.surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.borderColor),
        ),
      ),
    );
  }

  Widget _buildPhotoPreview() {
    final imageBytes = ImageBase64Utils.decode(_photoSource);

    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
      ),
      clipBehavior: Clip.antiAlias,
      child: _photoFile != null
          ? Image.file(File(_photoFile!.path), fit: BoxFit.cover)
          : imageBytes != null
              ? Image.memory(imageBytes, fit: BoxFit.cover)
              : _photoSource.trim().startsWith('http')
                  ? Image.network(
                      _photoSource.trim(),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildPhotoPlaceholder(),
                    )
                  : _buildPhotoPlaceholder(),
    );
  }

  Widget _buildPhotoPlaceholder() {
    return Icon(Icons.person, color: AppTheme.primaryColor, size: 46);
  }

  Future<void> _pickPhoto() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 30,
      maxWidth: 600,
      maxHeight: 600,
    );
    if (file == null) return;
    setState(() => _photoFile = file);
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim();

    if (name.isEmpty) {
      Get.snackbar('Nama wajib diisi', 'Mohon masukkan nama lengkap.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final photoUrl = _photoFile != null
          ? await ImageBase64Utils.encodeXFile(_photoFile!)
          : _photoSource.trim().isEmpty
              ? null
              : _photoSource.trim();
      final success = await _authController.updateProfile(
        name: name,
        phone: phone,
        photoUrl: photoUrl,
      );
      if (!mounted) return;

      if (success) {
        Get.snackbar('Profil diperbarui', 'Informasi akun berhasil disimpan.');
        Get.back(result: true);
      } else {
        final message = _authController.errorMessage.value.isNotEmpty
            ? _authController.errorMessage.value
            : 'Gagal memperbarui profil. Coba lagi.';
        Get.snackbar('Gagal', message);
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar('Gagal', 'Foto profil gagal disimpan. Coba pilih foto yang lebih kecil.');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
