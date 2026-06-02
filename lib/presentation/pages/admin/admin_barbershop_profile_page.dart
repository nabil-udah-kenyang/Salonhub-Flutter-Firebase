import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/image_base64_utils.dart';
import '../../controllers/auth_controller.dart';

class AdminBarbershopProfilePage extends StatefulWidget {
  const AdminBarbershopProfilePage({super.key});

  @override
  State<AdminBarbershopProfilePage> createState() => _AdminBarbershopProfilePageState();
}

class _AdminBarbershopProfilePageState extends State<AdminBarbershopProfilePage> {
  final AuthController _authController = Get.find<AuthController>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isSaving = false;
  bool _isPasswordSaving = false;
  String? _barbershopId;
  bool _hasSyncedControllers = false;
  String _profilePhotoUrl = '';
  String _coverPhotoUrl = '';
  XFile? _profilePhotoFile;
  XFile? _coverPhotoFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _barbershopStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return _buildEmptyState();
            }

            final doc = snapshot.data!.docs.first;
            final data = doc.data();
            _barbershopId = doc.id;
            if (!_hasSyncedControllers) {
              _syncControllers(data);
              _hasSyncedControllers = true;
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildPreviewCard(data),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Profil Barbershop'),
                  const SizedBox(height: 12),
                  _buildProfileForm(data),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Foto Barbershop'),
                  const SizedBox(height: 12),
                  _buildPhotoForm(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Keamanan Akun'),
                  const SizedBox(height: 12),
                  _buildPasswordForm(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _barbershopStream() {
    final user = _authController.user;
    final seedOwnerId = user?.preferences?['barbershopOwnerId']?.toString();
    final ownerIds = {
      if (user?.id != null) user!.id!,
      if (seedOwnerId != null && seedOwnerId.isNotEmpty) seedOwnerId,
      if (user?.email.toLowerCase().contains('barberking') == true) 'admin_barberking',
      if (user?.email.toLowerCase().contains('urban') == true) 'admin_urban_groom',
    }.take(10).toList();

    return _firestore
        .collection(AppConstants.barbershopsCollection)
        .where('ownerId', whereIn: ownerIds.isEmpty ? ['__empty__'] : ownerIds)
        .limit(1)
        .snapshots();
  }

  void _syncControllers(Map<String, dynamic> data) {
    final photos = List<String>.from(data['photos'] ?? []);
    _setIfDifferent(_nameController, data['name']?.toString() ?? '');
    _setIfDifferent(_addressController, data['address']?.toString() ?? '');
    _setIfDifferent(_descriptionController, data['description']?.toString() ?? '');
    _setIfDifferent(_phoneController, data['phone']?.toString() ?? '');
    _profilePhotoUrl = photos.isNotEmpty ? photos[0] : '';
    _coverPhotoUrl = photos.length > 1 ? photos[1] : '';
  }

  void _setIfDifferent(TextEditingController controller, String value) {
    if (controller.text != value && !controller.selection.isValid) {
      controller.text = value;
    }
    if (controller.text.isEmpty && value.isNotEmpty) {
      controller.text = value;
    }
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profil Barber',
                style: AppTheme.heading2.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                'Kelola identitas toko dan keamanan akun',
                style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor),
              ),
            ],
          ),
        ),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.primaryExtraLight,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.storefront_rounded, color: AppTheme.primaryColor),
        ),
      ],
    );
  }

  Widget _buildPhotoPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_alt_outlined, color: AppTheme.textSecondaryColor),
          const SizedBox(height: 8),
          Text(
            'Pilih Foto',
            style: AppTheme.bodyText3.copyWith(color: AppTheme.textSecondaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoPicker({
    required String title,
    required String description,
    required String imageUrl,
    required VoidCallback onPick,
  }) {
    final isLocalPath = imageUrl.isNotEmpty && (imageUrl.startsWith('/') || imageUrl.startsWith('file:'));
    final imageBytes = ImageBase64Utils.decode(imageUrl);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTheme.bodyText1.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(description, style: AppTheme.bodyText3.copyWith(color: AppTheme.textSecondaryColor)),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: onPick,
          child: Container(
            height: title.contains('Profil') ? 130 : 170,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.borderColor),
              color: AppTheme.backgroundColor,
            ),
            child: imageUrl.isEmpty
                ? _buildPhotoPlaceholder()
                : ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: isLocalPath
                        ? Image.file(File(imageUrl), fit: BoxFit.cover)
                        : imageBytes != null
                            ? Image.memory(imageBytes, fit: BoxFit.cover)
                            : Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => _buildPhotoPlaceholder(),
                                loadingBuilder: (context, child, progress) => progress == null
                                    ? child
                                    : Center(
                                        child: CircularProgressIndicator(
                                          value: progress.expectedTotalBytes != null
                                              ? progress.cumulativeBytesLoaded / (progress.expectedTotalBytes ?? 1)
                                              : null,
                                          color: AppTheme.primaryColor,
                                        ),
                                      ),
                              ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewCard(Map<String, dynamic> data) {
    final photos = List<String>.from(data['photos'] ?? []);
    final profilePhoto = photos.isNotEmpty ? photos[0] : '';
    final coverPhoto = photos.length > 1 ? photos[1] : '';
    final isApproved = data['isApproved'] as bool? ?? false;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: SizedBox(
              height: 150,
              width: double.infinity,
              child: _buildImage(coverPhoto, 'lib/assets/images/admin_barber_cover.svg', BoxFit.cover),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Transform.translate(
                  offset: const Offset(0, -24),
                  child: Container(
                    width: 86,
                    height: 86,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: _buildImage(profilePhoto, 'lib/assets/images/admin_barber_profile.svg', BoxFit.cover),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['name']?.toString() ?? 'Barbershop',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.heading3.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data['address']?.toString() ?? 'Alamat belum diisi',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.bodyText3.copyWith(color: AppTheme.textSecondaryColor),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildStatusBadge(isApproved ? 'Approved' : 'Pending'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String url, String fallbackAsset, BoxFit fit) {
    if (url.trim().isEmpty) {
      return SvgPicture.asset(fallbackAsset, fit: fit);
    }

    final imageBytes = ImageBase64Utils.decode(url);
    if (imageBytes != null) {
      return Image.memory(imageBytes, fit: fit);
    }

    if (!url.startsWith('http')) {
      return SvgPicture.asset(
        url,
        fit: fit,
      );
    }

    return Image.network(
      url,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => SvgPicture.asset(fallbackAsset, fit: fit),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: AppTheme.primaryExtraLight,
          child: const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryColor),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String label) {
    final approved = label == 'Approved';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: approved ? AppTheme.successColor.withValues(alpha: 0.12) : AppTheme.warningColor.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        label,
        style: AppTheme.bodyText3.copyWith(
          color: approved ? AppTheme.successColor : const Color(0xFF9A6B00),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTheme.heading3.copyWith(fontWeight: FontWeight.w800),
    );
  }

  Widget _buildProfileForm(Map<String, dynamic> data) {
    return _buildPanel(
      children: [
        _buildTextField('Nama Barbershop', _nameController, Icons.storefront_outlined),
        const SizedBox(height: 14),
        _buildTextField('Alamat Barbershop', _addressController, Icons.location_on_outlined, maxLines: 2),
        const SizedBox(height: 14),
        _buildTextField('Deskripsi', _descriptionController, Icons.notes_rounded, maxLines: 3),
        const SizedBox(height: 14),
        _buildTextField('Nomor WhatsApp', _phoneController, Icons.phone_outlined),
        const SizedBox(height: 18),
        _buildPrimaryButton(
          label: _isSaving ? 'Menyimpan...' : 'Simpan Profil Barber',
          icon: Icons.save_rounded,
          onTap: _isSaving ? null : _saveProfile,
        ),
      ],
    );
  }

  Widget _buildPhotoForm() {
    return _buildPanel(
      children: [
        Text(
          'Unggah foto langsung dari perangkat. Foto profil tampil sebagai avatar toko, sedangkan foto sampul muncul di header.',
          style: AppTheme.bodyText3.copyWith(color: AppTheme.textSecondaryColor),
        ),
        const SizedBox(height: 14),
        _buildPhotoPicker(
          title: 'Foto Profil',
          description: 'Rekomendasi ukuran persegi 1:1',
          imageUrl: _profilePhotoFile != null ? _profilePhotoFile!.path : _profilePhotoUrl,
          onPick: () async {
            final file = await _picker.pickImage(
              source: ImageSource.gallery,
              imageQuality: 30,
              maxWidth: 600,
              maxHeight: 600,
            );
            if (file != null) {
              setState(() {
                _profilePhotoFile = file;
              });
            }
          },
        ),
        const SizedBox(height: 14),
        _buildPhotoPicker(
          title: 'Foto Sampul',
          description: 'Rekomendasi 16:9 agar tampil maksimal',
          imageUrl: _coverPhotoFile != null ? _coverPhotoFile!.path : _coverPhotoUrl,
          onPick: () async {
            final file = await _picker.pickImage(
              source: ImageSource.gallery,
              imageQuality: 30,
              maxWidth: 900,
              maxHeight: 675,
            );
            if (file != null) {
              setState(() {
                _coverPhotoFile = file;
              });
            }
          },
        ),
        const SizedBox(height: 18),
        _buildPrimaryButton(
          label: _isSaving ? 'Menyimpan...' : 'Simpan Foto Barber',
          icon: Icons.photo_library_rounded,
          onTap: _isSaving ? null : _saveProfile,
        ),
      ],
    );
  }

  Widget _buildPasswordForm() {
    return _buildPanel(
      children: [
        _buildTextField('Password Baru', _passwordController, Icons.lock_outline, obscureText: true),
        const SizedBox(height: 14),
        _buildTextField('Konfirmasi Password Baru', _confirmPasswordController, Icons.lock_reset_rounded, obscureText: true),
        const SizedBox(height: 18),
        _buildPrimaryButton(
          label: _isPasswordSaving ? 'Mengubah...' : 'Ganti Password',
          icon: Icons.password_rounded,
          onTap: _isPasswordSaving ? null : _changePassword,
        ),
      ],
    );
  }

  Widget _buildPanel({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      maxLines: obscureText ? 1 : maxLines,
      obscureText: obscureText,
      style: AppTheme.bodyText2.copyWith(fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: AppTheme.backgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppTheme.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppTheme.borderColor),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({required String label, required IconData icon, required VoidCallback? onTap}) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 19),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (_barbershopId == null) return;
    if (_nameController.text.trim().isEmpty || _addressController.text.trim().isEmpty) {
      Get.snackbar('Data belum lengkap', 'Nama dan alamat barbershop wajib diisi');
      return;
    }

    setState(() => _isSaving = true);
    try {
      String profilePhoto = _profilePhotoUrl;
      String coverPhoto = _coverPhotoUrl;

      if (_profilePhotoFile != null) {
        profilePhoto = await ImageBase64Utils.encodeXFile(_profilePhotoFile!);
      }
      if (_coverPhotoFile != null) {
        coverPhoto = await ImageBase64Utils.encodeXFile(_coverPhotoFile!);
      }

      final photos = <String>[
        if (profilePhoto.isNotEmpty) profilePhoto,
        if (coverPhoto.isNotEmpty) coverPhoto,
      ];

      await _firestore.collection(AppConstants.barbershopsCollection).doc(_barbershopId).set({
        'name': _nameController.text.trim(),
        'address': _addressController.text.trim(),
        'description': _descriptionController.text.trim(),
        'phone': _phoneController.text.trim(),
        'whatsapp': _phoneController.text.trim(),
        'photos': photos,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      Get.snackbar('Berhasil', 'Profil barbershop berhasil diperbarui');
      setState(() {
        _profilePhotoFile = null;
        _coverPhotoFile = null;
        _profilePhotoUrl = profilePhoto;
        _coverPhotoUrl = coverPhoto;
      });
    } catch (e) {
      Get.snackbar('Gagal', 'Profil barbershop gagal diperbarui');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _changePassword() async {
    if (_passwordController.text.length < 6) {
      Get.snackbar('Password terlalu pendek', 'Password minimal 6 karakter');
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      Get.snackbar('Password tidak cocok', 'Konfirmasi password harus sama');
      return;
    }

    setState(() => _isPasswordSaving = true);
    try {
      await _auth.currentUser?.updatePassword(_passwordController.text);
      _passwordController.clear();
      _confirmPasswordController.clear();
      Get.snackbar('Berhasil', 'Password akun admin berhasil diperbarui');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        Get.snackbar('Login ulang diperlukan', 'Silakan logout dan login kembali sebelum mengganti password');
      } else {
        Get.snackbar('Gagal', e.message ?? 'Password gagal diperbarui');
      }
    } catch (e) {
      Get.snackbar('Gagal', 'Password gagal diperbarui');
    } finally {
      if (mounted) setState(() => _isPasswordSaving = false);
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                color: AppTheme.primaryExtraLight,
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(Icons.store_mall_directory_outlined, color: AppTheme.primaryColor, size: 42),
            ),
            const SizedBox(height: 18),
            Text(
              'Data barbershop belum ditemukan',
              textAlign: TextAlign.center,
              style: AppTheme.heading3.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Pastikan akun admin sudah terhubung dengan data barbershop di database.',
              textAlign: TextAlign.center,
              style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor),
            ),
          ],
        ),
      ),
    );
  }
}
