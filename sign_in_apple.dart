import 'package:firebase_auth/firebase_auth.dart';
import 'package:stepauth/data/repositories/auth_repository.dart';

class SignInWithApple {
  const SignInWithApple(this._repository);
  final AuthRepository _repository;
  Future<User> call() => _repository.signInWithApple();
}
