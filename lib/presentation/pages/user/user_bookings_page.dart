import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/barbershop_model.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/models/service_model.dart';
import '../../../data/models/stylist_model.dart';
import '../../../data/repositories/barbershop_repository.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../data/repositories/service_repository.dart';
import '../../../data/repositories/stylist_repository.dart';
import '../../controllers/auth_controller.dart';
import 'user_search_page.dart';

class UserBookingsPage extends StatefulWidget {
  const UserBookingsPage({super.key});

  @override
  State<UserBookingsPage> createState() => _UserBookingsPageState();
}

class _UserBookingsPageState extends State<UserBookingsPage> {
  final BookingRepository _bookingRepository = BookingRepository();
  final BarbershopRepository _barbershopRepository = BarbershopRepository();
  final ServiceRepository _serviceRepository = ServiceRepository();
  final StylistRepository _stylistRepository = StylistRepository();
  int _selectedTabIndex = 0;
  String? _cancellingBookingId;
  String? _ratingBookingId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Booking Saya',
                      style: AppTheme.heading1,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.to(() => const UserSearchPage()),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Booking Baru',
                        style: AppTheme.bodyText3.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Tabs
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildStatusTab('Aktif', 0),
                  const SizedBox(width: 8),
                  _buildStatusTab('Selesai', 1),
                  const SizedBox(width: 8),
                  _buildStatusTab('Dibatalkan', 2),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Bookings List
            Expanded(
              child: _buildUserBookings(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserBookings() {
    final authController = Get.find<AuthController>();
    final userId = authController.user?.id;

    if (userId == null || userId.isEmpty) {
      return Center(
        child: Text(
          'Silakan login untuk melihat booking.',
          style: AppTheme.bodyText2.copyWith(
            color: AppTheme.textSecondaryColor,
          ),
        ),
      );
    }

    return StreamBuilder<List<BookingModel>>(
      stream: _bookingRepository.streamBookingsByUserId(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryColor,
            ),
          );
        }

        final bookings = snapshot.data ?? [];
        bookings.sort((a, b) {
          final dateCompare = b.bookingDate.compareTo(a.bookingDate);
          if (dateCompare != 0) return dateCompare;
          return b.bookingTime.compareTo(a.bookingTime);
        });

        final filtered = _filterBookings(bookings);

        if (filtered.isEmpty) {
          return _buildEmptyStateMessage();
        }

        return FutureBuilder<_BookingLookupData>(
          future: _loadBookingLookupData(),
          builder: (context, lookupSnapshot) {
            final lookup = lookupSnapshot.data ?? _BookingLookupData.empty();
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              separatorBuilder: (context, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final booking = filtered[index];
                final salon = lookup.barbershops[booking.barbershopId];
                final serviceNames = booking.serviceIds
                    .map((id) => lookup.services[id]?.name)
                    .whereType<String>()
                    .toList();
                final servicesSummary = serviceNames.isEmpty
                    ? '${booking.serviceIds.length} layanan'
                    : serviceNames.join(' + ');
                final canCancel = _canCancelStatus(booking.status) && booking.id != null;
                final canReview = _canReviewBooking(booking);
                final isCancelling = _cancellingBookingId == booking.id;
                final isRating = _ratingBookingId == booking.id;

                return _buildBookingCard(
                  bookingCode: booking.id ?? '-',
                  salonName: salon?.name ?? 'Barbershop tidak ditemukan',
                  service: servicesSummary,
                  dateTime: '${_formatDate(booking.bookingDate)}, ${booking.bookingTime}',
                  address: salon?.address ?? 'Alamat belum tersedia',
                  status: _statusLabel(booking.status),
                  statusColor: _statusColor(booking.status),
                  onDetail: () => _showBookingDetail(booking, salon, serviceNames, lookup.stylists[booking.stylistId]?.name),
                  canCancel: canCancel,
                  onCancel: canCancel ? () => _confirmCancel(booking) : null,
                  isCancelling: isCancelling,
                  canReview: canReview,
                  onReview: canReview ? () => _showRatingDialog(booking) : null,
                  isReviewed: booking.isReviewed,
                  isRating: isRating,
                );
              },
            );
          },
        );
      },
    );
  }
  
  Widget _buildBookingCard({
    required String bookingCode,
    required String salonName,
    required String service,
    required String dateTime,
    required String address,
    required String status,
    required Color statusColor,
    required VoidCallback onDetail,
    required bool canCancel,
    VoidCallback? onCancel,
    bool isCancelling = false,
    required bool canReview,
    VoidCallback? onReview,
    bool isReviewed = false,
    bool isRating = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
                      salonName,
                      style: AppTheme.heading3,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kode: $bookingCode',
                      style: AppTheme.bodyText2.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      service,
                      style: AppTheme.bodyText1.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: AppTheme.bodyText3.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: AppTheme.textSecondaryColor,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                dateTime,
                style: AppTheme.bodyText2.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: AppTheme.textSecondaryColor,
                size: 16,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  address,
                  style: AppTheme.bodyText2.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onDetail,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: AppTheme.borderColor),
                  ),
                  child: Text(
                    'Detail Booking',
                    style: AppTheme.bodyText2.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextButton(
                  onPressed: canReview
                      ? (isRating ? null : onReview)
                      : (canCancel && !isCancelling)
                          ? onCancel
                          : null,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: canReview
                        ? AppTheme.warningColor.withValues(alpha: 0.12)
                        : canCancel
                            ? Colors.red.withValues(alpha: 0.1)
                            : AppTheme.borderColor.withValues(alpha: 0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isCancelling || isRating
                      ? SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: isRating ? AppTheme.warningColor : Colors.red,
                          ),
                        )
                      : Text(
                          canReview
                              ? 'Beri Rating'
                              : isReviewed
                                  ? 'Sudah Rating'
                                  : canCancel
                                      ? 'Batalkan'
                                      : 'Tidak Bisa',
                          style: AppTheme.bodyText2.copyWith(
                            color: canReview
                                ? AppTheme.warningColor
                                : canCancel
                                    ? Colors.red
                                    : AppTheme.textSecondaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTab(String label, int index) {
    final isActive = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_selectedTabIndex != index) {
            setState(() => _selectedTabIndex = index);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primaryColor : AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive
                  ? AppTheme.primaryColor
                  : AppTheme.borderColor,
            ),
          ),
          child: Text(
            label,
            style: AppTheme.bodyText2.copyWith(
              color: isActive ? Colors.white : AppTheme.textPrimaryColor,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyStateMessage() {
    final copy = _selectedTabIndex == 0
        ? 'Belum ada booking aktif. Mulai buat jadwal baru untuk melihatnya di sini.'
        : _selectedTabIndex == 1
            ? 'Belum ada booking selesai. Booking yang telah selesai akan tampil di sini.'
            : 'Belum ada booking dibatalkan.';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_busy,
              size: 36,
              color: AppTheme.textSecondaryColor,
            ),
            const SizedBox(height: 12),
            Text(
              copy,
              textAlign: TextAlign.center,
              style: AppTheme.bodyText2.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<BookingModel> _filterBookings(List<BookingModel> bookings) {
    switch (_selectedTabIndex) {
      case 1:
        return bookings.where((booking) => booking.status == 'completed').toList();
      case 2:
        return bookings.where((booking) => booking.status == 'cancelled').toList();
      default:
        return bookings
            .where((booking) => !_isFinalStatus(booking.status))
            .toList();
    }
  }

  bool _isFinalStatus(String status) {
    return status == 'completed' || status == 'cancelled';
  }

  bool _canCancelStatus(String status) {
    return status == 'pending';
  }

  bool _canReviewBooking(BookingModel booking) {
    return booking.id != null &&
        booking.status == 'completed' &&
        !booking.isReviewed;
  }

  Future<void> _showRatingDialog(BookingModel booking) async {
    if (booking.id == null) return;

    var selectedRating = 5;
    final rating = await showDialog<int>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Beri Rating Barbershop'),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starValue = index + 1;
                  final isSelected = starValue <= selectedRating;
                  return IconButton(
                    onPressed: () {
                      setDialogState(() => selectedRating = starValue);
                    },
                    icon: Icon(
                      isSelected ? Icons.star : Icons.star_border,
                      color: AppTheme.warningColor,
                      size: 34,
                    ),
                  );
                }),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(selectedRating),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Kirim'),
                ),
              ],
            );
          },
        );
      },
    );

    if (rating == null) {
      return;
    }

    setState(() => _ratingBookingId = booking.id);
    try {
      await _barbershopRepository.submitRating(
        bookingId: booking.id!,
        barbershopId: booking.barbershopId,
        rating: rating,
      );

      if (mounted) {
        Get.snackbar(
          'Terima kasih',
          'Rating barbershop berhasil disimpan.',
          backgroundColor: AppTheme.surfaceColor,
          colorText: AppTheme.textPrimaryColor,
        );
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Gagal menyimpan rating',
          e.toString(),
          backgroundColor: AppTheme.errorColor.withValues(alpha: 0.1),
          colorText: AppTheme.errorColor,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _ratingBookingId = null);
      }
    }
  }

  Future<void> _confirmCancel(BookingModel booking) async {
    if (booking.id == null) return;
    final shouldCancel = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Batalkan Booking?'),
              content: const Text(
                'Salon akan diberitahu jika kamu membatalkan booking ini.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Kembali'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorColor,
                  ),
                  child: const Text('Batalkan'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!shouldCancel) {
      return;
    }

    setState(() => _cancellingBookingId = booking.id);
    try {
      await _bookingRepository.cancelBooking(
        booking.id!,
        'Dibatalkan oleh pengguna',
      );
      if (mounted) {
        Get.snackbar(
          'Booking dibatalkan',
          'Kami telah menginformasikan salon terkait.',
          backgroundColor: AppTheme.surfaceColor,
          colorText: AppTheme.textPrimaryColor,
        );
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Gagal membatalkan',
          e.toString(),
          backgroundColor: AppTheme.errorColor.withValues(alpha: 0.1),
          colorText: AppTheme.errorColor,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _cancellingBookingId = null);
      }
    }
  }

  void _showBookingDetail(
    BookingModel booking,
    BarbershopModel? salon,
    List<String> services,
    String? stylistName,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.borderColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  'Detail Booking',
                  style: AppTheme.heading2,
                ),
                const SizedBox(height: 16),
                _buildDetailRow('Kode Booking', booking.id ?? '-'),
                _buildDetailRow('Salon', salon?.name ?? 'Barbershop tidak ditemukan'),
                _buildDetailRow('Alamat', salon?.address ?? 'Alamat belum tersedia'),
                _buildDetailRow(
                  'Layanan',
                  services.isEmpty ? '${booking.serviceIds.length} layanan' : services.join(', '),
                ),
                _buildDetailRow(
                  'Stylist',
                  stylistName ?? 'Belum ditentukan',
                ),
                _buildDetailRow(
                  'Jadwal',
                  '${_formatFullDate(booking.bookingDate)} • ${booking.bookingTime}',
                ),
                _buildDetailRow(
                  'Total Pembayaran',
                  'Rp ${booking.totalPrice.toStringAsFixed(0)}',
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => Get.back(),
                  child: const Text('Tutup'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTheme.bodyText2.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: AppTheme.bodyText1.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  String _formatFullDate(DateTime date) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<_BookingLookupData> _loadBookingLookupData() async {
    final barbershops = await _barbershopRepository.streamApprovedBarbershops(activeOnly: false).first;
    final services = await _serviceRepository.getAllServices();
    final stylists = await _stylistRepository.getAllStylists();
    return _BookingLookupData(
      barbershops: {for (final item in barbershops) if (item.id != null) item.id!: item},
      services: {for (final item in services) if (item.id != null) item.id!: item},
      stylists: {for (final item in stylists) if (item.id != null) item.id!: item},
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'confirmed':
        return 'Dikonfirmasi';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
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
      default:
        return AppTheme.warningColor;
    }
  }
}

class _BookingLookupData {
  final Map<String, BarbershopModel> barbershops;
  final Map<String, ServiceModel> services;
  final Map<String, StylistModel> stylists;

  _BookingLookupData({
    required this.barbershops,
    required this.services,
    required this.stylists,
  });

  factory _BookingLookupData.empty() {
    return _BookingLookupData(
      barbershops: {},
      services: {},
      stylists: {},
    );
  }
}
