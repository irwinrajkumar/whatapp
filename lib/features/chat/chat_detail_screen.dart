import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatapp/features/chat/chat_models.dart';
import 'package:whatapp/features/chat/select_contact_screen.dart';
import 'package:whatapp/state/providers.dart';
import 'package:whatapp/features/contacts/contact.dart';
import 'package:whatapp/features/payments/upi_payment_screen.dart';
import 'package:whatapp/utils/image_picker_util.dart';
import 'dart:io';

class ChatDetailScreen extends ConsumerStatefulWidget {
  final String threadId;
  final String contactId;

  const ChatDetailScreen({
    super.key,
    required this.threadId,
    required this.contactId,
  });

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  String? _replyToMessageId;

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    final chat = ref.read(chatsProvider);
    final msg = chat.sendText(
      threadId: widget.threadId,
      text: _messageController.text,
      replyToMessageId: _replyToMessageId,
    );
    // API integration point (currently FakeApiClient behind ChatRepository).
    await ref.read(chatRepositoryProvider).sendMessage(msg);
    setState(() {
      _messageController.clear();
      _replyToMessageId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final chats = ref.watch(chatsProvider);
    final contacts = ref.watch(contactsProvider);
    final contact = contacts.byId(widget.contactId);
    final messages = chats.messagesFor(widget.threadId);
    final replyTo = _replyToMessageId == null
        ? null
        : chats.messageById(widget.threadId, _replyToMessageId!);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      chats.markThreadRead(widget.threadId);
    });

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: (contact?.avatarUrl == null)
                  ? null
                  : CachedNetworkImageProvider(contact!.avatarUrl!),
              child: contact?.avatarUrl == null
                  ? Text(
                      (contact?.displayName ?? '?').isEmpty
                          ? '?'
                          : (contact?.displayName ?? '?')[0].toUpperCase(),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact?.displayName ?? 'Chat',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  "online",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.videocam), onPressed: () {}),
          IconButton(icon: const Icon(Icons.call), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showChatMenu(context);
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const NetworkImage(
              'https://user-images.githubusercontent.com/15075759/28719144-86dc0f70-73b1-11e7-911d-60d70fcded21.png',
            ),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withAlpha(128)
                  : Colors.white,
              BlendMode.dstATop,
            ),
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return _buildMessageBubble(context, message, messages);
                },
              ),
            ),
            _buildInputArea(contact: contact, replyToText: replyTo?.text),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(
    BuildContext context,
    ChatMessage message,
    List<ChatMessage> allMessages,
  ) {
    final isMe = message.isMe;
    final replyTo = message.replyToMessageId == null
        ? null
        : allMessages
              .where((m) => m.id == message.replyToMessageId)
              .cast<ChatMessage?>()
              .firstOrNull;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: () => _showMessageActions(context, message),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          decoration: BoxDecoration(
            color: isMe
                ? (Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF005C4B)
                      : const Color(0xFFE7FFDB))
                : (Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF1F2C33)
                      : Colors.white),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
              bottomRight: isMe ? Radius.zero : const Radius.circular(12),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 4, right: 70),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (replyTo != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          replyTo.text,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                    if (message.imageUrl != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(message.imageUrl!),
                          width: 250,
                          height: 250,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 250,
                              height: 250,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image_not_supported),
                            );
                          },
                        ),
                      ),
                      if (message.text.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          message.text,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ] else ...[
                      Text(message.text, style: const TextStyle(fontSize: 16)),
                    ],
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(message.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(
                          context,
                        ).textTheme.bodySmall?.color?.withAlpha(153),
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      Icon(
                        _statusIcon(message.status),
                        size: 16,
                        color: message.status == MessageStatus.seen
                            ? Colors.blue
                            : Theme.of(context).hintColor,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea({
    required Contact? contact,
    required String? replyToText,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_replyToMessageId != null && replyToText != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF1F2C33)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Replying',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF25D366),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          replyToText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _replyToMessageId = null),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF1F2C33)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.emoji_emotions_outlined,
                          color: Colors.grey,
                        ),
                        onPressed: () {},
                      ),
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: const InputDecoration(
                            hintText: "Message",
                            border: InputBorder.none,
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.attach_file, color: Colors.grey),
                        onPressed: () {
                          _showAttachmentMenu(
                            context,
                            contact?.displayName ?? 'User',
                            contact?.phoneNumber,
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.grey),
                        onPressed: () => _pickAndSendImage(isCamera: true),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF00A884),
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: _sendMessage,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAttachmentMenu(
    BuildContext context,
    String contactName,
    String? contactPhone,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            shrinkWrap: true,
            children: [
              _buildAttachmentItem(
                Icons.insert_drive_file,
                'Document',
                Colors.indigo,
                onTap: () {},
              ),
              _buildAttachmentItem(
                Icons.camera_alt,
                'Camera',
                Colors.pink,
                onTap: () {
                  Navigator.pop(context);
                  _pickAndSendImage(isCamera: true);
                },
              ),
              _buildAttachmentItem(
                Icons.image,
                'Gallery',
                Colors.purple,
                onTap: () {
                  Navigator.pop(context);
                  _pickAndSendImage(isCamera: false);
                },
              ),
              _buildAttachmentItem(
                Icons.headset,
                'Audio',
                Colors.orange,
                onTap: () {},
              ),
              _buildAttachmentItem(
                Icons.location_on,
                'Location',
                Colors.green,
                onTap: () {},
              ),
              _buildAttachmentItem(
                Icons.currency_rupee,
                'Payment',
                const Color(0xFF00A884),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UPIPaymentScreen(
                        receiverName: contactName,
                        receiverContact: contactPhone,
                      ),
                    ),
                  );
                },
              ),
              _buildAttachmentItem(
                Icons.person,
                'Contact',
                Colors.blue,
                onTap: () {},
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttachmentItem(
    IconData icon,
    String label,
    Color color, {
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          child: CircleAvatar(
            radius: 28,
            backgroundColor: color,
            child: Icon(icon, color: Colors.white, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  IconData _statusIcon(MessageStatus status) {
    switch (status) {
      case MessageStatus.sent:
        return Icons.check;
      case MessageStatus.delivered:
        return Icons.done_all;
      case MessageStatus.seen:
        return Icons.done_all;
    }
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }

  void _showMessageActions(BuildContext context, ChatMessage message) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.reply),
                title: const Text('Reply'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _replyToMessageId = message.id);
                },
              ),
              ListTile(
                leading: const Icon(Icons.forward),
                title: const Text('Forward'),
                onTap: () async {
                  Navigator.pop(context);
                  await Navigator.push(
                    this.context,
                    MaterialPageRoute(
                      builder: (_) => SelectContactScreen(
                        mode: SelectContactMode.forwardMessage,
                        forwardFromThreadId: widget.threadId,
                        forwardMessageId: message.id,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.pop(context);
                  ref
                      .read(chatsProvider)
                      .deleteMessage(widget.threadId, message.id);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showChatMenu(BuildContext context) {
    final contacts = ref.read(contactsProvider);
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final isFav = contacts.isFavorite(widget.contactId);
        final isBlocked = contacts.isBlocked(widget.contactId);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(isFav ? Icons.star : Icons.star_border),
                title: Text(
                  isFav ? 'Remove from favorites' : 'Add to favorites',
                ),
                onTap: () {
                  Navigator.pop(context);
                  contacts.toggleFavorite(widget.contactId);
                },
              ),
              ListTile(
                leading: Icon(isBlocked ? Icons.lock_open : Icons.block),
                title: Text(isBlocked ? 'Unblock contact' : 'Block contact'),
                onTap: () {
                  Navigator.pop(context);
                  if (isBlocked) {
                    contacts.unblock(widget.contactId);
                  } else {
                    contacts.block(widget.contactId);
                    Navigator.of(this.context).pop();
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.bolt),
                title: const Text('Simulate incoming message'),
                onTap: () {
                  Navigator.pop(context);
                  ref
                      .read(chatsProvider)
                      .receiveMockIncoming(
                        threadId: widget.threadId,
                        text: 'Incoming message',
                      );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickAndSendImage({required bool isCamera}) async {
    final imagePickerUtil = ImagePickerUtil();
    File? imageFile;

    if (isCamera) {
      imageFile = await imagePickerUtil.pickImageFromCamera();
    } else {
      imageFile = await imagePickerUtil.pickImageFromGallery();
    }

    if (imageFile == null) return;

    // For demo purposes, we'll use the local file path as the image URL
    // In a real app, you would upload the image to a server and get a URL
    final imageUrl = imageFile.path;

    // Send the image message
    final chat = ref.read(chatsProvider);
    final msg = chat.sendImage(
      threadId: widget.threadId,
      imageUrl: imageUrl,
      caption: '',
      replyToMessageId: _replyToMessageId,
    );

    // API integration point (currently FakeApiClient behind ChatRepository)
    await ref.read(chatRepositoryProvider).sendMessage(msg);

    if (!mounted) return;

    setState(() {
      _replyToMessageId = null;
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Image sent successfully'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
