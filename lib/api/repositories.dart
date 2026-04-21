import 'package:whatapp/api/api_client.dart';
import 'package:whatapp/features/chat/chat_models.dart';
import 'package:whatapp/features/contacts/contact.dart';
import 'package:whatapp/features/session/app_session.dart';

class AuthRepository {
  final ApiClient api;
  AuthRepository(this.api);

  Future<void> requestOtp({required String identity}) async {
    await api.post<Map<String, Object?>>('/auth/request-otp', {
      'identity': identity,
    });
  }

  Future<bool> verifyOtp({required String identity, required String otp}) async {
    // Demo: accept any 6-digit otp.
    if (otp.trim().length != 6) return false;
    await api.post<Map<String, Object?>>('/auth/verify-otp', {
      'identity': identity,
      'otp': otp,
    });
    return true;
  }
}

class ContactsRepository {
  final ApiClient api;
  ContactsRepository(this.api);

  Future<List<Contact>> fetchContacts() async {
    // Demo: API is optional; return fallback list if not present.
    try {
      final raw = await api.get<List<Object?>>('/contacts');
      return raw
          .whereType<Map>()
          .map((m) => Contact(
                id: m['id'].toString(),
                displayName: m['displayName'].toString(),
                about: (m['about'] ?? '').toString(),
                phoneNumber: m['phoneNumber']?.toString(),
                avatarUrl: m['avatarUrl']?.toString(),
              ))
          .toList(growable: false);
    } catch (_) {
      return const [
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
      ];
    }
  }
}

class ChatRepository {
  final ApiClient api;
  ChatRepository(this.api);

  Future<void> sendMessage(ChatMessage message) async {
    await api.post<Map<String, Object?>>('/chats/${message.threadId}/send', {
      'id': message.id,
      'text': message.text,
      'createdAt': message.createdAt.toIso8601String(),
    });
  }
}

class ProfileRepository {
  final ApiClient api;
  ProfileRepository(this.api);

  Future<void> updateProfile(UserProfile profile) async {
    await api.post<Map<String, Object?>>('/me/profile', profile.toJson());
  }

  Future<void> updatePrivacy(PrivacySettings privacy) async {
    await api.post<Map<String, Object?>>('/me/privacy', privacy.toJson());
  }
}

