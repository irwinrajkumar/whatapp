import 'package:flutter/material.dart';
import 'package:whatapp/features/chat/create_group_screen.dart';

class GroupListScreen extends StatelessWidget {
  const GroupListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const CircleAvatar(
          radius: 35,
          backgroundColor: Color(0xFF128C7E),
          child: Icon(Icons.groups, color: Colors.white, size: 40),
        ),
        const SizedBox(height: 10),
        const Text(
          'Stay connected with groups',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'Groups make it easy to plan, coordinate, and stay in touch with friends and family.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF128C7E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text(
            'Start your community',
            style: TextStyle(color: Colors.white),
          ),
        ),
        const Divider(height: 40),
        ListTile(
          leading: const CircleAvatar(
            backgroundColor: Color(0xFF128C7E),
            child: Icon(Icons.add, color: Colors.white),
          ),
          title: const Text(
            'New group',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateGroupScreen(),
              ),
            );
          },
        ),
      ],
    );
  }
}
