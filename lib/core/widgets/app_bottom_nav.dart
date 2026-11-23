import 'package:easy_shop_client/core/theme/app_colors.dart';
import 'package:easy_shop_client/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class BottomNavItem {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final int badgeCount;

  const BottomNavItem({
    required this.icon,
    required this.label,
    this.selectedIcon,
    this.badgeCount = 0,
  });
}

class AppBottomNav extends StatelessWidget {
  final List<BottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: List.generate(items.length, (index) {
            final item = items[index];
            final isSelected = index == currentIndex;
            final color = isSelected ? AppColors.primary : AppColors.textGrey;
            return Expanded(
              child: InkWell(
                onTap: () => onTap(index),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 36,
                      height: 2,
                      color: isSelected
                          ? AppColors.primary
                          : Colors.transparent,
                    ),
                    const SizedBox(height: 8),
                    Badge(
                      isLabelVisible: item.badgeCount > 0,
                      label: Text('${item.badgeCount}'),
                      backgroundColor: AppColors.error,
                      child: Icon(
                        isSelected ? item.selectedIcon ?? item.icon : item.icon,
                        color: color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.label,
                      style: AppTextStyles.caption.copyWith(
                        color: color,
                        fontSize: 11,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
