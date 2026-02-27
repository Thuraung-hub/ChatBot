// lib/models/models.dart

// ─── Product ──────────────────────────────────────────────────────────────────
class Product {
  final String id;
  final String name;
  final double price;
  final double rating;
  final int    reviewCount;
  final String imageUrl;
  final String description;
  final String category;
  final List<String> specs;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    required this.description,
    required this.category,
    this.specs = const [],
  });
}

// ─── Review ───────────────────────────────────────────────────────────────────
class Review {
  final String id;
  final String username;
  final double rating;
  final String comment;
  final String date;
  final bool isLocal;

  const Review({
    required this.id,
    required this.username,
    required this.rating,
    required this.comment,
    required this.date,
    this.isLocal = false,
  });
}

// ─── Chat Message ─────────────────────────────────────────────────────────────
class ChatMessage {
  final String id;
  final String text;
  final bool   isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
