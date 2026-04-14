import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../config/app_constants.dart';
import '../models/user_profile.dart';
import '../services/google_sign_in_service.dart';
import '../services/secure_storage_service.dart';

class AuthProvider extends ChangeNotifier {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? _user;
  UserProfile? _profile;
  bool _loading = true;

  User? get user => _user;
  UserProfile? get profile => _profile;
  bool get loading => _loading;
  bool get isAdmin => _profile?.isAdmin ?? false;
  bool get isLoggedIn => _user != null;

  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  // =============================
  // AUTH STATE LISTENER
  // =============================

  Future<void> _onAuthStateChanged(User? user) async {
    _user = user;

    if (user != null) {
      await _loadProfile(user.uid);
      final token = await _auth.currentUser?.getIdToken();
      if (token != null && token.isNotEmpty) {
        await SecureStorageService.saveAuthToken(token);
      }
    } else {
      _profile = null;
      await SecureStorageService.clearAuthToken();
    }

    _loading = false;
    notifyListeners();
  }

  // =============================
  // LOAD USER PROFILE
  // =============================

  Future<void> _loadProfile(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();

      if (doc.exists) {
        _profile = UserProfile.fromMap(uid, doc.data()!);
      }

    } catch (e) {
      debugPrint('Error loading profile: $e');
    }
  }

  // RBAC helper: checks directly from Firestore whether the current user
  // has the strict 'admin' role.
  Future<bool> hasFirestoreAdminRole() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    try {
      final doc = await _db
          .collection(AppConstants.usersCollection)
          .doc(currentUser.uid)
          .get();

      if (!doc.exists) return false;

      final data = doc.data();
      final role = (data?['role'] ?? AppConstants.customerRole).toString();
      return role == AppConstants.adminRole;
    } catch (e) {
      debugPrint('Error checking admin role: $e');
      return false;
    }
  }

  // =============================
  // EMAIL LOGIN
  // =============================

  Future<void> signInWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      debugPrint('Error in signInWithEmail: $e');
      rethrow;
    }
  }

  // =============================
  // EMAIL SIGNUP
  // =============================

  Future<void> signUpWithEmail(
      String email,
      String password,
      String name
  ) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = cred.user!.uid;

      final profileData = {
        'name': name,
        'email': email,
        'role': 'customer',
      };

      await _db.collection('users').doc(uid).set(profileData);

      _profile = UserProfile.fromMap(uid, profileData);
      notifyListeners();
    } catch (e) {
      debugPrint('Error in signUpWithEmail: $e');
      rethrow;
    }
  }

  // =============================
  // GOOGLE LOGIN (WEB + MOBILE)
  // =============================

  Future<void> signInWithGoogle() async {

    try {
      UserCredential cred;

      // ---------- WEB ----------
      if (kIsWeb) {

        GoogleAuthProvider googleProvider = GoogleAuthProvider();

        cred = await _auth.signInWithPopup(googleProvider);

      }

      // ---------- MOBILE ----------
      else {
        final googleSignIn = await GoogleSignInService.instance.client;
        final GoogleSignInAccount googleUser =
          await googleSignIn.authenticate();

        final GoogleSignInAuthentication googleAuth =
          googleUser.authentication;
        final authz = await googleUser.authorizationClient
          .authorizationForScopes(<String>['email', 'profile']);

        final credential = GoogleAuthProvider.credential(
          accessToken: authz?.accessToken,
          idToken: googleAuth.idToken,
        );

        cred = await _auth.signInWithCredential(credential);

      }

      final uid = cred.user!.uid;

      // Create user profile if new
      final doc = await _db.collection('users').doc(uid).get();

      if (!doc.exists) {

        final profileData = {
          'name': cred.user!.displayName ?? '',
          'email': cred.user!.email ?? '',
          'role': 'customer',
        };

        await _db.collection('users').doc(uid).set(profileData);
      }

    } catch (e) {

      throw Exception(e.toString());

    }
  }

  // =============================
  // LOGOUT
  // =============================

  Future<void> _clearUserChat(String uid) async {
    // Delete only this user's chat messages so other users' chats are untouched.
    final snapshot = await _db
        .collection('chat')
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

    try {
      await _auth.signOut();
      await SecureStorageService.clearAuthToken();
    } catch (e) {
      debugPrint('Error in signOut: $e');
      rethrow;
    }

    try {
      final googleSignIn = await GoogleSignInService.instance.client;
      await googleSignIn.signOut();
    } catch (_) {}

  }

}