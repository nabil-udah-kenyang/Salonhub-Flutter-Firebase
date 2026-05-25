import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../data/repositories/service_repository.dart';
import '../../../data/repositories/stylist_repository.dart';
import '../../controllers/auth_controller.dart';
import '../../helpers/admin_barbershop_helper.dart';

class AdminBookingsPage extends StatefulWidget {
  const AdminBookingsPage({super.key});

  @override
  State<AdminBookingsPage> createState() => _AdminBookingsPageState();
}

class _AdminBookingsPageState extends State<AdminBookingsPage> {
  final AuthController _authController = Get.find<AuthController>();
  final BookingRepository _bookingRepository = BookingRepository();
  final StylistRepository _stylistRepository = StylistRepository();
  final ServiceRepository _serviceRepository = ServiceRepository();

  final List<String> _statusFilters = ['Semua', 'pending', 'confirmed', 'completed', 'cancelled'];
  String _selectedStatus = 'Semua';
  String? _barbershopId;
  bool _isLoadingBarbershop = true;
  Map<String, String> _stylistNameCache = {};
  Map<String, String> _serviceNameCache = {};
  final Map<String, String> _userNameCache = {};

  @override
  void initState() {
    super.initState();
    _initContext();
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_busy, size: 40, color: AppTheme.textSecondaryColor),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _initContext() async {
    final barbershopId = await AdminBarbershopHelper.fetchPrimaryBarbershopId(_authController);
    if (!mounted) return;
    setState(() {
      _barbershopId = barbershopId;
      _isLoadingBarbershop = false;
    });
    if (barbershopId != null) {
      await _warmupCaches(barbershopId);
    }
  }

