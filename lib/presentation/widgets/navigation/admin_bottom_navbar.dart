import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class AdminBottomNavbar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AdminBottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(
          top: BorderSide(color: AppTheme.borderColor.withOpacity(0.7)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
          child: Row(
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              final isSelected = currentIndex == index;

              return Expanded(
                child: InkWell(
                  onTap: () => onTap(index),
                  borderRadius: BorderRadius.circular(18),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryExtraLight : Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSelected ? item.activeIcon : item.icon,
                          size: 22,
                          color: isSelected ? AppTheme.primaryColor : AppTheme.textTertiary,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.bodySmall.copyWith(
                            fontSize: 11,
                            color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  static const List<_AdminNavItem> _items = [
    _AdminNavItem(Icons.dashboard_rounded, Icons.dashboard_outlined, 'Dashboard'),
    _AdminNavItem(Icons.groups_rounded, Icons.groups_outlined, 'Stylist'),
    _AdminNavItem(Icons.content_cut_rounded, Icons.content_cut_outlined, 'Layanan'),
    _AdminNavItem(Icons.event_note_rounded, Icons.event_note_outlined, 'Booking'),
    _AdminNavItem(Icons.storefront_rounded, Icons.storefront_outlined, 'Profil'),
  ];
}

class _AdminNavItem {
  final IconData activeIcon;
  final IconData icon;
  final String label;

  const _AdminNavItem(this.activeIcon, this.icon, this.label);
}
