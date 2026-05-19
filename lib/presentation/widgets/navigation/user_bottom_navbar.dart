import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class UserBottomNavbar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const UserBottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _RoleBottomBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        _RoleNavItem(Icons.home_rounded, Icons.home_outlined, 'Home'),
        _RoleNavItem(Icons.search_rounded, Icons.search_outlined, 'Search'),
        _RoleNavItem(Icons.calendar_month_rounded, Icons.calendar_month_outlined, 'Booking'),
        _RoleNavItem(Icons.favorite_rounded, Icons.favorite_border_rounded, 'Favorite'),
        _RoleNavItem(Icons.person_rounded, Icons.person_outline_rounded, 'Profile'),
      ],
    );
  }
}

class _RoleBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<_RoleNavItem> items;

  const _RoleBottomBar({
    required this.currentIndex,
    required this.onTap,
    required this.items,
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
            children: List.generate(items.length, (index) {
              final item = items[index];
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
}

class _RoleNavItem {
  final IconData activeIcon;
  final IconData icon;
  final String label;

  const _RoleNavItem(this.activeIcon, this.icon, this.label);
}