  Future<void> _warmupCaches(String barbershopId) async {
    final stylists = await _stylistRepository.getStylistsByBarbershopId(barbershopId);
    final services = await _serviceRepository.getServicesByBarbershopId(barbershopId);
    setState(() {
      _stylistNameCache = {for (final stylist in stylists) stylist.id!: stylist.name};
      _serviceNameCache = {for (final service in services) service.id!: service.name};
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingBarbershop) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)));
    }

    if (_barbershopId == null) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Belum ada data barbershop untuk akun ini. Hubungi tim SalonHub untuk menghubungkan akun admin ke barbershop tertentu.',
              textAlign: TextAlign.center,
              style: AppTheme.bodyText1.copyWith(color: AppTheme.textSecondaryColor),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildStatusTabs(),
            Expanded(
              child: StreamBuilder<List<BookingModel>>(
                stream: _bookingRepository.streamBookingsByBarbershopId(_barbershopId!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
                  }

                  final bookings = _filterBookings(snapshot.data ?? []);
                  final stats = _computeStats(snapshot.data ?? []);

                  return Column(
                    children: [
                      _buildStatsRow(stats),
                      const SizedBox(height: 12),
                      Expanded(
                        child: bookings.isEmpty
                            ? _buildEmptyState('Belum ada booking dengan filter ini. Pelanggan akan muncul di sini setelah melakukan reservasi.')
                            : ListView.separated(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                                itemCount: bookings.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 12),
                                itemBuilder: (context, index) => _buildBookingCard(bookings[index]),
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kelola Booking', style: AppTheme.heading1),
                const SizedBox(height: 4),
                Text(
                  'Pantau semua jadwal pelanggan secara real-time dan ubah statusnya kapan saja.',
                  style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryExtraLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.event_available_rounded, color: AppTheme.primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: _statusFilters.map((status) {
          final isSelected = status == _selectedStatus;
          final label = status == 'Semua'
              ? 'Semua'
              : status == 'pending'
                  ? 'Menunggu'
                  : status == 'confirmed'
                      ? 'Dikonfirmasi'
                      : status == 'completed'
                          ? 'Selesai'
                          : 'Dibatalkan';
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedStatus = status),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryColor : AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor),
                ),
                child: Text(
                  label,
                  style: AppTheme.bodyText2.copyWith(
                    color: isSelected ? Colors.white : AppTheme.textPrimaryColor,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatsRow(Map<String, dynamic> stats) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: _buildStatCard('Total Booking', stats['total'].toString(), AppTheme.primaryColor)),
          const SizedBox(width: 8),
          Expanded(child: _buildStatCard('Selesai', stats['completed'].toString(), AppTheme.successColor)),
          const SizedBox(width: 8),
          Expanded(child: _buildStatCard('Dibatalkan', stats['cancelled'].toString(), AppTheme.errorColor)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: AppTheme.heading2.copyWith(color: color)),
          const SizedBox(height: 4),
          Text(title, style: AppTheme.bodyText2.copyWith(color: color.withValues(alpha: 0.9))),
        ],
      ),
    );
  }

  Widget _buildBookingCard(BookingModel booking) {
    final customerNameFuture = _loadUserName(booking.userId);
    final serviceNames = booking.serviceIds.map((id) => _serviceNameCache[id] ?? 'Layanan').toList();
    final stylistName = _stylistNameCache[booking.stylistId] ?? 'Stylist';
    final statusLabel = _statusLabel(booking.status);
    final statusColor = _statusColor(booking.status);
    final canTakeAction = _canTakeAction(booking.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<String>(
            future: customerNameFuture,
            builder: (context, snapshot) {
              final customerName = snapshot.data ?? 'Pelanggan';
              return Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(customerName, style: AppTheme.heading3),
                        const SizedBox(height: 4),
                        Text(serviceNames.join(' + '), maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(_formatDate(booking.bookingDate), style: AppTheme.bodyText2),
                      Text(booking.bookingTime, style: AppTheme.bodyText1.copyWith(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.person_outline, size: 16, color: AppTheme.textSecondaryColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text('Stylist: $stylistName', style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(statusLabel, style: AppTheme.bodyText3.copyWith(color: statusColor, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showBookingDetail(booking, stylistName, serviceNames),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: AppTheme.borderColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Detail'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: canTakeAction ? () => _openStatusAction(booking) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canTakeAction ? AppTheme.primaryColor : AppTheme.borderColor,
                    foregroundColor: canTakeAction ? Colors.white : AppTheme.textSecondaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(canTakeAction ? 'Aksi' : 'Tidak Ada Aksi'),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  List<BookingModel> _filterBookings(List<BookingModel> bookings) {
    bookings.sort((a, b) {
      final dateCompare = b.bookingDate.compareTo(a.bookingDate);
      if (dateCompare != 0) return dateCompare;
      return b.bookingTime.compareTo(a.bookingTime);
    });

    if (_selectedStatus == 'Semua') {
      return bookings;
    }
    return bookings.where((booking) => booking.status == _selectedStatus).toList();
  }

  Map<String, dynamic> _computeStats(List<BookingModel> bookings) {
    final total = bookings.length;
    final completed = bookings.where((b) => b.status == 'completed').length;
    final cancelled = bookings.where((b) => b.status == 'cancelled').length;
    return {'total': total, 'completed': completed, 'cancelled': cancelled};
  }

  Future<String> _loadUserName(String userId) async {
    if (_userNameCache.containsKey(userId)) return _userNameCache[userId]!;
    final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final name = doc.data()?['name']?.toString() ?? 'Pelanggan';
    _userNameCache[userId] = name;
    return name;
  }

  Future<void> _openStatusAction(BookingModel booking) async {
    final actions = _statusActionsFor(booking);
    if (actions.isEmpty) return;

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(width: 50, height: 4, decoration: BoxDecoration(color: AppTheme.borderColor, borderRadius: BorderRadius.circular(2))),
                ),
                const SizedBox(height: 16),
                Text('Aksi Booking', style: AppTheme.heading3),
                const SizedBox(height: 12),
                ...actions.map(
                  (action) => _buildActionTile(action.icon, action.label, action.onTap),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _canTakeAction(String status) {
    return !_isFinalStatus(status);
  }

  bool _isFinalStatus(String status) {
    return status == 'completed' || status == 'cancelled';
  }

  List<_BookingAction> _statusActionsFor(BookingModel booking) {
    switch (booking.status) {
      case 'pending':
        return [
          _BookingAction(
            Icons.done_all,
            'Konfirmasi booking',
            () => _updateStatus(booking, 'confirmed'),
          ),
          _BookingAction(
            Icons.close_rounded,
            'Batalkan booking',
            () => _cancelBooking(booking),
          ),
        ];
      case 'confirmed':
      case 'in_progress':
      case 'rescheduled':
        return [
          _BookingAction(
            Icons.check_circle,
            'Tandai selesai',
            () => _updateStatus(booking, 'completed'),
          ),
          _BookingAction(
            Icons.close_rounded,
            'Batalkan booking',
            () => _cancelBooking(booking),
          ),
        ];
      default:
        return [];
    }
  }

  Widget _buildActionTile(IconData icon, String label, Future<void> Function() onTap) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(label, style: AppTheme.bodyText1),
      onTap: () async {
        Navigator.pop(context);
        await onTap();
      },
    );
  }

  Future<void> _updateStatus(BookingModel booking, String status) async {
    await _bookingRepository.updateBookingStatus(booking.id!, status);
    Get.snackbar('Berhasil', 'Status booking diperbarui menjadi ${_statusLabel(status)}');
  }

  Future<void> _cancelBooking(BookingModel booking) async {
    final reasonController = TextEditingController();
    final shouldCancel = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Batalkan Booking'),
            content: TextField(
              controller: reasonController,
              decoration: const InputDecoration(hintText: 'Alasan pembatalan (opsional)'),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
                child: const Text('Batalkan'),
              ),
            ],
          ),
        ) ??
        false;
    if (!shouldCancel) return;
    await _bookingRepository.cancelBooking(booking.id!, reasonController.text.trim().isEmpty ? 'Dibatalkan oleh admin' : reasonController.text.trim());
    Get.snackbar('Booking dibatalkan', 'Kami memberitahu pelanggan terkait pembatalan ini');
  }

  void _showBookingDetail(BookingModel booking, String stylistName, List<String> services) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(width: 60, height: 4, decoration: BoxDecoration(color: AppTheme.borderColor, borderRadius: BorderRadius.circular(2))),
                ),
                const SizedBox(height: 16),
                Text('Detail Booking', style: AppTheme.heading2),
                const SizedBox(height: 12),
                _detailRow('Tanggal', _formatFullDate(booking.bookingDate)),
                _detailRow('Waktu', booking.bookingTime),
                _detailRow('Layanan', services.join(', ')),
                _detailRow('Stylist', stylistName),
                _detailRow('Status', _statusLabel(booking.status)),
                _detailRow('Nominal', _formatRupiah(booking.totalPrice)),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Tutup'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor)),
          ),
          Expanded(
            child: Text(value, style: AppTheme.bodyText1.copyWith(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${date.day} ${months[date.month - 1]}';
  }

  String _formatFullDate(DateTime date) {
    const months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatRupiah(double value) => 'Rp ${value.toStringAsFixed(0)}';

  String _statusLabel(String status) {
    switch (status) {
      case 'confirmed':
        return 'Dikonfirmasi';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      case 'rescheduled':
        return 'Dijadwalkan ulang';
      default:
        return 'Menunggu';
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'confirmed':
        return AppTheme.primaryColor;
      case 'completed':
        return AppTheme.successColor;
      case 'cancelled':
        return AppTheme.errorColor;
      case 'rescheduled':
        return AppTheme.warningColor;
      default:
        return AppTheme.textSecondaryColor;
    }
  }
}

class _BookingAction {
  final IconData icon;
  final String label;
  final Future<void> Function() onTap;

  const _BookingAction(this.icon, this.label, this.onTap);
}
