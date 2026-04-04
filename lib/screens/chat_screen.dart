import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../config/app_constants.dart';
import '../config/app_validators.dart';
import '../app_theme.dart';
import '../providers/chat_provider.dart';
import '../services/auth_service.dart';
import '../services/gemini_client.dart';
import '../services/monitoring_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  late final ChatProvider _chatProvider;
  bool _sending = false;
  int _lastMessageCount = 0;

  @override
  void initState() {
    super.initState();
    _chatProvider = ChatProvider(geminiClient: HttpGeminiClient());
    _sendWelcomeMessageIfNeeded();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _chatProvider.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool animated = true}) {
    if (!_scrollController.hasClients) return;

    final target =
        _scrollController.position.maxScrollExtent + AppConstants.chatScrollOffset;

    if (animated) {
      _scrollController.animateTo(
        target,
        duration: const Duration(
            milliseconds: AppConstants.chatScrollAnimationMilliseconds),
        curve: Curves.easeOut,
      );
      return;
    }

    _scrollController.jumpTo(target);
  }

  Future<void> _sendWelcomeMessageIfNeeded() async {
    final auth = context.read<AuthService>();
    final uid = auth.user?.uid;
    if (uid == null) return;

    final existingWelcome = await FirebaseFirestore.instance
        .collection('chat')
        .where('userId', isEqualTo: uid)
        .where('type', isEqualTo: 'welcome')
        .limit(1)
        .get();

    if (existingWelcome.docs.isNotEmpty) {
      return;
    }

    await FirebaseFirestore.instance.collection('chat').add({
      'userId': uid,
      'sender': 'bot',
      'userName': 'Shop Bot',
      'type': 'welcome',
      'text':
          "Hey there! 👋 I'm your personal style & tech assistant and you can ask about with the products name,category and delivery information  .",
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  bool _containsWord(String text, String word) {
    final regex = RegExp('\\b${RegExp.escape(word)}\\b', caseSensitive: false);
    return regex.hasMatch(text);
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  String? _buildQuickLocalReply(String message, String userName) {
    final query = message.toLowerCase();

    if (_containsWord(query, 'delivery') ||
        query.contains('how long') ||
        (query.contains('delivery') && _containsWord(query, 'date'))) {
      final now = DateTime.now();
      final startDate = now.add(const Duration(days: 2));
      final endDate = now.add(
        const Duration(days: AppConstants.deliveryLeadDays),
      );
      return 'Hello $userName! Your order is currently being processed. You can expect delivery between ${_formatDate(startDate)} and ${_formatDate(endDate)}. We\'ll send you a notification as soon as it out for delivery.';
    }

    if (_containsWord(query, 'hi') || _containsWord(query, 'hello')) {
      return 'Hey! Great style starts with the right tech. What are you looking for today?';
    }

    if (_containsWord(query, 'help') || _containsWord(query, 'assist')) {
      return 'I can help with product info, iPhone models, apparel, and delivery timelines. What would you like to know?';
    }

    if (_containsWord(query, 'thanks') || _containsWord(query, 'thank you')) {
      return 'You\'re welcome! Ask me anytime if you need more help.';
    }

    return null;
  }

  /// BOT REPLY FUNCTION
  Future<void> _botReply(String message, String uid, String userName) async {
    final quickReply = _buildQuickLocalReply(message, userName);
    final reply = quickReply ?? await _chatProvider.ask(message);

    await FirebaseFirestore.instance.collection('chat').add({
      'userId': uid,
      'sender': 'bot',
      'userName': 'Shop Bot',
      'text': reply,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// SEND MESSAGE
  Future<void> _sendMessage() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final auth = context.read<AuthService>();
    if (auth.user == null || auth.profile == null) return;

    final trace = await MonitoringService.startTrace('chat_send_message');
    setState(() => _sending = true);

    final text = _controller.text.trim();
    _controller.clear();

    try {
      /// SAVE USER MESSAGE
      await FirebaseFirestore.instance.collection('chat').add({
        'userId': auth.user!.uid,
        'sender': 'user',
        'userName': auth.profile!.name,
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
      });

      /// BOT REPLY
      await _botReply(text, auth.user!.uid, auth.profile!.name);
    } catch (error, stackTrace) {
      await MonitoringService.captureException(
        error,
        stackTrace: stackTrace,
        hint: 'chat_send_message',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Unable to send message. Please try again.'),
            backgroundColor: AppTheme.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
      await MonitoringService.stopTrace(trace);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final myUid = auth.user?.uid ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFF0B1020),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10182A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Shop Assistant'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chat')
                  .where('userId', isEqualTo: myUid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  );
                }

                final docs = snapshot.data!.docs;
                docs.sort((a, b) {
                  final aData = a.data() as Map<String, dynamic>;
                  final bData = b.data() as Map<String, dynamic>;
                  final aTime = aData['createdAt'] as Timestamp?;
                  final bTime = bData['createdAt'] as Timestamp?;

                  if (aTime == null && bTime == null) return 0;
                  if (aTime == null) return -1;
                  if (bTime == null) return 1;

                  return aTime.compareTo(bTime);
                });

                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'Ask about products or categories!',
                      style: TextStyle(color: Color(0xFF9AA4B2)),
                    ),
                  );
                }

                if (docs.length != _lastMessageCount) {
                  _lastMessageCount = docs.length;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToBottom(animated: true);
                  });
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final data = docs[i].data() as Map<String, dynamic>;
                    final sender = (data['sender'] ?? 'user').toString();
                    final isMe = sender == 'user';

                    return _MessageBubble(
                      userName: data['userName'] ?? 'User',
                      text: data['text'] ?? '',
                      isMe: isMe,
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: const BoxDecoration(
              color: Color(0xFF10182A),
              border: Border(top: BorderSide(color: Color(0xFF1D2A44))),
            ),
            child: SafeArea(
              top: false,
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _controller,
                        validator: AppValidators.comment,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Ask about products...',
                          hintStyle: TextStyle(color: Color(0xFF9AA4B2)),
                          filled: true,
                          fillColor: Color(0xFF16233A),
                          prefixIcon: Icon(
                            Icons.chat_bubble_outline_rounded,
                            color: Color(0xFF9AA4B2),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(14)),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(14)),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(14)),
                            borderSide: BorderSide(
                                color: AppTheme.primaryLight, width: 1.2),
                          ),
                        ),
                        onFieldSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _sending ? null : _sendMessage,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        minimumSize: const Size(0, 0),
                      ),
                      child: _sending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.send_rounded, size: 20),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String userName;
  final String text;
  final bool isMe;

  const _MessageBubble({
    required this.userName,
    required this.text,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 4),
                child: Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textGray,
                  ),
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe ? AppTheme.primary : const Color(0xFF18243A),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMe ? 18 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 18),
                ),
                border: isMe
                    ? null
                    : Border.all(color: const Color(0xFF243550), width: 1),
              ),
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
