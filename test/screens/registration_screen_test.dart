import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pinky_shop/models/user_profile.dart';
import 'package:pinky_shop/screens/registration_screen.dart';
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
  testWidgets('shows invalid email error on registration form',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthService>.value(
        value: _FakeAuthService(),
        child: const MaterialApp(home: RegistrationScreen()),
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'Test User');
    await tester.enterText(find.byType(TextFormField).at(1), 'invalid-email');
    await tester.enterText(find.byType(TextFormField).at(2), 'password123');

    final policyCheckbox = find.byType(CheckboxListTile);
    await tester.ensureVisible(policyCheckbox);
    await tester.tap(policyCheckbox);
    await tester.pumpAndSettle();

    final createAccountButton =
      find.widgetWithText(ElevatedButton, 'Create Account');
    await tester.ensureVisible(createAccountButton);
    await tester.tap(createAccountButton);
    await tester.pump();

    expect(find.text('Enter a valid email address.'), findsOneWidget);
  });
}
