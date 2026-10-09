import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../domain/repository/google_auth_service.dart';

/// [GoogleAuthService] implementation using the `google_sign_in` plugin to
/// perform a native sign-in and then exchange the Google credential with
/// Firebase via `signInWithCredential`.
class FirebaseGoogleAuthService implements GoogleAuthService {
  FirebaseGoogleAuthService([FirebaseAuth? auth, GoogleSignIn? googleSignIn])
    : _auth = auth ?? FirebaseAuth.instance,
      _google = googleSignIn ?? GoogleSignIn();

  final FirebaseAuth _auth;
  final GoogleSignIn _google;

  @override
  Future<String> signInAndGetIdToken() async {
    try {
      final googleUser = await _google.signIn();
      if (googleUser == null) {
        throw const GoogleSignInFailure('Sign-in cancelled', cancelled: true);
      }
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;
      if (idToken == null) {
        throw const GoogleSignInFailure('Could not obtain Google id token');
      }

      final credential = GoogleAuthProvider.credential(
        idToken: idToken,
        accessToken: accessToken,
      );

      final userCred = await _auth.signInWithCredential(credential);
      final token = await userCred.user?.getIdToken(true);
      if (token == null) {
        throw const GoogleSignInFailure('Could not obtain a Firebase token');
      }
      return token;
    } on FirebaseAuthException catch (e) {
      final cancelled =
          e.code == 'canceled' || e.code == 'web-context-canceled';
      throw GoogleSignInFailure(e.message ?? e.code, cancelled: cancelled);
    } catch (e) {
      // Map google_sign_in cancellations / errors
      if (e is GoogleSignInAccount) {
        throw const GoogleSignInFailure('Sign-in cancelled', cancelled: true);
      }
      rethrow;
    }
  }

  @override
  Future<String?> currentIdToken() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return user.getIdToken(true);
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } finally {
      await _google.signOut();
    }
  }
}
