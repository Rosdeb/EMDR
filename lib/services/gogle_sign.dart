import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  static bool isInitialized = false;

  static Future<void> _initSignIn() async {
    if (!isInitialized) {
      // Required to get idToken and serverAuthCode (client_type: 3 from google-services.json)
      await _googleSignIn.initialize(
        serverClientId: "920630961042-m8fuhq1u4gb7q4pks19t413m790a52jv.apps.googleusercontent.com",
      );
      isInitialized = true;
    }
  }

  // Returns a Map with user data and tokens if needed
  static Future<User?> signInWithGoogle() async {
    try {
      await _initSignIn();
      
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate(
        scopeHint: ['email', 'profile'],
      );

      if (googleUser == null) {
        // The user canceled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      // Get access token using authorization client
      final authorizationClient = googleUser.authorizationClient;
      GoogleSignInClientAuthorization? authorization =
          await authorizationClient.authorizationForScopes(['email', 'profile']);
          
      String? accessToken = authorization?.accessToken;

      // If access token is null, try to prompt for it
      if (accessToken == null) {
        authorization = await authorizationClient.authorizeScopes(['email', 'profile']);
        accessToken = authorization.accessToken;
      }

      // Create a new credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );

      // Once signed in, return the UserCredential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Update user data in Firestore
        final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
        final docSnapshot = await userDoc.get();

        if (!docSnapshot.exists) {
          await userDoc.set({
            'uid': user.uid,
            'name': user.displayName ?? '',
            'email': user.email ?? '',
            'photoURL': user.photoURL ?? '',
            'provider': 'google',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }

      return user;
    } catch (e) {
      // Re-throw so the controller can catch it
      rethrow;
    }
  }

  static Future<void> signOut() async {
    try {
      if (isInitialized) {
        await _googleSignIn.signOut();
      }
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  static User? getCurrentUser() {
    return _auth.currentUser;
  }
}