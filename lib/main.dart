import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatapp/core/theme.dart';
import 'package:whatapp/features/chat/chat_list_screen.dart';
import 'package:whatapp/features/status/status_screen.dart';
import 'package:whatapp/features/call/call_screen.dart';
import 'package:whatapp/features/settings/settings_screen.dart';
import 'package:whatapp/features/chat/group_list_screen.dart';
import 'package:whatapp/features/auth/splash_screen.dart';
import 'package:whatapp/features/chat/select_contact_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WhatsApp',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: 1);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WhatsApp'),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined),
            onPressed: () {},
          ),
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'Settings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'New group', child: Text('New group')),
              const PopupMenuItem(
                value: 'New broadcast',
                child: Text('New broadcast'),
              ),
              const PopupMenuItem(
                value: 'Linked devices',
                child: Text('Linked devices'),
              ),
              const PopupMenuItem(
                value: 'Starred messages',
                child: Text('Starred messages'),
              ),
              const PopupMenuItem(value: 'Settings', child: Text('Settings')),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorWeight: 3.0,
          tabs: const [
            Tab(child: Icon(Icons.groups, size: 28)),
            Tab(text: 'Chats'),
            Tab(text: 'Status'),
            Tab(text: 'Calls'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          GroupListScreen(),
          ChatListScreen(),
          StatusScreen(),
          CallScreen(),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget? _buildFAB() {
    switch (_tabController.index) {
      case 1:
        return FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SelectContactScreen(),
              ),
            );
          },
          child: const Icon(Icons.message),
        );
      case 2:
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              mini: true,
              onPressed: () {},
              child: const Icon(Icons.edit, color: Colors.blueGrey),
            ),
            const SizedBox(height: 16),
            FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.camera_alt),
            ),
          ],
        );
      case 3:
        return FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.add_call),
        );
      default:
        return null;
    }
  }
}
