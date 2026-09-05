import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'soft_card.dart';

class AppAssets {
  static const String icon = 'assets/icons/mezmur.png';
  static const String categoryAvatar = 'assets/images/category_avatar.jpg';
  static const List<String> photos = [
    'assets/photo_2025-09-25_03-35-12.jpg',
    'assets/photo_2025-09-25_03-35-26.jpg',
    'assets/photo_2025-09-25_03-35-33.jpg',
    'assets/photo_2025-09-25_03-35-38.jpg',
  ];

  static String photoAt(int index) => photos[index % photos.length];
}

class SearchField extends StatelessWidget {
  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final bool autofocus;
  final bool readOnly;
  final VoidCallback? onTap;

  const SearchField({
    super.key,
    this.controller,
    this.hint = 'መዝሙር ፈልግ',
    this.onSubmitted,
    this.onChanged,
    this.onClear,
    this.autofocus = false,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      readOnly: readOnly,
      onTap: onTap,
      onSubmitted: onSubmitted,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.black87, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.searchHint, fontSize: 15),
        prefixIcon: const Icon(Icons.search, color: AppColors.searchHint),
        suffixIcon: controller != null && controller!.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.cancel, size: 20, color: Colors.black54),
                onPressed: () {
                  controller!.clear();
                  onClear?.call();
                  onChanged?.call('');
                },
              )
            : null,
        filled: true,
        fillColor: AppColors.searchBar,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class CountBadge extends StatelessWidget {
  final int count;

  const CountBadge({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.bgDeep,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: AppColors.ink,
          fontWeight: FontWeight.w400,
          fontSize: 13,
        ),
      ),
    );
  }
}

class CategoryChip extends StatelessWidget {
  final String label;

  const CategoryChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.bgDeep.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.ink,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class IconTile extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final Color? backgroundColor;

  const IconTile({
    super.key,
    required this.icon,
    this.iconColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.bgDeep,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: iconColor ?? AppColors.ink, size: 22),
    );
  }
}

/// Circular religious thumbnail used in list rows.
class PoemAvatar extends StatelessWidget {
  final int index;
  final double size;

  const PoemAvatar({super.key, required this.index, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.asset(
        AppAssets.photoAt(index),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: size,
          height: size,
          color: AppColors.bgDeep,
          child: const Icon(Icons.music_note, color: AppColors.ink),
        ),
      ),
    );
  }
}

/// Shared category list avatar — circular with soft shadow.
class CategoryAvatar extends StatelessWidget {
  final double size;

  const CategoryAvatar({super.key, this.size = 52});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          AppAssets.categoryAvatar,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: size,
            height: size,
            color: AppColors.bgDeep,
            child: const Icon(Icons.category, color: AppColors.ink),
          ),
        ),
      ),
    );
  }
}

/// Standard hymn list row matching the dark UI cards.
class HymnListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final int imageIndex;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;

  const HymnListTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.imageIndex = 0,
    this.isFavorite = false,
    this.onTap,
    this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      color: AppColors.card,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.inkMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onFavorite,
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}
