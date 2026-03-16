import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../providers/auth_provider.dart' as app;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _sendWelcomeMessageIfNeeded();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendWelcomeMessageIfNeeded() async {
    final auth = context.read<app.AuthProvider>();
    final uid = auth.user?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance.collection('chat').add({
      'userId': uid,
      'sender': 'bot',
      'userName': 'Shop Bot',
      'text': "Hey there! 👋 I'm your personal style & tech assistant and you can ask about with the products name,category and delivery information  .",
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  bool _containsWord(String text, String word) {
    final regex = RegExp('\\b${RegExp.escape(word)}\\b', caseSensitive: false);
    return regex.hasMatch(text);
  }

  /// BOT REPLY FUNCTION
  Future<void> _botReply(String message, String uid) async {
    final query = message.toLowerCase();

    if (_containsWord(query, 'hi') || _containsWord(query, 'hello')) {
      await FirebaseFirestore.instance.collection('chat').add({
        'userId': uid,
        'sender': 'bot',
        'userName': 'Shop Bot',
        'text':
            'Hey! Great style starts with the right tech. What are you looking for today? 🛍️',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return;
    }

    if (_containsWord(query, 'help') || _containsWord(query, 'assist')) {
      await FirebaseFirestore.instance.collection('chat').add({
        'userId': uid,
        'sender': 'bot',
        'userName': 'Shop Bot',
        'text':
            "I'm here to help! Whether you want the latest product information or some stylish apparel, just ask. What's on your mind? 😊",
        'createdAt': FieldValue.serverTimestamp(),
      });
      return;
    }

    if (_containsWord(query, 'thank') ||
      _containsWord(query, 'thanks') ||
      _containsWord(query, 'thank you')) {
      await FirebaseFirestore.instance.collection('chat').add({
        'userId': uid,
        'sender': 'bot',
        'userName': 'Shop Bot',
        'text':
            "You're welcome! If you have any more questions or need recommendations, just let me know. Happy shopping! 🛍️",
        'createdAt': FieldValue.serverTimestamp(),
      });
      return;
    }

    final snapshot =
        await FirebaseFirestore.instance.collection('products').get();

    String reply = "Sorry, I couldn't find any product.";
    final isReviewQuery = _containsWord(query, 'review') ||
      _containsWord(query, 'reviews') ||
      _containsWord(query, 'rating');

    final docs = snapshot.docs;

    // If user asks by product name, return only that single product.
    final matchedProduct = docs.where((doc) {
      final data = doc.data();
      final name = (data['name'] ?? '').toString().toLowerCase().trim();
      return name.isNotEmpty && query.contains(name);
    }).toList();

    if (matchedProduct.isNotEmpty) {
      final data = matchedProduct.first.data();
      if (isReviewQuery) {
        final review = (data['review'] ?? '').toString().trim();
        if (review.isNotEmpty) {
          reply = "Review for ${data['name']}:\n\n$review";
        } else {
          reply = "No review available yet for ${data['name']}.";
        }
      } else {
        reply =
            "${data['name']}\n\n${data['description']}\nPrice: \$${data['price']}";
      }
    } else {
      // If user asks by category, list all items under that category one-by-one.
      final matchedCategory = docs.map((doc) {
        final data = doc.data();
        return (data['category'] ?? '').toString().trim();
      }).firstWhere(
        (cat) => cat.isNotEmpty && query.contains(cat.toLowerCase()),
        orElse: () => '',
      );

      if (matchedCategory.isNotEmpty) {
        final categoryProducts = docs.where((doc) {
          final data = doc.data();
          return (data['category'] ?? '').toString().toLowerCase() ==
              matchedCategory.toLowerCase();
        }).toList();

        final buffer = StringBuffer('Products in $matchedCategory:\n\n');
        for (final productDoc in categoryProducts) {
          final p = productDoc.data();
          buffer.writeln('${p['name']}');
          buffer.writeln('${p['description']}');
          buffer.writeln('Price: \$${p['price']}');
          buffer.writeln('');
        }

        reply = buffer.toString().trimRight();
      }
    }

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
    if (_controller.text.trim().isEmpty) return;

    final auth = context.read<app.AuthProvider>();
    if (auth.user == null || auth.profile == null) return;

    setState(() => _sending = true);

    final text = _controller.text.trim();
    _controller.clear();

    /// SAVE USER MESSAGE
    await FirebaseFirestore.instance.collection('chat').add({
      'userId': auth.user!.uid,
      'sender': 'user',
      'userName': auth.profile!.name,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });

    /// BOT REPLY
    await _botReply(text, auth.user!.uid);

    setState(() => _sending = false);

    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 200,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<app.AuthProvider>();
    final myUid = auth.user?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Assistant'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          /// CHAT MESSAGES
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chat')
                  .where('userId', isEqualTo: myUid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.primary));
                }

                final docs = [...snapshot.data!.docs]
                  ..sort((a, b) {
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
                      style: TextStyle(color: AppTheme.textGray),
                    ),
                  );
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

          /// MESSAGE INPUT
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppTheme.borderGray)),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Ask about products...',
                        prefixIcon: Icon(
                          Icons.chat_bubble_outline_rounded,
                          color: AppTheme.textGray,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe ? AppTheme.primary : AppTheme.bgGray,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMe ? 18 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 18),
                ),
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: isMe ? Colors.white : AppTheme.dark,
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