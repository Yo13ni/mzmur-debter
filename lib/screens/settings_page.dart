// screens/settings_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_config.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // We use a Consumer to get access to the AppConfig provider
    return Scaffold(
      appBar: AppBar(
        title: const Text('ቅንብሮች'), // Amharic for 'Settings'
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
      ),
      body: Consumer<AppConfig>(
        builder: (context, appConfig, child) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Dark Mode Setting
              ListTile(
                title: const Text('ጥቁር ገጽታ'), // Amharic for 'Dark Mode'
                trailing: Switch(
                  value: appConfig.themeMode == ThemeMode.dark,
                  onChanged: (isDark) {
                    appConfig.toggleTheme();
                  },
                ),
              ),

              const Divider(),

              // Font Size Setting
              ListTile(
                title: const Text('የፊደል መጠን'), // Amharic for 'Font Size'
                subtitle: const Text('የጽሑፍ መጠን ጨምር ወይም ቀንስ'), // 'Increase or decrease text size'
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: appConfig.decreaseFontSize,
                    ),
                    Text(
                      '${(appConfig.fontSizeScale * 100).toInt()}%',
                      style: const TextStyle(fontSize: 16),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: appConfig.increaseFontSize,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}