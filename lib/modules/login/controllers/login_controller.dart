import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../../controllers/api_controller.dart';
import '../views/phone_screen.dart';

class LoginController extends GetxController {
  final isLoading = false.obs;

  final ApiController _apiController = ApiController();


  Future<void> signInWithGoogle1() async {
    isLoading.value = true;
    final GoogleSignIn _googleSignIn = GoogleSignIn();
    try {
      // Google account tanlash
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('Google account tanlandi');
        return; // User bekor qildi
      }
      //print cleint id ni konsolda chop etish
      print('Client ID: ${_googleSignIn.clientId}');
      print('Client ID: ${_googleSignIn.currentUser}');
      print('Client ID: ${_googleSignIn.forceAccountName}');
      print('Client ID: ${_googleSignIn.serverClientId}');

      // Google auth ma'lumotlarini olish
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      print('User email address: ${googleUser.email}');
      print('User name: ${googleUser.displayName}');
      await _apiController.sendGoogleIdToken(googleAuth.idToken!, 'WEB');
    } catch (e) {
      print('Google Sign-In error: $e');
    }
  }

  Future<void> signInWithGoogle() async {
    isLoading.value = true;
    final GoogleSignIn _googleSignInIos = GoogleSignIn(
      scopes: ['email', 'profile'],
      clientId: '331143083816-kir3q80qqfi63k3ons61ak2sat8n8pdj.apps.googleusercontent.com', // iOS Client ID
      serverClientId: '331143083816-kir3q80qqfi63k3ons61ak2sat8n8pdj.apps.googleusercontent.com', // Android Client ID
    );
    //final GoogleSignIn _googleSignInIos = GoogleSignIn();
    try {
      // Google account tanlash
      final GoogleSignInAccount? googleUser = await _googleSignInIos.signIn();
      if (googleUser == null) {
        print('Google account tanlandi');

        return; // User bekor qildi
      }
      //print cleint id ni konsolda chop etish
      print('Client ID: ${_googleSignInIos.clientId}');
      print('Client ID: ${_googleSignInIos.currentUser}');
      print('Client ID: ${_googleSignInIos.forceAccountName}');
      print('Client ID: ${_googleSignInIos.serverClientId}');

      // Google auth ma'lumotlarini olish
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      print('User email address: ${googleUser.email}');
      print('User name: ${googleUser.displayName}');
      await _apiController.sendGoogleIdToken(googleAuth.idToken!, 'IOS');

    } catch (e) {
      isLoading.value = false;
      print('Google Sign-In error: $e');
    }
  }

  Future<void> signInWithTelegram() async {
    Get.to(PhoneScreen());
    //Get.to(RegisterScreen());
  }

  Future<void> signInWithApple() async {
    isLoading.value = true;
    try {
      final credential = await SignInWithApple.getAppleIDCredential(scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName]);
      // Apple'dan kelgan ma'lumotlarni logda ko'rish
      print("Apple User ID: ${credential.userIdentifier}");
      print("Apple Email: ${credential.email}");
      print("Apple Full Name: ${credential.givenName} ${credential.familyName}");
      // Backendga yuborish (idToken orqali)
      if (credential.identityToken != null) {
        await _apiController.sendAppleIdToken(credential.identityToken!, 'IOS');
      } else {
        print("Apple Sign-In: identityToken null qaytdi!");
      }
    } catch (e) {
      print("Apple Sign-In error: $e");
    } finally {
      isLoading.value = false;
    }
  }

}