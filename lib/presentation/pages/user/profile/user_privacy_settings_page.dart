import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../controllers/auth_controller.dart';

class UserPrivacySettingsPage extends StatefulWidget {
  const UserPrivacySettingsPage({super.key});

  @override
  State<UserPrivacySettingsPage> createState() => _UserPrivacySettingsPageState();
}

class _UserPrivacySettingsPageState extends State<UserPrivacySettingsPage> {
  final AuthController _authController = Get.find<AuthController>();
  late Map<String, bool> _privacyPrefs;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _privacyPrefs = _loadPrefs();
  }

  Map<String, bool> _loadPrefs() {
    final prefs = _authController.currentUser.value?.preferences;
    final map = prefs != null && prefs['privacy'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(prefs['privacy'] as Map)
        : <String, dynamic>{};

    return {
      'shareProfile': map['shareProfile'] as bool? ?? true,
      'personalizedAds': map['personalizedAds'] as bool? ?? true,
      'dataInsights': map['dataInsights'] as bool? ?? true,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privasi'),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        foregroundColor: AppTheme.textPrimaryColor,
      ),
      body: Column(
        children: [
          _buildSwitch(
            title: 'Bagikan Profil ke Salon',
            subtitle: 'Salon dapat melihat riwayat layanan dan preferensi Anda.',
            keyName: 'shareProfile',
          ),
          _buildSwitch(
            title: 'Iklan Personal',
            subtitle: 'Konten promo disesuaikan dengan aktivitas Anda.',
            keyName: 'personalizedAds',
          ),
          _buildSwitch(
            title: 'Analitik Penggunaan',
            subtitle: 'Bantu kami meningkatkan layanan dengan data anonim.',
            keyName: 'dataInsights',
          ),
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: LinearProgressIndicator(),
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
      value: _privacyPrefs[keyName] ?? false,
      onChanged: (value) {
        setState(() {
          _privacyPrefs[keyName] = value;
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
    setState(() => _isSaving = true);
    final prefs = Map<String, dynamic>.from(_authController.currentUser.value?.preferences ?? {});
    prefs['privacy'] = _privacyPrefs;
    final success = await _authController.updateProfile(preferences: prefs);
    setState(() => _isSaving = false);

    if (success) {
      Get.snackbar('Berhasil', 'Pengaturan privasi diperbarui.');
    } else {
      final message = _authController.errorMessage.value.isNotEmpty
          ? _authController.errorMessage.value
          : 'Gagal menyimpan pengaturan.';
      Get.snackbar('Gagal', message);
    }
  }
}
