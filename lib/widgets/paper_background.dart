import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PaperBackground extends StatelessWidget {
  final Widget child;

  const PaperBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(color: AppColors.bg, child: child);
  }
}
