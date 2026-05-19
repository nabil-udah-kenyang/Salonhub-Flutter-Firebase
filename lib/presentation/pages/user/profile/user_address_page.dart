import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../controllers/auth_controller.dart';

class UserAddressPage extends StatefulWidget {
  const UserAddressPage({super.key});

  @override
  State<UserAddressPage> createState() => _UserAddressPageState();
}

class _UserAddressPageState extends State<UserAddressPage> {
  final AuthController _authController = Get.find<AuthController>();
  late List<Map<String, dynamic>> _addresses;

  @override
  void initState() {
    super.initState();
    _addresses = _loadAddresses();
  }

  List<Map<String, dynamic>> _loadAddresses() {
    final prefs = _authController.currentUser.value?.preferences;
    final list = prefs != null && prefs['addresses'] is List
        ? List<Map<String, dynamic>>.from(
            (prefs['addresses'] as List)
                .map((e) => Map<String, dynamic>.from(e as Map)))
        : <Map<String, dynamic>>[];
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alamat Saya'),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        foregroundColor: AppTheme.textPrimaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_location_alt_outlined),
            onPressed: _showAddressSheet,
          ),
        ],
      ),
      body: _addresses.isEmpty
          ? Center(
              child: Text(
                'Belum ada alamat tersimpan.',
                style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final address = _addresses[index];
                return _buildAddressCard(address, index);
              },
              separatorBuilder: (context, _) => const SizedBox(height: 12),
              itemCount: _addresses.length,
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddressSheet,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Alamat'),
      ),
    );
  }

  Widget _buildAddressCard(Map<String, dynamic> data, int index) {
    final label = data['label']?.toString() ?? 'Alamat';
    final detail = data['detail']?.toString() ?? '-';
    final isPrimary = data['isPrimary'] as bool? ?? false;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPrimary ? AppTheme.primaryColor : AppTheme.borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTheme.bodyText1.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              if (isPrimary)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Utama',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => _showAddressSheet(existingIndex: index),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _deleteAddress(index),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            detail,
            style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddressSheet({int? existingIndex}) async {
    final isEditing = existingIndex != null;
    final existing = isEditing ? _addresses[existingIndex] : <String, dynamic>{};

    final labelController = TextEditingController(text: existing['label']?.toString() ?? '');
    final detailController = TextEditingController(text: existing['detail']?.toString() ?? '');
    bool isPrimary = existing['isPrimary'] as bool? ?? false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, modalSetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isEditing ? 'Ubah Alamat' : 'Tambahkan Alamat', style: AppTheme.heading3),
                  const SizedBox(height: 16),
                  TextField(
                    controller: labelController,
                    decoration: const InputDecoration(labelText: 'Label (Rumah, Kantor, dll)'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: detailController,
                    decoration: const InputDecoration(labelText: 'Detail Alamat Lengkap'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    value: isPrimary,
                    onChanged: (value) {
                      modalSetState(() {
                        isPrimary = value ?? false;
                      });
                    },
                    title: const Text('Jadikan alamat utama'),
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: AppTheme.primaryColor,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final label = labelController.text.trim();
                        final detail = detailController.text.trim();
                        if (label.isEmpty || detail.isEmpty) {
                          Get.snackbar('Lengkapi data', 'Label dan detail alamat wajib diisi.');
                          return;
                        }

                        setState(() {
                          if (isPrimary) {
                            for (final address in _addresses) {
                              address['isPrimary'] = false;
                            }
                          }
                          final payload = {
                            'label': label,
                            'detail': detail,
                            'isPrimary': isPrimary,
                          };
                          if (isEditing) {
                          _addresses[existingIndex] = payload;
                        } else {
                          _addresses.add(payload);
                        }
                        });

                        Get.back();
                        _persist();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Simpan'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _deleteAddress(int index) async {
    final confirmed = await Get.dialog<bool>(AlertDialog(
          title: const Text('Hapus Alamat'),
          content: const Text('Yakin ingin menghapus alamat ini?'),
          actions: [
            TextButton(onPressed: () => Get.back(result: false), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
              child: const Text('Hapus'),
            ),
          ],
        )) ??
        false;
    if (!confirmed) return;

    setState(() {
      _addresses.removeAt(index);
    });
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = Map<String, dynamic>.from(_authController.currentUser.value?.preferences ?? {});
    prefs['addresses'] = _addresses;
    final success = await _authController.updateProfile(preferences: prefs);

    if (success) {
      Get.snackbar('Berhasil', 'Daftar alamat diperbarui.');
    } else {
      final message = _authController.errorMessage.value.isNotEmpty
          ? _authController.errorMessage.value
          : 'Gagal menyimpan perubahan.';
      Get.snackbar('Gagal', message);
    }
  }
}
