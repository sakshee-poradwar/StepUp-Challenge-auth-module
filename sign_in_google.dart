import 'package:firebase_auth/firebase_auth.dart';
import 'package:stepauth/data/repositories/auth_repository.dart';

class SignInWithGoogle {
  const SignInWithGoogle(this._repository);
  final AuthRepository _repository;
  Future<User> call() => _repository.signInWithGoogle();
}
