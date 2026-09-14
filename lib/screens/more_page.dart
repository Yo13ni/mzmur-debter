import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../widgets/soft_card.dart';
import 'settings_page.dart';
import 'info_page.dart';

class MorePage extends StatelessWidget {
  final bool embedded;

  const MorePage({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final ListView content = ListView(
      padding: EdgeInsets.fromLTRB(20, embedded ? 16 : 8, 20, 32),
      children: [
        const _SectionTitle('ተግባራት'),
        SoftCard(
          color: AppColors.card,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _MenuRow(
                icon: Icons.settings_outlined,
                label: 'ቅንብሮች',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsPage()),
                  );
                },
              ),
              const Divider(height: 1, color: AppColors.border, indent: 56),
              _MenuRow(
                icon: Icons.info_outline_rounded,
                label: 'መረጃ',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const InfoPage()),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const _SectionTitle('ስለ እኛ'),
        SoftCard(
          color: AppColors.card,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _MenuRow(
                icon: Icons.menu_book_outlined,
                label: 'ስለ መዝሙር ደብተሩ',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const InfoPage()),
                  );
                },
              ),
              const Divider(height: 1, color: AppColors.border, indent: 56),
              _MenuRow(
                icon: Icons.logout_rounded,
                label: 'ውጣ',
                onTap: () => SystemNavigator.pop(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          'Version 1.0.0',
          style: TextStyle(color: AppColors.inkMuted, fontSize: 13),
        ),
        const SizedBox(height: 4),
        const Text(
          '© 2024 Sabbath School Mezmur',
          style: TextStyle(color: AppColors.inkMuted, fontSize: 13),
        ),
      ],
    );

    if (embedded) {
      return SafeArea(child: content);
    }
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('ተጨማሪ'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: content,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.accent,
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      leading: Icon(icon, color: AppColors.accent),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w400)),
      trailing:
          const Icon(Icons.chevron_right_rounded, color: AppColors.inkMuted),
      onTap: onTap,
    );
  }
}
