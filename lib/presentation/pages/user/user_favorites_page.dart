import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/image_base64_utils.dart';
import '../../../core/utils/rating_formatter.dart';
import '../../../data/models/barbershop_model.dart';
import '../../../data/repositories/barbershop_repository.dart';
import '../../../core/constants/app_constants.dart';
import '../../controllers/auth_controller.dart';
import 'booking_flow/salon_detail_page.dart';

class UserFavoritesPage extends StatelessWidget {
  UserFavoritesPage({super.key});

  final BarbershopRepository _barbershopRepository = BarbershopRepository();

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    final userId = authController.user?.id;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(child: Text('Favorit Saya', style: AppTheme.heading1)),
                  Icon(Icons.favorite, color: AppTheme.primaryColor, size: 24),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: userId == null
                  ? _buildEmptyFavoriteState(message: 'Silakan login untuk melihat favorit kamu.')
                  : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection(AppConstants.usersCollection)
                          .doc(userId)
                          .snapshots(),
                      builder: (context, userSnapshot) {
                        if (userSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
                        }

                        final prefs = userSnapshot.data?.data()?['preferences'] as Map<String, dynamic>?;
                        final favoriteIds = (prefs?['favoriteBarbershopIds'] as List?)
                                ?.map((id) => id.toString())
                                .toList() ??
                            [];

                        if (favoriteIds.isEmpty) {
                          return _buildEmptyFavoriteState();
                        }

                        return StreamBuilder<List<BarbershopModel>>(
                          stream: _barbershopRepository.streamApprovedBarbershops(activeOnly: false),
                          builder: (context, salonSnapshot) {
                            if (salonSnapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
                            }

                            final salons = (salonSnapshot.data ?? [])
                                .where((salon) => salon.id != null && favoriteIds.contains(salon.id))
                                .toList();

                            if (salons.isEmpty) {
                              return _buildEmptyFavoriteState();
                            }

                            return ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: salons.length + 1,
                              separatorBuilder: (context, index) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  return Text('Salon Favorit', style: AppTheme.heading2);
                                }
                                return _buildFavoriteSalonCard(salons[index - 1]);
                              },
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteSalonCard(BarbershopModel salon) {
    final statusColor = salon.isActive ? AppTheme.successColor : AppTheme.errorColor;
    final statusLabel = salon.isActive ? 'Aktif' : 'Suspended';
    final profilePhoto = salon.photos.isNotEmpty ? salon.photos[0] : '';

    return InkWell(
      onTap: () => Get.to(() => SalonDetailPage(barbershop: salon)),
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.antiAlias,
              child: _buildSalonThumbnail(profilePhoto),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(salon.name, style: AppTheme.heading3, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(
                    salon.address,
                    style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            RatingFormatter.display(salon.rating),
                            style: AppTheme.bodyText2.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Text(
                        salon.totalReviews > 0 ? '${salon.totalReviews} ulasan' : 'Belum ada ulasan',
                        style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          statusLabel,
                          style: AppTheme.bodyText3.copyWith(color: statusColor, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.favorite, color: Colors.red, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSalonThumbnail(String source) {
    final trimmed = source.trim();
    final imageBytes = ImageBase64Utils.decode(trimmed);

    if (imageBytes != null) {
      return Image.memory(imageBytes, fit: BoxFit.cover);
    }

    if (trimmed.startsWith('http')) {
      return Image.network(
        trimmed,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildStoreIcon(),
      );
    }

    if (trimmed.endsWith('.svg')) {
      return SvgPicture.asset(trimmed, fit: BoxFit.cover);
    }

    return _buildStoreIcon();
  }

  Widget _buildStoreIcon() {
    return Icon(Icons.store, color: AppTheme.primaryColor, size: 24);
  }

  Widget _buildEmptyFavoriteState({String message = 'Favorit akan tampil dari database setelah kamu menyimpan barbershop favorit.'}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_border, color: AppTheme.textSecondaryColor, size: 40),
            const SizedBox(height: 12),
            Text('Belum ada favorit', style: AppTheme.heading3),
            const SizedBox(height: 6),
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
}
