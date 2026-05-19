import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/user_repository.dart';

class SuperadminUsersPage extends StatefulWidget {
  const SuperadminUsersPage({super.key});

  @override
  State<SuperadminUsersPage> createState() => _SuperadminUsersPageState();
}

class _SuperadminUsersPageState extends State<SuperadminUsersPage> {
  final UserRepository _userRepository = UserRepository();
  final TextEditingController _searchController = TextEditingController();
  final List<String> _roleFilters = ['Semua', 'Superadmin', 'Admin', 'User'];
  String _selectedRole = 'Semua';
  String _searchQuery = '';
  final Set<String> _processingUsers = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchAndFilters(),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<List<UserModel>>(
                stream: _userRepository.streamUsers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
                  }

                  if (snapshot.hasError) {
                    return _buildEmptyState('Gagal memuat data user: ${snapshot.error}');
                  }

                  final users = _filterUsers(snapshot.data ?? []);
                  if (users.isEmpty) {
                    return _buildEmptyState('Tidak ada user dengan filter saat ini.');
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: users.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => _buildUserCard(users[index]),
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
                Text('Kelola User', style: AppTheme.heading1),
                const SizedBox(height: 4),
                Text('Pantau semua peran dan status user', style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Tambah User',
              style: AppTheme.bodyText3.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: AppTheme.textSecondaryColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(hintText: 'Cari user berdasarkan nama atau email', border: InputBorder.none),
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
          const SizedBox(height: 12),
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _roleFilters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = _roleFilters[index];
                final selected = filter == _selectedRole;
                return GestureDetector(
                  onTap: () => setState(() => _selectedRole = filter),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? AppTheme.primaryColor : AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: selected ? AppTheme.primaryColor : AppTheme.borderColor),
                    ),
                    child: Text(
                      filter,
                      style: AppTheme.bodyText2.copyWith(
                        color: selected ? Colors.white : AppTheme.textPrimaryColor,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<UserModel> _filterUsers(List<UserModel> users) {
    return users.where((user) {
      final matchesRole = _selectedRole == 'Semua' || user.role == _roleValue(_selectedRole);
      final matchesQuery = _searchQuery.isEmpty ||
          user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesRole && matchesQuery;
    }).toList()
      ..sort((a, b) {
        final aDate = a.createdAt?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.createdAt?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });
  }

  Widget _buildUserCard(UserModel user) {
    final roleColor = _roleColor(user.role);
    final isProcessing = _processingUsers.contains(user.id);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 14, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(color: roleColor.withOpacity(0.12), borderRadius: BorderRadius.circular(26)),
                child: Icon(Icons.person, color: roleColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(user.name.isEmpty ? 'Tanpa Nama' : user.name, style: AppTheme.heading3),
                        ),
                        Switch(
                          value: user.isActive,
                          activeColor: AppTheme.primaryColor,
                          onChanged: (value) => _toggleActive(user, value),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(user.email, style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildChip(_roleLabel(user.role), roleColor),
                        const SizedBox(width: 8),
                        _buildChip(user.isActive ? 'Aktif' : 'Nonaktif', user.isActive ? AppTheme.successColor : AppTheme.errorColor),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showUserDetail(user),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), side: BorderSide(color: AppTheme.borderColor)),
                  child: const Text('Detail'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _openEditModal(user),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), side: BorderSide(color: AppTheme.borderColor)),
                  child: const Text('Edit'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: _canDelete(user) && !isProcessing ? () => _deleteUser(user) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: isProcessing
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Hapus'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
      child: Text(
        label,
        style: AppTheme.bodyText3.copyWith(color: color, fontWeight: FontWeight.w600),
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
            Icon(Icons.people_outline, size: 48, color: AppTheme.textSecondaryColor),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor)),
          ],
        ),
      ),
    );
  }

  void _toggleActive(UserModel user, bool isActive) {
    if (user.id == null) return;
    _userRepository.updateUser(userId: user.id!, isActive: isActive).catchError(
      (error) => Get.snackbar('Gagal', 'Tidak dapat memperbarui status aktif: $error', backgroundColor: AppTheme.errorColor, colorText: Colors.white),
    );
  }

  void _showUserDetail(UserModel user) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 60, height: 4, decoration: BoxDecoration(color: AppTheme.borderColor, borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 16),
              Text('Detail User', style: AppTheme.heading2),
              const SizedBox(height: 12),
              _detailRow('Nama', user.name.isEmpty ? 'Tanpa Nama' : user.name),
              _detailRow('Email', user.email),
              _detailRow('Peran', _roleLabel(user.role)),
              _detailRow('Status', user.isActive ? 'Aktif' : 'Nonaktif'),
              _detailRow('Verifikasi Email', user.isEmailVerified ? 'Sudah' : 'Belum'),
              if (user.phone != null && user.phone!.isNotEmpty) _detailRow('Telepon', user.phone!),
              _detailRow('Tanggal Bergabung', _formatDate(user.createdAt?.toDate())),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Tutup'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openEditModal(UserModel user) {
    final nameController = TextEditingController(text: user.name);
    String role = user.role;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) {
        bool isSubmitting = false;
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(width: 60, height: 4, decoration: BoxDecoration(color: AppTheme.borderColor, borderRadius: BorderRadius.circular(2))),
                  ),
                  const SizedBox(height: 16),
                  Text('Edit User', style: AppTheme.heading2),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Nama Lengkap',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: role,
                    decoration: InputDecoration(
                      labelText: 'Peran',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    items: const [
                      DropdownMenuItem(value: AppConstants.superadminRole, child: Text('Superadmin')),
                      DropdownMenuItem(value: AppConstants.adminRole, child: Text('Admin')),
                      DropdownMenuItem(value: AppConstants.userRole, child: Text('User')),
                    ],
                    onChanged: (value) => setStateModal(() => role = value ?? role),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              if (user.id == null) return;
                              setStateModal(() => isSubmitting = true);
                              try {
                                await _userRepository.updateUser(
                                  userId: user.id!,
                                  name: nameController.text.trim(),
                                  role: role,
                                );
                                Navigator.pop(context);
                                Get.snackbar('Berhasil', 'User diperbarui');
                              } catch (e) {
                                Get.snackbar('Gagal', 'Tidak dapat memperbarui user: $e', backgroundColor: AppTheme.errorColor, colorText: Colors.white);
                              } finally {
                                setStateModal(() => isSubmitting = false);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(isSubmitting ? 'Menyimpan...' : 'Simpan'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _deleteUser(UserModel user) async {
    if (user.id == null) return;
    final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Hapus User?'),
            content: Text('Data user ${user.email} akan dihapus permanen.'),
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

    if (!confirm) return;

    setState(() => _processingUsers.add(user.id!));
    try {
      await _userRepository.deleteUser(user.id!);
      Get.snackbar('Berhasil', 'User dihapus');
    } catch (e) {
      Get.snackbar('Gagal', 'Tidak dapat menghapus user: $e', backgroundColor: AppTheme.errorColor, colorText: Colors.white);
    } finally {
      setState(() => _processingUsers.remove(user.id));
    }
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 140, child: Text(label, style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor))),
          Expanded(child: Text(value, style: AppTheme.bodyText1.copyWith(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Color _roleColor(String role) {
    switch (role) {
      case AppConstants.superadminRole:
        return AppTheme.primaryColor;
      case AppConstants.adminRole:
        return AppTheme.infoColor;
      default:
        return AppTheme.successColor;
    }
  }

  String _roleLabel(String role) {
    switch (role) {
      case AppConstants.superadminRole:
        return 'Superadmin';
      case AppConstants.adminRole:
        return 'Admin';
      default:
        return 'User';
    }
  }

  String _roleValue(String filter) {
    switch (filter) {
      case 'Superadmin':
        return AppConstants.superadminRole;
      case 'Admin':
        return AppConstants.adminRole;
      case 'User':
        return AppConstants.userRole;
      default:
        return '';
    }
  }

  bool _canDelete(UserModel user) => user.email != 'superadmin@salonhub.com';

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day}-${date.month}-${date.year}';
  }
}
