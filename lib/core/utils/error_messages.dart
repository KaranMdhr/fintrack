import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

String authErrorMessage(Object error) {
  if (error is FirebaseAuthException) {
    return switch (error.code) {
      'invalid-email' => 'That email address looks invalid.',
      'user-disabled' => 'This account has been disabled.',
      'user-not-found' => 'No account exists for that email.',
      'wrong-password' ||
      'invalid-credential' => 'Incorrect email or password.',
      'email-already-in-use' => 'An account already exists for that email.',
      'weak-password' => 'Choose a stronger password (at least 6 characters).',
      'operation-not-allowed' => 'This sign-in method is not enabled.',
      'too-many-requests' => 'Too many attempts. Please try again later.',
      'network-request-failed' =>
        'Check your internet connection and try again.',
      'account-exists-with-different-credential' =>
        'This email is already linked to another sign-in method.',
      'missing-google-id-token' => 'Google sign-in failed. Please try again.',
      _ => 'Something went wrong. Please try again.',
    };
  }

  if (error is GoogleSignInException) {
    return switch (error.code) {
      GoogleSignInExceptionCode.canceled => 'Google sign-in was canceled.',
      GoogleSignInExceptionCode.interrupted =>
        'Google sign-in was interrupted. Please try again.',
      GoogleSignInExceptionCode.clientConfigurationError ||
      GoogleSignInExceptionCode.providerConfigurationError =>
        'Google sign-in is not configured correctly for this build.',
      GoogleSignInExceptionCode.uiUnavailable =>
        'Google sign-in is unavailable right now.',
      GoogleSignInExceptionCode.userMismatch =>
        'Please sign out of the other Google account and try again.',
      _ => 'Google sign-in failed. Please try again.',
    };
  }

  if (error is UnsupportedError) {
    return 'Google sign-in is not supported on this device.';
  }

  return 'Something went wrong. Please try again.';
}

String firestoreErrorMessage(Object error) {
  if (error is FirebaseException) {
    return switch (error.code) {
      'permission-denied' => 'You do not have permission to do that.',
      'unavailable' || 'deadline-exceeded' =>
        'The server is unreachable. Check your connection.',
      'not-found' => 'That item no longer exists.',
      _ => 'Something went wrong. Please try again.',
    };
  }

  return 'Something went wrong. Please try again.';
}
