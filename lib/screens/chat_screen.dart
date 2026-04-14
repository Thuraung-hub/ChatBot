import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../config/app_constants.dart';
import '../app_theme.dart';
import '../providers/chat_provider.dart';
import '../services/auth_service.dart';
import '../services/gemini_client.dart';
import '../services/monitoring_service.dart';
import '../widgets/chat_input_bar.dart';

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
  bool _showTypingIndicator = false;
  int _lastMessageCount = 0;

  static const List<ChatQuickReply> _quickReplies = [
    ChatQuickReply(
      label: 'Track Order',
      message: 'Track my order delivery status',
    ),
    ChatQuickReply(
      label: 'Return Policy',
      message: 'What is the return policy?',
    ),
  ];

  static const String _returnPolicyMessage =
      'Our return policy is designed to ensure customer satisfaction while maintaining fairness. '
      'Customers are allowed to return products within 7 to 14 days after purchase, depending on the item. '
      'To be eligible for a return, the product must be unused, in its original condition, and include all packaging and receipts.\n\n'
      'If the product is damaged, defective, or incorrect, customers can request a full refund or exchange. '
      'However, if the return is due to a change of mind, the item must still meet all return conditions.\n\n'
      'Refunds will be processed within 3 to 7 business days, and the amount will be returned using the original payment method.\n\n'
      'Please note that some items, such as personal care products or discounted items, may not be eligible for return.\n\n'
      'Our goal is to provide a smooth and trustworthy shopping experience for all customers.\n'
      'Thank you for your attention.';

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

    try {
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
            "Hey there! 👋 I'm your personal style & tech assistant and you can ask about with the products Description,review,category and delivery information  .",
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (error, stackTrace) {
      await MonitoringService.captureException(
        error,
        stackTrace: stackTrace,
        hint: 'chat_welcome_message',
      );
    }
  }

  Future<void> _showClearChatDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF10182A),
        title: const Text(
          'Clear Chat History?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This will permanently delete all your chat messages. This action cannot be undone.',
          style: TextStyle(color: Color(0xFF9AA4B2)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF9AA4B2)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Clear',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final auth = context.read<AuthService>();
      final uid = auth.user?.uid ?? '';

      if (uid.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Unable to clear chat right now. Please re-login.'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.redAccent.shade700,
          ),
        );
        return;
      }

      try {
        await _chatProvider.clearChatHistory(uid);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Chat history cleared'),
              duration: Duration(seconds: 2),
              backgroundColor: Color(0xFF10182A),
            ),
          );
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to clear chat history'),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.redAccent.shade700,
            ),
          );
        }
      }
    }
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

  Map<String, dynamic> _safeMap(dynamic data) {
    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }

  String? _buildQuickLocalReply(String message, String userName) {
    final query = message.toLowerCase();

    if ((query.contains('return') && query.contains('policy')) ||
        _containsWord(query, 'refund') ||
        _containsWord(query, 'exchange') ||
        query.contains('change of mind')) {
      return _returnPolicyMessage;
    }

    if (_containsWord(query, 'delivery') ||
        query.contains('how long') ||
        (query.contains('delivery') && _containsWord(query, 'date'))) {
      final now = DateTime.now();
      final startDate = now.add(const Duration(days: 2));
      final endDate = now.add(
        const Duration(days: AppConstants.deliveryLeadDays),
      );
      return 'Hello $userName! You can expect delivery between ${_formatDate(startDate)} and ${_formatDate(endDate)}. We\'ll send you a notification as soon as it out for delivery.';
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

  bool _isReviewQuery(String query) {
    return _containsWord(query, 'review') ||
        _containsWord(query, 'reviews') ||
        _containsWord(query, 'rating') ||
        _containsWord(query, 'spec') ||
        _containsWord(query, 'specification') ||
        _containsWord(query, 'details');
  }

  bool _isProductListQuery(String query) {
    final hasProductWord =
        _containsWord(query, 'product') || _containsWord(query, 'products');
    final hasCatalogWord =
        _containsWord(query, 'catalog') || _containsWord(query, 'inventory');
    final hasListIntent =
        _containsWord(query, 'list') ||
        _containsWord(query, 'show') ||
        _containsWord(query, 'all') ||
        _containsWord(query, 'items');
    return hasCatalogWord || hasProductWord || (hasProductWord && hasListIntent);
  }

  int _extractRequestedPage(String query) {
    final match = RegExp(r'\bpage\s*(\d+)\b', caseSensitive: false).firstMatch(query);
    if (match == null) return 1;
    final parsed = int.tryParse(match.group(1) ?? '1') ?? 1;
    return parsed < 1 ? 1 : parsed;
  }

  String _buildPaginatedProductsReply(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs, {
    required int page,
    int pageSize = 8,
  }) {
    final total = docs.length;
    final totalPages = (total / pageSize).ceil();
    final safePage = page > totalPages ? totalPages : page;
    final start = (safePage - 1) * pageSize;
    final end = (start + pageSize) > total ? total : (start + pageSize);
    final items = docs.sublist(start, end);

    final buffer = StringBuffer(
      'Available products (Page $safePage of $totalPages):\n\n',
    );

    for (final productDoc in items) {
      final product = _safeMap(productDoc.data());
      final name = (product['name'] ?? 'Product').toString();
      final category = (product['category'] ?? 'General').toString();
      final price = (product['price'] ?? '-').toString();
      final description = (product['description'] ?? '').toString().trim();
      final shortDescription = description.length > 80
          ? '${description.substring(0, 80)}...'
          : description;

      buffer.writeln('• $name');
      buffer.writeln('Category: $category');
      buffer.writeln('Price: \$$price');
      if (shortDescription.isNotEmpty) {
        buffer.writeln(shortDescription);
      }
      buffer.writeln('');
    }

    if (safePage < totalPages) {
      buffer.writeln(
        'Type "show products page ${safePage + 1}" to see more items.',
      );
    }

    return buffer.toString().trimRight();
  }

  Future<String?> _buildCatalogReply(String message) async {
    final query = message.toLowerCase().trim();
    if (query.isEmpty) return null;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('products')
          .limit(120)
          .get();

      final docs = snapshot.docs;
      if (docs.isEmpty) return null;

      final isReview = _isReviewQuery(query);
      if (_isProductListQuery(query)) {
        final requestedPage = _extractRequestedPage(query);
        return _buildPaginatedProductsReply(
          docs,
          page: requestedPage,
        );
      }

      final matchedByName = docs.where((doc) {
        final data = _safeMap(doc.data());
        final name = (data['name'] ?? '').toString().toLowerCase().trim();
        return name.isNotEmpty && query.contains(name);
      }).toList();

      if (matchedByName.isNotEmpty) {
        final product = _safeMap(matchedByName.first.data());
        final name = (product['name'] ?? 'Product').toString();
        final description = (product['description'] ?? '').toString().trim();
        final price = (product['price'] ?? '').toString().trim();
        final review = (product['review'] ?? '').toString().trim();

        if (isReview) {
          if (review.isNotEmpty) {
            return 'Review for $name:\n\n$review';
          }
          return 'No review available yet for $name.';
        }

        return '$name\n\n$description\nPrice: \$$price';
      }

      String? matchedCategory;
      for (final doc in docs) {
        final data = _safeMap(doc.data());
        final category = (data['category'] ?? '').toString().trim();
        if (category.isNotEmpty && query.contains(category.toLowerCase())) {
          matchedCategory = category;
          break;
        }
      }

      if (matchedCategory != null) {
        final categoryProducts = docs.where((doc) {
          final data = _safeMap(doc.data());
          final category = (data['category'] ?? '').toString();
          return category.toLowerCase() == matchedCategory!.toLowerCase();
        }).toList();

        if (categoryProducts.isEmpty) return null;

        final buffer = StringBuffer('Products in $matchedCategory:\n\n');
        for (final productDoc in categoryProducts) {
          final p = _safeMap(productDoc.data());
          buffer.writeln((p['name'] ?? '').toString());
          buffer.writeln((p['description'] ?? '').toString());
          buffer.writeln('Price: \$${p['price'] ?? '-'}');
          buffer.writeln('');
        }
        return buffer.toString().trimRight();
      }

      return null;
    } catch (error, stackTrace) {
      await MonitoringService.captureException(
        error,
        stackTrace: stackTrace,
        hint: 'chat_catalog_reply',
      );
      return 'I could not load product information right now. Please try again in a moment.';
    }
  }

  /// BOT REPLY FUNCTION
  Future<void> _botReply(String message, String uid, String userName) async {
    final quickReply = _buildQuickLocalReply(message, userName);
    final catalogReply = quickReply == null ? await _buildCatalogReply(message) : null;
    String reply;

    if (quickReply != null || catalogReply != null) {
      reply = quickReply ?? catalogReply!;
    } else {
      if (mounted) {
        setState(() => _showTypingIndicator = true);
      }
      try {
        reply = await _chatProvider.ask(message);
      } finally {
        if (mounted) {
          setState(() => _showTypingIndicator = false);
        }
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

  Future<void> _sendQuickReply(String message) async {
    _controller.text = message;
    await _sendMessage();
  }

  /// SEND MESSAGE
  Future<void> _sendMessage() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final auth = context.read<AuthService>();
    if (auth.user == null) return;

    final trace = await MonitoringService.startTrace('chat_send_message');
    setState(() => _sending = true);

    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() => _sending = false);
      await MonitoringService.stopTrace(trace);
      return;
    }

    final userName = auth.profile?.name.trim().isNotEmpty == true
        ? auth.profile!.name
        : ((auth.user?.displayName?.trim().isNotEmpty ?? false)
            ? auth.user!.displayName!
            : 'Customer');

    _controller.clear();

    try {
      /// SAVE USER MESSAGE
      await FirebaseFirestore.instance.collection('chat').add({
        'userId': auth.user!.uid,
        'sender': 'user',
        'userName': userName,
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
      });

      /// BOT REPLY
      await _botReply(text, auth.user!.uid, userName);
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
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all_rounded),
            onPressed: _showClearChatDialog,
            tooltip: 'Clear chat history',
          ),
        ],
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
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Unable to load chat right now. Please refresh and try again.',
                      style: TextStyle(color: Color(0xFF9AA4B2)),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  );
                }

                final docs = snapshot.data!.docs;
                docs.sort((a, b) {
                  final aData = _safeMap(a.data());
                  final bData = _safeMap(b.data());
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
                  itemCount: docs.length + (_showTypingIndicator ? 1 : 0),
                  itemBuilder: (context, i) {
                    if (_showTypingIndicator && i == docs.length) {
                      return const _TypingIndicatorBubble();
                    }

                    final data = _safeMap(docs[i].data());
                    final sender = (data['sender'] ?? 'user').toString();
                    final isMe = sender == 'user';

                    return _MessageBubble(
                      userName: (data['userName'] ?? 'User').toString(),
                      text: (data['text'] ?? '').toString(),
                      isMe: isMe,
                    );
                  },
                );
              },
            ),
          ),
          ChatInputBar(
            formKey: _formKey,
            controller: _controller,
            sending: _sending,
            onSend: _sendMessage,
            quickReplies: _quickReplies,
            onQuickReplySelected: _sendQuickReply,
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

class _TypingIndicatorBubble extends StatefulWidget {
  const _TypingIndicatorBubble();

  @override
  State<_TypingIndicatorBubble> createState() => _TypingIndicatorBubbleState();
}

class _TypingIndicatorBubbleState extends State<_TypingIndicatorBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF16233A),
          borderRadius: BorderRadius.circular(18),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                final start = index * 0.18;
                final end = start + 0.6;
                final value = _controller.value;
                final opacity = value < start || value > end
                    ? 0.35
                    : 0.35 + ((value - start) / (end - start)) * 0.65;
                final scale = value < start || value > end
                    ? 0.85
                    : 0.85 + ((value - start) / (end - start)) * 0.25;

                return Padding(
                  padding: EdgeInsets.only(left: index == 0 ? 0 : 6),
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: opacity),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}
