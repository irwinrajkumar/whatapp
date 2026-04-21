import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:whatapp/features/contacts/contact.dart';

class ContactsProvider extends ChangeNotifier {
  bool _isSyncing = false;
  final List<Contact> _contacts = [];
  final Set<String> _blocked = {};
  final Set<String> _favorites = {};

  bool get isSyncing => _isSyncing;
  List<Contact> get contacts => List.unmodifiable(_contacts);
  Set<String> get blockedIds => Set.unmodifiable(_blocked);
  Set<String> get favoriteIds => Set.unmodifiable(_favorites);

  List<Contact> get visibleContacts =>
      _contacts.where((c) => !_blocked.contains(c.id)).toList(growable: false);

  List<Contact> get favoriteContacts => visibleContacts
      .where((c) => _favorites.contains(c.id))
      .toList(growable: false);

  bool isBlocked(String contactId) => _blocked.contains(contactId);
  bool isFavorite(String contactId) => _favorites.contains(contactId);

  Future<void> syncMockContacts() async {
    if (_isSyncing) return;
    _isSyncing = true;
    notifyListeners();

    // Simulate a contacts sync (replace later with real device contacts).
    await Future<void>.delayed(const Duration(milliseconds: 700));

    _contacts
      ..clear()
      ..addAll(const [
        Contact(
          id: 'c_alice',
          displayName: 'Alice',
          about: 'Design is thinking made visual.',
          phoneNumber: '+1 111 111 1111',
          avatarUrl: 'https://randomuser.me/api/portraits/women/1.jpg',
        ),
        Contact(
          id: 'c_bob',
          displayName: 'Bob',
          about: 'Available',
          phoneNumber: '+1 222 222 2222',
          avatarUrl: 'https://randomuser.me/api/portraits/men/2.jpg',
        ),
        Contact(
          id: 'c_charlie',
          displayName: 'Charlie',
          about: 'At the gym',
          phoneNumber: '+1 333 333 3333',
          avatarUrl: 'https://randomuser.me/api/portraits/men/3.jpg',
        ),
        Contact(
          id: 'c_david',
          displayName: 'David',
          about: 'Busy',
          phoneNumber: '+1 444 444 4444',
          avatarUrl: 'https://randomuser.me/api/portraits/men/4.jpg',
        ),
        Contact(
          id: 'c_eve',
          displayName: 'Eve',
          about: 'Urgent calls only',
          phoneNumber: '+1 555 555 5555',
          avatarUrl: 'https://randomuser.me/api/portraits/women/5.jpg',
        ),
      ]);

    _isSyncing = false;
    notifyListeners();
  }

  void toggleFavorite(String contactId) {
    if (_favorites.contains(contactId)) {
      _favorites.remove(contactId);
    } else {
      _favorites.add(contactId);
    }
    notifyListeners();
  }

  void block(String contactId) {
    _blocked.add(contactId);
    _favorites.remove(contactId);
    notifyListeners();
  }

  void unblock(String contactId) {
    _blocked.remove(contactId);
    notifyListeners();
  }

  Contact? byId(String contactId) {
    for (final c in _contacts) {
      if (c.id == contactId) return c;
    }
    return null;
  }
}

