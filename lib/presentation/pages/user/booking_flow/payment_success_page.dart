import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_theme.dart';
import '../user_main_page.dart';

class PaymentSuccessPage extends StatelessWidget {
  final String bookingId;
  final double totalPrice;

  const PaymentSuccessPage({
    super.key,
    required this.bookingId,
    required this.totalPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Spacer(),
              
              // Success Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.check_circle,
                  color: AppTheme.successColor,
                  size: 60,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Success Message
              Text(
                'Booking Terkirim!',
                style: AppTheme.heading1.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.successColor,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              Text(
                'Booking kamu menunggu konfirmasi admin. Kami akan memberi tahu saat jadwal disetujui.',
                style: AppTheme.bodyText1.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // Booking Details
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.shadowColor,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildDetailRow('ID Booking', bookingId),
                    const Divider(height: 16),
                    _buildDetailRow('Total Pembayaran', 'Rp ${totalPrice.toInt()}'),
                    const Divider(height: 16),
                    _buildDetailRow('Metode Pembayaran', 'Bayar di Tempat'),
                    const Divider(height: 16),
                    _buildDetailRow('Status', 'Menunggu Konfirmasi'),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Action Buttons
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Get.offAll(() => const UserMainPage(initialIndex: 2));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                      minimumSize: const Size(double.infinity, 0),
                    ),
                    child: Text(
                      'Lihat Detail Booking',
                      style: AppTheme.bodyText1.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  OutlinedButton(
                    onPressed: () {
                      Get.offAll(() => const UserMainPage());
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      side: BorderSide(
                        color: AppTheme.primaryColor,
                      ),
                      minimumSize: const Size(double.infinity, 0),
                    ),
                    child: Text(
                      'Kembali ke Beranda',
                      style: AppTheme.bodyText1.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: AppTheme.bodyText2.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTheme.bodyText1.copyWith(
              fontWeight: FontWeight.w600,
              color: label == 'Status' ? AppTheme.successColor : AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
  
}
