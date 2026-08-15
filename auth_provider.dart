import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stepauth/data/repositories/auth_repository.dart';
import 'package:stepauth/domain/entities/user_profile.dart';
import 'package:stepauth/domain/usecases/sign_in_apple.dart';
import 'package:stepauth/domain/usecases/sign_in_email.dart';
import 'package:stepauth/domain/usecases/sign_in_google.dart';
import 'package:stepauth/domain/usecases/sign_out.dart';
import 'package:stepauth/domain/usecases/sign_up_email.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});


final authStateProvider = StreamProvider<User?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.authStateChanges;
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});

final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(currentUserProvider)?.uid;
});

final userProfileStreamProvider = StreamProvider<UserProfile?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value(null);
  return repo.watchUserProfile(uid);
});

final signInWithGoogleProvider = Provider<SignInWithGoogle>((ref) {
  return SignInWithGoogle(ref.watch(authRepositoryProvider));
});
final signInWithAppleProvider = Provider<SignInWithApple>((ref) {
  return SignInWithApple(ref.watch(authRepositoryProvider));
});
final signInWithEmailProvider = Provider<SignInWithEmail>((ref) {
  return SignInWithEmail(ref.watch(authRepositoryProvider));
});
final signUpWithEmailProvider = Provider<SignUpWithEmail>((ref) {
  return SignUpWithEmail(ref.watch(authRepositoryProvider));
});
final signOutProvider = Provider<SignOut>((ref) {
  return SignOut(ref.watch(authRepositoryProvider));
});

class AuthNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}
  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(signInWithGoogleProvider).call(),
    );
  }
  Future<void> signInWithApple() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(signInWithAppleProvider).call(),
    );
  }
  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(signInWithEmailProvider).call(
            email: email,
            password: password,
          ),
    );
  }
  Future<void> signUpWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(signUpWithEmailProvider).call(
            email: email,
            password: password,
            displayName: displayName,
          ),
    );
  }
  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(signOutProvider).call(),
    );
  }
}

final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, void>(AuthNotifier.new);
