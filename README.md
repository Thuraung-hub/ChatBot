# Pinky Shop — Flutter

A Flutter conversion of the original React/Firebase Pinky Shop e-commerce app.

---

## Live Deployment

- Web app: https://chatbot-flutter-7b34f.web.app

---

## Project Structure

```
lib/
├── main.dart                        # App entry, routing, auth guards
├── app_theme.dart                   # Colors, ThemeData
├── firebase_options.dart            # ⚠️  Replace with FlutterFire generated file
│
├── models/
│   ├── product.dart
│   ├── cart_item.dart
│   └── user_profile.dart            # UserProfile + Comment
│
├── providers/
│   └── auth_provider.dart           # Firebase Auth + Firestore profile
│
├── screens/
│   ├── login_screen.dart
│   ├── signup_screen.dart
│   ├── home_screen.dart
│   ├── product_detail_screen.dart
│   ├── cart_screen.dart
│   ├── profile_screen.dart
│   ├── chat_screen.dart
│   └── admin_dashboard.dart
│
└── widgets/
    └── product_card.dart
```

---

## Setup Instructions

### 1. Prerequisites

- Flutter SDK 3.0+ installed
- Dart SDK 3.0+
- Firebase project (same one used by the React app, or a new one)

### 2. Install dependencies

```bash
cd pinky_shop_flutter
flutter pub get
```

### 3. Configure Firebase

#### Option A — Reuse existing Firebase project (recommended)
Your Firestore data (products, users, cart) will carry over automatically.

#### Option B — New Firebase project
Create one at https://console.firebase.google.com

#### Generate firebase_options.dart

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Run from inside the flutter project directory
flutterfire configure
```

This generates a correct `lib/firebase_options.dart`. It replaces the placeholder file.

### 4. Enable Firebase services

In your Firebase Console:
- **Authentication** → Enable Email/Password and Google providers
- **Firestore** → Create database (start in test mode or copy rules from `firestore.rules`)
- **Google Sign-In** → Add SHA-1 fingerprint for Android

### 5. Android — Add google-services.json

Download `google-services.json` from Firebase Console and place it at:
```
android/app/google-services.json
```

### 6. iOS — Add GoogleService-Info.plist

Download `GoogleService-Info.plist` and place it at:
```
ios/Runner/GoogleService-Info.plist
```

Also add your `REVERSED_CLIENT_ID` to `ios/Runner/Info.plist` for Google Sign-In.

### 7. Run the app

```bash
flutter run
```

---

## Features

| Feature | React Original | Flutter |
|---|---|---|
| Email login/signup | ✅ | ✅ |
| Google Sign-In | ✅ | ✅ |
| Product listing (grouped by category) | ✅ | ✅ |
| Real-time Firestore streams | ✅ | ✅ |
| Add to cart | ✅ | ✅ |
| Cart management (qty, delete) | ✅ | ✅ |
| Order summary | ✅ | ✅ |
| Product detail + hero image | ✅ | ✅ |
| Product comments | ✅ | ✅ |
| Admin — add product | ✅ | ✅ |
| Admin — edit product | ✅ | ✅ |
| Admin — delete product | ✅ | ✅ |
| Community chat | ✅ | ✅ |
| Profile screen | ✅ | ✅ |
| Route guards (auth, admin) | ✅ | ✅ |
| Seed data on empty store | ✅ | ✅ |

---

## Firestore Rules

Copy the `firestore.rules` from the original React project — the data structure is identical.

---

## Dependencies

| Package | Purpose |
|---|---|
| `firebase_core` | Firebase initialization |
| `firebase_auth` | Authentication |
| `cloud_firestore` | Database |
| `google_sign_in` | Google OAuth |
| `provider` | State management |
| `cached_network_image` | Efficient image loading |
| `shimmer` | Loading skeletons |
