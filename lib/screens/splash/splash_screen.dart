import 'package:flutter/material.dart';

// Importation de l'écran de connexion.
// Le fichier login_screen.dart se trouve dans le dossier login.
import '../login/login_screen.dart';

// ----------------------------------------------------------
// ÉCRAN DE DÉMARRAGE DE L'APPLICATION GUINEAGO
// ----------------------------------------------------------

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // ----------------------------------------------------------
  // NAVIGATION VERS L'ÉCRAN DE CONNEXION
  // ----------------------------------------------------------

  /// Attend deux secondes puis ouvre l'écran de connexion.
  Future<void> _allerVersLogin() async {
    // Attend deux secondes pour afficher le Splash Screen.
    await Future.delayed(const Duration(seconds: 2));

    // Vérifie que l'écran existe toujours.
    if (!mounted) return;

    // Remplace le Splash Screen par l'écran de connexion.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  // ----------------------------------------------------------
  // INITIALISATION DE L'ÉCRAN
  // ----------------------------------------------------------

  @override
  void initState() {
    super.initState();

    // Lance automatiquement le compte à rebours
    // dès que le Splash Screen est affiché.
    _allerVersLogin();
  }

  // ----------------------------------------------------------
  // CONSTRUCTION DE L'INTERFACE
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // Récupération des dimensions de l'écran du téléphone.
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      // Suppression de toute marge autour du contenu.
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ----------------------------------------------------------
          // 1. IMAGE DE FOND
          // ----------------------------------------------------------
          Image.asset(
            'assets/images/splash/guineago_splash.webp',

            // L'image couvre entièrement l'écran.
            fit: BoxFit.cover,
          ),

          // ----------------------------------------------------------
          // 2. LÉGER DÉGRADÉ
          // ----------------------------------------------------------

          // Ce dégradé permet d'améliorer la lisibilité
          // du contenu placé en haut et en bas de l'écran.
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.15),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.30),
                ],
              ),
            ),
          ),

          // ----------------------------------------------------------
          // 3. LOGO GUINEAGO
          // ----------------------------------------------------------
          Positioned(
            top: screenHeight * 0.08,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/logo/logo.webp',

                // Taille du logo adaptée à la largeur du téléphone.
                width: screenWidth * 0.58,
              ),
            ),
          ),

          // ----------------------------------------------------------
          // 4. SLOGAN DU BAS
          // ----------------------------------------------------------
          Positioned(
            left: 20,
            right: 20,
            bottom: screenHeight * 0.055,
            child: Column(
              children: [
                // Slogan placé en bas de l'écran.
                // La police Caveat donne un style manuscrit.
                const Text(
                  'La Guinée\nautrement !',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    // Police manuscrite ajoutée dans les assets.
                    fontFamily: 'Caveat',

                    // Couleur blanche pour une bonne lisibilité.
                    color: Colors.white,

                    // Taille du slogan.
                    fontSize: 42,

                    // Épaisseur de l'écriture.
                    fontWeight: FontWeight.w500,

                    // Espacement vertical entre les deux lignes.
                    height: 0.95,
                  ),
                ),

                // Espace entre le slogan et le trait coloré.
                const SizedBox(height: 14),

                // Trait décoratif aux couleurs de la Guinée.
                const _TraitCouleursGuinee(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------
// WIDGET DU TRAIT AUX COULEURS DE LA GUINÉE
// ----------------------------------------------------------

class _TraitCouleursGuinee extends StatelessWidget {
  const _TraitCouleursGuinee();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      height: 18,

      // Utilise un CustomPainter pour dessiner le trait.
      child: CustomPaint(painter: _TraitGuineePainter()),
    );
  }
}

// ----------------------------------------------------------
// PAINTER RESPONSABLE DU DESSIN DU TRAIT COLORÉ
// ----------------------------------------------------------

class _TraitGuineePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Épaisseur du trait.
    const strokeWidth = 7.0;

    // ----------------------------------------------------------
    // COULEUR ROUGE
    // ----------------------------------------------------------

    final peintureRouge = Paint()
      ..color = Colors.red
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      const Offset(5, 12),
      Offset(size.width * 0.35, 5),
      peintureRouge,
    );

    // ----------------------------------------------------------
    // COULEUR JAUNE
    // ----------------------------------------------------------

    final peintureJaune = Paint()
      ..color = Colors.amber
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(size.width * 0.30, 7),
      Offset(size.width * 0.68, 5),
      peintureJaune,
    );

    // ----------------------------------------------------------
    // COULEUR VERTE
    // ----------------------------------------------------------

    final peintureVerte = Paint()
      ..color = Colors.green
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(size.width * 0.63, 5),
      Offset(size.width - 5, 3),
      peintureVerte,
    );
  }

  // ----------------------------------------------------------
  // VÉRIFICATION DU BESOIN DE REDESSIN
  // ----------------------------------------------------------

  // Indique à Flutter que le dessin ne doit pas être
  // redessiné si ses paramètres ne changent pas.

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
