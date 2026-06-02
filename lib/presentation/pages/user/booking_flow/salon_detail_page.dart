import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/image_base64_utils.dart';
import '../../../../core/utils/rating_formatter.dart';
import '../../../../data/models/barbershop_model.dart';
import '../../../../data/repositories/service_repository.dart';
import '../../../../data/repositories/stylist_repository.dart';
import 'service_selection_page.dart';

class SalonDetailPage extends StatelessWidget {
  final BarbershopModel barbershop;
  final ServiceRepository _serviceRepository = ServiceRepository();
  final StylistRepository _stylistRepository = StylistRepository();

  SalonDetailPage({
    super.key,
    required this.barbershop,
  });

  @override
  Widget build(BuildContext context) {
    final isSuspended = !barbershop.isActive;
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // Header Image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: AppTheme.primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.cardGradient,
                ),
                child: Stack(
                  children: [
                    _buildCoverImage(),
                    // Back Button
                    Positioned(
                      top: 60,
                      left: 20,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.shadowColor,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: () => Get.back(),
                          icon: Icon(
                            Icons.arrow_back,
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    // Favorite Button
                    Positioned(
                      top: 60,
                      right: 20,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.shadowColor,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: () {
                            // Add to favorites logic
                          },
                          icon: Icon(
                            Icons.favorite_border_outlined,
                            color: AppTheme.errorColor,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Salon Info
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.shadowColor,
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isSuspended)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.errorColor.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: AppTheme.errorColor),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Salon ini sedang disuspend oleh admin. Booking sementara tidak tersedia.',
                              style: AppTheme.bodyText2.copyWith(color: AppTheme.errorColor, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          barbershop.name,
                          style: AppTheme.heading2.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.successColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              color: AppTheme.warningColor,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              RatingFormatter.display(barbershop.rating),
                              style: AppTheme.bodyText2.copyWith(
                                color: AppTheme.successColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: AppTheme.textSecondary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          barbershop.address,
                          style: AppTheme.bodyText1.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Quick Info
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _buildInfoChip(
                        isSuspended ? 'Suspended' : 'Buka',
                        Icons.access_time,
                        isSuspended ? AppTheme.errorColor : AppTheme.successColor,
                      ),
                      _buildInfoChip(
                        '${barbershop.totalReviews} Review',
                        Icons.reviews,
                        AppTheme.primaryColor,
                      ),
                      _buildInfoChip(
                        'Tersedia',
                        Icons.check_circle,
                        AppTheme.infoColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          
          // Description
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tentang Salon',
                    style: AppTheme.heading2.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    barbershop.description,
                    style: AppTheme.bodyText1.copyWith(
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
          
          // Services Preview
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Layanan Populer',
                          style: AppTheme.heading2.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        'Lihat Semua',
                        style: AppTheme.bodyText1.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder(
                    future: barbershop.id == null
                        ? null
                        : _serviceRepository.getServicesByBarbershopId(barbershop.id!),
                    builder: (context, snapshot) {
                      final services = snapshot.data ?? [];
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          height: 150,
                          child: Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
                        );
                      }
                      if (services.isEmpty) {
                        return _buildEmptyPreview('Belum ada layanan di database.');
                      }
                      return SizedBox(
                        height: 150,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: services.take(6).length,
                          separatorBuilder: (context, index) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final service = services[index];
                            return _buildServiceCard(
                              service.name,
                              'Rp ${service.price.toStringAsFixed(0)}',
                              '${service.duration} menit',
                              Icons.content_cut,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
          
          // Stylists Preview
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Stylist Kami',
                          style: AppTheme.heading2.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        'Lihat Semua',
                        style: AppTheme.bodyText1.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder(
                    future: barbershop.id == null
                        ? null
                        : _stylistRepository.getStylistsByBarbershopId(barbershop.id!),
                    builder: (context, snapshot) {
                      final stylists = snapshot.data ?? [];
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          height: 142,
                          child: Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
                        );
                      }
                      if (stylists.isEmpty) {
                        return _buildEmptyPreview('Belum ada stylist di database.');
                      }
                      return SizedBox(
                        height: 142,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: stylists.take(6).length,
                          separatorBuilder: (context, index) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final stylist = stylists[index];
                            return _buildStylistCard(
                              stylist.name,
                              stylist.specializations.isNotEmpty ? stylist.specializations.first : 'Stylist',
                              '${stylist.experience} tahun',
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
          
          // Operating Hours
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jam Operasional',
                    style: AppTheme.heading2.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
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
                        _buildOperatingHour('Senin', '09:00 - 21:00', true),
                        _buildOperatingHour('Selasa', '09:00 - 21:00', true),
                        _buildOperatingHour('Rabu', '09:00 - 21:00', true),
                        _buildOperatingHour('Kamis', '09:00 - 21:00', true),
                        _buildOperatingHour('Jumat', '09:00 - 22:00', true),
                        _buildOperatingHour('Sabtu', '08:00 - 22:00', true),
                        _buildOperatingHour('Minggu', '08:00 - 20:00', true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          boxShadow: [
            BoxShadow(
              color: AppTheme.shadowColor,
              blurRadius: 15,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isSuspended ? null : () => _openServiceSelection(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 54),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: Text(
            isSuspended ? 'Salon Disuspend' : 'Pesan Sekarang',
            style: AppTheme.bodyText1.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoverImage() {
    final coverPhoto = barbershop.photos.length > 1 ? barbershop.photos[1] : '';

    if (coverPhoto.isEmpty) {
      return SvgPicture.asset(
        'lib/assets/images/admin_barber_cover.svg',
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      );
    }

    final imageBytes = ImageBase64Utils.decode(coverPhoto);
    if (imageBytes != null) {
      return Image.memory(
        imageBytes,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      );
    }

    if (coverPhoto.startsWith('http')) {
      return Image.network(
        coverPhoto,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => SvgPicture.asset(
          'lib/assets/images/admin_barber_cover.svg',
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    }

    return SvgPicture.asset(
      coverPhoto,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
    );
  }

  Future<void> _openServiceSelection() async {
    final barbershopId = barbershop.id;
    if (barbershopId == null || barbershopId.isEmpty) {
      Get.snackbar('Data belum lengkap', 'ID barbershop tidak ditemukan.');
      return;
    }

    Get.dialog(
      const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
      barrierDismissible: false,
    );

    try {
      final services = await _serviceRepository.getServicesByBarbershopId(barbershopId);
      final stylists = await _stylistRepository.getStylistsByBarbershopId(barbershopId);

      Get.back();

      if (services.isEmpty || stylists.isEmpty) {
        Get.snackbar(
          'Belum tersedia',
          'Layanan atau stylist untuk barbershop ini belum tersedia di database.',
        );
        return;
      }

      Get.to(() => ServiceSelectionPage(
        barbershop: barbershop,
        services: services,
        stylists: stylists,
      ));
    } catch (e) {
      Get.back();
      Get.snackbar('Gagal memuat data', 'Layanan dan stylist gagal dimuat dari database.');
    }
  }

  Widget _buildEmptyPreview(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Text(
        message,
        style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor),
        textAlign: TextAlign.center,
      ),
    );
  }
  
  Widget _buildInfoChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTheme.bodyText2.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
  
  Widget _buildServiceCard(
    String name,
    String price,
    String duration,
    IconData icon,
  ) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            name,
            style: AppTheme.bodyText1.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            price,
            style: AppTheme.bodyText2.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                duration,
                style: AppTheme.bodyText3.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStylistCard(
    String name,
    String role,
    String experience,
  ) {
    return Container(
      width: 112,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              Icons.person_outline,
              color: AppTheme.primaryColor,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: AppTheme.bodyText2.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            role,
            style: AppTheme.bodyText3.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            experience,
            style: AppTheme.bodyText3.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
  
  Widget _buildOperatingHour(String day, String hours, bool isOpen) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.borderColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              day,
              style: AppTheme.bodyText1.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Row(
            children: [
              Text(
                hours,
                style: AppTheme.bodyText1.copyWith(
                  color: isOpen ? AppTheme.successColor : AppTheme.textSecondary,
                ),
              ),
              if (isOpen) ...[
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppTheme.successColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
