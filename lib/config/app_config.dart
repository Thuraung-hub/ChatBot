import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration for API base URLs
enum Environment {
  development,
  staging,
  production,
}

class Config {
  static Environment _environment = Environment.development;

  static Environment environmentFromString(
    String? rawValue, {
    Environment fallback = Environment.development,
  }) {
    final normalized = rawValue?.trim().toLowerCase();
    switch (normalized) {
      case 'dev':
      case 'development':
        return Environment.development;
      case 'stage':
      case 'staging':
        return Environment.staging;
      case 'prod':
      case 'production':
        return Environment.production;
      default:
        return fallback;
    }
  }

  static String _requireEnv(String key) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      throw StateError('Missing required environment variable: $key');
    }
    return value;
  }

  /// Set the environment
  static void setEnvironment(Environment env) {
    _environment = env;
  }

  /// Get the base API URL based on current environment
  static String get apiBaseUrl {
    final override = dotenv.env['API_BASE_URL'];
    if (override != null && override.isNotEmpty) {
      return override;
    }

    switch (_environment) {
      case Environment.development:
        return dotenv.env['API_BASE_URL_DEVELOPMENT'] ??
            'https://localhost:3000/api';
      case Environment.staging:
        return dotenv.env['API_BASE_URL_STAGING'] ??
            'https://staging-api.pinkshop.com/api';
      case Environment.production:
        // Firebase Hosting deployment - point to your backend API
        return dotenv.env['API_BASE_URL_PRODUCTION'] ??
            'https://api.pinkshop.com/api';
    }
  }

  /// Get the API key based on current environment
  static String get apiKey {
    final override = dotenv.env['API_KEY'];
    if (override != null && override.isNotEmpty) {
      return override;
    }

    switch (_environment) {
      case Environment.development:
        return _requireEnv('API_KEY_DEVELOPMENT');
      case Environment.staging:
        return _requireEnv('API_KEY_STAGING');
      case Environment.production:
        return _requireEnv('API_KEY_PRODUCTION');
    }
  }

  static String get authRegisterEndpoint =>
      dotenv.env['AUTH_REGISTER_ENDPOINT'] ?? 'auth/register';

  static String get deleteAccountEndpoint =>
      dotenv.env['DELETE_ACCOUNT_ENDPOINT'] ?? 'users/me';

  /// Gemini API key used by AI service calls.
  static String get geminiApiKey => _requireEnv('GEMINI_API_KEY');

  static String? get sentryDsn {
    final dsn = dotenv.env['SENTRY_DSN'];
    if (dsn == null || dsn.isEmpty) return null;
    return dsn;
  }

  static bool get enableFirebasePerformance {
    final value = dotenv.env['ENABLE_FIREBASE_PERFORMANCE'];
    return (value ?? 'true').toLowerCase() == 'true';
  }

  /// Firebase Hosting URL (for reference)
  static const String firebaseHostingUrl =
      'https://pinky-shop-f5ad6.web.app';

  /// Check if in development mode
  static bool get isDevelopment => _environment == Environment.development;

  /// Check if in production mode
  static bool get isProduction => _environment == Environment.production;

  /// Get current environment name
  static String get environmentName => _environment.toString().split('.').last;
}
