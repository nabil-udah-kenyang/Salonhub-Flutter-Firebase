import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../controllers/auth_controller.dart';

class UserNotificationSettingsPage extends StatefulWidget {
  const UserNotificationSettingsPage({super.key});

  @override
  State<UserNotificationSettingsPage> createState() => _UserNotificationSettingsPageState();
}

class _UserNotificationSettingsPageState extends State<UserNotificationSettingsPage> {
  final AuthController _authController = Get.find<AuthController>();
  late Map<String, bool> _notificationPrefs;

  @override
  void initState() {
    super.initState();
    _notificationPrefs = _loadPrefs();
  }

  Map<String, bool> _loadPrefs() {
    final prefs = _authController.currentUser.value?.preferences;
    final map = prefs != null && prefs['notifications'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(prefs['notifications'] as Map)
        : <String, dynamic>{};

    return {
      'bookingUpdates': map['bookingUpdates'] as bool? ?? true,
      'promoUpdates': map['promoUpdates'] as bool? ?? true,
      'reminders': map['reminders'] as bool? ?? true,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        foregroundColor: AppTheme.textPrimaryColor,
      ),
      body: Column(
        children: [
          _buildSwitch(
            title: 'Update Booking',
            subtitle: 'Terima kabar terbaru terkait jadwal dan perubahan booking.',
            keyName: 'bookingUpdates',
          ),
          _buildSwitch(
            title: 'Promo & Penawaran',
            subtitle: 'Dapatkan info promo salon favorit Anda.',
            keyName: 'promoUpdates',
          ),
          _buildSwitch(
            title: 'Pengingat Jadwal',
            subtitle: 'Pengingat otomatis sebelum jadwal layanan dimulai.',
            keyName: 'reminders',
          ),
        ],
      ),
    );
  }

  Widget _buildSwitch({
    required String title,
    required String subtitle,
    required String keyName,
  }) {
    return SwitchListTile.adaptive(
      title: Text(title, style: AppTheme.bodyText1.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor)),
      value: _notificationPrefs[keyName] ?? false,
      onChanged: (value) {
        setState(() {
          _notificationPrefs[keyName] = value;
        });
        _persist();
      },
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppTheme.primaryColor;
        }
        return AppTheme.textSecondaryColor;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppTheme.primaryColor.withValues(alpha: 0.3);
        }
        return AppTheme.borderColor;
      }),
    );
  }

  Future<void> _persist() async {
    final prefs = Map<String, dynamic>.from(_authController.currentUser.value?.preferences ?? {});
    prefs['notifications'] = _notificationPrefs;
    final success = await _authController.updateProfile(preferences: prefs);

    if (success) {
      Get.snackbar('Berhasil', 'Preferensi notifikasi diperbarui.');
    } else {
      final message = _authController.errorMessage.value.isNotEmpty
          ? _authController.errorMessage.value
          : 'Gagal menyimpan pengaturan.';
      Get.snackbar('Gagal', message);
    }
  }
}
