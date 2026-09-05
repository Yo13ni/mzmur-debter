import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/ui_bits.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 3),
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Image.asset(
                AppAssets.icon,
                width: 88,
                height: 88,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 88,
                  height: 88,
                  color: AppColors.card,
                  child: const Icon(Icons.menu_book_rounded,
                      size: 44, color: AppColors.ink),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'የመዝሙር ደብተር',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w400,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'ለሰንበት ተማሪዎች',
              style: TextStyle(fontSize: 15, color: AppColors.inkMuted),
            ),
            const Spacer(flex: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: 0.35 + (_controller.value * 0.55),
                      minHeight: 6,
                      backgroundColor: AppColors.card,
                      color: AppColors.accent,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'መዝሙራትን ይጽፋል...',
              style: TextStyle(
                color: AppColors.accent,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
