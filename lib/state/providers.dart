import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatapp/api/api_client.dart';
import 'package:whatapp/api/repositories.dart';
import 'package:whatapp/features/chat/chat_models.dart';
import 'package:whatapp/features/chat/chat_provider.dart';
import 'package:whatapp/features/contacts/contacts_provider.dart';
import 'package:whatapp/features/session/app_session.dart';

// API + repositories
final apiClientProvider = Provider<ApiClient>((ref) => FakeApiClient());

final authRepositoryProvider =
    Provider<AuthRepository>((ref) => AuthRepository(ref.watch(apiClientProvider)));

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(ref.watch(apiClientProvider)),
);

final contactsRepositoryProvider = Provider<ContactsRepository>(
  (ref) => ContactsRepository(ref.watch(apiClientProvider)),
);

final chatRepositoryProvider =
    Provider<ChatRepository>((ref) => ChatRepository(ref.watch(apiClientProvider)));

// App session (wrap existing ChangeNotifier so UI can migrate gradually)
final appSessionProvider = ChangeNotifierProvider<AppSession>((ref) {
  final session = AppSession();
  // Initialize lazily from SplashScreen via ref.read(appSessionProvider).initialize()
  return session;
});

final contactsProvider = ChangeNotifierProvider<ContactsProvider>((ref) {
  final p = ContactsProvider();
  // Sync lazily; screens can trigger it as needed.
  p.syncMockContacts();
  return p;
});

final chatsProvider = ChangeNotifierProvider<ChatProvider>((ref) {
  final p = ChatProvider();
  p.seedDemoIfEmpty();
  return p;
});

// Convenience selectors
final threadMessagesProvider =
    Provider.family<List<ChatMessage>, String>((ref, threadId) {
  return ref.watch(chatsProvider).messagesFor(threadId);
});

