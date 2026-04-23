import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_theme.dart';
import '../config/app_constants.dart';
import '../services/auth_service.dart';
import '../services/conversation_chat_service.dart';
import '../utils/responsive.dart';

class AdminChatInboxScreen extends StatefulWidget {
  const AdminChatInboxScreen({super.key});

  @override
  State<AdminChatInboxScreen> createState() => _AdminChatInboxScreenState();
}

class _AdminChatInboxScreenState extends State<AdminChatInboxScreen> {
  final ConversationChatService _chatService = ConversationChatService();
  final TextEditingController _replyCtrl = TextEditingController();
  final ScrollController _messageScrollCtrl = ScrollController();
  String? _selectedConversationId;
  String _selectedCustomerLabel = 'Customer';
  bool _sending = false;

  @override
  void dispose() {
    _replyCtrl.dispose();
    _messageScrollCtrl.dispose();
    super.dispose();
  }

  void _selectConversation(
    String conversationId, {
    required String customerName,
    required String customerEmail,
  }) {
    final label = customerName.trim().isNotEmpty
        ? customerName.trim()
        : (customerEmail.trim().isNotEmpty ? customerEmail.trim() : 'Customer');

    setState(() {
      _selectedConversationId = conversationId;
      _selectedCustomerLabel = label;
    });
    _chatService.markConversationRead(conversationId, forAdmin: true);
  }

  Future<void> _sendAdminReply(AuthService auth) async {
    final text = _replyCtrl.text.trim();
    final conversationId = _selectedConversationId;
    if (text.isEmpty || conversationId == null) return;

    final senderName = auth.profile?.name.trim().isNotEmpty == true
        ? auth.profile!.name
        : (auth.user?.email ?? 'Admin');

    setState(() => _sending = true);
    _replyCtrl.clear();

    try {
      await _chatService.sendMessage(
        conversationId: conversationId,
        senderId: auth.user?.uid ?? 'admin',
        senderRole: AppConstants.adminRole,
        senderName: senderName,
        text: text,
      );
      await _chatService.markConversationRead(conversationId, forAdmin: true);
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  String _formatTime(Timestamp? ts) {
    if (ts == null) return '--';
    final dt = ts.toDate();
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  Widget _buildConversationList(bool isMobile) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _chatService.watchAdminConversations(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'Failed to load customer chats.',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          );
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          if (_selectedConversationId != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              setState(() {
                _selectedConversationId = null;
                _selectedCustomerLabel = 'Customer';
              });
            });
          }
          return const Center(
            child: Text(
              'No customer chats yet.',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        final hasSelected = docs.any((d) => d.id == _selectedConversationId);
        if (_selectedConversationId == null || !hasSelected) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            final firstData = docs.first.data();
            _selectConversation(
              docs.first.id,
              customerName: (firstData['customerName'] ?? '').toString(),
              customerEmail: (firstData['customerEmail'] ?? '').toString(),
            );
          });
        }

