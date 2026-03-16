class UserProfile {
  final String id;
  final String name;
  final String email;
  final String role; // 'admin' | 'customer'

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  bool get isAdmin => role == 'admin';

  factory UserProfile.fromMap(String id, Map<String, dynamic> data) {
    return UserProfile(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'customer',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
    };
  }
}

class Comment {
  final String id;
  final String userId;
  final String userName;
  final String text;
  final String createdAt;

  Comment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.text,
    required this.createdAt,
  });

  factory Comment.fromMap(String id, Map<String, dynamic> data) {
    return Comment(
      id: id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      text: data['text'] ?? '',
      createdAt: data['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'text': text,
      'createdAt': createdAt,
    };
  }
}
