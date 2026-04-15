import 'package:cloud_firestore/cloud_firestore.dart';

class ManualReply {
  final String id;
  final String keyword;
  final String reply;
  final String createdBy;
  final DateTime? timestamp;

  const ManualReply({
    required this.id,
    required this.keyword,
    required this.reply,
    required this.createdBy,
    required this.timestamp,
  });

  factory ManualReply.fromMap(String id, Map<String, dynamic> data) {
    final rawTimestamp = data['timestamp'];
    DateTime? parsedTimestamp;

    if (rawTimestamp is Timestamp) {
      parsedTimestamp = rawTimestamp.toDate();
    } else if (rawTimestamp is String) {
      parsedTimestamp = DateTime.tryParse(rawTimestamp);
    }

    return ManualReply(
      id: id,
      keyword: (data['keyword'] ?? '').toString().trim(),
      reply: (data['reply'] ?? '').toString().trim(),
      createdBy: (data['createdBy'] ?? '').toString().trim(),
      timestamp: parsedTimestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'keyword': keyword,
      'reply': reply,
      'createdBy': createdBy,
      'timestamp': timestamp == null ? FieldValue.serverTimestamp() : Timestamp.fromDate(timestamp!),
    };
  }
}
