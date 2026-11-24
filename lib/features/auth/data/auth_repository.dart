import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  AuthRepository(this._auth);

  final FirebaseAuth _auth;
  Future<void>? _googleSignInInit;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> signInWithGoogle() async {
    if (kIsWeb) {
      await _auth.signInWithPopup(GoogleAuthProvider());
      return;
    }

    await (_googleSignInInit ??= GoogleSignIn.instance.initialize());

    if (!GoogleSignIn.instance.supportsAuthenticate()) {
      throw UnsupportedError(
        'Google sign-in UI is not supported on this platform.',
      );
    }

    final GoogleSignInAccount account = await GoogleSignIn.instance
        .authenticate();
    final String? idToken = account.authentication.idToken;

    if (idToken == null) {
      throw FirebaseAuthException(
        code: 'missing-google-id-token',
        message: 'Google did not return an ID token.',
      );
    }

    final OAuthCredential credential = GoogleAuthProvider.credential(
      idToken: idToken,
    );
    await _auth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    final Future<void>? googleInit = _googleSignInInit;
    if (!kIsWeb && googleInit != null) {
      await googleInit;
      await GoogleSignIn.instance.signOut();
    }
    await _auth.signOut();
  }
}