        return ListView.separated(
          itemCount: docs.length,
          separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0x223A4B68)),
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data();
            final isSelected = doc.id == _selectedConversationId;
            final unread = (data['adminUnreadCount'] ?? 0) as int;
            final name = (data['customerName'] ?? 'Customer').toString();
            final email = (data['customerEmail'] ?? '').toString();
            final last = (data['lastMessage'] ?? '').toString();
            final time = _formatTime(data['lastMessageAt'] as Timestamp?);

            return ListTile(
              selected: isSelected,
              selectedTileColor: const Color(0xFF1A2540),
              onTap: () => _selectConversation(
                doc.id,
                customerName: name,
                customerEmail: email,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              title: Text(
                name,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                email.isEmpty ? last : '$email\n$last',
                maxLines: isMobile ? 2 : 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFFB0BED8), height: 1.35),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(time, style: const TextStyle(color: Color(0xFF8EA3C5), fontSize: 11)),
                  const SizedBox(height: 6),
                  if (unread > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        unread.toString(),
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildThread(AuthService auth, bool isMobile) {
    final conversationId = _selectedConversationId;
    if (conversationId == null) {
      return Column(
        children: [
          const Expanded(
            child: Center(
              child: Text(
                'Select a customer chat to start.',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ),
          _buildReplyComposer(auth, enabled: false),
        ],
      );
    }

    return Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _chatService.watchConversationMessages(conversationId),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    'Unable to load messages.',
                    style: TextStyle(color: Colors.white70),
                  ),
                );
              }

              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(color: AppTheme.primary),
                );
              }

              final docs = snapshot.data!.docs;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!_messageScrollCtrl.hasClients) return;
                _messageScrollCtrl.jumpTo(_messageScrollCtrl.position.maxScrollExtent);
              });

              if (docs.isEmpty) {
                return const Center(
                  child: Text(
                    'No messages in this chat yet.',
                    style: TextStyle(color: Colors.white70),
                  ),
                );
              }

              return ListView.builder(
                controller: _messageScrollCtrl,
                padding: const EdgeInsets.all(12),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data();
                  final role = (data['senderRole'] ?? '').toString();
                  final isAdminMessage = role == AppConstants.adminRole;
                  final isBotMessage = role == 'bot';
                  final bubbleColor = isAdminMessage
                      ? AppTheme.primary
                      : isBotMessage
                          ? const Color(0xFF2F4A7A)
                          : const Color(0xFF1A2945);

                  return Align(
                    alignment:
                        isAdminMessage ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * (isMobile ? 0.92 : 0.7),
                      ),
                      decoration: BoxDecoration(
                        color: bubbleColor,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(14),
                          topRight: const Radius.circular(14),
                          bottomLeft: Radius.circular(isAdminMessage ? 14 : 6),
                          bottomRight: Radius.circular(isAdminMessage ? 6 : 14),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (data['senderName'] ?? 'Unknown').toString(),
                            style: TextStyle(
                              color: isAdminMessage ? Colors.black87 : Colors.white70,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            (data['text'] ?? '').toString(),
                            style: TextStyle(
                              color: isAdminMessage ? Colors.black : Colors.white,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        _buildReplyComposer(auth, enabled: true),
      ],
    );
  }

  Widget _buildReplyComposer(AuthService auth, {required bool enabled}) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        decoration: const BoxDecoration(
          color: Color(0xFF10182A),
          border: Border(
            top: BorderSide(color: Color(0xFF233552), width: 1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              enabled
                  ? 'Reply to $_selectedCustomerLabel'
                  : 'Reply to Customer (select a customer first)',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 520;
                if (compact) {
                  return Column(
                    children: [
                      TextFormField(
                        controller: _replyCtrl,
                        minLines: 1,
                        maxLines: 3,
                        enabled: enabled,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Type reply to customer...',
                          hintStyle: const TextStyle(color: Color(0xFF93A2BF)),
                          filled: true,
                          fillColor: const Color(0xFF17233D),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF2E4267)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: AppTheme.primary, width: 1.5),
                          ),
                        ),
                        onFieldSubmitted: (_) {
                          if (enabled) {
                            _sendAdminReply(auth);
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: (!enabled || _sending)
                              ? null
                              : () => _sendAdminReply(auth),
                          icon: _sending
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.send_rounded),
                          label: const Text('Reply'),
                        ),
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _replyCtrl,
                        minLines: 1,
                        maxLines: 3,
                        enabled: enabled,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Type reply to customer...',
                          hintStyle: const TextStyle(color: Color(0xFF93A2BF)),
                          filled: true,
                          fillColor: const Color(0xFF17233D),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF2E4267)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: AppTheme.primary, width: 1.5),
                          ),
                        ),
                        onFieldSubmitted: (_) {
                          if (enabled) {
                            _sendAdminReply(auth);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 120,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: (!enabled || _sending)
                            ? null
                            : () => _sendAdminReply(auth),
                        icon: _sending
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.send_rounded),
                        label: const Text('Reply'),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final isMobile = context.isMobile;
    final showThreadOnly = isMobile && _selectedConversationId != null;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1426),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10182A),
        foregroundColor: Colors.white,
        title: Text(showThreadOnly ? 'Customer Chat' : 'Admin Inbox'),
        leading: showThreadOnly
            ? IconButton(
                onPressed: () => setState(() => _selectedConversationId = null),
                icon: const Icon(Icons.arrow_back_rounded),
              )
            : IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
      ),
      body: isMobile
          ? (showThreadOnly
              ? _buildThread(auth, isMobile)
              : _buildConversationList(isMobile))
          : Row(
              children: [
                SizedBox(
                  width: 360,
                  child: Container(
                    color: const Color(0xFF10182A),
                    child: _buildConversationList(isMobile),
                  ),
                ),
                const VerticalDivider(width: 1, color: Color(0xFF233552)),
                Expanded(child: _buildThread(auth, isMobile)),
              ],
            ),
    );
  }
}
