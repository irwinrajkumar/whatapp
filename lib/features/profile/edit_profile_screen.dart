import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatapp/features/session/app_session.dart';
import 'package:whatapp/state/providers.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _aboutController;
  String _phoneNumber = "";

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _aboutController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final session = ref.read(appSessionProvider);
    final profile = session.profile;
    _nameController.text = profile?.displayName ?? _nameController.text;
    _aboutController.text = profile?.about ?? _aboutController.text;
    _phoneNumber = profile?.phoneNumber ?? session.authIdentity ?? _phoneNumber;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 28),
            // Profile Photo section
            Center(
              child: Stack(
                children: [
                  Hero(
                    tag: 'profile-pic',
                    child: CircleAvatar(
                      radius: 80,
                      backgroundColor: isDarkMode
                          ? Colors.grey[800]
                          : Colors.grey[200],
                      backgroundImage: const NetworkImage(
                        'https://randomuser.me/api/portraits/men/5.jpg',
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        // Image picker logic
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Color(0xFF00A884),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Name section
            _buildEditTile(
              icon: Icons.person,
              title: "Name",
              subtitle: _nameController.text,
              onTap: () => _showEditDialog("Name", _nameController),
              description:
                  "This is not your username or pin. This name will be visible to your WhatsApp contacts.",
            ),

            const Padding(
              padding: EdgeInsets.only(left: 72),
              child: Divider(height: 1),
            ),

            // About section (Status Message)
            _buildEditTile(
              icon: Icons.info_outline,
              title: "About",
              subtitle: _aboutController.text,
              onTap: () => _showEditDialog("About", _aboutController),
            ),

            const Padding(
              padding: EdgeInsets.only(left: 72),
              child: Divider(height: 1),
            ),

            // Phone section
            _buildEditTile(
              icon: Icons.call,
              title: "Phone",
              subtitle: _phoneNumber,
              onTap: null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    String? description,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Icon(icon, color: const Color(0xFF8696A0)),
      ),
      title: Text(
        title,
        style: const TextStyle(color: Color(0xFF8696A0), fontSize: 14),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          if (description != null) ...[
            const SizedBox(height: 12),
            Text(
              description,
              style: const TextStyle(
                color: Color(0xFF8696A0),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
      trailing: onTap != null
          ? const Icon(Icons.edit, color: Color(0xFF00A884), size: 20)
          : null,
    );
  }

  void _showEditDialog(String title, TextEditingController controller) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: Text(
            "Enter your $title",
            style: const TextStyle(fontSize: 18),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
            decoration: InputDecoration(
              hintText: "Enter $title",
              counterText: title == "Name" ? "25" : null,
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF00A884), width: 2),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "CANCEL",
                style: TextStyle(
                  color: Color(0xFF00A884),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {});
                Navigator.pop(context);
                _persistProfile();
              },
              child: const Text(
                "SAVE",
                style: TextStyle(
                  color: Color(0xFF00A884),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _persistProfile() async {
    final session = ref.read(appSessionProvider);
    final current = session.profile;
    final profile = (current ??
            UserProfile(
              displayName: _nameController.text.trim().isEmpty
                  ? 'Your name'
                  : _nameController.text.trim(),
              about: _aboutController.text.trim().isEmpty
                  ? 'Available'
                  : _aboutController.text.trim(),
              phoneNumber: session.authIdentity,
            ))
        .copyWith(
      displayName: _nameController.text.trim().isEmpty
          ? (current?.displayName ?? 'Your name')
          : _nameController.text.trim(),
      about: _aboutController.text.trim().isEmpty
          ? (current?.about ?? 'Available')
          : _aboutController.text.trim(),
      phoneNumber: _phoneNumber.isEmpty ? current?.phoneNumber : _phoneNumber,
    );

    await session.saveProfile(profile);
    await ref.read(profileRepositoryProvider).updateProfile(profile);
  }
}
