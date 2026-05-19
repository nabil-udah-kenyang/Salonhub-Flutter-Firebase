import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../presentation/controllers/auth_controller.dart';
import '../../../routes/app_routes.dart';
import 'superadmin_analytics_page.dart';
import 'superadmin_barbershops_page.dart';
import 'superadmin_users_page.dart';

class SuperadminHomePage extends StatefulWidget {
  const SuperadminHomePage({super.key});

  @override
  State<SuperadminHomePage> createState() => _SuperadminHomePageState();
}

class _SuperadminHomePageState extends State<SuperadminHomePage> {
  late final Future<_DashboardData> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: FutureBuilder<_DashboardData>(
          future: _dashboardFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, color: AppTheme.errorColor, size: 36),
                      const SizedBox(height: 12),
                      Text(
                        'Gagal memuat data dashboard.\n${snapshot.error ?? ''}',
                        textAlign: TextAlign.center,
                        style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => setState(() => _dashboardFuture = _loadDashboardData()),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final data = snapshot.data!;
            return RefreshIndicator(
              onRefresh: () async {
                setState(() => _dashboardFuture = _loadDashboardData());
                await _dashboardFuture;
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    Text('Statistik Platform', style: AppTheme.heading2),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard('Total Salon', data.totalSalons.toString(), Icons.store, AppTheme.primaryColor),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard('Total Stylist', data.totalStylists.toString(), Icons.people, AppTheme.primaryColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard('Total Pelanggan', data.totalCustomers.toString(), Icons.person, AppTheme.primaryColor),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard('Total Booking', data.totalBookings.toString(), Icons.calendar_today, AppTheme.primaryColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text('Ringkasan Pendapatan Platform', style: AppTheme.heading2),
                    const SizedBox(height: 16),
                    _buildRevenueCard(data.totalRevenue),
                    const SizedBox(height: 24),
                    Text('Aksi Cepat', style: AppTheme.heading2),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildQuickAction('Kelola User', Icons.people, AppTheme.primaryColor, () => Get.to(() => const SuperadminUsersPage()))),
                        const SizedBox(width: 12),
                        Expanded(child: _buildQuickAction('Kelola Salon', Icons.storefront, AppTheme.primaryColor, () => Get.to(() => const SuperadminBarbershopsPage()))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildQuickAction('Analytics', Icons.analytics, AppTheme.primaryColor, () => Get.to(() => const SuperadminAnalyticsPage()))),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text('Pengajuan Pending', style: AppTheme.heading2),
                    const SizedBox(height: 16),
                    if (data.pendingShops.isEmpty)
                      _buildEmptyPending()
                    else
                      ...data.pendingShops.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildActivityCard(
                              item.name,
                              item.ownerEmail,
                              item.submittedAt,
                              Icons.store,
                              AppTheme.warningColor,
                            ),
                          )),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard Superadmin',
                style: AppTheme.heading2.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.4),
              ),
              const SizedBox(height: 4),
              Text(
                'Selamat datang kembali, Superadmin!',
                style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: _showLogoutDialog,
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
    );
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

  Widget _buildRevenueCard(double totalRevenue) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
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
          Text('Total Pendapatan Platform', style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor)),
          const SizedBox(height: 8),
          Text(
            _formatCurrency(totalRevenue),
            style: AppTheme.heading1.copyWith(color: AppTheme.textPrimary, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.trending_up, color: Colors.green, size: 20),
              const SizedBox(width: 4),
              Text(
                'Real-time sejak awal bulan',
                style: AppTheme.bodyText2.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.w600),
              ),
            ],
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
  
  Widget _buildActivityCard(String title, String description, String time, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
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
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: AppTheme.bodyText2.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: AppTheme.bodyText2.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTopSalonCard(String name, String revenue, double rating, int rank) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: rank == 1 ? Colors.amber : rank == 2 ? Colors.grey : Colors.brown,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                rank.toString(),
                style: AppTheme.bodyText2.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTheme.bodyText1.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      rating.toString(),
                      style: AppTheme.bodyText2.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            revenue,
            style: AppTheme.bodyText1.copyWith(
              color: Colors.purple,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPending() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.successColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.verified, color: AppTheme.successColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tidak ada pengajuan pending. Semua barbershop telah diverifikasi.',
              style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Future<_DashboardData> _loadDashboardData() async {
    final firestore = FirebaseFirestore.instance;
    final results = await Future.wait([
      firestore.collection(AppConstants.barbershopsCollection).get(),
      firestore.collection(AppConstants.stylistsCollection).get(),
      firestore.collection(AppConstants.usersCollection).get(),
      firestore.collection(AppConstants.bookingsCollection).get(),
    ]);

    final barbershopsSnap = results[0] as QuerySnapshot<Map<String, dynamic>>;
    final stylistsSnap = results[1] as QuerySnapshot<Map<String, dynamic>>;
    final usersSnap = results[2] as QuerySnapshot<Map<String, dynamic>>;
    final bookingsSnap = results[3] as QuerySnapshot<Map<String, dynamic>>;

    final totalRevenue = bookingsSnap.docs.fold<double>(0, (sum, doc) {
      final price = doc.data()['totalPrice'];
      if (price is num) {
        return sum + price.toDouble();
      }
      return sum;
    });

    final pendingShopsDocs = barbershopsSnap.docs
        .where((doc) => !(doc.data()['isApproved'] as bool? ?? false))
        .toList()
      ..sort((a, b) {
        final aCreated = (a.data()['createdAt'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bCreated = (b.data()['createdAt'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bCreated.compareTo(aCreated);
      });

    final userEmails = {
      for (final doc in usersSnap.docs) doc.id: (doc.data()['email']?.toString() ?? 'tidak diketahui'),
    };

    final pendingDisplay = pendingShopsDocs.take(4).map((doc) {
      final createdAt = (doc.data()['createdAt'] as Timestamp?)?.toDate();
      return _PendingShop(
        name: doc.data()['name']?.toString() ?? 'Barbershop',
        ownerEmail: userEmails[doc.data()['ownerId']] ?? 'Owner tidak ditemukan',
        submittedAt: createdAt != null ? _formatRelativeTime(createdAt) : 'Tanggal tidak diketahui',
      );
    }).toList();

    final totalCustomers = usersSnap.docs.where((doc) => doc.data()['role'] == AppConstants.userRole).length;

    return _DashboardData(
      totalSalons: barbershopsSnap.size,
      totalStylists: stylistsSnap.size,
      totalCustomers: totalCustomers,
      totalBookings: bookingsSnap.size,
      totalRevenue: totalRevenue,
      pendingShops: pendingDisplay,
    );
  }

  String _formatCurrency(double value) {
    if (value >= 1000000) {
      return 'Rp ${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) {
      return 'Rp ${(value / 1000).toStringAsFixed(1)}K';
    }
    return 'Rp ${value.toStringAsFixed(0)}';
  }

  String _formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
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

class _DashboardData {
  final int totalSalons;
  final int totalStylists;
  final int totalCustomers;
  final int totalBookings;
  final double totalRevenue;
  final List<_PendingShop> pendingShops;

  const _DashboardData({
    required this.totalSalons,
    required this.totalStylists,
    required this.totalCustomers,
    required this.totalBookings,
    required this.totalRevenue,
    required this.pendingShops,
  });
}

class _PendingShop {
  final String name;
  final String ownerEmail;
  final String submittedAt;

  const _PendingShop({
    required this.name,
    required this.ownerEmail,
    required this.submittedAt,
  });
}
