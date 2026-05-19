import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../controllers/auth_controller.dart';

class UserPaymentMethodsPage extends StatefulWidget {
  const UserPaymentMethodsPage({super.key});

  @override
  State<UserPaymentMethodsPage> createState() => _UserPaymentMethodsPageState();
}

class _UserPaymentMethodsPageState extends State<UserPaymentMethodsPage> {
  final AuthController _authController = Get.find<AuthController>();
  late List<Map<String, dynamic>> _methods;

  @override
  void initState() {
    super.initState();
    _methods = _loadMethods();
  }

  List<Map<String, dynamic>> _loadMethods() {
    final prefs = _authController.currentUser.value?.preferences;
    final list = prefs != null && prefs['paymentMethods'] is List
        ? List<Map<String, dynamic>>.from(
            (prefs['paymentMethods'] as List)
                .map((e) => Map<String, dynamic>.from(e as Map)))
        : <Map<String, dynamic>>[];
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Metode Pembayaran'),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        foregroundColor: AppTheme.textPrimaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_card_outlined),
            onPressed: _showAddMethodSheet,
          ),
        ],
      ),
      body: _methods.isEmpty
          ? Center(
              child: Text(
                'Belum ada metode pembayaran tersimpan.',
                style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final method = _methods[index];
                return _buildMethodCard(method, index);
              },
              separatorBuilder: (context, _) => const SizedBox(height: 12),
              itemCount: _methods.length,
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddMethodSheet,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Metode'),
      ),
    );
  }

  Widget _buildMethodCard(Map<String, dynamic> method, int index) {
    final type = (method['type'] ?? 'lainnya') as String;
    final icon = _iconForType(type);
    final label = method['label']?.toString() ?? 'Metode Pembayaran';
    final lastDigits = method['lastDigits']?.toString() ?? '--';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
            child: Icon(icon, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTheme.bodyText1.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  '•••• $lastDigits',
                  style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _confirmDelete(index),
          ),
        ],
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'bank':
        return Icons.account_balance;
      case 'credit':
        return Icons.credit_card;
      case 'ewallet':
        return Icons.wallet_giftcard;
      default:
        return Icons.payment;
    }
  }

  Future<void> _confirmDelete(int index) async {
    final confirmed = await Get.dialog<bool>(AlertDialog(
          title: const Text('Hapus Metode'),
          content: const Text('Yakin ingin menghapus metode pembayaran ini?'),
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
      _methods.removeAt(index);
    });
    await _persist();
  }

  Future<void> _showAddMethodSheet() async {
    final labelController = TextEditingController();
    final lastDigitsController = TextEditingController();
    String type = 'bank';

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
                  Text('Tambahkan Metode', style: AppTheme.heading3),
                  const SizedBox(height: 16),
                  TextField(
                    controller: labelController,
                    decoration: const InputDecoration(labelText: 'Nama Metode (mis. BCA VA)'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: lastDigitsController,
                    decoration: const InputDecoration(labelText: '4 digit terakhir / nomor referensi'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: type,
                    decoration: const InputDecoration(labelText: 'Tipe'),
                    items: const [
                      DropdownMenuItem(value: 'bank', child: Text('Transfer Bank')),
                      DropdownMenuItem(value: 'credit', child: Text('Kartu Kredit/Debit')),
                      DropdownMenuItem(value: 'ewallet', child: Text('Dompet Digital')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        modalSetState(() {
                          type = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final label = labelController.text.trim();
                        final digits = lastDigitsController.text.trim();

                        if (label.isEmpty || digits.isEmpty) {
                          Get.snackbar('Lengkapi data', 'Nama metode dan nomor wajib diisi.');
                          return;
                        }

                        setState(() {
                          _methods.add({
                            'label': label,
                            'lastDigits': digits,
                            'type': type,
                          });
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

  Future<void> _persist() async {
    final prefs = Map<String, dynamic>.from(_authController.currentUser.value?.preferences ?? {});
    prefs['paymentMethods'] = _methods;
    final success = await _authController.updateProfile(preferences: prefs);

    if (success) {
      Get.snackbar('Berhasil', 'Metode pembayaran diperbarui.');
    } else {
      final message = _authController.errorMessage.value.isNotEmpty
          ? _authController.errorMessage.value
          : 'Gagal menyimpan perubahan.';
      Get.snackbar('Gagal', message);
    }
  }
}
