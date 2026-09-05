import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// 3-tab bar: categories, favorites, write — your app's real navigation.
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      color: AppColors.nav,
      padding: EdgeInsets.only(bottom: bottom > 0 ? bottom : 8, top: 8),
      child: Row(
        children: [
          _Item(
            icon: Icons.grid_view_rounded,
            label: 'ምድቦች',
            selected: currentIndex == 0,
            onTap: () => onTap(0),
          ),
          _Item(
            icon: Icons.favorite_border,
            selectedIcon: Icons.favorite,
            label: 'ተወዳጆች',
            selected: currentIndex == 1,
            onTap: () => onTap(1),
          ),
          _Item(
            icon: Icons.edit_note_rounded,
            label: 'ፃፍ',
            selected: currentIndex == 2,
            onTap: () => onTap(2),
          ),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Item({
    required this.icon,
    this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.ink : AppColors.accent;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? (selectedIcon ?? icon) : icon,
              color: color,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FloatingBottomNav extends AppBottomNav {
  const FloatingBottomNav({
    super.key,
    required super.currentIndex,
    required super.onTap,
  });
}
