import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_theme.dart';
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
  late final TextEditingController _photoUrlController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = _authController.currentUser.value;
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _photoUrlController = TextEditingController(text: user?.photoUrl ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _photoUrlController.dispose();
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
              child: CircleAvatar(
                radius: 42,
                backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                backgroundImage: (_photoUrlController.text.trim().isNotEmpty)
                    ? NetworkImage(_photoUrlController.text.trim())
                    : null,
                child: _photoUrlController.text.trim().isEmpty
                    ? Icon(Icons.person, color: AppTheme.primaryColor, size: 42)
                    : null,
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
            const SizedBox(height: 16),
            _buildLabel('URL Foto Profil'),
            _buildInput(
              _photoUrlController,
              hintText: 'https://contoh.com/foto.jpg',
              keyboardType: TextInputType.url,
              onChanged: (_) => setState(() {}),
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

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim();
    final photoUrl = _photoUrlController.text.trim().isEmpty
        ? null
        : _photoUrlController.text.trim();

    if (name.isEmpty) {
      Get.snackbar('Nama wajib diisi', 'Mohon masukkan nama lengkap.');
      return;
    }

    setState(() => _isSaving = true);
    final success = await _authController.updateProfile(
      name: name,
      phone: phone,
      photoUrl: photoUrl,
    );
    setState(() => _isSaving = false);

    if (success) {
      Get.snackbar('Profil diperbarui', 'Informasi akun berhasil disimpan.');
      Get.back(result: true);
    } else {
      final message = _authController.errorMessage.value.isNotEmpty
          ? _authController.errorMessage.value
          : 'Gagal memperbarui profil. Coba lagi.';
      Get.snackbar('Gagal', message);
    }
  }
}
