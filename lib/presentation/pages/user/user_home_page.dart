import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/barbershop_model.dart';
import '../../../data/repositories/barbershop_repository.dart';
import '../../controllers/auth_controller.dart';
import 'booking_flow/salon_detail_page.dart';
import 'user_search_page.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  final BarbershopRepository _barbershopRepository = BarbershopRepository();
  final TextEditingController _searchController = TextEditingController();

  final List<_PromoBannerData> _promoBanners = const [
    _PromoBannerData(
      title: 'Fresh Look Week',
      subtitle: 'Booking haircut premium mulai dari Rp50.000 minggu ini.',
      tag: 'Promo',
      icon: Icons.local_offer_outlined,
      gradient: [AppTheme.primaryColor, Color(0xFF5B7CFF)],
      action: _PromoAction.promo,
    ),
    _PromoBannerData(
      title: 'Salon Terdekat',
      subtitle: 'Temukan stylist terbaik di sekitar lokasimu lebih cepat.',
      tag: 'Nearby',
      icon: Icons.near_me_outlined,
      gradient: [Color(0xFF111827), Color(0xFF374151)],
      action: _PromoAction.nearest,
    ),
    _PromoBannerData(
      title: 'Top Rated Grooming',
      subtitle: 'Salon rating tinggi untuk hasil yang lebih percaya diri.',
      tag: '4.8+',
      icon: Icons.star_outline_rounded,
      gradient: [Color(0xFF0EA5E9), Color(0xFF235AFF)],
      action: _PromoAction.topRated,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Premium Header
            SliverAppBar(
              expandedHeight: 185,
              floating: false,
              pinned: true,
              backgroundColor: AppTheme.primaryColor,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'lib/assets/images/barber.jpg',
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.18),
                            AppTheme.primaryColor.withValues(alpha: 0.78),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selamat Datang! 👋',
                            style: AppTheme.bodyText2.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Temukan Salon Terbaik',
                            style: AppTheme.heading1.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Search Bar Section
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 24, 20, 16),
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
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _submitSearch(),
                  decoration: InputDecoration(
                    hintText: 'Cari salon atau layanan...',
                    hintStyle: AppTheme.bodyText1.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    prefixIcon: Icon(
                      Icons.search_outlined,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                    suffixIcon: GestureDetector(
                      onTap: () => _openSearch(
                        context,
                        query: _currentQuery(),
                        sortByNearest: true,
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.tune_outlined,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ),
          
            // Quick Actions
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _buildQuickAction(
                      'Lokasi',
                      Icons.location_on_outlined,
                      AppTheme.primaryColor,
                      () => _openSearch(
                        context,
                        query: _currentQuery(),
                        sortByNearest: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildQuickAction(
                      'Promo',
                      Icons.local_offer_outlined,
                      AppTheme.primaryColor,
                      () => _openSearch(
                        context,
                        query: _currentQuery(),
                        showPromoOnly: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildQuickAction(
                      'Terdekat',
                      Icons.near_me_outlined,
                      AppTheme.primaryColor,
                      () => _openSearch(
                        context,
                        query: _currentQuery(),
                        sortByNearest: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildQuickAction(
                      'Rating',
                      Icons.star_outline,
                      AppTheme.primaryColor,
                      () => _openSearch(
                        context,
                        query: _currentQuery(),
                        topRatedOnly: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            
            // Categories Section
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kategori Layanan',
                      style: AppTheme.heading2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 100,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildCategoryCard(
                            'Haircut',
                            Icons.content_cut,
                            AppTheme.primaryColor,
                            () => _openSearch(
                              context,
                              category: 'Haircut',
                            ),
                          ),
                          const SizedBox(width: 12),
                          _buildCategoryCard(
                            'Hair Color',
                            Icons.palette,
                            AppTheme.primaryColor,
                            () => _openSearch(
                              context,
                              category: 'Hair Color',
                            ),
                          ),
                          const SizedBox(width: 12),
                          _buildCategoryCard(
                            'Hair Spa',
                            Icons.spa,
                            AppTheme.primaryColor,
                            () => _openSearch(
                              context,
                              category: 'Hair Treatment',
                            ),
                          ),
                          const SizedBox(width: 12),
                          _buildCategoryCard(
                            'Styling',
                            Icons.style,
                            AppTheme.primaryColor,
                            () => _openSearch(
                              context,
                              query: 'styling',
                            ),
                          ),
                          const SizedBox(width: 12),
                          _buildCategoryCard(
                            'Beard',
                            Icons.face,
                            AppTheme.primaryColor,
                            () => _openSearch(
                              context,
                              category: 'Beard & Mustache',
                            ),
                          ),
                          const SizedBox(width: 12),
                          _buildCategoryCard(
                            'Facial',
                            Icons.face_retouching_natural,
                            AppTheme.primaryColor,
                            () => _openSearch(
                              context,
                              query: 'facial',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            SliverToBoxAdapter(
              child: _PromoCarousel(
                banners: _promoBanners,
                onTap: _handlePromoAction,
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
            
            // Featured Salons
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Salon Unggulan',
                        style: AppTheme.heading2.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.to(() => const UserSearchPage()),
                      child: Text(
                        'Lihat Semua',
                        style: AppTheme.bodyText1.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            
            StreamBuilder<List<BarbershopModel>>(
              stream: _barbershopRepository.streamApprovedBarbershops(activeOnly: false),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: CircularProgressIndicator(color: AppTheme.primaryColor),
                      ),
                    ),
                  );
                }

                final salons = snapshot.data ?? [];
                salons.sort((a, b) => b.rating.compareTo(a.rating));

                if (salons.isEmpty) {
                  return SliverToBoxAdapter(
                    child: _buildEmptyDatabaseState(),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final salon = salons[index];
                      return _buildPremiumSalonCard(
                        salon,
                        salon.totalReviews > 0 ? '${salon.totalReviews} ulasan' : 'Belum ada ulasan',
                        index == 0,
                      );
                    },
                    childCount: salons.length,
                  ),
                );
              },
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  void _submitSearch() {
    _openSearch(
      context,
      query: _currentQuery(),
    );
  }

  String? _currentQuery() {
    final text = _searchController.text.trim();
    return text.isEmpty ? null : text;
  }
  
  Widget _buildQuickAction(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: AppTheme.bodyText2.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: 80,
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTheme.bodyText3.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _openSearch(
    BuildContext context, {
    String? query,
    String? category,
    bool showPromoOnly = false,
    bool sortByNearest = false,
    bool topRatedOnly = false,
  }) {
    Get.to(
      () => UserSearchPage(
        initialQuery: query,
        initialCategory: category,
        showPromoOnly: showPromoOnly,
        sortByNearest: sortByNearest,
        topRatedOnly: topRatedOnly,
      ),
    );
  }
  
  Widget _buildPremiumSalonCard(
    BarbershopModel salon,
    String reviews,
    bool isPromoted,
  ) {
    final coverPhoto = salon.photos.length > 1 ? salon.photos[1] : '';
    final isSuspended = !salon.isActive;
    final statusLabel = isSuspended ? 'Suspended' : 'Buka';
    final statusColor = isSuspended ? AppTheme.errorColor : AppTheme.primaryColor;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
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
      child: InkWell(
        onTap: () => Get.to(() => SalonDetailPage(barbershop: salon)),
        borderRadius: BorderRadius.circular(20),
        child: Column(
        children: [
          // Image Section
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: Container(
            height: 150,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppTheme.cardGradient,
            ),
            child: Stack(
              children: [
                Positioned.fill(child: _buildSalonCoverImage(coverPhoto)),
                
                // Prom Badge
                if (isPromoted)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.warningColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_fire_department_outlined,
                            color: Colors.white,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Promo',
                            style: AppTheme.bodyText3.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                // Favorite Button
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () async {
                      try {
                        final auth = Get.find<AuthController>();
                        final userId = auth.user?.id;
                        final salonId = salon.id;

                        if (userId == null || salonId == null) {
                          Get.snackbar('Gagal', 'Silakan login terlebih dahulu.');
                          return;
                        }

                        await FirebaseFirestore.instance
                            .collection(AppConstants.usersCollection)
                            .doc(userId)
                            .update({
                          'preferences.favoriteBarbershopIds': FieldValue.arrayUnion([salonId]),
                          'updatedAt': FieldValue.serverTimestamp(),
                        });

                        await auth.refreshUserData();

                        Get.snackbar(
                          'Favorit',
                          '${salon.name} ditambahkan ke favorit.',
                          backgroundColor: Colors.white,
                          colorText: AppTheme.textPrimary,
                        );
                      } catch (e) {
                        Get.snackbar('Gagal', 'Tidak dapat menambahkan favorit.');
                      }
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.shadowColor,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.favorite_border_outlined,
                        color: AppTheme.errorColor,
                        size: 20,
                      ),
                    ),
                  ),
                ),

                if (isSuspended)
                  Positioned(
                    bottom: 12,
                    left: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Salon sedang disuspend oleh admin',
                              style: AppTheme.bodyText3.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          ),
          
          // Content Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        salon.name,
                        style: AppTheme.heading3.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
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
                            salon.rating.toString(),
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
                
                const SizedBox(height: 8),
                
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: AppTheme.textSecondary,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        salon.address,
                        style: AppTheme.bodyText2.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusLabel,
                        style: AppTheme.bodyText2.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (isSuspended)
                      Text(
                        'Tidak menerima booking',
                        style: AppTheme.bodyText2.copyWith(color: AppTheme.errorColor, fontWeight: FontWeight.w600),
                      )
                    else
                      Text(
                        reviews,
                        style: AppTheme.bodyText2.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildSalonCoverImage(String url) {
    if (url.trim().isEmpty) {
      return SvgPicture.asset(
        'lib/assets/images/admin_barber_cover.svg',
        fit: BoxFit.cover,
      );
    }

    if (url.startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => SvgPicture.asset(
          'lib/assets/images/admin_barber_cover.svg',
          fit: BoxFit.cover,
        ),
      );
    }

    return SvgPicture.asset(url, fit: BoxFit.cover);
  }

  Widget _buildEmptyDatabaseState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.primaryExtraLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.storefront_outlined, color: AppTheme.primaryColor, size: 32),
          ),
          const SizedBox(height: 14),
          Text(
            'Belum ada barbershop aktif',
            style: AppTheme.heading3.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Data akan tampil otomatis setelah barbershop tersedia dan disetujui di database.',
            textAlign: TextAlign.center,
            style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor),
          ),
        ],
      ),
    );
  }

  void _handlePromoAction(_PromoBannerData data) {
    switch (data.action) {
      case _PromoAction.promo:
        _openSearch(context, showPromoOnly: true);
        break;
      case _PromoAction.nearest:
        _openSearch(context, sortByNearest: true);
        break;
      case _PromoAction.topRated:
        _openSearch(context, topRatedOnly: true);
        break;
    }
  }
}

class _PromoCarousel extends StatefulWidget {
  final List<_PromoBannerData> banners;
  final ValueChanged<_PromoBannerData> onTap;

  const _PromoCarousel({
    required this.banners,
    required this.onTap,
  });

  @override
  State<_PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<_PromoCarousel> {
  late final PageController _controller;
  Timer? _autoTimer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.9);
    _startAutoPlay();
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _autoTimer?.cancel();
    _autoTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!_controller.hasClients || widget.banners.isEmpty) return;
      final nextIndex = (_currentIndex + 1) % widget.banners.length;
      _controller.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 185,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.banners.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              final data = widget.banners[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _buildPromoBanner(
                  data: data,
                  onTap: () => widget.onTap(data),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.banners.length, (index) {
            final isActive = index == _currentIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 6,
              width: isActive ? 26 : 10,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isActive
                    ? AppTheme.primaryColor
                    : AppTheme.primaryColor.withValues(alpha: 0.25),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildPromoBanner({
    required _PromoBannerData data,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: data.gradient,
          ),
          boxShadow: [
            BoxShadow(
              color: data.gradient.first.withValues(alpha: 0.22),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              bottom: -14,
              child: Icon(
                data.icon,
                size: 92,
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.22),
                    ),
                  ),
                  child: Text(
                    data.tag,
                    style: AppTheme.bodyText3.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  data.title,
                  style: AppTheme.heading3.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  data.subtitle,
                  style: AppTheme.bodyText2.copyWith(
                    color: Colors.white.withValues(alpha: 0.88),
                    height: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PromoBannerData {
  final String title;
  final String subtitle;
  final String tag;
  final IconData icon;
  final List<Color> gradient;
  final _PromoAction action;

  const _PromoBannerData({
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.icon,
    required this.gradient,
    required this.action,
  });
}

enum _PromoAction { promo, nearest, topRated }
