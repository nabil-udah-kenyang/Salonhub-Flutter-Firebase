import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';

class SuperadminAnalyticsPage extends StatefulWidget {
  const SuperadminAnalyticsPage({super.key});

  @override
  State<SuperadminAnalyticsPage> createState() => _SuperadminAnalyticsPageState();
}

class _SuperadminAnalyticsPageState extends State<SuperadminAnalyticsPage> {
  late DateTimeRange _selectedRange;
  late Future<_AnalyticsData> _analyticsFuture;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedRange = DateTimeRange(
      start: now.subtract(const Duration(days: 29)),
      end: now,
    );
    _analyticsFuture = _loadAnalyticsData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: FutureBuilder<_AnalyticsData>(
          future: _analyticsFuture,
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
                        'Gagal memuat data analytics.\n${snapshot.error ?? ''}',
                        textAlign: TextAlign.center,
                        style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => setState(() => _analyticsFuture = _loadAnalyticsData()),
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
                setState(() => _analyticsFuture = _loadAnalyticsData());
                await _analyticsFuture;
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 16),
                    _buildRangeSelector(),
                    const SizedBox(height: 24),
                    Text('Ringkasan Performa', style: AppTheme.heading2),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildStatCard('Total Booking', data.totalBookings.toString(), Icons.calendar_month, AppTheme.primaryColor)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildStatCard('Pendapatan', _formatCurrency(data.totalRevenue), Icons.payments, AppTheme.successColor)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildStatCard('Salon Baru', data.newBarbershops.toString(), Icons.storefront, AppTheme.infoColor)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildStatCard('User Baru', data.newUsers.toString(), Icons.person_add, AppTheme.warningColor)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text('Pendapatan Platform', style: AppTheme.heading2),
                    const SizedBox(height: 16),
                    _buildRevenueCard(data.totalRevenue, data.completedBookings, data.cancelledBookings),
                    const SizedBox(height: 24),
                    Text('Pendapatan per Salon', style: AppTheme.heading2),
                    const SizedBox(height: 16),
                    _buildRevenueList(data.revenueBySalon),
                    const SizedBox(height: 24),
                    Text('Kategori Layanan Terpopuler', style: AppTheme.heading2),
                    const SizedBox(height: 16),
                    _buildCategoryList(data.topCategories),
                    const SizedBox(height: 24),
                    Text('Aktivitas Harian', style: AppTheme.heading2),
                    const SizedBox(height: 16),
                    _buildDailyChart(data.dailyStats),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRevenueRow(String salon, String revenue, double percentage) {
    final progress = (percentage.clamp(0.0, 100.0)) / 100.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(salon, style: AppTheme.bodyText1.copyWith(fontWeight: FontWeight.w600))),
            Text(revenue, style: AppTheme.bodyText1.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: AppTheme.borderColor,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
        ),
        const SizedBox(height: 4),
        Text('${percentage.toStringAsFixed(1)}% dari total rentang', style: AppTheme.bodyText3.copyWith(color: AppTheme.textSecondaryColor)),
      ],
    );
  }

  Widget _buildCategoryRow(String category, String bookings, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(5)),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(category, style: AppTheme.bodyText1.copyWith(fontWeight: FontWeight.w600))),
        Text(bookings, style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor)),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Analytics Platform', style: AppTheme.heading1),
              const SizedBox(height: 4),
              Text('Pantau kinerja SalonHub berdasarkan data Firestore', style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor)),
            ],
          ),
        ),
        Icon(Icons.analytics_outlined, color: AppTheme.primaryColor, size: 26),
      ],
    );
  }

  Widget _buildRangeSelector() {
    return InkWell(
      onTap: _pickDateRange,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_month, color: AppTheme.primaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Rentang tanggal', style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor)),
                  const SizedBox(height: 2),
                  Text(_formatRange(_selectedRange), style: AppTheme.bodyText1.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Icon(Icons.arrow_drop_down, color: AppTheme.textSecondaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: AppTheme.heading2.copyWith(color: AppTheme.textPrimary, fontWeight: FontWeight.w800)),
                Text(title, style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueCard(double revenue, int completed, int cancelled) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total Pendapatan Platform', style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor)),
          const SizedBox(height: 6),
          Text(_formatCurrency(revenue), style: AppTheme.heading1.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.check_circle, color: AppTheme.successColor),
              const SizedBox(width: 6),
              Text('$completed booking selesai', style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor)),
              const SizedBox(width: 12),
              Icon(Icons.cancel_outlined, color: AppTheme.errorColor),
              const SizedBox(width: 6),
              Text('$cancelled dibatalkan', style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueList(List<_TopItem> items) {
    if (items.isEmpty) {
      return _buildPlaceholder('Belum ada data pendapatan di rentang ini.');
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: items.map((item) => Padding(
              padding: EdgeInsets.only(bottom: item == items.last ? 0 : 12),
              child: _buildRevenueRow(item.label, _formatCurrency(item.value), item.percentage),
            )).toList(),
      ),
    );
  }

  Widget _buildCategoryList(List<_TopItem> items) {
    if (items.isEmpty) {
      return _buildPlaceholder('Belum ada data kategori pada rentang ini.');
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: items.map((item) => Padding(
              padding: EdgeInsets.only(bottom: item == items.last ? 0 : 12),
              child: _buildCategoryRow(item.label, '${item.value.toInt()} booking', AppTheme.primaryColor.withOpacity(0.8)),
            )).toList(),
      ),
    );
  }

  Widget _buildDailyChart(List<_DayStat> stats) {
    if (stats.isEmpty) {
      return _buildPlaceholder('Belum ada aktivitas booking pada rentang ini.');
    }
    final maxCount = stats.map((e) => e.count).fold<int>(0, (max, value) => value > max ? value : max);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        height: 220,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: stats.map((stat) {
            final double heightFactor = maxCount == 0 ? 0 : stat.count / maxCount;
            return Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(stat.count.toString(), style: AppTheme.bodyText3.copyWith(color: AppTheme.textSecondaryColor)),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: 18,
                        height: 150 * heightFactor,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(stat.label, style: AppTheme.bodyText3.copyWith(color: AppTheme.textSecondaryColor)),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppTheme.textSecondaryColor),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor))),
        ],
      ),
    );
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final newRange = await showDateRangePicker(
      context: context,
      initialDateRange: _selectedRange,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
    );
    if (newRange != null) {
      setState(() {
        _selectedRange = newRange;
        _analyticsFuture = _loadAnalyticsData();
      });
    }
  }

  Future<_AnalyticsData> _loadAnalyticsData() async {
    final firestore = FirebaseFirestore.instance;
    final results = await Future.wait([
      firestore.collection(AppConstants.bookingsCollection).get(),
      firestore.collection(AppConstants.barbershopsCollection).get(),
      firestore.collection(AppConstants.usersCollection).get(),
      firestore.collection(AppConstants.servicesCollection).get(),
    ]);

    final bookingsSnap = results[0] as QuerySnapshot<Map<String, dynamic>>;
    final barbershopsSnap = results[1] as QuerySnapshot<Map<String, dynamic>>;
    final usersSnap = results[2] as QuerySnapshot<Map<String, dynamic>>;
    final servicesSnap = results[3] as QuerySnapshot<Map<String, dynamic>>;

    final start = DateTime(_selectedRange.start.year, _selectedRange.start.month, _selectedRange.start.day);
    final end = DateTime(_selectedRange.end.year, _selectedRange.end.month, _selectedRange.end.day, 23, 59, 59);

    final serviceCategories = {
      for (final doc in servicesSnap.docs) doc.id: (doc.data()['category'] ?? 'Lainnya').toString(),
    };
    final barbershopNames = {
      for (final doc in barbershopsSnap.docs) doc.id: (doc.data()['name'] ?? 'Barbershop').toString(),
    };

    double totalRevenue = 0;
    int totalBookings = 0;
    int completedBookings = 0;
    int cancelledBookings = 0;
    final Map<String, double> revenueBySalon = {};
    final Map<String, int> categoryCounts = {};
    final Map<String, int> dailyCounts = {};

    for (final doc in bookingsSnap.docs) {
      final bookingDate = (doc.data()['bookingDate'] as Timestamp?)?.toDate();
      if (bookingDate == null) continue;
      if (bookingDate.isBefore(start) || bookingDate.isAfter(end)) continue;

      totalBookings++;
      final totalPrice = (doc.data()['totalPrice'] as num?)?.toDouble() ?? 0;
      totalRevenue += totalPrice;

      final barbershopId = doc.data()['barbershopId']?.toString() ?? '';
      if (barbershopId.isNotEmpty) {
        revenueBySalon[barbershopId] = (revenueBySalon[barbershopId] ?? 0) + totalPrice;
      }

      final status = doc.data()['status']?.toString() ?? '';
      if (status == AppConstants.bookingCompleted) {
        completedBookings++;
      } else if (status == AppConstants.bookingCancelled) {
        cancelledBookings++;
      }

      final dayKey = DateTime(bookingDate.year, bookingDate.month, bookingDate.day).toIso8601String();
      dailyCounts[dayKey] = (dailyCounts[dayKey] ?? 0) + 1;

      final List<dynamic> serviceIds = doc.data()['serviceIds'] ?? [];
      for (final id in serviceIds) {
        final category = serviceCategories[id?.toString()] ?? 'Lainnya';
        categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
      }
    }

    final newUsers = usersSnap.docs.where((doc) {
      final createdAt = (doc.data()['createdAt'] as Timestamp?)?.toDate();
      if (createdAt == null) return false;
      return !createdAt.isBefore(start) && !createdAt.isAfter(end);
    }).length;

    final newBarbershops = barbershopsSnap.docs.where((doc) {
      final createdAt = (doc.data()['createdAt'] as Timestamp?)?.toDate();
      if (createdAt == null) return false;
      return !createdAt.isBefore(start) && !createdAt.isAfter(end);
    }).length;

    final topSalons = revenueBySalon.entries
        .map((entry) => _TopItem(
              label: barbershopNames[entry.key] ?? 'Barbershop',
              value: entry.value,
              percentage: totalRevenue == 0 ? 0 : (entry.value / totalRevenue) * 100,
            ))
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topCategories = categoryCounts.entries
        .map((entry) => _TopItem(label: entry.key, value: entry.value.toDouble(), percentage: 0))
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final dailyStats = dailyCounts.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final mappedDailyStats = dailyStats.map((entry) {
      final date = DateTime.parse(entry.key);
      return _DayStat(label: '${date.day}/${date.month}', count: entry.value);
    }).toList();

    return _AnalyticsData(
      totalRevenue: totalRevenue,
      totalBookings: totalBookings,
      completedBookings: completedBookings,
      cancelledBookings: cancelledBookings,
      newUsers: newUsers,
      newBarbershops: newBarbershops,
      revenueBySalon: topSalons.take(5).toList(),
      topCategories: topCategories.take(4).toList(),
      dailyStats: mappedDailyStats.take(7).toList(),
    );
  }

  String _formatRange(DateTimeRange range) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${range.start.day} ${months[range.start.month - 1]} ${range.start.year} - ${range.end.day} ${months[range.end.month - 1]} ${range.end.year}';
  }

  String _formatCurrency(double value) {
    if (value >= 1000000000) {
      return 'Rp ${(value / 1000000000).toStringAsFixed(1)}B';
    }
    if (value >= 1000000) {
      return 'Rp ${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) {
      return 'Rp ${(value / 1000).toStringAsFixed(1)}K';
    }
    return 'Rp ${value.toStringAsFixed(0)}';
  }
}

class _AnalyticsData {
  final double totalRevenue;
  final int totalBookings;
  final int completedBookings;
  final int cancelledBookings;
  final int newUsers;
  final int newBarbershops;
  final List<_TopItem> revenueBySalon;
  final List<_TopItem> topCategories;
  final List<_DayStat> dailyStats;

  const _AnalyticsData({
    required this.totalRevenue,
    required this.totalBookings,
    required this.completedBookings,
    required this.cancelledBookings,
    required this.newUsers,
    required this.newBarbershops,
    required this.revenueBySalon,
    required this.topCategories,
    required this.dailyStats,
  });
}

class _TopItem {
  final String label;
  final double value;
  final double percentage;

  const _TopItem({
    required this.label,
    required this.value,
    required this.percentage,
  });
}

class _DayStat {
  final String label;
  final int count;

  const _DayStat({required this.label, required this.count});
}
