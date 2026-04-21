import 'package:flutter/material.dart';

class StatusScreen extends StatelessWidget {
  const StatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ListTile(
            leading: Stack(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage(
                    'https://randomuser.me/api/portraits/men/5.jpg',
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Color(0xFF25D366),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
            title: const Text(
              'My status',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text('Tap to add status update'),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            width: double.infinity,
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1B272E)
                : Colors.grey[200],
            child: Text(
              'Recent updates',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildStatusTile(
            name: "Alice",
            time: "15 minutes ago",
            imageUrl: "https://randomuser.me/api/portraits/women/1.jpg",
            isSeen: false,
          ),
          _buildStatusTile(
            name: "Bob",
            time: "Today, 10:45 AM",
            imageUrl: "https://randomuser.me/api/portraits/men/2.jpg",
            isSeen: false,
          ),
          _buildStatusTile(
            name: "Charlie",
            time: "Today, 9:20 AM",
            imageUrl: "https://randomuser.me/api/portraits/men/3.jpg",
            isSeen: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTile({
    required String name,
    required String time,
    required String imageUrl,
    required bool isSeen,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSeen ? Colors.grey : const Color(0xFF25D366),
            width: 2.5,
          ),
        ),
        child: CircleAvatar(
          radius: 24,
          backgroundImage: NetworkImage(imageUrl),
        ),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(time),
    );
  }
}
