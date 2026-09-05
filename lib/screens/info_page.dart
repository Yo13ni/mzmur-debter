import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/soft_card.dart';
import '../widgets/ui_bits.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('መረጃ'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          SoftCard(
            color: AppColors.card,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.asset(
                    AppAssets.icon,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'የመዝሙር ደብተር',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'ለሰንበት ተማሪዎች',
                  style: TextStyle(color: AppColors.inkMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SoftCard(
            color: AppColors.card,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ስለ መተግበሪያው',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'ይህ የመዝሙር መተግበሪያ በኢትዮጵያ ኦርቶዶክስ ተዋህዶ ቤተክርስቲያን ስር ለሚገኙ አገልጋዮች በሙሉ ለመዝሙር ደብተርነት የሚያገለግል ሲሆን ተጠቃሚዎች ግጥሞችን በምድቦች መደርደር፣ ተወዳጅ ግጥሞችን በመለየት እና አዳዲስ ግጥሞችን በመጨመር እንዲሁም መዝሙሮችን በመላላክ መጠቀም ይችላሉ።\n\nበልዑል እግዚአብሔር እርዳታ በጽርሐ ጽዮን አብማ ማርያም ኮከበ ጽባሕ ሰንበት ትምህርት ቤት መዝሙር ክፍል ለአገልግሎትነት ይውል ዘንድ ተሰራ።',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.55,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(color: AppColors.border),
                const SizedBox(height: 8),
                const _ContactRow(
                  icon: Icons.email_outlined,
                  text: 'yoni13awoke@gmail.com',
                ),
                const _ContactRow(
                  icon: Icons.send_outlined,
                  text: 'telegram: @yo_uno',
                ),
                const _ContactRow(
                  icon: Icons.calendar_today_outlined,
                  text: '2017 ዓ.ም',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ContactRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.accent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: AppColors.inkMuted),
            ),
          ),
        ],
      ),
    );
  }
}
