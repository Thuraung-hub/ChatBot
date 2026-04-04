import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pinky_shop/models/user_profile.dart';
import 'package:pinky_shop/screens/login_screen.dart';
import 'package:pinky_shop/services/auth_service.dart';
import 'package:provider/provider.dart';

class _FakeAuthService extends ChangeNotifier implements AuthService {
  @override
  User? get user => null;

  @override
  UserProfile? get profile => null;

  @override
  bool get loading => false;

  @override
  bool get processing => false;

  @override
  String? get errorMessage => null;

  @override
  bool get isAdmin => false;

  @override
  bool get isLoggedIn => false;

  @override
  void clearError() {}

  @override
  Future<void> deleteAccount() async {}

  @override
  Future<void> deleteMyData() async {}

  @override
  Future<void> registerWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {}

  @override
  Future<void> signInWithEmail(String email, String password) async {}

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<void> signInWithIdentifier(String identifier, String password) async {}

  @override
  Future<void> signOut() async {}

  @override
  Future<void> signUpWithEmail(String email, String password, String name) async {}
}

void main() {
  testWidgets('shows email error when Login is tapped with empty email',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthService>.value(
        value: _FakeAuthService(),
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.pumpAndSettle();

    final loginButtonFinder = find.widgetWithText(ElevatedButton, 'Login');
    expect(loginButtonFinder, findsOneWidget);

    await tester.tap(loginButtonFinder);
    await tester.pump();

    expect(find.text('Email or username is required.'), findsOneWidget);
  });
}
