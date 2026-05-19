import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/barbershop_model.dart';
import '../../../data/models/service_model.dart';
import '../../../data/repositories/barbershop_repository.dart';
import '../../../data/repositories/service_repository.dart';
import 'booking_flow/salon_detail_page.dart';

class UserSearchPage extends StatefulWidget {
  const UserSearchPage({
    super.key,
    this.initialQuery,
    this.initialCategory,
    this.showPromoOnly = false,
    this.sortByNearest = false,
    this.topRatedOnly = false,
  });

  final String? initialQuery;
  final String? initialCategory;
  final bool showPromoOnly;
  final bool sortByNearest;
  final bool topRatedOnly;

  @override
  State<UserSearchPage> createState() => _UserSearchPageState();
}

class _UserSearchPageState extends State<UserSearchPage> {
  final BarbershopRepository _barbershopRepository = BarbershopRepository();
  final ServiceRepository _serviceRepository = ServiceRepository();
  late final TextEditingController _searchController;
  late String _selectedCategory;
  late bool _showPromoOnly;
  late bool _sortByNearest;
  late bool _topRatedOnly;

  final List<String> _categories = const [
    'Semua',
    'Haircut',
    'Hair Color',
    'Hair Treatment',
    'Beard & Mustache',
  ];

  List<BarbershopModel> _allSalons = const [];
  List<ServiceModel> _allServices = const [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery ?? '');
    _selectedCategory = widget.initialCategory ?? 'Semua';
    _showPromoOnly = widget.showPromoOnly;
    _sortByNearest = widget.sortByNearest;
    _topRatedOnly = widget.topRatedOnly;
    _searchController.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onQueryChanged)
      ..dispose();
    super.dispose();
  }

  void _onQueryChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Search Header
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cari Salon',
                    style: AppTheme.heading1,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Masukkan nama salon atau layanan...',
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppTheme.primaryColor,
                      ),
                      filled: true,
                      fillColor: AppTheme.surfaceColor,
                    ),
                  ),
                ],
              ),
            ),
            
            // Filters
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((category) {
                        final isSelected = _selectedCategory == category;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildFilterChip(
                            category,
                            isSelected,
                            () {
                              setState(() {
                                _selectedCategory = category;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip(
                          'Promo',
                          _showPromoOnly,
                          () {
                            setState(() {
                              _showPromoOnly = !_showPromoOnly;
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          'Terdekat',
                          _sortByNearest,
                          () {
                            setState(() {
                              _sortByNearest = !_sortByNearest;
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          'Rating 4.8+',
                          _topRatedOnly,
                          () {
                            setState(() {
                              _topRatedOnly = !_topRatedOnly;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Search Results
            Expanded(
              child: StreamBuilder<List<BarbershopModel>>(
                stream: _barbershopRepository.streamApprovedBarbershops(activeOnly: false),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
                  }

                  _allSalons = snapshot.data ?? [];

                  return FutureBuilder<List<ServiceModel>>(
                    future: _serviceRepository.getAllServices(),
                    builder: (context, serviceSnapshot) {
                      _allServices = serviceSnapshot.data ?? [];
                      final salons = _computeFilteredResults();

                      return ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Hasil Pencarian', style: AppTheme.heading2),
                              Text(
                                '${salons.length} salon',
                                style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (salons.isEmpty)
                            _buildEmptySearchState()
                          else
                            ...salons.map((salon) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildSalonCard(
                                  salon,
                                  salon.totalReviews > 0 ? '${salon.totalReviews} ulasan' : 'Belum ada ulasan',
                                  false,
                                ),
                              );
                            }),
                        ],
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
  
  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
          ),
        ),
        child: Text(
          label,
          style: AppTheme.bodyText2.copyWith(
            color: isSelected ? Colors.white : AppTheme.textPrimaryColor,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
  
  Widget _buildSalonCard(BarbershopModel salon, String distance, bool isPromoted) {
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
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.store,
                  color: AppTheme.primaryColor,
                  size: 32,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            salon.name,
                            style: AppTheme.heading3,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isPromoted) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'PROMO',
                              style: AppTheme.bodyText3.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      salon.address,
                      style: AppTheme.bodyText2.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                      maxLines: 2,
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
                            Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              salon.rating.toString(),
                              style: AppTheme.bodyText2.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_on,
                              color: AppTheme.textSecondaryColor,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              distance,
                              style: AppTheme.bodyText2.copyWith(
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: (salon.isActive ? AppTheme.primaryColor : AppTheme.errorColor).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            salon.isActive ? 'Aktif' : 'Suspended',
                            style: AppTheme.bodyText3.copyWith(
                              color: salon.isActive ? AppTheme.primaryColor : AppTheme.errorColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.access_time,
                    color: AppTheme.textSecondaryColor,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Buka: 09:00 - 21:00',
                    style: AppTheme.bodyText2.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Lihat Detail',
                  style: AppTheme.bodyText3.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
        ),
      ),
    );
  }

  List<BarbershopModel> _computeFilteredResults() {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = <BarbershopModel>[];

    for (final salon in _allSalons) {
      if (_matchesFilters(salon, query)) {
        filtered.add(salon);
      }
    }

    if (_sortByNearest) {
      filtered.sort((a, b) => a.address.compareTo(b.address));
    } else {
      filtered.sort((a, b) => b.rating.compareTo(a.rating));
    }

    return filtered;
  }

  bool _matchesFilters(BarbershopModel salon, String query) {
    final name = salon.name.toLowerCase();
    final address = (salon.address).toLowerCase();
    final matchesQuery = query.isEmpty ||
        name.contains(query) ||
        address.contains(query) ||
        _servicesForSalon(salon.id).any((service) => service.name.toLowerCase().contains(query));

    final categories = _salonCategories(salon.id);
    final matchesCategory = _selectedCategory == 'Semua' ||
        categories.contains(_selectedCategory);

    final matchesPromo = !_showPromoOnly;
    final matchesTopRated = !_topRatedOnly || salon.rating >= 4.8;

    return matchesQuery && matchesCategory && matchesPromo && matchesTopRated;
  }

  Set<String> _salonCategories(String? barbershopId) {
    if (barbershopId == null) return {};
    return _servicesForSalon(barbershopId)
        .map((service) => service.category)
        .toSet();
  }

  List<ServiceModel> _servicesForSalon(String? barbershopId) {
    if (barbershopId == null) return [];
    return _allServices.where((service) => service.barbershopId == barbershopId && service.isActive).toList();
  }

  Widget _buildEmptySearchState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.search_off, color: AppTheme.textSecondaryColor, size: 32),
          const SizedBox(height: 12),
          Text('Tidak ada salon yang cocok.', style: AppTheme.bodyText1),
          const SizedBox(height: 4),
          Text(
            'Data diambil dari database. Coba ubah kata kunci atau filter.',
            textAlign: TextAlign.center,
            style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor),
          ),
        ],
      ),
    );
  }
}
