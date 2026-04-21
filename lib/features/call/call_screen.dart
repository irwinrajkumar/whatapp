import 'package:flutter/material.dart';

class CallScreen extends StatelessWidget {
  const CallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          leading: const CircleAvatar(
            radius: 28,
            backgroundColor: Color(0xFF128C7E),
            child: Icon(Icons.link, color: Colors.white, size: 28),
          ),
          title: const Text(
            'Create call link',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: const Text('Share a link for your WhatsApp call'),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          width: double.infinity,
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1B272E)
              : Colors.grey[200],
          child: Text(
            'Recent',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodySmall?.color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _buildCallTile(
          name: "John Doe",
          time: "March 15, 11:30 AM",
          imageUrl: "https://randomuser.me/api/portraits/men/1.jpg",
          isMissed: true,
          isIncoming: true,
          isVideo: false,
        ),
        _buildCallTile(
          name: "Jane Smith",
          time: "March 14, 8:45 PM",
          imageUrl: "https://randomuser.me/api/portraits/women/2.jpg",
          isMissed: false,
          isIncoming: false,
          isVideo: true,
        ),
        _buildCallTile(
          name: "Mom",
          time: "March 13, 2:15 PM",
          imageUrl: "https://randomuser.me/api/portraits/women/3.jpg",
          isMissed: false,
          isIncoming: true,
          isVideo: false,
        ),
      ],
    );
  }

  Widget _buildCallTile({
    required String name,
    required String time,
    required String imageUrl,
    required bool isMissed,
    required bool isIncoming,
    required bool isVideo,
  }) {
    return ListTile(
      leading: CircleAvatar(
        radius: 28,
        backgroundImage: NetworkImage(imageUrl),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Row(
        children: [
          Icon(
            isIncoming ? Icons.call_received : Icons.call_made,
            size: 16,
            color: isMissed ? Colors.red : Colors.green,
          ),
          const SizedBox(width: 4),
          Text(time),
        ],
      ),
      trailing: Icon(
        isVideo ? Icons.videocam : Icons.call,
        color: const Color(0xFF128C7E),
      ),
    );
  }
}
