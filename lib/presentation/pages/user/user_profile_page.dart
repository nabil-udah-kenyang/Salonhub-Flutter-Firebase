import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/image_base64_utils.dart';
import '../../../data/models/user_model.dart';
import '../../../presentation/controllers/auth_controller.dart';
import '../../../routes/app_routes.dart';
import 'profile/user_account_settings_page.dart';
import 'profile/user_notification_settings_page.dart';
import 'profile/user_privacy_settings_page.dart';
import 'profile/user_payment_methods_page.dart';
import 'profile/user_address_page.dart';
import 'profile/user_about_page.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  AuthController get _authController => Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Obx(() {
        final user = _authController.currentUser.value;
        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final preferences = user.preferences ?? {};
        final paymentCount = (preferences['paymentMethods'] as List?)?.length ?? 0;
        final addressCount = (preferences['addresses'] as List?)?.length ?? 0;

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('Profil Saya', style: AppTheme.heading1),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.settings_outlined),
                        color: AppTheme.primaryColor,
                        onPressed: _openAccountSettings,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildProfileHeader(user),
                const SizedBox(height: 20),
                _buildQuickStats(paymentCount: paymentCount, addressCount: addressCount),
                const SizedBox(height: 24),
                _buildSection(
                  'Pengaturan',
                  [
                    _buildMenuItem(
                      title: 'Akun Saya',
                      subtitle: 'Kelola nama, nomor telepon, dan avatar',
                      icon: Icons.person_outline,
                      onTap: _openAccountSettings,
                    ),
                    _buildMenuItem(
                      title: 'Notifikasi',
                      subtitle: 'Atur preferensi pesan dan pengingat',
                      icon: Icons.notifications_outlined,
                      onTap: () => Get.to(() => const UserNotificationSettingsPage()),
                    ),
                    _buildMenuItem(
                      title: 'Privasi',
                      subtitle: 'Kontrol data pribadi dan berbagi info',
                      icon: Icons.privacy_tip_outlined,
                      onTap: () => Get.to(() => const UserPrivacySettingsPage()),
                    ),
                    _buildMenuItem(
                      title: 'Pembayaran',
                      subtitle: '$paymentCount metode tersimpan',
                      icon: Icons.payment_outlined,
                      onTap: () => Get.to(() => const UserPaymentMethodsPage()),
                    ),
                    _buildMenuItem(
                      title: 'Alamat',
                      subtitle: '$addressCount alamat aktif',
                      icon: Icons.location_on_outlined,
                      onTap: () => Get.to(() => const UserAddressPage()),
                    ),
                  ],
                ),
                _buildSection('Lainnya', [
                  _buildMenuItem(
                    title: 'Tentang',
                    subtitle: 'Informasi aplikasi dan versi',
                    icon: Icons.info_outline,
                    onTap: () => Get.to(() => const UserAboutPage()),
                  ),
                  _buildMenuItem(
                    title: 'Keluar',
                    subtitle: 'Keluar dari akun dan kembali ke login',
                    icon: Icons.logout,
                    onTap: _showLogoutDialog,
                    isDestructive: true,
                  ),
                ]),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader(UserModel user) {
    final photoUrl = user.photoUrl;
    final photoBytes = photoUrl == null ? null : ImageBase64Utils.decode(photoUrl);
    final ImageProvider? photoProvider = photoBytes != null
        ? MemoryImage(photoBytes)
        : photoUrl != null && photoUrl.startsWith('http')
            ? NetworkImage(photoUrl)
            : null;
    final phoneRaw = (user.phone ?? '').trim();
    final phoneDisplay = phoneRaw.isEmpty ? 'Belum ada nomor' : phoneRaw;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
            backgroundImage: photoProvider,
            child: photoUrl == null || photoUrl.isEmpty || (photoBytes == null && !photoUrl.startsWith('http'))
                ? Icon(Icons.person, size: 38, color: AppTheme.primaryColor)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: AppTheme.heading2.copyWith(fontSize: 20),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  phoneDisplay,
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondaryColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 36,
                  child: OutlinedButton.icon(
                    onPressed: _openAccountSettings,
                    icon: const Icon(Icons.edit_outlined, size: 15),
                    label: const Text(
                      'Edit Profil',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      side: BorderSide(color: AppTheme.primaryColor.withValues(alpha: 0.35)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats({required int paymentCount, required int addressCount}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 360;
        final cards = [
          _buildStatCard(
            title: 'Pembayaran',
            value: '$paymentCount',
            icon: Icons.credit_card,
          ),
          _buildStatCard(
            title: 'Alamat',
            value: '$addressCount',
            icon: Icons.home_work_outlined,
          ),
        ];

        if (isNarrow) {
          return Column(
            children: [
              cards[0],
              const SizedBox(height: 12),
              cards[1],
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: cards[0]),
            const SizedBox(width: 12),
            Expanded(child: cards[1]),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({required String title, required String value, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 19,
            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
            child: Icon(icon, color: AppTheme.primaryColor, size: 19),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondaryColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(value, style: AppTheme.heading2.copyWith(fontSize: 20)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (isDestructive ? Colors.red : AppTheme.primaryColor).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isDestructive ? Colors.red : AppTheme.primaryColor,
                size: 19,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.bodyText1.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDestructive ? Colors.red : AppTheme.textPrimaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondaryColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppTheme.textSecondaryColor.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
    final children = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      children.add(ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: items[i],
      ));
      if (i != items.length - 1) {
        children.add(Divider(
          height: 1,
          indent: 68,
          color: AppTheme.borderColor.withValues(alpha: 0.65),
        ));
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTheme.heading2.copyWith(fontSize: 20)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.borderColor.withValues(alpha: 0.75)),
            ),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: AppTheme.surfaceColor,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: AppTheme.errorColor,
                  size: 28,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Keluar dari akun?',
                style: AppTheme.heading3.copyWith(fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Kamu akan diarahkan kembali ke halaman masuk.',
                style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: Get.back,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textPrimaryColor,
                        side: BorderSide(color: AppTheme.borderColor),
                        minimumSize: const Size(0, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back();
                        await _authController.signOut();
                        Get.offAllNamed(AppRoutes.signin);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.errorColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 48),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Keluar',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openAccountSettings() async {
    final updated = await Get.to<bool>(() => const UserAccountSettingsPage());
    if (updated == true) {
      await _authController.refreshUserData();
      _authController.currentUser.refresh();
    }
  }

}
