import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  GoogleSignInService._();

  static const String _webClientId =
      '152322049825-j0699hb3ng6efutl4jegufkm3fqrec1g.apps.googleusercontent.com';

  static final GoogleSignInService instance = GoogleSignInService._();

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _initialized = false;

  Future<GoogleSignIn> get client async {
    if (!_initialized) {
      await _googleSignIn.initialize(serverClientId: _webClientId);
      _initialized = true;
    }
    return _googleSignIn;
  }
}
