import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';

class UserAboutPage extends StatelessWidget {
  const UserAboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tentang Aplikasi'),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        foregroundColor: AppTheme.textPrimaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Image.asset(
                    'lib/assets/images/logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppConstants.appName,
                      style: AppTheme.heading2,
                    ),
                    Text(
                      'Versi ${AppConstants.appVersion}',
                      style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'SalonHub adalah platform pemesanan layanan grooming yang membantu pengguna menemukan salon terbaik, memesan layanan, serta memantau status booking secara real-time.',
              style: AppTheme.bodyText1,
            ),
            const SizedBox(height: 24),
            Text('Fitur Unggulan', style: AppTheme.heading3),
            const SizedBox(height: 12),
            _buildFeature('🗓️ Jadwal fleksibel dengan pengingat otomatis'),
            _buildFeature('💳 Banyak pilihan metode pembayaran'),
            _buildFeature('⭐ Review dan rating salon terpercaya'),
            _buildFeature('📍 Rekomendasi salon terdekat'),
            const Spacer(),
            Text(
              '© ${DateTime.now().year} SalonHub. Semua hak dilindungi.',
              style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeature(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(text, style: AppTheme.bodyText1),
    );
  }
}
