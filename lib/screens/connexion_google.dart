import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'accueil.dart';

class EcranConnexion extends StatefulWidget {
  const EcranConnexion({Key? key}) : super(key: key);
  @override
  _EcranConnexionState createState() => _EcranConnexionState();
}
class _EcranConnexionState extends State<EcranConnexion> {
  bool _loading = false;
  Future<void> _handleSignIn() async {
    setState(() => _loading = true);
    final account = await AuthService.signIn();
    setState(() => _loading = false);
    if (account != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Accueil()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Échec de la connexion avec Google")),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: _loading
            ? const CircularProgressIndicator(color: Colors.green)
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', height: 100),
            const SizedBox(height: 40),
            const Text(
              "Connectez-vous pour continuer",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
              ),
              icon: const Icon(Icons.login, color: Colors.white),
              label: const Text(
                "Se connecter avec Google",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: _handleSignIn,
            ),
          ],
        ),
      ),
    );
  }
}