import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  GoogleSignInService._();

  static final GoogleSignInService instance = GoogleSignInService._();

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _initialized = false;

  Future<GoogleSignIn> get client async {
    if (!_initialized) {
      await _googleSignIn.initialize();
      _initialized = true;
    }
    return _googleSignIn;
  }
}
