import 'package:firebase_auth/firebase_auth.dart';
import 'package:stepauth/data/repositories/auth_repository.dart';

class SignInWithEmail {
  const SignInWithEmail(this._repository);
  final AuthRepository _repository;
  Future<User> call({required String email, required String password}) =>
      _repository.signInWithEmail(email: email, password: password);
}
