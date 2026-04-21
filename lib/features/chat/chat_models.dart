import 'package:flutter/foundation.dart';

enum MessageStatus { sent, delivered, seen }

@immutable
class ChatMessage {
  final String id;
  final String threadId;
  final String text;
  final bool isMe;
  final DateTime createdAt;
  final MessageStatus status;
  final String? replyToMessageId;
  final String? imageUrl;

  const ChatMessage({
    required this.id,
    required this.threadId,
    required this.text,
    required this.isMe,
    required this.createdAt,
    required this.status,
    this.replyToMessageId,
    this.imageUrl,
  });

  ChatMessage copyWith({
    String? id,
    String? threadId,
    String? text,
    bool? isMe,
    DateTime? createdAt,
    MessageStatus? status,
    String? replyToMessageId,
    String? imageUrl,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      threadId: threadId ?? this.threadId,
      text: text ?? this.text,
      isMe: isMe ?? this.isMe,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

@immutable
class ChatThread {
  final String id;
  final String contactId;
  final DateTime updatedAt;
  final int unreadCount;

  const ChatThread({
    required this.id,
    required this.contactId,
    required this.updatedAt,
    required this.unreadCount,
  });

  ChatThread copyWith({
    DateTime? updatedAt,
    int? unreadCount,
  }) {
    return ChatThread(
      id: id,
      contactId: contactId,
      updatedAt: updatedAt ?? this.updatedAt,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

