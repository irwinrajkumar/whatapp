import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:whatapp/features/chat/chat_detail_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatapp/state/providers.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contacts = ref.watch(contactsProvider);
    final chats = ref.watch(chatsProvider);

    final threads = chats.threads
        .where((t) => !contacts.isBlocked(t.contactId))
        .toList(growable: false);

    if (threads.isEmpty) {
      return Center(
        child: Text(
          'No chats yet.\nTap the message button to start one.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Theme.of(context).hintColor),
        ),
      );
    }

    return ListView.separated(
      itemCount: threads.length,
      separatorBuilder: (context, index) =>
          const Divider(height: 1, indent: 80),
      itemBuilder: (context, index) {
        final thread = threads[index];
        final contact = contacts.byId(thread.contactId);
        final messages = chats.messagesFor(thread.id);
        final last = messages.isNotEmpty ? messages.last : null;

        final title = contact?.displayName ?? 'Unknown';
        final subtitle = last?.text ?? 'Tap to chat';
        final avatar = contact?.avatarUrl;

        return ListTile(
          leading: CircleAvatar(
            radius: 28,
            backgroundImage: avatar == null
                ? null
                : CachedNetworkImageProvider(avatar),
            backgroundColor: Colors.grey[300],
            child: avatar == null
                ? Text(title.isEmpty ? '?' : title[0].toUpperCase())
                : null,
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Row(
            children: [
              Expanded(
                child: Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatTime(last?.createdAt),
                style: TextStyle(
                  color: thread.unreadCount > 0
                      ? const Color(0xFF25D366)
                      : Theme.of(context).textTheme.bodySmall?.color,
                  fontSize: 12,
                ),
              ),
              if (thread.unreadCount > 0) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF25D366),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    thread.unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ChatDetailScreen(threadId: thread.id, contactId: thread.contactId),
              ),
            );
          },
        );
      },
    );
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }
}
