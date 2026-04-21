import 'package:flutter/material.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final List<Map<String, String>> _contacts = [
    {
      "name": "Alice",
      "status": "Available",
      "image": "https://randomuser.me/api/portraits/women/1.jpg",
    },
    {
      "name": "Bob",
      "status": "At the gym",
      "image": "https://randomuser.me/api/portraits/men/2.jpg",
    },
    {
      "name": "Charlie",
      "status": "Busy",
      "image": "https://randomuser.me/api/portraits/men/3.jpg",
    },
    {
      "name": "David",
      "status": "Urgent calls only",
      "image": "https://randomuser.me/api/portraits/men/4.jpg",
    },
  ];

  final Set<int> _selectedIndices = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'New group',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '${_selectedIndices.length} of ${_contacts.length} selected',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_selectedIndices.isNotEmpty)
            Container(
              height: 90,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedIndices.length,
                itemBuilder: (context, index) {
                  int contactIndex = _selectedIndices.elementAt(index);
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            CircleAvatar(
                              radius: 25,
                              backgroundImage: NetworkImage(
                                _contacts[contactIndex]['image']!,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _contacts[contactIndex]['name']!,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: GestureDetector(
                            onTap: () => setState(
                              () => _selectedIndices.remove(contactIndex),
                            ),
                            child: const CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.grey,
                              child: Icon(
                                Icons.close,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: _contacts.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedIndices.contains(index);
                return ListTile(
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundImage: NetworkImage(
                          _contacts[index]['image']!,
                        ),
                      ),
                      if (isSelected)
                        const Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 10,
                            backgroundColor: Color(0xFF00A884),
                            child: Icon(
                              Icons.check,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: Text(
                    _contacts[index]['name']!,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(_contacts[index]['status']!),
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedIndices.remove(index);
                      } else {
                        _selectedIndices.add(index);
                      }
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _selectedIndices.isNotEmpty
          ? FloatingActionButton(
              onPressed: () {
                // Navigate to name group screen
              },
              backgroundColor: const Color(0xFF00A884),
              child: const Icon(Icons.arrow_forward, color: Colors.white),
            )
          : null,
    );
  }
}
