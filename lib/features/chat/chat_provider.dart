import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:whatapp/features/chat/chat_models.dart';

class ChatProvider extends ChangeNotifier {
  final Map<String, ChatThread> _threadsById = {};
  final Map<String, List<ChatMessage>> _messagesByThreadId = {};

  List<ChatThread> get threads {
    final list = _threadsById.values.toList(growable: false);
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  ChatThread ensureThreadForContact(String contactId) {
    final existing = _threadsById.values.where((t) => t.contactId == contactId);
    if (existing.isNotEmpty) return existing.first;

    final id = 't_$contactId';
    final thread = ChatThread(
      id: id,
      contactId: contactId,
      updatedAt: DateTime.now(),
      unreadCount: 0,
    );
    _threadsById[id] = thread;
    _messagesByThreadId[id] = [];
    notifyListeners();
    return thread;
  }

  List<ChatMessage> messagesFor(String threadId) =>
      List.unmodifiable(_messagesByThreadId[threadId] ?? const []);

  ChatMessage? messageById(String threadId, String messageId) {
    final msgs = _messagesByThreadId[threadId];
    if (msgs == null) return null;
    for (final m in msgs) {
      if (m.id == messageId) return m;
    }
    return null;
  }

  void markThreadRead(String threadId) {
    final thread = _threadsById[threadId];
    if (thread == null) return;
    _threadsById[threadId] = thread.copyWith(unreadCount: 0);

    // When opening a chat, any "delivered" outgoing messages become "seen".
    final msgs = _messagesByThreadId[threadId];
    if (msgs != null) {
      bool changed = false;
      for (var i = 0; i < msgs.length; i++) {
        final m = msgs[i];
        if (m.isMe && m.status != MessageStatus.seen) {
          msgs[i] = m.copyWith(status: MessageStatus.seen);
          changed = true;
        }
      }
      if (changed) {
        // fallthrough to notify
      }
    }
    notifyListeners();
  }

  ChatMessage sendText({
    required String threadId,
    required String text,
    String? replyToMessageId,
  }) {
    final clean = text.trim();
    if (clean.isEmpty) {
      throw ArgumentError.value(text, 'text', 'Must not be empty');
    }

    final id = _newMessageId();
    final now = DateTime.now();
    final msg = ChatMessage(
      id: id,
      threadId: threadId,
      text: clean,
      isMe: true,
      createdAt: now,
      status: MessageStatus.sent,
      replyToMessageId: replyToMessageId,
    );

    final list = _messagesByThreadId.putIfAbsent(threadId, () => []);
    list.add(msg);
    _touchThread(threadId, now);
    notifyListeners();

    // Simulate delivery a moment later.
    Timer(const Duration(milliseconds: 800), () {
      _updateStatus(threadId, id, MessageStatus.delivered);
    });

    return msg;
  }

  ChatMessage sendImage({
    required String threadId,
    required String imageUrl,
    String? caption,
    String? replyToMessageId,
  }) {
    final id = _newMessageId();
    final now = DateTime.now();
    final msg = ChatMessage(
      id: id,
      threadId: threadId,
      text: caption ?? '',
      isMe: true,
      createdAt: now,
      status: MessageStatus.sent,
      replyToMessageId: replyToMessageId,
      imageUrl: imageUrl,
    );

    final list = _messagesByThreadId.putIfAbsent(threadId, () => []);
    list.add(msg);
    _touchThread(threadId, now);
    notifyListeners();

    // Simulate delivery a moment later.
    Timer(const Duration(milliseconds: 800), () {
      _updateStatus(threadId, id, MessageStatus.delivered);
    });

    return msg;
  }

  void receiveMockIncoming({
    required String threadId,
    required String text,
  }) {
    final id = _newMessageId();
    final now = DateTime.now();
    final msg = ChatMessage(
      id: id,
      threadId: threadId,
      text: text.trim(),
      isMe: false,
      createdAt: now,
      status: MessageStatus.seen,
    );
    final list = _messagesByThreadId.putIfAbsent(threadId, () => []);
    list.add(msg);

    final thread = _threadsById[threadId];
    if (thread != null) {
      _threadsById[threadId] = thread.copyWith(
        updatedAt: now,
        unreadCount: thread.unreadCount + 1,
      );
    }
    notifyListeners();
  }

  void deleteMessage(String threadId, String messageId) {
    final list = _messagesByThreadId[threadId];
    if (list == null) return;
    list.removeWhere((m) => m.id == messageId);
    notifyListeners();
  }

  void forwardMessage({
    required String fromThreadId,
    required String messageId,
    required String toThreadId,
  }) {
    final original = messageById(fromThreadId, messageId);
    if (original == null) return;
    sendText(threadId: toThreadId, text: original.text);
  }

  void seedDemoIfEmpty() {
    if (_threadsById.isNotEmpty) return;
    // These contact IDs match the mock contacts in ContactsProvider.
    final t1 = ensureThreadForContact('c_alice');
    final t2 = ensureThreadForContact('c_bob');
    final t3 = ensureThreadForContact('c_charlie');

    receiveMockIncoming(threadId: t1.id, text: 'Hey!');
    sendText(threadId: t1.id, text: 'Hello, how are you?');
    receiveMockIncoming(
      threadId: t1.id,
      text: "I'm good, thanks for asking. What about you?",
    );

    receiveMockIncoming(threadId: t2.id, text: 'Are you free today?');
    sendText(threadId: t2.id, text: 'Yes, after 6.');
    receiveMockIncoming(threadId: t3.id, text: 'Gym later?');
  }

  void _touchThread(String threadId, DateTime now) {
    final existing = _threadsById[threadId];
    if (existing == null) return;
    _threadsById[threadId] = existing.copyWith(updatedAt: now);
  }

  void _updateStatus(String threadId, String messageId, MessageStatus status) {
    final list = _messagesByThreadId[threadId];
    if (list == null) return;
    for (var i = 0; i < list.length; i++) {
      final m = list[i];
      if (m.id == messageId && m.isMe) {
        if (m.status == MessageStatus.seen) return;
        if (status.index <= m.status.index) return;
        list[i] = m.copyWith(status: status);
        notifyListeners();
        return;
      }
    }
  }

  String _newMessageId() {
    final rand = Random();
    return 'm_${DateTime.now().microsecondsSinceEpoch}_${rand.nextInt(1 << 20)}';
  }
}

