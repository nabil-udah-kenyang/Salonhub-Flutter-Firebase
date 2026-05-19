import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_theme.dart';

class UserHelpCenterPage extends StatelessWidget {
  const UserHelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pusat Bantuan'),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        foregroundColor: AppTheme.textPrimaryColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHelpCard(
            title: 'Live Chat',
            subtitle: 'Chat langsung dengan tim SalonHub (09.00 - 21.00 WIB).',
            icon: Icons.chat_bubble_outline,
            actionLabel: 'Mulai Chat',
            onTap: () => _copyToClipboard('https://wa.me/6281234567890'),
          ),
          _buildHelpCard(
            title: 'Email Support',
            subtitle: 'Kirimkan detail kendala Anda ke support@salonhub.app',
            icon: Icons.email_outlined,
            actionLabel: 'Salin Email',
            onTap: () => _copyToClipboard('support@salonhub.app'),
          ),
          _buildHelpCard(
            title: 'FAQ & Panduan',
            subtitle: 'Pelajari cara menggunakan aplikasi dengan panduan lengkap.',
            icon: Icons.menu_book_outlined,
            actionLabel: 'Lihat FAQ',
            onTap: () => Get.snackbar('FAQ', 'Fitur akan segera hadir.', snackPosition: SnackPosition.BOTTOM),
          ),
          const SizedBox(height: 24),
          Text(
            'Status Layanan',
            style: AppTheme.heading3,
          ),
          const SizedBox(height: 8),
          _buildStatusRow('Customer Support', 'Aktif'),
          _buildStatusRow('SLA Balasan', '< 30 menit'),
          _buildStatusRow('Ketersediaan', 'Setiap hari'),
        ],
      ),
    );
  }

  Widget _buildHelpCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String actionLabel,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.bodyText1.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor),
                ),
              ],
            ),
          ),
          TextButton(onPressed: onTap, child: Text(actionLabel)),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor),
            ),
          ),
          Text(
            value,
            style: AppTheme.bodyText1.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Future<void> _copyToClipboard(String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    Get.snackbar('Disalin', 'Informasi telah disalin ke clipboard.');
  }
}
