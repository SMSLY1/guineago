// Importation de Firebase Authentication
// Permet de gérer la connexion, l'inscription et la déconnexion.
import 'package:firebase_auth/firebase_auth.dart';

// Importation de Google Sign-In
// Permet à l'utilisateur de se connecter avec son compte Google.
import 'package:google_sign_in/google_sign_in.dart';

// Classe responsable de la gestion de l'authentification
class AuthService {
  // Instance de Firebase Authentication
  // Elle permet d'utiliser les fonctionnalités de connexion Firebase.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Instance de Google Sign-In
  // Elle permet de gérer la connexion avec Google.
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // Variable permettant de vérifier si Google Sign-In a déjà été initialisé.
  // false = Google n'est pas encore initialisé.
  // true = Google est déjà initialisé.
  bool _googleInitialise = false;

  // ============================================================
  // CONNEXION AVEC EMAIL ET MOT DE PASSE
  // ============================================================

  // Cette méthode reçoit :
  // - email : l'adresse e-mail de l'utilisateur
  // - motDePasse : le mot de passe de l'utilisateur
  //
  // Elle retourne :
  // - un objet User si la connexion réussit
  // - null si aucun utilisateur n'est retourné
  Future<User?> connexion(String email, String motDePasse) async {
    try {
      // Tentative de connexion à Firebase
      // await attend la réponse de Firebase avant de continuer.
      final resultat = await _auth.signInWithEmailAndPassword(
        email: email,
        password: motDePasse,
      );

      // Retourne l'utilisateur connecté.
      return resultat.user;
    } on FirebaseAuthException {
      // Nous conservons l'erreur Firebase originale.
      //
      // Cela permet à login_screen.dart de récupérer le code
      // de l'erreur et d'afficher un message compréhensible.
      //
      // Exemples :
      // - invalid-credential
      // - user-not-found
      // - network-request-failed
      // - user-disabled
      rethrow;
    }
  }

  // ============================================================
  // INITIALISATION DE GOOGLE SIGN-IN
  // ============================================================

  // Cette méthode initialise Google Sign-In une seule fois.
  Future<void> _initialiserGoogle() async {
    // Si Google est déjà initialisé,
    // nous évitons de refaire l'initialisation.
    if (_googleInitialise) return;

    // Initialisation de Google Sign-In.
    await _googleSignIn.initialize();

    // Nous indiquons que l'initialisation est terminée.
    _googleInitialise = true;
  }

  // ============================================================
  // CONNEXION AVEC GOOGLE
  // ============================================================

  // Cette méthode permet à l'utilisateur de se connecter avec Google.
  //
  // Elle retourne :
  // - l'utilisateur Firebase connecté
  // - null si aucun utilisateur n'est retourné
  Future<User?> connexionAvecGoogle() async {
    try {
      // Initialisation de Google Sign-In avant son utilisation.
      await _initialiserGoogle();

      // Ouverture de la fenêtre de sélection du compte Google.
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      // Récupération des informations d'authentification Google.
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // Création des identifiants Firebase à partir du token Google.
      //
      // Firebase utilise cet identifiant pour authentifier
      // l'utilisateur dans notre application.
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // Connexion à Firebase avec les identifiants Google.
      final resultat = await _auth.signInWithCredential(credential);

      // Retourne l'utilisateur Firebase connecté.
      return resultat.user;
    } on FirebaseAuthException {
      // Conservation de l'erreur Firebase originale.
      // Elle pourra être traitée dans l'interface utilisateur.
      rethrow;
    } catch (e) {
      // Gestion des autres erreurs qui ne sont pas
      // directement des erreurs Firebase.
      //
      // Exemple : problème avec Google Sign-In.
      throw Exception('Erreur lors de la connexion avec Google : $e');
    }
  }

  // ============================================================
  // DÉCONNEXION
  // ============================================================

  // Cette méthode déconnecte l'utilisateur de Firebase
  // et de son compte Google.
  Future<void> deconnexion() async {
    // Déconnexion de Firebase Authentication.
    await _auth.signOut();

    // Déconnexion de Google Sign-In.
    await _googleSignIn.signOut();
  }
}
