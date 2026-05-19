import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/service_model.dart';
import '../../../data/repositories/service_repository.dart';
import '../../controllers/auth_controller.dart';
import '../../helpers/admin_barbershop_helper.dart';

class AdminServicesPage extends StatefulWidget {
  const AdminServicesPage({super.key});

  @override
  State<AdminServicesPage> createState() => _AdminServicesPageState();
}

class _AdminServicesPageState extends State<AdminServicesPage> {
  final AuthController _authController = Get.find<AuthController>();
  final ServiceRepository _serviceRepository = ServiceRepository();

  String? _barbershopId;
  bool _isLoadingBarbershop = true;
  String _selectedCategory = 'Semua';
  String _searchQuery = '';

  final List<String> _categories = ['Semua', ...ServiceModel.categories];

  @override
  void initState() {
    super.initState();
    _initBarbershop();
  }

  Future<void> _initBarbershop() async {
    final id = await AdminBarbershopHelper.fetchPrimaryBarbershopId(_authController);
    if (!mounted) return;
    setState(() {
      _barbershopId = id;
      _isLoadingBarbershop = false;
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
              'Akun admin belum terhubung ke barbershop manapun. Hubungi tim SalonHub untuk mengaktifkan data barbershop.',
              style: AppTheme.bodyText1.copyWith(color: AppTheme.textSecondaryColor),
              textAlign: TextAlign.center,
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
            _buildCategoryFilter(),
            const SizedBox(height: 8),
            _buildSearchField(),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<List<ServiceModel>>(
                stream: _serviceRepository.streamServicesByBarbershopId(_barbershopId!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
                  }

                  final services = (snapshot.data ?? [])
                      .where((service) {
                        final matchesCategory = _selectedCategory == 'Semua' || service.category == _selectedCategory;
                        final matchesQuery = service.name.toLowerCase().contains(_searchQuery.toLowerCase());
                        return matchesCategory && matchesQuery;
                      })
                      .toList();

                  if (services.isEmpty) {
                    return _buildEmptyState('Belum ada layanan dengan filter saat ini.');
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: services.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => _buildServiceCard(services[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openServiceForm(),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Layanan Baru'),
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
                Text('Kelola Layanan', style: AppTheme.heading1),
                const SizedBox(height: 4),
                Text(
                  'Susun katalog layanan, atur harga, durasi, dan ketersediaannya.',
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
            child: const Icon(Icons.design_services_rounded, color: AppTheme.primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = category),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryColor : AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor),
              ),
              child: Text(
                category,
                style: AppTheme.bodyText2.copyWith(
                  color: isSelected ? Colors.white : AppTheme.textPrimaryColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: TextField(
          onChanged: (value) => setState(() => _searchQuery = value.trim()),
          decoration: InputDecoration(
            icon: Icon(Icons.search, color: AppTheme.textSecondaryColor),
            border: InputBorder.none,
            hintText: 'Cari layanan berdasarkan nama',
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard(ServiceModel service) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: service.photo.isEmpty
                    ? const Icon(Icons.design_services_rounded, color: AppTheme.primaryColor)
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          service.photo,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.design_services_rounded, color: AppTheme.primaryColor),
                        ),
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
                          child: Text(service.name, style: AppTheme.heading3, maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                        PopupMenuButton<String>(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          onSelected: (value) => _handleServiceMenu(value, service),
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'edit', child: Text('Edit')),
                            PopupMenuItem(value: 'status', child: Text(service.isActive ? 'Nonaktifkan' : 'Aktifkan')),
                            const PopupMenuDivider(),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Hapus', style: TextStyle(color: AppTheme.errorColor)),
                            ),
                          ],
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryExtraLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.more_horiz, size: 18, color: AppTheme.primaryColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      service.description,
                      style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    _buildInfoChip(Icons.category_outlined, service.category),
                    _buildInfoChip(Icons.schedule, '${service.duration} menit'),
                    _buildInfoChip(Icons.attach_money, _formatRupiah(service.price)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Switch(
                value: service.isActive,
                onChanged: (_) => _toggleServiceStatus(service),
                thumbColor: WidgetStateProperty.all(AppTheme.primaryColor),
                trackColor: WidgetStateProperty.all(AppTheme.primaryColor.withValues(alpha: 0.3)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.textSecondaryColor),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: AppTheme.bodyText3,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
          ),
        ],
      ),
    );
  }

  void _handleServiceMenu(String action, ServiceModel service) {
    switch (action) {
      case 'edit':
        _openServiceForm(service: service);
        break;
      case 'status':
        _toggleServiceStatus(service);
        break;
      case 'delete':
        _confirmDelete(service);
        break;
    }
  }

  Future<void> _toggleServiceStatus(ServiceModel service) async {
    await _serviceRepository.toggleServiceStatus(service.id!, !service.isActive);
    Get.snackbar('Berhasil', service.isActive ? 'Layanan dinonaktifkan' : 'Layanan diaktifkan');
  }

  Future<void> _confirmDelete(ServiceModel service) async {
    final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Hapus Layanan?'),
            content: Text('"${service.name}" akan disembunyikan dari katalog pelanggan.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
                child: const Text('Hapus'),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldDelete) return;
    await _serviceRepository.deleteService(service.id!);
    Get.snackbar('Berhasil', 'Layanan dihapus');
  }

  Future<void> _openServiceForm({ServiceModel? service}) async {
    if (_barbershopId == null) return;

    final nameController = TextEditingController(text: service?.name ?? '');
    final descriptionController = TextEditingController(text: service?.description ?? '');
    final priceController = TextEditingController(text: service?.price.toString() ?? '0');
    final durationController = TextEditingController(text: service?.duration.toString() ?? '30');
    String category = service?.category ?? ServiceModel.categories.first;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (sheetContext) {
        bool isSubmitting = false;
        return StatefulBuilder(
          builder: (_, setModalState) {
            Future<void> handleSubmit() async {
              if (nameController.text.trim().isEmpty || priceController.text.trim().isEmpty) {
                Get.snackbar('Validasi', 'Nama dan harga layanan wajib diisi');
                return;
              }

              final double price = double.tryParse(priceController.text.trim()) ?? 0;
              final int duration = int.tryParse(durationController.text.trim()) ?? 30;

              setModalState(() => isSubmitting = true);
              try {
                if (service == null) {
                  final newService = ServiceModel(
                    name: nameController.text.trim(),
                    description: descriptionController.text.trim(),
                    category: category,
                    price: price,
                    duration: duration,
                    photo: '',
                    barbershopId: _barbershopId!,
                  );
                  await _serviceRepository.createService(newService);
                  Get.snackbar('Berhasil', 'Layanan ditambahkan');
                } else {
                  final updated = service.copyWith(
                    name: nameController.text.trim(),
                    description: descriptionController.text.trim(),
                    category: category,
                    price: price,
                    duration: duration,
                  );
                  await _serviceRepository.updateService(updated);
                  Get.snackbar('Berhasil', 'Layanan diperbarui');
                }

                if (!sheetContext.mounted) return;
                Navigator.pop(sheetContext);
              } catch (e) {
                Get.snackbar('Gagal', e.toString());
              } finally {
                setModalState(() => isSubmitting = false);
              }
            }

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
                  children: [
                    Center(
                      child: Container(
                        width: 60,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.borderColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(service == null ? 'Layanan Baru' : 'Edit Layanan', style: AppTheme.heading2),
                    const SizedBox(height: 16),
                    _buildModalField('Nama Layanan', nameController, icon: Icons.design_services_outlined),
                    const SizedBox(height: 12),
                    _buildModalField('Deskripsi', descriptionController, icon: Icons.notes_outlined, maxLines: 3),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      // ignore: deprecated_member_use
                      value: category,
                      decoration: InputDecoration(
                        labelText: 'Kategori',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      items: ServiceModel.categories
                          .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                          .toList(),
                      onChanged: (value) => setModalState(() => category = value ?? category),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildModalField('Harga (Rp)', priceController, icon: Icons.attach_money, keyboardType: TextInputType.number),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildModalField('Durasi (menit)', durationController, icon: Icons.schedule, keyboardType: TextInputType.number),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isSubmitting ? null : handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(isSubmitting ? 'Menyimpan...' : 'Simpan Layanan'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildModalField(
    String label,
    TextEditingController controller, {
    IconData? icon,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        filled: true,
        fillColor: AppTheme.backgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppTheme.borderColor),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.design_services_outlined, size: 48, color: AppTheme.textSecondaryColor),
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

  String _formatRupiah(double value) {
    return 'Rp ${value.toStringAsFixed(0)}';
  }
}
