import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/stylist_model.dart';
import '../../../data/repositories/stylist_repository.dart';
import '../../controllers/auth_controller.dart';
import '../../helpers/admin_barbershop_helper.dart';

class AdminStylistsPage extends StatefulWidget {
  const AdminStylistsPage({super.key});

  @override
  State<AdminStylistsPage> createState() => _AdminStylistsPageState();
}

class _AdminStylistsPageState extends State<AdminStylistsPage> {
  final AuthController _authController = Get.find<AuthController>();
  final StylistRepository _stylistRepository = StylistRepository();

  String? _barbershopId;
  bool _isLoadingBarbershop = true;
  String _searchQuery = '';

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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
      );
    }

    if (_barbershopId == null) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Akun admin belum terhubung dengan data barbershop. Hubungi tim SalonHub untuk mengatur kepemilikan barbershop terlebih dahulu.',
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
            _buildSearchBar(),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<List<StylistModel>>(
                stream: _stylistRepository.streamStylistsByBarbershopId(_barbershopId!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
                  }

                  final stylists = (snapshot.data ?? [])
                      .where((stylist) => stylist.name.toLowerCase().contains(_searchQuery.toLowerCase()))
                      .toList();

                  if (stylists.isEmpty) {
                    return _buildEmptyState('Belum ada stylist aktif. Tambahkan stylist baru agar pelanggan bisa memilih penata rambut.');
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: stylists.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => _buildStylistCard(stylists[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openStylistForm(),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Stylist Baru'),
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
                Text('Kelola Stylist', style: AppTheme.heading1),
                const SizedBox(height: 4),
                Text(
                  'Tambah, edit, dan atur penjadwalan stylist untuk barbershop kamu.',
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
            child: const Icon(Icons.content_cut_rounded, color: AppTheme.primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
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
            hintText: 'Cari stylist berdasarkan nama atau keahlian',
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildStylistCard(StylistModel stylist) {
    final skills = stylist.specializations;
    final isAvailable = stylist.isActive;

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
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: stylist.photo.isEmpty
                    ? const Icon(Icons.person_rounded, color: AppTheme.primaryColor)
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          stylist.photo,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.person_rounded, color: AppTheme.primaryColor),
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
                          child: Text(
                            stylist.name,
                            style: AppTheme.heading3,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        PopupMenuButton<String>(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          onSelected: (value) => _handleMenuAction(value, stylist),
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'edit', child: Text('Edit')),
                            PopupMenuItem(
                              value: 'status',
                              child: Text(stylist.isActive ? 'Nonaktifkan' : 'Aktifkan'),
                            ),
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
                    const SizedBox(height: 4),
                    Text(
                      stylist.specializations.isEmpty ? 'Stylist' : stylist.specializations.join(' • '),
                      style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.work_outline, size: 16, color: AppTheme.textSecondaryColor),
                        const SizedBox(width: 4),
                        Text('${stylist.experience} tahun', style: AppTheme.bodyText2),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isAvailable
                                ? AppTheme.successColor.withValues(alpha: 0.12)
                                : AppTheme.errorColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isAvailable ? 'Aktif' : 'Nonaktif',
                            style: AppTheme.bodyText3.copyWith(
                              color: isAvailable ? AppTheme.successColor : AppTheme.errorColor,
                              fontWeight: FontWeight.w700,
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
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              children: skills.isEmpty
                  ? [_buildSkillChip('Belum ada keahlian')]
                  : skills.map(_buildSkillChip).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action, StylistModel stylist) {
    switch (action) {
      case 'edit':
        _openStylistForm(stylist: stylist);
        break;
      case 'status':
        _toggleStylistStatus(stylist);
        break;
      case 'delete':
        _confirmDelete(stylist);
        break;
    }
  }

  Future<void> _toggleStylistStatus(StylistModel stylist) async {
    await _stylistRepository.toggleStylistStatus(stylist.id!, !stylist.isActive);
    Get.snackbar('Berhasil', stylist.isActive ? 'Stylist dinonaktifkan' : 'Stylist diaktifkan');
  }

  Future<void> _confirmDelete(StylistModel stylist) async {
    final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Hapus Stylist?'),
            content: Text('Stylist ${stylist.name} akan disembunyikan dari daftar pemilihan pelanggan.'),
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
    await _stylistRepository.deleteStylist(stylist.id!);
    Get.snackbar('Berhasil', 'Stylist telah disembunyikan');
  }

  Future<void> _openStylistForm({StylistModel? stylist}) async {
    if (_barbershopId == null) return;
    final nameController = TextEditingController(text: stylist?.name ?? '');
    final bioController = TextEditingController(text: stylist?.bio ?? '');
    final experienceController = TextEditingController(text: stylist?.experience.toString() ?? '0');
    final specializationController = TextEditingController(text: stylist?.specializations.join(', ') ?? '');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        bool isSubmitting = false;
        return StatefulBuilder(
          builder: (_, setModalState) {
            Future<void> handleSubmit() async {
              if (nameController.text.trim().isEmpty) {
                Get.snackbar('Validasi', 'Nama stylist wajib diisi');
                return;
              }

              int experience = int.tryParse(experienceController.text.trim()) ?? 0;
              List<String> specializations = specializationController.text
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();

              setModalState(() => isSubmitting = true);
              try {
                if (stylist == null) {
                  final newStylist = StylistModel(
                    name: nameController.text.trim(),
                    photo: '',
                    specializations: specializations,
                    experience: experience,
                    barbershopId: _barbershopId!,
                    bio: bioController.text.trim().isEmpty ? null : bioController.text.trim(),
                  );
                  await _stylistRepository.createStylist(newStylist);
                  Get.snackbar('Berhasil', 'Stylist ditambahkan');
                } else {
                  final updated = stylist.copyWith(
                    name: nameController.text.trim(),
                    specializations: specializations,
                    experience: experience,
                    bio: bioController.text.trim().isEmpty ? null : bioController.text.trim(),
                  );
                  await _stylistRepository.updateStylist(updated);
                  Get.snackbar('Berhasil', 'Stylist diperbarui');
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
                    Text(
                      stylist == null ? 'Stylist Baru' : 'Edit Stylist',
                      style: AppTheme.heading2,
                    ),
                    const SizedBox(height: 16),
                    _buildModalField('Nama Stylist', nameController, icon: Icons.person_outline),
                    const SizedBox(height: 12),
                    _buildModalField('Bio/Keterangan', bioController, icon: Icons.notes_rounded, maxLines: 3),
                    const SizedBox(height: 12),
                    _buildModalField('Pengalaman (tahun)', experienceController, icon: Icons.work_outline, keyboardType: TextInputType.number),
                    const SizedBox(height: 12),
                    _buildModalField('Keahlian (pisahkan dengan koma)', specializationController, icon: Icons.content_cut_outlined),
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
                        child: Text(isSubmitting ? 'Menyimpan...' : 'Simpan Stylist'),
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
            Icon(Icons.people_outline, size: 48, color: AppTheme.textSecondaryColor),
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

  Widget _buildSkillChip(String skill) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        skill,
        style: AppTheme.bodyText3.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.w600),
      ),
    );
  }
}
