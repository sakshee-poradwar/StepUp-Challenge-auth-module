import 'package:firebase_auth/firebase_auth.dart';
import 'package:stepauth/data/repositories/auth_repository.dart';

class SignUpWithEmail {
  const SignUpWithEmail(this._repository);
  final AuthRepository _repository;
  Future<User> call({
    required String email,
    required String password,
    required String displayName,
  }) =>
      _repository.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
}
