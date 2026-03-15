import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'db_service.dart';
class AuthService {
  static final DBService _dbService = DBService();
  /// Initialize GoogleSignIn with your Web client ID
  static Future<void> init() async {
    await GoogleSignIn.instance.initialize(
      serverClientId: "305099822950-h3v7k3a5kc8r995g42029p1jdbpftpc2.apps.googleusercontent.com",
    );
  }
  static Future<GoogleSignInAccount?> signIn() async {
    try {
      final compte = await GoogleSignIn.instance.authenticate();
      if (compte != null) {
        final userData = {
          "id": compte.id,
          "name": compte.displayName,
          "email": compte.email,
          "photoUrl": compte.photoUrl,
        };
        await _dbService.enregistrerCompte(userData);
      }
      return compte;
    } catch (e) {
      debugPrint("Erreur de connexion avec Google: $e");
      return null;
    }
  }
  static Future<Map<String, dynamic>?> getCompteCourant() async {
    final compteLocal = await _dbService.getCompte();
    if (compteLocal != null) return compteLocal;
    try {
      final result = GoogleSignIn.instance.attemptLightweightAuthentication();
      final GoogleSignInAccount? compte =
      result is Future<GoogleSignInAccount?>
          ? await result
          : result as GoogleSignInAccount?;
      if (compte != null) {
        final userData = {
          "id": compte.id,
          "name": compte.displayName,
          "email": compte.email,
          "photoUrl": compte.photoUrl,
        };
        await _dbService.enregistrerCompte(userData);
        return userData;
      }
    } catch (e) {
      debugPrint("Silent sign-in failed: $e");
    }
    return null;
  }
  static Future<void> signOut() async {
    await GoogleSignIn.instance.signOut();
    await _dbService.supprimerCompte();
  }
}