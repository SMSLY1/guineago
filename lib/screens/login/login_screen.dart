import 'package:flutter/material.dart';

// Importation de Firebase Authentication.
// Utilisé pour la réinitialisation du mot de passe.
import 'package:firebase_auth/firebase_auth.dart';

// Permet d'accéder au gestionnaire de langue.
import 'package:provider/provider.dart';

// Gestionnaire de langue de GuineaGo.
import '../../providers/language_provider.dart';

// Service responsable de la connexion avec Firebase Authentication.
import '../../services/auth_service.dart';

import '../main/main_navigation_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Contrôleur permettant de récupérer l'adresse e-mail
  // saisie par l'utilisateur.
  final TextEditingController _emailController = TextEditingController();

  // Contrôleur permettant de récupérer le mot de passe
  // saisi par l'utilisateur.
  final TextEditingController _motDePasseController = TextEditingController();

  // Clé permettant d'identifier et de valider le formulaire.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Instance du service qui communique avec Firebase Authentication.
  final AuthService _authService = AuthService();

  // Indique si une connexion Firebase est actuellement en cours.
  bool _isConnexionEnCours = false;

  // Indique si le mot de passe est actuellement visible.
  bool _motDePasseVisible = false;

  // ============================================================
  // TRADUCTION DES ERREURS D'AUTHENTIFICATION
  // ============================================================

  // Cette méthode transforme les erreurs Firebase
  // en messages compréhensibles pour l'utilisateur.
  //
  // erreur : l'erreur reçue pendant la connexion
  // langue : la langue sélectionnée dans l'application
  String _messageErreurAuth(Object erreur, String langue) {
    // Récupération du code Firebase si l'erreur
    // est une FirebaseAuthException.
    String? code;

    if (erreur is FirebaseAuthException) {
      code = erreur.code;
    }

    // Messages en français
    if (langue == 'fr') {
      switch (code) {
        case 'invalid-credential':
        case 'wrong-password':
        case 'user-not-found':
          return 'E-mail ou mot de passe incorrect.';

        case 'invalid-email':
          return 'Veuillez saisir une adresse e-mail valide.';

        case 'user-disabled':
          return 'Ce compte a été désactivé.';

        case 'network-request-failed':
          return 'Problème de connexion Internet.';

        case 'too-many-requests':
          return 'Trop de tentatives. Réessayez plus tard.';

        default:
          return 'Une erreur est survenue. Veuillez réessayer.';
      }
    }

    // Messages en anglais
    switch (code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Incorrect email or password.';

      case 'invalid-email':
        return 'Please enter a valid email address.';

      case 'user-disabled':
        return 'This account has been disabled.';

      case 'network-request-failed':
        return 'Internet connection problem.';

      case 'too-many-requests':
        return 'Too many attempts. Try again later.';

      default:
        return 'An error occurred. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Récupère le gestionnaire de langue de l'application.
    final languageProvider = Provider.of<LanguageProvider>(context);

    // Récupère la langue actuellement sélectionnée.
    final langue = languageProvider.langue;
    return Scaffold(
      // Fond blanc correspondant à la maquette du Login.
      backgroundColor: Colors.white,

      body: Form(
        // Clé permettant d'identifier et de valider le formulaire.
        key: _formKey,

        child: SafeArea(
          // Évite que le contenu passe sous les éléments système Android.
          child: Stack(
            children: [
              // --------------------------------------------------
              // Décoration jaune en premier.
              // Elle se trouve EN DESSOUS de la forme verte.
              // --------------------------------------------------
              Positioned(
                top: 55,
                left: 0,
                child: IgnorePointer(
                  child: ClipPath(
                    clipper: TopLeftYellowClipper(),
                    child: Container(
                      width: 85,
                      height: 100,
                      color: const Color(0xFFFFC107),
                    ),
                  ),
                ),
              ),

              // --------------------------------------------------
              // Décoration verte en deuxième.
              // Elle se trouve AU-DESSUS de la forme jaune.
              // --------------------------------------------------
              Positioned(
                top: 0,
                left: 0,
                child: IgnorePointer(
                  child: ClipPath(
                    clipper: TopLeftGreenClipper(),
                    child: Container(
                      width: 160,
                      height: 100,
                      color: const Color(0xFF033D27),
                    ),
                  ),
                ),
              ),
              // --------------------------------------------------
              // Contenu principal du formulaire.
              // --------------------------------------------------
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // --------------------------------------------------
                      // En-tête contenant le sélecteur de langue et le logo.
                      // --------------------------------------------------
                      Column(
                        children: [
                          // Sélecteur de langue placé en haut à droite.
                          Align(
                            alignment: Alignment.centerRight,
                            child: PopupMenuButton<String>(
                              onSelected: (String nouvelleLangue) {
                                // Demande au LanguageProvider de changer la langue.
                                languageProvider.changerLangue(nouvelleLangue);
                              },
                              // Liste des langues disponibles.
                              itemBuilder: (BuildContext context) => [
                                const PopupMenuItem<String>(
                                  value: 'FR',
                                  child: Row(
                                    children: [
                                      // Drapeau français.
                                      Image(
                                        image: AssetImage(
                                          'assets/images/flags/drappeau_fr.webp',
                                        ),
                                        width: 28,
                                        height: 18,
                                        fit: BoxFit.cover,
                                      ),

                                      SizedBox(width: 8),

                                      Text('FR'),
                                    ],
                                  ),
                                ),

                                const PopupMenuItem<String>(
                                  value: 'EN',
                                  child: Row(
                                    children: [
                                      // Drapeau anglais.
                                      Image(
                                        image: AssetImage(
                                          'assets/images/flags/drappeau_an.webp',
                                        ),
                                        width: 28,
                                        height: 18,
                                        fit: BoxFit.cover,
                                      ),

                                      SizedBox(width: 8),

                                      Text('EN'),
                                    ],
                                  ),
                                ),
                              ],

                              // Affiche la langue et son drapeau actuellement sélectionnés.
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Drapeau correspondant à la langue actuelle.
                                    Image(
                                      image: AssetImage(
                                        langue == 'FR'
                                            ? 'assets/images/flags/drappeau_fr.webp'
                                            : 'assets/images/flags/drappeau_an.webp',
                                      ),
                                      width: 28,
                                      height: 18,
                                      fit: BoxFit.cover,
                                    ),

                                    const SizedBox(width: 6),

                                    // Langue actuellement sélectionnée.
                                    Text(
                                      langue,
                                      style: const TextStyle(
                                        color: Color(0xFF033D27),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),

                                    // Petite flèche du menu.
                                    const Icon(
                                      Icons.keyboard_arrow_down,
                                      color: Color(0xFF033D27),
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Logo officiel de GuineaGo.
                          Image.asset('assets/logo/logo.webp', width: 150),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // --------------------------------------------------
                      // Titre principal.
                      // --------------------------------------------------
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          langue == 'FR' ? 'Bienvenue !' : 'Welcome!',
                          style: const TextStyle(
                            // Vert principal de GuineaGo.
                            color: Color(0xFF033D27),

                            // Taille du titre.
                            fontSize: 24,

                            // Titre en gras.
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // --------------------------------------------------
                      // Sous-titre.
                      // --------------------------------------------------
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          langue == 'FR'
                              ? 'Connectez-vous pour explorer\n'
                                    'les merveilles de la Guinée.'
                              : 'Log in to explore\n'
                                    'the wonders of Guinea.',
                          style: const TextStyle(
                            // Gris discret comme dans la maquette.
                            color: Colors.grey,

                            // Taille du sous-titre.
                            fontSize: 12,

                            // Espacement entre les lignes.
                            height: 1.4,
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // --------------------------------------------------
                      // Champ e-mail.
                      // --------------------------------------------------
                      TextFormField(
                        // Permet de récupérer l'adresse e-mail saisie.
                        controller: _emailController,

                        keyboardType: TextInputType.emailAddress,

                        // Vérifie que l'utilisateur a bien saisi son e-mail.
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return langue == 'FR'
                                ? 'Veuillez saisir votre adresse e-mail'
                                : 'Please enter your email address';
                          }

                          return null;
                        },

                        decoration: InputDecoration(
                          // Texte affiché dans le champ.
                          labelText: langue == 'FR'
                              ? 'Adresse e-mail'
                              : 'Email address',

                          // Espacement intérieur du champ.
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),

                          // Icône e-mail à gauche.
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color: Color(0xFF033D27),
                          ),

                          // Fond blanc.
                          filled: true,
                          fillColor: Colors.white,

                          // Bordure normale.
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFFE0E0E0),
                              width: 1,
                            ),
                          ),

                          // Bordure lorsque le champ n'est pas sélectionné.
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFFE0E0E0),
                              width: 1,
                            ),
                          ),

                          // Bordure lorsque le champ est sélectionné.
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFF033D27),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // --------------------------------------------------
                      // Champ mot de passe.
                      // --------------------------------------------------
                      TextFormField(
                        // Permet de récupérer le mot de passe saisi.
                        controller: _motDePasseController,

                        // Masque ou affiche le mot de passe selon l'état actuel.
                        obscureText: !_motDePasseVisible,

                        // Vérifie que le mot de passe est renseigné.
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez saisir votre mot de passe';
                          }

                          return null;
                        },

                        decoration: InputDecoration(
                          // Texte affiché dans le champ.
                          labelText: langue == 'FR'
                              ? 'Mot de passe'
                              : 'Password',

                          // Espacement intérieur du champ.
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),

                          // Icône cadenas.
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: Color(0xFF033D27),
                          ),

                          // Bouton permettant d'afficher ou de masquer le mot de passe.
                          suffixIcon: IconButton(
                            onPressed: () {
                              // Inverse l'état de visibilité du mot de passe.
                              setState(() {
                                _motDePasseVisible = !_motDePasseVisible;
                              });
                            },
                            icon: Icon(
                              _motDePasseVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: const Color(0xFF033D27),
                            ),
                          ),

                          // Fond blanc.
                          filled: true,
                          fillColor: Colors.white,

                          // Bordure normale.
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFFE0E0E0),
                              width: 1,
                            ),
                          ),

                          // Bordure non sélectionnée.
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFFE0E0E0),
                              width: 1,
                            ),
                          ),

                          // Bordure sélectionnée.
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFF033D27),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),

                      // --------------------------------------------------
                      // Mot de passe oublié.
                      // --------------------------------------------------
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () async {
                            // Vérifie que l'adresse e-mail est valide.
                            final email = _emailController.text.trim();

                            if (email.isEmpty || !email.contains('@')) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    langue == 'FR'
                                        ? 'Veuillez saisir une adresse e-mail valide.'
                                        : 'Please enter a valid email address.',
                                  ),
                                ),
                              );

                              return;
                            }

                            try {
                              // Envoie un e-mail de réinitialisation.
                              await FirebaseAuth.instance
                                  .sendPasswordResetEmail(email: email);

                              // Vérifie que le contexte existe toujours.
                              if (!context.mounted) return;

                              // Informe l'utilisateur que l'e-mail a été envoyé.
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    langue == 'FR'
                                        ? 'Un e-mail de réinitialisation a été envoyé.'
                                        : 'A password reset email has been sent.',
                                  ),
                                ),
                              );
                            } on FirebaseAuthException catch (e) {
                              // Vérifie que le contexte existe toujours.
                              if (!context.mounted) return;

                              // Affiche l'erreur Firebase.
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    langue == 'FR'
                                        ? e.message ??
                                              'Une erreur est survenue.'
                                        : e.message ?? 'An error occurred.',
                                  ),
                                ),
                              );
                            }
                          },
                          child: Text(
                            langue == 'FR'
                                ? 'Mot de passe oublié ?'
                                : 'Forgot password?',
                            style: TextStyle(
                              // Vert principal de GuineaGo.
                              color: Color(0xFF033D27),

                              // Taille du texte.
                              fontSize: 14,

                              // Texte légèrement renforcé.
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      // --------------------------------------------------
                      // Bouton principal de connexion.
                      // --------------------------------------------------
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            // Jaune de la charte GuineaGo.
                            backgroundColor: const Color(0xFFFFC107),

                            // Texte noir.
                            foregroundColor: Colors.black,

                            // Hauteur du bouton.
                            minimumSize: const Size(double.infinity, 52),

                            // Coins arrondis.
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),

                          // Désactive le bouton pendant la connexion.
                          onPressed: _isConnexionEnCours
                              ? null
                              : () async {
                                  // Vérifie le formulaire.
                                  if (!_formKey.currentState!.validate()) {
                                    return;
                                  }

                                  // Active le chargement.
                                  setState(() {
                                    _isConnexionEnCours = true;
                                  });

                                  try {
                                    // Affiche le message de chargement.
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Connexion en cours...'),
                                      ),
                                    );

                                    // Récupère l'e-mail.
                                    final email = _emailController.text.trim();

                                    // Récupère le mot de passe.
                                    final motDePasse =
                                        _motDePasseController.text;

                                    // Connexion avec Firebase.
                                    await _authService.connexion(
                                      email,
                                      motDePasse,
                                    );

                                    // Vérifie que le contexte existe toujours.
                                    if (!context.mounted) return;

                                    // Redirige l'utilisateur vers l'accueil après une connexion réussie.
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const MainNavigationScreen(),
                                      ),
                                    );
                                  } catch (e) {
                                    // Réactive le bouton après une erreur.
                                    if (mounted) {
                                      setState(() {
                                        _isConnexionEnCours = false;
                                      });
                                    }

                                    // Vérifie que le contexte existe toujours.
                                    if (!context.mounted) return;

                                    // Affiche l'erreur.
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          _messageErreurAuth(e, langue),
                                        ),
                                      ),
                                    );
                                  }
                                },

                          // Contenu du bouton.
                          child: _isConnexionEnCours
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    // Épaisseur de l'indicateur.
                                    strokeWidth: 2.5,

                                    // Couleur de l'indicateur.
                                    color: Colors.black,
                                  ),
                                )
                              : Stack(
                                  children: [
                                    // Texte centré.
                                    Center(
                                      child: Text(
                                        langue == 'FR'
                                            ? 'Se connecter'
                                            : 'Log in',
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),

                                    // Flèche à droite.
                                    const Positioned(
                                      right: 0,
                                      top: 0,
                                      bottom: 0,
                                      child: Center(
                                        child: Icon(
                                          Icons.arrow_forward,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),

                      // --------------------------------------------------
                      // Séparateur entre connexion classique et Google.
                      // --------------------------------------------------
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            // Ligne gauche.
                            const Expanded(
                              child: Divider(
                                color: Color(0xFFE0E0E0),
                                thickness: 1,
                              ),
                            ),

                            // Texte OU.
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                langue == 'FR' ? 'OU' : 'OR',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                            // Ligne droite.
                            const Expanded(
                              child: Divider(
                                color: Color(0xFFE0E0E0),
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // --------------------------------------------------
                      // Bouton de connexion Google.
                      // --------------------------------------------------
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: _isConnexionEnCours
                              ? null
                              : () async {
                                  setState(() {
                                    _isConnexionEnCours = true;
                                  });

                                  try {
                                    final utilisateur = await _authService
                                        .connexionAvecGoogle();

                                    if (!context.mounted) return;

                                    if (utilisateur != null) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const MainNavigationScreen(),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (!context.mounted) return;

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          _messageErreurAuth(e, langue),
                                        ),
                                      ),
                                    );
                                  } finally {
                                    if (mounted) {
                                      setState(() {
                                        _isConnexionEnCours = false;
                                      });
                                    }
                                  }
                                },
                          style: OutlinedButton.styleFrom(
                            // Fond blanc.
                            backgroundColor: Colors.white,

                            // Bordure légère.
                            side: const BorderSide(color: Color(0xFFE0E0E0)),

                            // Coins arrondis.
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Logo Google officiel.
                              Image.asset(
                                'assets/images/google/google_logo.webp',
                                width: 30,
                                height: 30,
                              ),

                              const SizedBox(width: 8),

                              // Texte du bouton.
                              Text(
                                langue == 'FR'
                                    ? 'Continuer avec Google'
                                    : 'Continue with Google',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // --------------------------------------------------
                      // Message concernant l'inscription.
                      // --------------------------------------------------
                      const SizedBox(height: 18),

                      // Pour la V1, l'inscription n'est pas encore disponible.
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            langue == 'FR'
                                ? 'Pas encore de compte ? "bientôt disponible"'
                                : 'No account yet? "Coming soon"',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================================
// Forme verte située dans le coin supérieur gauche.
// ==========================================================
class TopLeftGreenClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // Départ dans le coin supérieur gauche.
    path.moveTo(0, 0);

    // Bord supérieur.
    path.lineTo(size.width, 0);

    // Courbe vers la gauche.
    path.quadraticBezierTo(
      size.width * 0.72,
      size.height * 0.55,
      0,
      size.height,
    );

    // Retour au point de départ.
    path.lineTo(0, 0);

    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

// ==========================================================
// Forme jaune située sous la forme verte.
// ==========================================================
class TopLeftYellowClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // Départ dans le coin supérieur gauche.
    path.moveTo(0, 0);

    // Partie supérieure.
    path.lineTo(size.width * 0.95, 0);

    // Courbe vers le bas et la gauche.
    path.quadraticBezierTo(
      size.width * 0.55,
      size.height * 0.55,
      0,
      size.height,
    );

    // Retour au point de départ.
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
