import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_profile.dart';

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
    } else {
      _profile = null;
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

  // =============================
  // EMAIL LOGIN
  // =============================

  Future<void> signInWithEmail(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // =============================
  // EMAIL SIGNUP
  // =============================

  Future<void> signUpWithEmail(
      String email,
      String password,
      String name
  ) async {

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

        final GoogleSignInAccount? googleUser =
            await GoogleSignIn().signIn();

        if (googleUser == null) return;

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
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

    await _auth.signOut();

    try {
      await GoogleSignIn().signOut();
    } catch (_) {}

  }

}