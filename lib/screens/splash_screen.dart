import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';
import '../services/auth_service.dart';
import 'accueil.dart';
import 'connexion_google.dart';

class MySplashScreen extends StatelessWidget {
  const MySplashScreen({Key? key}) : super(key: key);

  Future<Widget> _navigateAfterSplash() async {
    final user = await AuthService.getCompteCourant();
    if (user != null) {
      return const Accueil();
    } else {
      return const EcranConnexion();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      seconds: 3,
      navigateAfterFuture: _navigateAfterSplash(),
      title: const Text(
        'Gérer vos notes en toute sécurité',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20.0,
          color: Colors.black,
        ),
        textAlign: TextAlign.center,
      ),
      backgroundColor: Colors.white,
      loaderColor: Colors.green,
      image: Image.asset('assets/logo.png'),
      photoSize: 90.0,
      loadingText: const Text(''),
      styleTextUnderTheLoader: new TextStyle(),
      loadingTextPadding: new EdgeInsets.all(0.0),
      useLoader: true,
    );
  }
}