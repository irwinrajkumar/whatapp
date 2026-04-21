import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatapp/features/session/app_session.dart';
import 'package:whatapp/state/providers.dart';

class PrivacySettingsScreen extends ConsumerStatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  ConsumerState<PrivacySettingsScreen> createState() =>
      _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends ConsumerState<PrivacySettingsScreen> {
  String _lastSeen = "Everyone";
  String _profilePhoto = "Everyone";
  String _about = "Everyone";
  String _status = "My contacts";
  bool _readReceipts = true;
  bool _loaded = false;

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      final privacy = ref.read(appSessionProvider).privacy;
      _lastSeen = privacy.lastSeen;
      _profilePhoto = privacy.profilePhoto;
      _about = privacy.about;
      _status = privacy.status;
      _readReceipts = privacy.readReceipts;
      _loaded = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text(
              'SAVE',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Who can see my personal info',
              style: TextStyle(
                color: Color(0xFF128C7E),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildPrivacyTile(
            "Last seen",
            _lastSeen,
            () => _showPicker("Last seen", [
              "Everyone",
              "My contacts",
              "Nobody",
            ], (val) => setState(() => _lastSeen = val)),
          ),
          _buildPrivacyTile(
            "Profile photo",
            _profilePhoto,
            () => _showPicker("Profile photo", [
              "Everyone",
              "My contacts",
              "Nobody",
            ], (val) => setState(() => _profilePhoto = val)),
          ),
          _buildPrivacyTile(
            "About",
            _about,
            () => _showPicker("About", [
              "Everyone",
              "My contacts",
              "Nobody",
            ], (val) => setState(() => _about = val)),
          ),
          _buildPrivacyTile(
            "Status",
            _status,
            () => _showPicker("Status", [
              "My contacts",
              "My contacts except...",
              "Only share with...",
            ], (val) => setState(() => _status = val)),
          ),

          const Divider(),
          SwitchListTile(
            activeThumbColor: const Color(0xFF128C7E),
            title: const Text("Read receipts"),
            subtitle: const Text(
              "If turned off, you won't send or receive read receipts. Read receipts are always sent for group chats.",
            ),
            value: _readReceipts,
            onChanged: (val) => setState(() => _readReceipts = val),
          ),

          const Divider(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Disappearing messages',
              style: TextStyle(
                color: Color(0xFF128C7E),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildPrivacyTile("Default message timer", "Off", () {}),

          const Divider(),
          _buildSimpleTile(Icons.groups, "Groups", "Everyone"),
          _buildSimpleTile(Icons.location_on, "Live location", "None"),
          _buildSimpleTile(Icons.block, "Blocked contacts", "0"),
          _buildSimpleTile(Icons.fingerprint, "Fingerprint lock", "Disabled"),
        ],
      ),
    );
  }

  Widget _buildPrivacyTile(String title, String value, VoidCallback onTap) {
    return ListTile(onTap: onTap, title: Text(title), subtitle: Text(value));
  }

  Widget _buildSimpleTile(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Text(value, style: const TextStyle(color: Colors.grey)),
      onTap: () {},
    );
  }

  void _showPicker(
    String title,
    List<String> options,
    Function(String) onSelect,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...options.map(
                (opt) => RadioListTile<String>(
                  title: Text(opt),
                  value: opt,
                  groupValue: _valueForTitle(title),
                  onChanged: (val) {
                    onSelect(val!);
                    _save();
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _valueForTitle(String title) {
    switch (title) {
      case 'Last seen':
        return _lastSeen;
      case 'Profile photo':
        return _profilePhoto;
      case 'About':
        return _about;
      case 'Status':
        return _status;
      default:
        return '';
    }
  }

  Future<void> _save() async {
    final session = ref.read(appSessionProvider);
    final updated = PrivacySettings(
      lastSeen: _lastSeen,
      profilePhoto: _profilePhoto,
      about: _about,
      status: _status,
      readReceipts: _readReceipts,
    );
    await session.savePrivacy(updated);
    await ref.read(profileRepositoryProvider).updatePrivacy(updated);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Privacy settings saved')),
    );
  }
}
