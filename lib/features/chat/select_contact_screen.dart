import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatapp/features/chat/chat_detail_screen.dart';
import 'package:whatapp/features/chat/create_group_screen.dart';
import 'package:whatapp/state/providers.dart';

enum SelectContactMode { startChat, forwardMessage }

class SelectContactScreen extends ConsumerWidget {
  final SelectContactMode mode;
  final String? forwardFromThreadId;
  final String? forwardMessageId;

  const SelectContactScreen({
    super.key,
    this.mode = SelectContactMode.startChat,
    this.forwardFromThreadId,
    this.forwardMessageId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contacts = ref.watch(contactsProvider);
    final visible = contacts.visibleContacts;
    final favs = contacts.favoriteContacts;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              mode == SelectContactMode.forwardMessage
                  ? 'Forward to...'
                  : 'Select contact',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '${visible.length} contacts',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: contacts.isSyncing ? null : contacts.syncMockContacts,
          ),
        ],
      ),
      body: ListView(
        children: [
          _buildActionTile(context, Icons.group, 'New group'),
          _buildActionTile(context, Icons.person_add, 'Invite friends'),
          _buildActionTile(context, Icons.block, 'Blocked contacts'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Favorites',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          if (favs.isEmpty)
            const ListTile(
              title: Text('No favorites yet'),
              subtitle: Text('Long-press a contact to add to favorites.'),
            )
          else
            ...favs.map((c) => _buildContactTile(context, c.id)),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Contacts on WhatsApp',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          if (contacts.isSyncing)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          ...visible.map((c) => _buildContactTile(context, c.id)),
        ],
      ),
    );
  }

  Widget _buildActionTile(BuildContext context, IconData icon, String title) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFF128C7E),
        child: Icon(icon, color: Colors.white),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      onTap: () {
        if (title == 'New group') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateGroupScreen()),
          );
        } else if (title == 'Invite friends') {
          _inviteFriends(context);
        } else if (title == 'Blocked contacts') {
          _showBlockedContacts(context);
        }
      },
    );
  }

  Widget _buildContactTile(BuildContext context, String contactId) {
    final container = ProviderScope.containerOf(context, listen: false);
    final contacts = container.read(contactsProvider);
    final chats = container.read(chatsProvider);
    final contact = contacts.byId(contactId);
    if (contact == null) return const SizedBox.shrink();

    return ListTile(
      leading: CircleAvatar(
        backgroundImage:
            contact.avatarUrl == null ? null : NetworkImage(contact.avatarUrl!),
        child: contact.avatarUrl == null
            ? Text(contact.displayName.isEmpty
                ? '?'
                : contact.displayName[0].toUpperCase())
            : null,
      ),
      title: Text(
        contact.displayName,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(contact.about),
      trailing: contacts.isFavorite(contactId)
          ? const Icon(Icons.star, color: Color(0xFF25D366), size: 20)
          : null,
      onLongPress: () => _showContactActions(context, contactId),
      onTap: () {
        final thread = chats.ensureThreadForContact(contactId);
        if (mode == SelectContactMode.forwardMessage) {
          final fromThreadId = forwardFromThreadId;
          final msgId = forwardMessageId;
          if (fromThreadId != null && msgId != null) {
            chats.forwardMessage(
              fromThreadId: fromThreadId,
              messageId: msgId,
              toThreadId: thread.id,
            );
          }
          Navigator.pop(context);
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ChatDetailScreen(threadId: thread.id, contactId: contactId),
          ),
        );
      },
    );
  }

  void _showContactActions(BuildContext context, String contactId) {
    final contacts =
        ProviderScope.containerOf(context, listen: false).read(contactsProvider);
    final isFav = contacts.isFavorite(contactId);
    final isBlocked = contacts.isBlocked(contactId);

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(isFav ? Icons.star : Icons.star_border),
                title: Text(isFav ? 'Remove favorite' : 'Add to favorites'),
                onTap: () {
                  Navigator.pop(context);
                  contacts.toggleFavorite(contactId);
                },
              ),
              ListTile(
                leading: Icon(isBlocked ? Icons.lock_open : Icons.block),
                title: Text(isBlocked ? 'Unblock' : 'Block'),
                onTap: () {
                  Navigator.pop(context);
                  if (isBlocked) {
                    contacts.unblock(contactId);
                  } else {
                    contacts.block(contactId);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _inviteFriends(BuildContext context) async {
    const link = 'https://example.com/whatapp-invite';
    await Clipboard.setData(const ClipboardData(text: link));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invite link copied to clipboard')),
    );
  }

  void _showBlockedContacts(BuildContext context) {
    final contacts =
        ProviderScope.containerOf(context, listen: false).read(contactsProvider);
    final blocked = contacts.blockedIds.toList(growable: false);

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: blocked.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('No blocked contacts.'),
                )
              : ListView(
                  shrinkWrap: true,
                  children: [
                    const ListTile(
                      title: Text(
                        'Blocked contacts',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...blocked.map((id) {
                      final c = contacts.byId(id);
                      return ListTile(
                        title: Text(c?.displayName ?? id),
                        trailing: TextButton(
                          onPressed: () {
                            contacts.unblock(id);
                            Navigator.pop(context);
                          },
                          child: const Text('UNBLOCK'),
                        ),
                      );
                    }),
                  ],
                ),
        );
      },
    );
  }
}
