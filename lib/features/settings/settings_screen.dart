import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatapp/features/auth/welcome_screen.dart';
import 'package:whatapp/features/profile/edit_profile_screen.dart';
import 'package:whatapp/features/profile/privacy_settings_screen.dart';
import 'package:whatapp/state/providers.dart';
import 'package:whatapp/features/payments/payments_home_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(appSessionProvider);
    final profile = session.profile;

    final displayName = profile?.displayName ?? 'Your name';
    final about = profile?.about ?? 'Available';

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );
            },
            leading: const CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(
                'https://randomuser.me/api/portraits/men/5.jpg',
              ),
            ),
            title: Text(
              displayName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(about),
            trailing: const Icon(Icons.qr_code, color: Color(0xFF128C7E)),
          ),
          const Divider(),
          _buildSettingsTile(
            Icons.key,
            'Account',
            'Security notifications, change number',
          ),
          _buildSettingsTile(
            Icons.lock,
            'Privacy',
            'Block contacts, disappearing messages',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrivacySettingsScreen(),
                ),
              );
            },
          ),
          _buildSettingsTile(
            Icons.chat,
            'Chats',
            'Theme, wallpapers, chat history',
          ),
          _buildSettingsTile(
            Icons.notifications,
            'Notifications',
            'Message, group & call tones',
          ),
          _buildSettingsTile(
            Icons.currency_rupee,
            'Payments',
            'History, bank accounts',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PaymentsHomeScreen(),
                ),
              );
            },
          ),
          _buildSettingsTile(
            Icons.data_usage,
            'Storage and data',
            'Network usage, auto-download',
          ),
          _buildSettingsTile(
            Icons.language,
            'App language',
            'English (device\'s language)',
          ),
          _buildSettingsTile(
            Icons.help_outline,
            'Help',
            'Help center, contact us, privacy policy',
          ),
          _buildSettingsTile(Icons.group, 'Invite a friend', ''),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              final navigator = Navigator.of(context);
              await ref.read(appSessionProvider).logout();
              if (!context.mounted) return;
              navigator.pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                (route) => false,
              );
            },
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'from\nMeta',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    IconData icon,
    String title,
    String subtitle, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(title),
      subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
      onTap: onTap,
    );
  }
}
