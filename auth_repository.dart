import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:platform/platform.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:stepauth/core/constants/app_constants.dart';
import 'package:stepauth/domain/entities/user_profile.dart';

class AuthException implements Exception {
  const AuthException(this.message, {this.code});
  final String message;
  final String? code;
  @override
  String toString() => 'AuthException($code): $message';
}

class AuthRepository {
  AuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
    LocalPlatform? platform,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _platform = platform ?? const LocalPlatform();
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;
  final LocalPlatform _platform;
  (user) {
  
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  User? get currentUser => _auth.currentUser;
  
  String? get userId => _auth.currentUser?.uid;
  
  Future<User> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthException('Google Sign-In was cancelled.', code: 'cancelled');
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user!;
      
      await _upsertUserProfile(user, provider: 'google');
      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_friendlyFirebaseMessage(e.code), code: e.code);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Google Sign-In failed: $e');
    }
  }
  
  Future<User> signInWithApple() async {
    if (!_platform.isIOS && !_platform.isMacOS && !kIsWeb) {
      throw const AuthException(
        'Apple Sign-In is only available on iOS and macOS.',
        code: 'platform-not-supported',
      );
    }
    try {
     
      final rawNonce = _generateNonce();
      final nonce = _sha256OfString(rawNonce);
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );
      final userCredential = await _auth.signInWithCredential(oauthCredential);
      final user = userCredential.user!;
      
      if (appleCredential.givenName != null) {
        final name =
            '${appleCredential.givenName} ${appleCredential.familyName ?? ''}'
                .trim();
        await user.updateDisplayName(name);
      }
      await _upsertUserProfile(user, provider: 'apple');
      return user;
    } on SignInWithAppleAuthorizationException catch (e) {
      throw AuthException('Apple Sign-In failed: ${e.message}', code: e.code.name);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_friendlyFirebaseMessage(e.code), code: e.code);
    }
  }
  
  Future<User> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential.user!;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_friendlyFirebaseMessage(e.code), code: e.code);
    }
  }
  
  Future<User> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user!;
      
      await user.updateDisplayName(displayName);
      await user.reload();
      await _upsertUserProfile(
        _auth.currentUser!,
        provider: 'email',
        displayName: displayName,
      );
      return _auth.currentUser!;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_friendlyFirebaseMessage(e.code), code: e.code);
    }
  }
  
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(_friendlyFirebaseMessage(e.code), code: e.code);
    }
  }

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }
  
  Stream<UserProfile?> watchUserProfile(String uid) {
    return _firestore
        .collection(AppConstants.kUsersCollection)
        .doc(uid)
        .withConverter<UserProfile>(
          fromFirestore: (snap, _) => UserProfile.fromFirestore(snap),
          toFirestore: (profile, _) => profile.toFirestore(),
        )
        .snapshots()
        .map((snap) => snap.data());
  }
  
  Future<UserProfile?> getUserProfile(String uid) async {
    final doc = await _firestore
        .collection(AppConstants.kUsersCollection)
        .doc(uid)
        .get();
    if (!doc.exists) return null;
    return UserProfile.fromFirestore(doc);
  }
 
  Future<void> updateProfile({
    required String uid,
    String? displayName,
    String? avatarUrl,
    int? dailyStepGoal,
  }) async {
    final updates = <String, dynamic>{
      'lastActiveAt': FieldValue.serverTimestamp(),
    };
    if (displayName != null) updates['displayName'] = displayName;
    if (avatarUrl != null) updates['avatarUrl'] = avatarUrl;
    if (dailyStepGoal != null) updates['dailyStepGoal'] = dailyStepGoal;
    await _firestore
        .collection(AppConstants.kUsersCollection)
        .doc(uid)
        .update(updates);
    
    if (displayName != null && _auth.currentUser != null) {
      await _auth.currentUser!.updateDisplayName(displayName);
    }
  }
  
  Future<void> markProfileComplete(String uid) async {
    await _firestore
        .collection(AppConstants.kUsersCollection)
        .doc(uid)
        .update({'isProfileComplete': true});
  }
  
  Future<void> _upsertUserProfile(
    User user, {
    required String provider,
    String? displayName,
  }) async {
    final ref = _firestore
        .collection(AppConstants.kUsersCollection)
        .doc(user.uid);
    final existingDoc = await ref.get();
    if (!existingDoc.exists) {
      
      final profile = UserProfile(
        uid: user.uid,
        email: user.email ?? '',
        displayName: displayName ?? user.displayName ?? 'StepSync User',
        avatarUrl: user.photoURL,
        isProfileComplete: false,
        createdAt: DateTime.now(),
        lastActiveAt: DateTime.now(),
      );
      await ref.set(profile.toFirestore());
    } else {
      
      await ref.update({'lastActiveAt': FieldValue.serverTimestamp()});
    }
  }
 
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }
  
  String _sha256OfString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
 
  String _friendlyFirebaseMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait and try again.';
      case 'user-disabled':
        return 'This account has been disabled.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
