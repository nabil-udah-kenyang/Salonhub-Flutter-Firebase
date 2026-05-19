import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/barbershop_model.dart';
import '../../../data/repositories/barbershop_repository.dart';
import '../../controllers/auth_controller.dart';

class SuperadminBarbershopsPage extends StatefulWidget {
  const SuperadminBarbershopsPage({super.key});

  @override
  State<SuperadminBarbershopsPage> createState() => _SuperadminBarbershopsPageState();
}

class _SuperadminBarbershopsPageState extends State<SuperadminBarbershopsPage> {
  final AuthController _authController = Get.find<AuthController>();
  final BarbershopRepository _barbershopRepository = BarbershopRepository();
  final TextEditingController _searchController = TextEditingController();
  final Map<String, String> _ownerEmailCache = {};
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<String> _filters = ['Semua', 'Pending', 'Aktif', 'Suspended'];
  String _selectedFilter = 'Semua';
  String _searchQuery = '';
  final Set<String> _processing = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSuperadmin = _authController.user?.email == 'superadmin@salonhub.com';

    if (!isSuperadmin) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Halaman ini hanya dapat diakses oleh Superadmin.',
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
            _buildSearchField(),
            const SizedBox(height: 12),
            _buildStatusFilter(),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<List<BarbershopModel>>(
                stream: _barbershopRepository.streamBarbershops(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
                  }

                  if (snapshot.hasError) {
                    return _buildEmptyState('Gagal memuat data barbershop: ${snapshot.error}');
                  }

                  final barbershops = _filterBarbershops(snapshot.data ?? []);
                  if (barbershops.isEmpty) {
                    return _buildEmptyState('Belum ada barbershop dengan filter ini.');
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: barbershops.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => _buildBarbershopCard(barbershops[index]),
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kelola Barbershop', style: AppTheme.heading1),
                const SizedBox(height: 4),
                Text(
                  'Setujui dan kontrol semua UMKM barbershop di SalonHub.',
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
            child: const Icon(Icons.store_mall_directory, color: AppTheme.primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: AppTheme.textSecondaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Cari berdasarkan nama atau alamat',
                  border: InputBorder.none,
                ),
                onChanged: (value) => setState(() => _searchQuery = value.trim()),
              ),
            ),
            if (_searchQuery.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
                child: const Icon(Icons.close, size: 18),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusFilter() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = filter == _selectedFilter;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = filter),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryColor : AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor),
              ),
              child: Text(
                filter,
                style: AppTheme.bodyText2.copyWith(
                  color: isSelected ? Colors.white : AppTheme.textPrimaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.store_mall_directory_outlined, size: 48, color: AppTheme.textSecondaryColor),
            const SizedBox(height: 12),
            Text(
              message,
              style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<BarbershopModel> _filterBarbershops(List<BarbershopModel> barbershops) {
    return barbershops.where((shop) {
      final matchesQuery = _searchQuery.isEmpty ||
          shop.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          shop.address.toLowerCase().contains(_searchQuery.toLowerCase());

      bool matchesFilter = true;
      switch (_selectedFilter) {
        case 'Pending':
          matchesFilter = !shop.isApproved;
          break;
        case 'Aktif':
          matchesFilter = shop.isApproved && shop.isActive;
          break;
        case 'Suspended':
          matchesFilter = shop.isApproved && !shop.isActive;
          break;
        default:
          matchesFilter = true;
      }

      return matchesQuery && matchesFilter;
    }).toList()
      ..sort((a, b) {
        int scoreA = _statusScore(a);
        int scoreB = _statusScore(b);
        if (scoreA != scoreB) return scoreA.compareTo(scoreB);
        return (b.createdAt ?? Timestamp.now()).compareTo(a.createdAt ?? Timestamp.now());
      });
  }

  int _statusScore(BarbershopModel shop) {
    if (!shop.isApproved) return 0; // pending first
    if (shop.isApproved && !shop.isActive) return 1; // suspended
    return 2; // active
  }

  Widget _buildBarbershopCard(BarbershopModel shop) {
    final statusLabel = !_isApproved(shop)
        ? 'Pending'
        : shop.isActive
            ? 'Aktif'
            : 'Suspended';
    final statusColor = !_isApproved(shop)
        ? AppTheme.warningColor
        : shop.isActive
            ? AppTheme.successColor
            : AppTheme.errorColor;

    return FutureBuilder<String>(
      future: _loadOwnerEmail(shop.ownerId),
      builder: (context, snapshot) {
        final ownerEmail = snapshot.data ?? 'Memuat email...';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.store, color: AppTheme.primaryColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(shop.name, style: AppTheme.heading3),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                statusLabel,
                                style: AppTheme.bodyText3.copyWith(color: statusColor, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          shop.address,
                          style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ownerEmail,
                          style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildInfoTile('Status Approval', statusLabel, statusColor)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildInfoTile('Aktif', shop.isActive ? 'Ya' : 'Tidak', shop.isActive ? AppTheme.successColor : AppTheme.errorColor)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showBarbershopDetail(shop, ownerEmail),
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
                    child: _buildActionButton(shop),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoTile(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTheme.bodyText3.copyWith(color: AppTheme.textSecondaryColor)),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTheme.bodyText1.copyWith(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BarbershopModel shop) {
    final isProcessing = _processing.contains(shop.id);

    if (!_isApproved(shop)) {
      return ElevatedButton(
        onPressed: isProcessing ? null : () => _approveBarbershop(shop),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: isProcessing
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Text('Setujui'),
      );
    }

    if (shop.isActive) {
      return ElevatedButton(
        onPressed: isProcessing ? null : () => _suspendBarbershop(shop),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.errorColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: isProcessing
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Text('Suspend'),
      );
    }

    return ElevatedButton(
      onPressed: isProcessing ? null : () => _activateBarbershop(shop),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.successColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: isProcessing
          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : const Text('Aktifkan'),
    );
  }

  Future<String> _loadOwnerEmail(String ownerId) async {
    if (_ownerEmailCache.containsKey(ownerId)) return _ownerEmailCache[ownerId]!;
    final doc = await _firestore.collection('users').doc(ownerId).get();
    final email = doc.data()?['email']?.toString() ?? 'Pengelola tidak ditemukan';
    _ownerEmailCache[ownerId] = email;
    return email;
  }

  Future<void> _approveBarbershop(BarbershopModel shop) async {
    if (shop.id == null) return;
    setState(() => _processing.add(shop.id!));
    try {
      await _barbershopRepository.updateApprovalStatus(shop.id!, true);
      Get.snackbar('Disetujui', 'Barbershop ${shop.name} kini aktif di katalog pelanggan');
    } catch (e) {
      Get.snackbar('Gagal', 'Tidak dapat menyetujui barbershop: $e', backgroundColor: AppTheme.errorColor, colorText: Colors.white);
    } finally {
      setState(() => _processing.remove(shop.id));
    }
  }

  Future<void> _suspendBarbershop(BarbershopModel shop) async {
    if (shop.id == null) return;
    setState(() => _processing.add(shop.id!));
    try {
      await _barbershopRepository.updateActiveStatus(shop.id!, false);
      Get.snackbar('Disuspend', 'Barbershop ${shop.name} disembunyikan dari pelanggan');
    } catch (e) {
      Get.snackbar('Gagal', 'Tidak dapat menyuspend barbershop: $e', backgroundColor: AppTheme.errorColor, colorText: Colors.white);
    } finally {
      setState(() => _processing.remove(shop.id));
    }
  }

  Future<void> _activateBarbershop(BarbershopModel shop) async {
    if (shop.id == null) return;
    setState(() => _processing.add(shop.id!));
    try {
      await _barbershopRepository.updateActiveStatus(shop.id!, true);
      Get.snackbar('Aktif kembali', 'Barbershop ${shop.name} kembali tampil ke pelanggan');
    } catch (e) {
      Get.snackbar('Gagal', 'Tidak dapat mengaktifkan barbershop: $e', backgroundColor: AppTheme.errorColor, colorText: Colors.white);
    } finally {
      setState(() => _processing.remove(shop.id));
    }
  }

  void _showBarbershopDetail(BarbershopModel shop, String ownerEmail) {
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
                  child: Container(
                    width: 60,
                    height: 4,
                    decoration: BoxDecoration(color: AppTheme.borderColor, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Detail Barbershop', style: AppTheme.heading2),
                const SizedBox(height: 16),
                _detailRow('Nama', shop.name),
                _detailRow('Alamat', shop.address),
                _detailRow('Email Pemilik', ownerEmail),
                _detailRow('Status Approval', !_isApproved(shop) ? 'Pending' : shop.isActive ? 'Aktif' : 'Suspended'),
                _detailRow('Aktif', shop.isActive ? 'Ya' : 'Tidak'),
                if (shop.phone != null && shop.phone!.isNotEmpty) _detailRow('Telepon', shop.phone!),
                if (shop.whatsapp != null && shop.whatsapp!.isNotEmpty) _detailRow('WhatsApp', shop.whatsapp!),
                const SizedBox(height: 24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor)),
          ),
          Expanded(
            child: Text(value, style: AppTheme.bodyText1.copyWith(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  bool _isApproved(BarbershopModel shop) => shop.isApproved;
}
