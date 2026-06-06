import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppBottomNavItem {
  final String label;
  final IconData icon;

  const AppBottomNavItem({
    required this.label,
    required this.icon,
  });
}

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<AppBottomNavItem> items;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
        child: Container(
          height: 74,
          decoration: BoxDecoration(
            color: AppColors.glass.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: AppColors.purpleAccent.withValues(alpha: 0.16),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.purpleAccent.withValues(alpha: 0.16),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final selected = index == currentIndex;

              return Expanded(
                child: Tooltip(
                  message: item.label,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () => onTap(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.purpleAccent.withValues(alpha: 0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            item.icon,
                            color: selected ? AppColors.cyan : AppColors.textMuted,
                            size: 22,
                          ),
                          const SizedBox(height: 4),
                          FittedBox(
                            child: Text(
                              item.label,
                              style: TextStyle(
                                color:
                                    selected ? AppColors.purple3 : AppColors.textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
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
