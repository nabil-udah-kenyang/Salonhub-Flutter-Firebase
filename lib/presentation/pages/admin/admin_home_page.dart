import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/rating_formatter.dart';
import '../../../presentation/controllers/auth_controller.dart';
import '../../../routes/app_routes.dart';
import 'admin_barbershop_profile_page.dart';
import 'admin_bookings_page.dart';
import 'admin_services_page.dart';
import 'admin_stylists_page.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  void _goToStylists() {
    Get.to(() => AdminStylistsPage());
  }

  void _goToServices() {
    Get.to(() => AdminServicesPage());
  }

  void _goToBookings() {
    Get.to(() => const AdminBookingsPage());
  }

  void _goToProfile() {
    Get.to(() => const AdminBarbershopProfilePage());
  }

  List<String> _adminOwnerIds() {
    final authController = Get.find<AuthController>();
    final user = authController.user;
    final seedOwnerId = user?.preferences?['barbershopOwnerId']?.toString();
    return <String>[
      if (user?.id != null) user!.id!,
      if (seedOwnerId != null && seedOwnerId.isNotEmpty) seedOwnerId,
      if (user?.email.toLowerCase().contains('barberking') == true) 'admin_barberking',
      if (user?.email.toLowerCase().contains('urban') == true) 'admin_urban_groom',
      if (user?.name.toLowerCase().contains('barberking') == true) 'admin_barberking',
      if (user?.name.toLowerCase().contains('urban') == true) 'admin_urban_groom',
    ].toSet().take(10).toList();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _adminBarbershopStream() {
    final ownerIds = _adminOwnerIds();
    return FirebaseFirestore.instance
        .collection(AppConstants.barbershopsCollection)
        .where('ownerId', whereIn: ownerIds.isEmpty ? ['__empty__'] : ownerIds)
        .limit(1)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SalonHub Partner',
                          style: AppTheme.heading2.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Kelola barbershop kamu hari ini',
                          style: AppTheme.bodyText2.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.borderColor),
                    ),
                    child: Icon(
                      Icons.notifications_none_rounded,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () => _showLogoutDialog(),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: Icon(
                        Icons.logout_rounded,
                        color: AppTheme.errorColor,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 22),

              _buildBarbershopOverview(),

              const SizedBox(height: 24),

              _buildFirestoreStatsSection(),
              
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Jadwal Hari Ini',
                      style: AppTheme.heading3.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryExtraLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Buka sampai 21.00',
                      style: AppTheme.bodyText3.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _buildTodayScheduleSection(),

              const SizedBox(height: 24),

              Text(
                'Aksi Cepat',
                style: AppTheme.heading3.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: _buildQuickAction(
                      'Konfirmasi Booking',
                      Icons.fact_check_rounded,
                      AppTheme.primaryColor,
                      _goToBookings,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickAction(
                      'Kelola Stylist',
                      Icons.person_add_alt_1_rounded,
                      AppTheme.infoColor,
                      _goToStylists,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: _buildQuickAction(
                      'Kelola Layanan',
                      Icons.content_cut_rounded,
                      AppTheme.successColor,
                      _goToServices,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickAction(
                      'Profil Barbershop',
                      Icons.storefront_rounded,
                      AppTheme.primaryColor,
                      _goToProfile,
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

  Widget _buildBarbershopOverview() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _adminBarbershopStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildBarbershopCard(
            name: 'Memuat barbershop...',
            address: 'Mengambil data toko dari database',
            isActive: false,
            isApproved: false,
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildBarbershopCard(
            name: 'Barbershop belum terdaftar',
            address: 'Daftarkan atau hubungkan akun admin dengan data barbershop',
            isActive: false,
            isApproved: false,
          );
        }

        final data = snapshot.data!.docs.first.data();
        return _buildBarbershopCard(
          name: data['name']?.toString() ?? 'Barbershop',
          address: data['address']?.toString() ?? 'Alamat belum diisi',
          isActive: data['isActive'] as bool? ?? true,
          isApproved: data['isApproved'] as bool? ?? false,
          rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
          totalReviews: data['totalReviews'] as int? ?? 0,
        );
      },
    );
  }

  Widget _buildBarbershopCard({
    required String name,
    required String address,
    required bool isActive,
    required bool isApproved,
    double rating = 0.0,
    int totalReviews = 0,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.22),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
                ),
                child: const Icon(
                  Icons.storefront_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.heading3.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.bodyText3.copyWith(
                        color: Colors.white.withValues(alpha: 0.82),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isActive ? 'Open' : 'Closed',
                  style: AppTheme.bodyText3.copyWith(
                    color: isActive ? AppTheme.successColor : AppTheme.errorColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _buildHeroMetric('Status Approval', isApproved ? 'Approved' : 'Menunggu'),
              const SizedBox(width: 12),
              _buildHeroMetric(
                'Rating',
                rating > 0
                    ? '${RatingFormatter.display(rating)} ($totalReviews)'
                    : 'Belum ada',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroMetric(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTheme.bodyText3.copyWith(
                color: Colors.white.withValues(alpha: 0.76),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTheme.bodyText2.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildFirestoreStatsSection() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _adminBarbershopStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyPanel('Statistik belum tersedia karena barbershop belum terhubung.');
        }
        final barbershopDoc = snapshot.data!.docs.first;
        final barbershopData = barbershopDoc.data();
        final barbershopId = barbershopDoc.id;
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection(AppConstants.bookingsCollection)
              .where('barbershopId', isEqualTo: barbershopId)
              .snapshots(),
          builder: (context, bookingSnapshot) {
            final allBookings = bookingSnapshot.data?.docs ?? [];
            final today = DateTime.now();
            final todayBookings = allBookings.where((doc) {
              final bookingDate = (doc.data()['bookingDate'] as Timestamp?)?.toDate();
              return bookingDate != null &&
                  bookingDate.year == today.year &&
                  bookingDate.month == today.month &&
                  bookingDate.day == today.day;
            }).toList();
            final omzet = todayBookings.fold<double>(0, (sum, doc) {
              final status = doc.data()['status']?.toString().toLowerCase() ?? '';
              if (status == 'cancelled' || status == 'dibatalkan') return sum;
              return sum + ((doc.data()['totalPrice'] as num?)?.toDouble() ?? 0);
            });
            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection(AppConstants.stylistsCollection)
                  .where('barbershopId', isEqualTo: barbershopId)
                  .where('isActive', isEqualTo: true)
                  .snapshots(),
              builder: (context, stylistSnapshot) {
                final stylistCount = stylistSnapshot.data?.docs.length ?? 0;
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildStatCard('Booking Hari Ini', todayBookings.length.toString(), Icons.event_available_rounded, AppTheme.primaryColor)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildStatCard('Omzet Hari Ini', _formatRupiah(omzet), Icons.payments_rounded, AppTheme.successColor)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildStatCard('Stylist Aktif', stylistCount.toString(), Icons.groups_rounded, AppTheme.infoColor)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Rating',
                            RatingFormatter.display(
                              (barbershopData['rating'] as num?)?.toDouble() ?? 0,
                            ),
                            Icons.star_rounded,
                            AppTheme.warningColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildTodayScheduleSection() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _adminBarbershopStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyPanel('Jadwal belum tersedia.');
        }
        final barbershopId = snapshot.data!.docs.first.id;
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection(AppConstants.bookingsCollection)
              .where('barbershopId', isEqualTo: barbershopId)
              .snapshots(),
          builder: (context, bookingSnapshot) {
            final today = DateTime.now();
            final bookings = (bookingSnapshot.data?.docs ?? []).where((doc) {
              final bookingDate = (doc.data()['bookingDate'] as Timestamp?)?.toDate();
              return bookingDate != null &&
                  bookingDate.year == today.year &&
                  bookingDate.month == today.month &&
                  bookingDate.day == today.day;
            }).toList();
            bookings.sort((a, b) => (a.data()['bookingTime']?.toString() ?? '').compareTo(b.data()['bookingTime']?.toString() ?? ''));
            if (bookings.isEmpty) {
              return _buildEmptyPanel('Belum ada jadwal hari ini.');
            }
            return Column(
              children: bookings.map((doc) {
                final data = doc.data();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildScheduleCard(
                    data['bookingTime']?.toString() ?? '-',
                    '${(data['serviceIds'] as List?)?.length ?? 0} layanan',
                    data['userName']?.toString() ?? 'Pelanggan',
                  ),
                );
              }).toList(),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyPanel(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Text(
        message,
        style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor),
        textAlign: TextAlign.center,
      ),
    );
  }

  String _formatRupiah(double value) {
    if (value >= 1000000) return 'Rp ${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return 'Rp ${(value / 1000).toStringAsFixed(0)}K';
    return 'Rp ${value.toStringAsFixed(0)}';
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTheme.heading2.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTheme.bodyText2.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickAction(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTheme.bodyText2.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildScheduleCard(String time, String service, String customer) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            time,
            style: AppTheme.bodyText2.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              service,
              style: AppTheme.bodyText2,
            ),
          ),
          Text(
            customer,
            style: AppTheme.bodyText2.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    final AuthController authController = Get.find<AuthController>();

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
                        await authController.signOut();
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
}
