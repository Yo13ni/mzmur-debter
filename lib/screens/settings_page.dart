import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_config.dart';
import '../theme/app_colors.dart';
import '../widgets/soft_card.dart';
import 'info_page.dart';

class SettingsPage extends StatelessWidget {
  final bool embedded;

  const SettingsPage({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('ቅንብሮች'),
      ),
      body: Consumer<AppConfig>(
        builder: (context, appConfig, _) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              const _Header('የፊደል መጠን'),
              SoftCard(
                color: AppColors.card,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _SizeLabel('ትንሽ', appConfig.fontSizeLevel == 0),
                        _SizeLabel('መካከለኛ', appConfig.fontSizeLevel == 1),
                        _SizeLabel('ትልቅ', appConfig.fontSizeLevel == 2),
                      ],
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.accent,
                        inactiveTrackColor: AppColors.bgDeep,
                        thumbColor: AppColors.ink,
                      ),
                      child: Slider(
                        value: appConfig.fontSizeLevel.toDouble(),
                        min: 0,
                        max: 2,
                        divisions: 2,
                        onChanged: (v) =>
                            appConfig.setFontSizeLevel(v.round()),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.bgDeep,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'ይህ ምሳሌ ነው። የፊደል መጠንዎን እዚህ ላይ ሊቀይሩት ይችላሉ።',
                        style: TextStyle(
                          fontSize: 15 * appConfig.fontSizeScale,
                          height: 1.5,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SoftCard(
                color: AppColors.card,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const InfoPage()),
                  );
                },
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.accent),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'ስለ እኛ',
                        style: TextStyle(fontWeight: FontWeight.w400),
                      ),
                    ),
                    Icon(Icons.chevron_right, color: AppColors.inkMuted),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              const Center(
                child: Text(
                  'የመዝሙር ደብተር',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Center(
                child: Text(
                  'v1.0.0 • ለሰንበት ተማሪዎች',
                  style: TextStyle(color: AppColors.inkMuted, fontSize: 13),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String text;
  const _Header(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: AppColors.accent,
        ),
      ),
    );
  }
}

class _SizeLabel extends StatelessWidget {
  final String text;
  final bool selected;
  const _SizeLabel(this.text, this.selected);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: selected ? AppColors.ink : AppColors.inkMuted,
      ),
    );
  }
}
