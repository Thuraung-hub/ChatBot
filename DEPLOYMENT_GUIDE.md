# 🚀 Deployment Guide - Pinky Shop

## Environment Configuration

Your app now supports **3 deployment environments** with automatic API URL switching:

### 1. **Development** (Local Testing)
```
API URL: http://192.168.1.100:3000/api
API Key: dev-api-key-12345
Purpose: Local testing, debug builds
```

### 2. **Staging** (Pre-Production Testing)
```
API URL: https://staging-api.pinkshop.com/api
API Key: staging-api-key-67890
Purpose: Test before production deployment
```

### 3. **Production** (Live)
```
API URL: https://api.pinkshop.com/api
API Key: prod-api-key-secret
Purpose: Real users
```

---

## Building for Different Environments

### Option 1: Using Bash Script (Recommended)

```bash
# Make script executable
chmod +x build.sh

# Build for development
./build.sh dev

# Build for staging
./build.sh staging

# Build for production
./build.sh prod
```

### Option 2: Manual Commands

**Development (Debug)**
```bash
flutter build apk --debug \
  --dart-define=ENVIRONMENT=development
```

**Staging (Release)**
```bash
flutter build apk --release \
  --dart-define=ENVIRONMENT=staging
```

**Production (Release)**
```bash
flutter build apk --release \
  --dart-define=ENVIRONMENT=production
```

**iOS**
```bash
flutter build ios --release \
  --dart-define=ENVIRONMENT=production
```

---

## Changing API URLs at Runtime

### In Code

Edit `lib/config/app_config.dart`:

```dart
case Environment.production:
  return 'https://your-production-api.com/api';
```

### Via Environment Variable

Update `lib/main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Auto-detect environment or set manually
  final env = Environment.values.firstWhere(
    (e) => e.toString() == 'Environment.production',
    orElse: () => Environment.development,
  );
  
  Config.setEnvironment(env);
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const PinkyShopApp());
}
```

---

## Deployment Checklist

### Before Production Deployment

- [ ] Update API URLs in `lib/config/app_config.dart`
- [ ] Update API keys with production credentials
- [ ] Verify all services point to production API
- [ ] Test order creation and payments
- [ ] Test user authentication
- [ ] Check error handling and logging
- [ ] Run `flutter analyze` for code quality
- [ ] Test on real devices
- [ ] Update app version in `pubspec.yaml`
- [ ] Sign APK with release key
- [ ] Test Firebase configuration for production

### After Deployment

- [ ] Monitor API logs for errors
- [ ] Check user feedback for issues
- [ ] Monitor Firebase Crashlytics
- [ ] Be ready to rollback if needed

---

## Quick Reference: Common API URLs

**Local Development**
```
http://localhost:3000/api
http://192.168.1.x:3000/api (Replace x with your IP)
```

**Staging**
```
https://staging-api.myapp.com/api
https://api-staging.myapp.com/api
```

**Production**
```
https://api.myapp.com/api
https://api.pinkshop.com/api
```

---

## Troubleshooting

### App connects to wrong API endpoint

Check `lib/config/app_config.dart` - verify the `setEnvironment()` call in `main.dart`

### API 404 errors after deployment

- Verify the deployment API URL is correct
- Check API server is running and accessible
- Verify API keys are valid
- Check CORS settings if needed

### Authentication fails in production

- Ensure Firebase project is updated with production services
- Verify `google-services.json` is updated for production
- Check OAuth credentials in Firebase console

---

## Environment-Specific Features

### Development Only
- Debug logging enabled ✅
- All debug logs printed
- Long request timeouts (30s)

### Production Only
- Minimal logging
- Shorter request timeouts
- Error tracking (Sentry/Crashlytics)
- Rate limiting awareness

To add environment-specific code:

```dart
if (Config.isDevelopment) {
  debugPrint('Debug info: $data');
}

if (Config.isProduction) {
  // Production-only code
}
```

---

## Setting Up Your Backend

Make sure your backend API endpoints match these patterns:

```
GET    /api/products              → List all products
GET    /api/products/:id          → Get single product
POST   /api/orders                → Create order
GET    /api/orders?userId=xxx     → Get user orders
POST   /api/cart/add              → Add to cart
GET    /api/users/:userId         → Get user profile
```

See `lib/services/` for all available endpoints.

---

## Questions?

If the API URLs don't match your backend:

1. Update URLs in `lib/config/app_config.dart`
2. Update API keys in the same file
3. Test with `flutter run` locally first
4. Then build release APK/AAB for deployment
