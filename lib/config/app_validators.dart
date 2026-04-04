class AppValidators {
  static String? requiredField(String? value, {String label = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required.';
    }
    return null;
  }

  static String? email(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Email address is required.';
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(trimmed)) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  static String? password(String? value) {
    final text = value ?? '';
    if (text.isEmpty) return 'Password is required.';
    if (text.length < 8) {
      return 'Password must be at least 8 characters.';
    }
    if (!RegExp(r'[A-Za-z]').hasMatch(text) || !RegExp(r'\d').hasMatch(text)) {
      return 'Password must include letters and numbers.';
    }
    return null;
  }

  static String? name(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Name is required.';
    if (trimmed.length < 2) return 'Enter at least 2 characters.';
    if (!RegExp(r"^[a-zA-Z0-9\s\-\.']+$").hasMatch(trimmed)) {
      return 'Name contains invalid characters.';
    }
    return null;
  }

  static String? productName(String? value) =>
      requiredField(value, label: 'Product name');

  static String? category(String? value) =>
      requiredField(value, label: 'Category');

  static String? description(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Description is required.';
    if (trimmed.length < 10) {
      return 'Description must be at least 10 characters.';
    }
    return null;
  }

  static String? review(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return null;
    if (trimmed.length < 5) return 'Review should be at least 5 characters.';
    return null;
  }

  static String? price(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Price is required.';
    final parsed = double.tryParse(trimmed);
    if (parsed == null || parsed < 0) {
      return 'Enter a valid non-negative price.';
    }
    return null;
  }

  static String? url(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'URL is required.';
    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.isAbsolute || (uri.scheme != 'https')) {
      return 'Enter a valid HTTPS URL.';
    }
    return null;
  }

  static String? comment(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Comment cannot be empty.';
    if (trimmed.length < 2) return 'Comment is too short.';
    return null;
  }
}
