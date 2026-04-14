import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../config/app_config.dart';
import '../config/app_constants.dart';
import '../models/user_profile.dart';
import 'google_sign_in_service.dart';
import 'password_hasher.dart';
import 'secure_storage_service.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? _user;
  UserProfile? _profile;
  bool _loading = true;
  bool _processing = false;
  String? _errorMessage;

  User? get user => _user;
  UserProfile? get profile => _profile;
  bool get loading => _loading;
  bool get processing => _processing;
  String? get errorMessage => _errorMessage;
  bool get isAdmin => _profile?.isAdmin ?? false;
  bool get isLoggedIn => _user != null;

  AuthService() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _user = user;

    if (user != null) {
      await _loadProfile(user.uid);
      try {
        await _persistAuthToken();
      } catch (e) {
        debugPrint('Auth token persistence warning: $e');
      }
    } else {
      _profile = null;
      try {
        await SecureStorageService.clearAuthToken();
      } catch (e) {
        debugPrint('Auth token clear warning: $e');
      }
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> _loadProfile(String uid) async {
    try {
      final doc =
          await _db.collection(AppConstants.usersCollection).doc(uid).get();
      if (doc.exists) {
        _profile = UserProfile.fromMap(uid, doc.data()!);
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }
  }

  Future<void> _persistAuthToken() async {
    final token = await _auth.currentUser?.getIdToken();
    if (token != null && token.isNotEmpty) {
      await SecureStorageService.saveAuthToken(token);
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    final normalizedEmail = email.trim().toLowerCase();

    _setProcessing(true);
    _errorMessage = null;
    notifyListeners();
    try {
      await _auth.signInWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );
    } catch (e) {
      _errorMessage = _friendlyError(e);
      notifyListeners();
      rethrow;
    } finally {
      _setProcessing(false);
    }
  }

  Future<void> signInWithIdentifier(String identifier, String password) async {
    final normalized = identifier.trim();
    if (normalized.isEmpty) {
      throw Exception('Email or username is required.');
    }

    if (normalized.contains('@')) {
      return signInWithEmail(normalized, password);
    }

    final email = await _resolveEmailFromUsername(normalized);
    return signInWithEmail(email, password);
  }

  Future<void> sendPasswordReset(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty) {
      throw Exception('Email address is required.');
    }

    _setProcessing(true);
    _errorMessage = null;
    notifyListeners();

    try {
      await _auth.sendPasswordResetEmail(email: normalizedEmail);
    } catch (e) {
      _errorMessage = _friendlyError(e);
      notifyListeners();
      rethrow;
    } finally {
      _setProcessing(false);
    }
  }

  Future<void> registerWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedName = name.trim();

    _setProcessing(true);
    _errorMessage = null;
    notifyListeners();

    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );

      final uid = cred.user!.uid;
      final profileData = {
        'name': normalizedName,
        'email': normalizedEmail,
        'role': AppConstants.customerRole,
      };

      await _db
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .set(profileData);

      // Do not block app registration/login if external backend is unavailable.
      try {
        final hashedPassword = PasswordHasher.hashPassword(password);
        await _registerWithBackend(
          email: normalizedEmail,
          name: normalizedName,
          hashedPassword: hashedPassword,
        );
      } catch (backendError) {
        debugPrint('Backend registration warning: $backendError');
      }

      _profile = UserProfile.fromMap(uid, profileData);
      notifyListeners();
    } catch (e) {
      _errorMessage = _friendlyError(e);
      notifyListeners();
      rethrow;
    } finally {
      _setProcessing(false);
    }
  }

  Future<void> signUpWithEmail(
      String email, String password, String name) async {
    return registerWithEmail(email: email, password: password, name: name);
  }

  Future<String> _resolveEmailFromUsername(String username) async {
    final snapshot = await _db
        .collection(AppConstants.usersCollection)
        .where('name', isEqualTo: username)
        .limit(2)
        .get();

    if (snapshot.docs.isEmpty) {
      throw Exception('No account found for that username. Use email instead.');
    }

    final first = snapshot.docs.first.data();
    final email = (first['email'] as String?)?.trim();

    if (email == null || email.isEmpty) {
      throw Exception('Account email is missing. Please log in with your email.');
    }

    return email;
  }

  Future<void> signInWithGoogle() async {
    _setProcessing(true);
    _errorMessage = null;
    notifyListeners();

    try {
      UserCredential cred;

      if (kIsWeb) {
        final googleProvider = GoogleAuthProvider();
        cred = await _auth.signInWithPopup(googleProvider);
      } else {
        final googleSignIn = await GoogleSignInService.instance.client;
        final googleUser = await googleSignIn.authenticate();

        final googleAuth = googleUser.authentication;
        final authz = await googleUser.authorizationClient
            .authorizationForScopes(<String>['email', 'profile']);
        final credential = GoogleAuthProvider.credential(
          accessToken: authz?.accessToken,
          idToken: googleAuth.idToken,
        );
        cred = await _auth.signInWithCredential(credential);
      }

      final uid = cred.user!.uid;
      final doc =
          await _db.collection(AppConstants.usersCollection).doc(uid).get();

      if (!doc.exists) {
        final profileData = {
          'name': cred.user!.displayName ?? '',
          'email': cred.user!.email ?? '',
          'role': AppConstants.customerRole,
        };

        await _db
            .collection(AppConstants.usersCollection)
            .doc(uid)
            .set(profileData);
      }
    } catch (e) {
      _errorMessage = _friendlyError(e);
      notifyListeners();
      rethrow;
    } finally {
      _setProcessing(false);
    }
  }

  Uri _httpsUri(String path) {
    final uri = Uri.parse(path);
    if (uri.scheme == 'https') {
      return uri;
    }
    return uri.replace(scheme: 'https');
  }

  Future<void> _registerWithBackend({
    required String email,
    required String name,
    required String hashedPassword,
  }) async {
    final endpoint = Config.authRegisterEndpoint;
    if (endpoint.isEmpty) {
      return;
    }

    final uri = _httpsUri('${Config.apiBaseUrl}/$endpoint');
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'passwordHash': hashedPassword,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Registration failed: ${response.statusCode} ${response.body}',
      );
    }
  }

  Future<void> _clearUserChat(String uid) async {
    final snapshot = await _db
        .collection(AppConstants.chatCollection)
        .where('userId', isEqualTo: uid)
        .get();

    if (snapshot.docs.isEmpty) return;

    final batch = _db.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<void> signOut() async {
    final uid = _auth.currentUser?.uid;

    if (uid != null) {
      try {
        await _clearUserChat(uid);
      } catch (e) {
        debugPrint('Error clearing user chat on logout: $e');
      }
    }

    await _auth.signOut();
    await SecureStorageService.clearAuthToken();

    try {
      final googleSignIn = await GoogleSignInService.instance.client;
      await googleSignIn.signOut();
    } catch (_) {}
  }

  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found.');
    }

    _setProcessing(true);
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await SecureStorageService.readAuthToken() ??
          await user.getIdToken(true);

      final endpoint = Config.deleteAccountEndpoint;
      final deleteUri = _httpsUri('${Config.apiBaseUrl}/$endpoint');

      final response = await http.delete(
        deleteUri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'userId': user.uid,
          'email': user.email,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
          'Delete account failed: ${response.statusCode} ${response.body}',
        );
      }

      await _clearUserChat(user.uid);
      await _db.collection(AppConstants.usersCollection).doc(user.uid).delete();

      try {
        await user.delete();
      } catch (firebaseError) {
        debugPrint('Firebase Auth user delete failed: $firebaseError');
      }

      await SecureStorageService.clearAuthToken();
      final googleSignIn = await GoogleSignInService.instance.client;
      await googleSignIn.signOut();
      await _auth.signOut();

      _user = null;
      _profile = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = _friendlyError(e);
      notifyListeners();
      rethrow;
    } finally {
      _setProcessing(false);
    }
  }

  Future<void> deleteMyData() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found.');
    }

    _setProcessing(true);
    _errorMessage = null;
    notifyListeners();

    try {
      final ordersSnapshot = await _db
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .collection(AppConstants.ordersCollection)
          .get();

      if (ordersSnapshot.docs.isNotEmpty) {
        final batch = _db.batch();
        for (final doc in ordersSnapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }

      await SecureStorageService.clearAuthToken();
      notifyListeners();
    } catch (e) {
      _errorMessage = _friendlyError(e);
      notifyListeners();
      rethrow;
    } finally {
      _setProcessing(false);
    }
  }

  void _setProcessing(bool value) {
    if (_processing == value) return;
    _processing = value;
    notifyListeners();
  }

  String _friendlyError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-credential':
        case 'wrong-password':
        case 'invalid-login-credentials':
          return 'Incorrect email or password.';
        case 'user-not-found':
          return 'No account found with this email.';
        case 'email-already-in-use':
          return 'This email is already registered.';
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'weak-password':
          return 'Password is too weak. Use at least 8 characters.';
        case 'too-many-requests':
          return 'Too many attempts. Please try again in a few minutes.';
        case 'network-request-failed':
          return 'Network error. Check your internet connection and try again.';
        default:
          return error.message ?? 'Authentication failed. Please try again.';
      }
    }

    return error.toString().replaceFirst('Exception: ', '');
  }
}
