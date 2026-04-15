import 'package:cloud_firestore/cloud_firestore.dart';

import '../config/app_constants.dart';
import '../models/manual_reply.dart';

class ManualReplyService {
  final FirebaseFirestore _db;
  List<ManualReply>? _cachedReplies;
  DateTime? _cachedAt;

  static const Duration _cacheTtl = Duration(seconds: 30);

  ManualReplyService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _db.collection(AppConstants.manualRepliesCollection);

  Stream<QuerySnapshot<Map<String, dynamic>>> watchReplies() {
    return _collection.orderBy('timestamp', descending: true).snapshots();
  }

  Future<void> createReply({
    required String keyword,
    required String reply,
    required String createdBy,
  }) async {
    await _collection.add({
      'keyword': keyword.trim(),
      'reply': reply.trim(),
      'createdBy': createdBy.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });
    _invalidateCache();
  }

  Future<void> updateReply(
    String id, {
    required String keyword,
    required String reply,
    required String createdBy,
  }) async {
    await _collection.doc(id).update({
      'keyword': keyword.trim(),
      'reply': reply.trim(),
      'createdBy': createdBy.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });
    _invalidateCache();
  }

  Future<void> deleteReply(String id) async {
    await _collection.doc(id).delete();
    _invalidateCache();
  }

  Future<String?> findMatchingReply(String message) async {
    final normalizedMessage = message.toLowerCase().trim();
    if (normalizedMessage.isEmpty) return null;

    List<ManualReply> replies;
    try {
      replies = await _getReplies();
    } catch (_) {
      // Fail open: if manual reply lookup is unavailable, chatbot should continue with AI reply.
      return null;
    }

    // Match more specific keywords first (e.g., "how are you" before "how").
    replies.sort((a, b) => b.keyword.length.compareTo(a.keyword.length));

    for (final item in replies) {
      final keyword = item.keyword.toLowerCase().trim();
      if (keyword.isEmpty) continue;

      if (normalizedMessage.contains(keyword)) {
        return item.reply;
      }
    }

    return null;
  }

  Future<List<ManualReply>> _getReplies() async {
    final now = DateTime.now();
    if (_cachedReplies != null && _cachedAt != null) {
      if (now.difference(_cachedAt!) < _cacheTtl) {
        return List<ManualReply>.from(_cachedReplies!);
      }
    }

    final snapshot = await _collection.get();
    final replies = snapshot.docs
        .map((doc) => ManualReply.fromMap(doc.id, doc.data()))
        .where((item) => item.keyword.isNotEmpty && item.reply.isNotEmpty)
        .toList();

    _cachedReplies = replies;
    _cachedAt = now;

    return List<ManualReply>.from(replies);
  }

  void _invalidateCache() {
    _cachedReplies = null;
    _cachedAt = null;
  }
}
