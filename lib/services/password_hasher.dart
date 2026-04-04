import 'package:bcrypt/bcrypt.dart';

class PasswordHasher {
  PasswordHasher._();

  static String hashPassword(String password) {
    return BCrypt.hashpw(password, BCrypt.gensalt());
  }
}
