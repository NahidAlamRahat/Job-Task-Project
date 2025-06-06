import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class UserController {

  static var userData = FirebaseAuth.instance.currentUser;


  static Future<dynamic> loginWithGoogle(
      {required BuildContext context}) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser
          ?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      debugPrint('token => ${googleAuth?.accessToken}');

      var userCredential = await FirebaseAuth.instance.signInWithCredential(
          credential);

      // Save user
      UserController.userData = userCredential.user;

      debugPrint('Email => ${UserController.userData?.email}');
      debugPrint('Login success');

      if (UserController.userData != null) {
        debugPrint('User email: ${UserController.userData?.email}');
        debugPrint('User name: ${UserController.userData?.displayName}');
        debugPrint('Photo URL: ${UserController.userData?.photoURL}');
      } else {
        debugPrint('User is null!');
      }

      Navigator.pushNamedAndRemoveUntil(
          context, HomeScreen.name, (route) => false);
    } catch (e) {
      debugPrint('Google Sign-In error: $e');
    }
    return null;
  }


  static Future<void> signOut({required BuildContext context}) async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    userData = null;

    Navigator.pushNamedAndRemoveUntil(
      context, SignInScreen.name, (route) => true,);
  }


}
