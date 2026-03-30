/// Environment configuration for API base URLs
enum Environment {
  development,
  staging,
  production,
}

class Config {
  static Environment _environment = Environment.development;

  /// Set the environment
  static void setEnvironment(Environment env) {
    _environment = env;
  }

  /// Get the base API URL based on current environment
  static String get apiBaseUrl {
    switch (_environment) {
      case Environment.development:
        return 'http://192.168.1.100:3000/api'; // Local dev server
      case Environment.staging:
        return 'https://staging-api.pinkshop.com/api';
      case Environment.production:
        // Firebase Hosting deployment - point to your backend API
        return 'https://api.pinkshop.com/api'; // Change to your production API
    }
  }

  /// Get the API key based on current environment
  static String get apiKey {
    switch (_environment) {
      case Environment.development:
        return 'dev-api-key-12345';
      case Environment.staging:
        return 'staging-api-key-67890';
      case Environment.production:
        return 'prod-api-key-secret';
    }
  }

  /// Firebase Hosting URL (for reference)
  static const String firebaseHostingUrl = 'https://chatbot-flutter-7b34f.web.app';

  /// Check if in development mode
  static bool get isDevelopment => _environment == Environment.development;

  /// Check if in production mode
  static bool get isProduction => _environment == Environment.production;

  /// Get current environment name
  static String get environmentName => _environment.toString().split('.').last;
}
