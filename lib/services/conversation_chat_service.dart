import 'package:cloud_firestore/cloud_firestore.dart';

import '../config/app_constants.dart';

class ConversationChatService {
  final FirebaseFirestore _db;

  ConversationChatService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _conversations =>
      _db.collection(AppConstants.conversationsCollection);

  Future<String> ensureCustomerConversation({
    required String customerId,
    required String customerName,
    required String customerEmail,
  }) async {
    final ref = _conversations.doc(customerId);

    final payload = <String, dynamic>{
      'customerId': customerId,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'status': 'open',
      'assignedAdminId': null,
      'lastMessage': '',
      'lastSenderRole': '',
      'lastSenderName': '',
      'lastMessageAt': FieldValue.serverTimestamp(),
      'adminUnreadCount': 0,
      'customerUnreadCount': 0,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await ref.set(payload, SetOptions(merge: true));
    return ref.id;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchConversationMessages(
    String conversationId,
  ) {
    return _conversations
        .doc(conversationId)
        .collection(AppConstants.messagesCollection)
        .orderBy('createdAt')
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchAdminConversations() {
    return _conversations.orderBy('lastMessageAt', descending: true).snapshots();
  }

  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderRole,
    required String senderName,
    required String text,
  }) async {
    final normalizedText = text.trim();
    if (normalizedText.isEmpty) return;

    final convoRef = _conversations.doc(conversationId);
    final msgRef = convoRef.collection(AppConstants.messagesCollection).doc();

    await _db.runTransaction((tx) async {
      final convoSnap = await tx.get(convoRef);
      if (!convoSnap.exists) {
        tx.set(convoRef, {
          'customerId': conversationId,
          'customerName': senderRole == AppConstants.customerRole ? senderName : '',
          'customerEmail': '',
          'status': 'open',
          'assignedAdminId': null,
          'adminUnreadCount': 0,
          'customerUnreadCount': 0,
          'lastMessage': '',
          'lastSenderRole': '',
          'lastSenderName': '',
          'lastMessageAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      tx.set(msgRef, {
        'senderId': senderId,
        'senderRole': senderRole,
        'senderName': senderName,
        'text': normalizedText,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      final updates = <String, dynamic>{
        'lastMessage': normalizedText,
        'lastSenderRole': senderRole,
        'lastSenderName': senderName,
        'lastMessageAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (senderRole == AppConstants.customerRole) {
        updates['adminUnreadCount'] = FieldValue.increment(1);
      } else {
        updates['customerUnreadCount'] = FieldValue.increment(1);
      }

      tx.set(convoRef, updates, SetOptions(merge: true));
    });
  }

  Future<void> sendAdminManualReplyToCustomer({
    required String customerId,
    required String adminId,
    required String adminName,
    required String text,
  }) async {
    final normalizedText = text.trim();
    if (normalizedText.isEmpty) return;

    await sendMessage(
      conversationId: customerId,
      senderId: adminId,
      senderRole: AppConstants.adminRole,
      senderName: adminName,
      text: normalizedText,
    );

    // Backward compatibility: mirror admin replies into the legacy chat
    // collection so customers still on old chat flow can see the message.
    await _db.collection(AppConstants.chatCollection).add({
      'userId': customerId,
      'sender': 'bot',
      'userName': adminName,
      'text': normalizedText,
      'type': 'admin_reply',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> markConversationRead(
    String conversationId, {
    required bool forAdmin,
  }) async {
    final updates = <String, dynamic>{
      forAdmin ? 'adminUnreadCount' : 'customerUnreadCount': 0,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await _conversations.doc(conversationId).set(updates, SetOptions(merge: true));
  }

  Future<void> clearConversationMessages(String conversationId) async {
    final messagesRef =
        _conversations.doc(conversationId).collection(AppConstants.messagesCollection);

    while (true) {
      final snap = await messagesRef.limit(400).get();
      if (snap.docs.isEmpty) break;

      final batch = _db.batch();
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }

    await _conversations.doc(conversationId).set({
      'lastMessage': '',
      'lastSenderRole': '',
      'lastSenderName': '',
      'lastMessageAt': FieldValue.serverTimestamp(),
      'adminUnreadCount': 0,
      'customerUnreadCount': 0,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
