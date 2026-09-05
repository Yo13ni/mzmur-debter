import 'package:flutter/material.dart';

IconData iconForCategory(String category) {
  final c = category.toLowerCase();
  if (c.contains('ማርያም') || c.contains('እመቤት') || c.contains('ድንግል')) {
    return Icons.auto_awesome;
  }
  if (c.contains('ስቅለት') || c.contains('መስቀል')) {
    return Icons.help_outline_rounded;
  }
  if (c.contains('ጥምቀት') || c.contains('ውሃ')) {
    return Icons.water_drop_outlined;
  }
  if (c.contains('ቅዱሳን') || c.contains('መላእክት')) {
    return Icons.person_outline_rounded;
  }
  if (c.contains('ትንሳኤ')) {
    return Icons.wb_sunny_outlined;
  }
  if (c.contains('ልደት') || c.contains('ፅጌ') || c.contains('ጽጌ')) {
    return Icons.favorite_outline;
  }
  if (c.contains('አማላጅ') || c.contains('ንስሀ')) {
    return Icons.groups_outlined;
  }
  if (c.contains('ቤተ') || c.contains('ቤተክርስቲያን') || c.contains('ንግስ')) {
    return Icons.account_balance_outlined;
  }
  if (c.contains('ሰርግ')) {
    return Icons.favorite;
  }
  if (c.contains('ዘወትር')) {
    return Icons.menu_book_outlined;
  }
  return Icons.music_note_outlined;
}
