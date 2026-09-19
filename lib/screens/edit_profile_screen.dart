// ==========================================================
// IMPORTATIONS
// ==========================================================

// Composants graphiques de Flutter.
import 'package:flutter/material.dart';

// Gestion des fichiers sur le téléphone.
import 'dart:io';

// Firebase Authentication.
import 'package:firebase_auth/firebase_auth.dart';

// Cloud Firestore.
import 'package:cloud_firestore/cloud_firestore.dart';

// Sélection d'images dans la galerie.
import 'package:image_picker/image_picker.dart';

// Accès au dossier local de l'application.
import 'package:path_provider/path_provider.dart';

// Sauvegarde des préférences locales.
import 'package:shared_preferences/shared_preferences.dart';

// Importation de l'écran de connexion
import 'login/login_screen.dart';

// ==========================================================
// ÉCRAN DE MODIFICATION DU PROFIL
// ==========================================================

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

// ==========================================================
// ÉTAT DE L'ÉCRAN
// ==========================================================

class _EditProfileScreenState extends State<EditProfileScreen> {
  // --------------------------------------------------------
  // CONTRÔLEURS DES CHAMPS
  // --------------------------------------------------------

  // Contrôleur du nom complet.
  final TextEditingController _nomController = TextEditingController();

  // Contrôleur de l'adresse e-mail.
  final TextEditingController _emailController = TextEditingController();

  // Contrôleur du numéro de téléphone.
  final TextEditingController _telephoneController = TextEditingController();

  // Contrôleur du pays.
  final TextEditingController _paysController = TextEditingController();

  // Contrôleur de la ville.
  final TextEditingController _villeController = TextEditingController();

  // Indique si un enregistrement est en cours.
  bool _enregistrementEnCours = false;

  // --------------------------------------------------------
  // GESTION DE LA PHOTO
  // --------------------------------------------------------

  // Objet permettant d'ouvrir la galerie.
  final ImagePicker _selecteurImage = ImagePicker();

  // Contient la photo sélectionnée par l'utilisateur.
  File? _photoSelectionnee;

  // ========================================================
  // INITIALISATION
  // ========================================================

  @override
  void initState() {
    super.initState();

    // Charge les informations existantes du profil.
    _chargerInformationsProfil();
  }

  // ========================================================
  // CHARGER LES INFORMATIONS DU PROFIL
  // ========================================================

  Future<void> _chargerInformationsProfil() async {
    // Récupère l'utilisateur actuellement connecté.
    final User? utilisateur = FirebaseAuth.instance.currentUser;

    // Vérifie qu'un utilisateur est connecté.
    if (utilisateur == null) return;

    // Préremplit le nom depuis Firebase Authentication.
    _nomController.text = utilisateur.displayName ?? '';

    // Préremplit l'e-mail depuis Firebase Authentication.
    _emailController.text = utilisateur.email ?? '';

    try {
      // Récupère le document de l'utilisateur dans Firestore.
      final DocumentSnapshot document = await FirebaseFirestore.instance
          .collection('users')
          .doc(utilisateur.uid)
          .get();

      // Vérifie que le document existe.
      if (document.exists) {
        // Convertit les données Firestore en Map.
        final Map<String, dynamic> donnees =
            document.data() as Map<String, dynamic>;

        // Charge le numéro de téléphone.
        _telephoneController.text = donnees['telephone'] ?? '';

        // Charge le pays.
        _paysController.text = donnees['pays'] ?? '';

        // Charge la ville.
        _villeController.text = donnees['ville'] ?? '';
      }

      // Charge la photo enregistrée localement.
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();

      // Récupère le chemin enregistré.
      final String? cheminPhoto = preferences.getString('chemin_photo_profil');

      // Vérifie que le chemin existe.
      if (cheminPhoto != null) {
        // Crée un objet File avec le chemin.
        final File fichierPhoto = File(cheminPhoto);

        // Vérifie que le fichier existe réellement.
        if (await fichierPhoto.exists()) {
          // Affiche la photo dans l'écran.
          if (!mounted) return;

          setState(() {
            _photoSelectionnee = fichierPhoto;
          });
        }
      }
    } catch (e) {
      // Affiche l'erreur dans le terminal.
      debugPrint('Erreur lors du chargement du profil : $e');
    }
  }

  // ========================================================
  // CHOISIR UNE PHOTO DANS LA GALERIE
  // ========================================================

  Future<void> _choisirPhoto() async {
    // Ouvre la galerie du téléphone.
    final XFile? image = await _selecteurImage.pickImage(
      source: ImageSource.gallery,

      // Réduit légèrement la taille de l'image.
      imageQuality: 80,
    );

    // Si l'utilisateur annule la sélection, on arrête.
    if (image == null) return;

    // Met à jour l'image affichée à l'écran.
    setState(() {
      _photoSelectionnee = File(image.path);
    });
  }

  // ========================================================
  // SAUVEGARDER LA PHOTO LOCALEMENT
  // ========================================================

  Future<void> _sauvegarderPhotoLocalement() async {
    // Vérifie si une photo a été sélectionnée.
    if (_photoSelectionnee == null) return;

    // Récupère le dossier privé de l'application.
    final Directory dossierApplication =
        await getApplicationDocumentsDirectory();

    // Génère un nom unique pour chaque nouvelle photo.
    final String nomFichier =
        'photo_profil_${DateTime.now().millisecondsSinceEpoch}.jpg';

    // Définit le chemin de destination.
    final String cheminPhoto = '${dossierApplication.path}/$nomFichier';

    // Copie la nouvelle photo dans le dossier de l'application.
    final File photoSauvegardee = await _photoSelectionnee!.copy(cheminPhoto);

    // Ouvre les préférences locales.
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    // Récupère l'ancien chemin de la photo.
    final String? ancienChemin = preferences.getString('chemin_photo_profil');

    // Enregistre le nouveau chemin.
    await preferences.setString('chemin_photo_profil', photoSauvegardee.path);

    // Supprime l'ancienne photo si elle existe
    // et si elle est différente de la nouvelle.
    if (ancienChemin != null &&
        ancienChemin.isNotEmpty &&
        ancienChemin != photoSauvegardee.path) {
      final File anciennePhoto = File(ancienChemin);

      if (await anciennePhoto.exists()) {
        await anciennePhoto.delete();
      }
    }

    // Affiche le chemin dans le terminal.
    debugPrint('Nouvelle photo sauvegardée : ${photoSauvegardee.path}');
  }
  // ========================================================
  // RECONNEXION DE L'UTILISATEUR
  // ========================================================

  Future<bool> _reconnecterUtilisateur() async {
    // Récupère l'utilisateur connecté.
    final User? utilisateur = FirebaseAuth.instance.currentUser;

    // Vérifie que l'utilisateur existe.
    if (utilisateur == null) return false;

    // Récupère son adresse e-mail actuelle.
    final String email = utilisateur.email ?? '';

    // Vérifie que l'adresse e-mail existe.
    if (email.isEmpty) return false;

    // Contrôleur du mot de passe.
    final TextEditingController motDePasseController = TextEditingController();

    // Affiche une boîte de dialogue.
    final String? motDePasse = await showDialog<String>(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Reconnexion nécessaire'),

          content: TextField(
            controller: motDePasseController,

            // Masque le mot de passe.
            obscureText: true,

            decoration: const InputDecoration(
              labelText: 'Mot de passe actuel',
              prefixIcon: Icon(Icons.lock),
              border: OutlineInputBorder(),
            ),
          ),

          actions: [
            // Bouton Annuler.
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },

              child: const Text('Annuler'),
            ),

            // Bouton Continuer.
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, motDePasseController.text);
              },

              child: const Text('Continuer'),
            ),
          ],
        );
      },
    );

    // Libère le contrôleur.
    motDePasseController.dispose();

    // Vérifie si l'utilisateur a annulé.
    if (motDePasse == null || motDePasse.isEmpty) {
      return false;
    }

    try {
      // Crée les informations d'identification Firebase.
      final AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: motDePasse,
      );

      // Reconnecte l'utilisateur.
      await utilisateur.reauthenticateWithCredential(credential);

      return true;
    } on FirebaseAuthException catch (e) {
      // Affiche une erreur à l'utilisateur.
      if (!mounted) return false;

      String message = 'Reconnexion impossible.';

      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        message = 'Le mot de passe est incorrect.';
      } else if (e.code == 'user-not-found') {
        message = 'Utilisateur introuvable.';
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));

      return false;
    }
  }

  // ========================================================
  // ENREGISTRER LES INFORMATIONS DU PROFIL
  // ========================================================

  Future<void> _enregistrerInformations() async {
    // Empêche plusieurs clics simultanés.
    if (_enregistrementEnCours) return;

    // Masque le clavier.
    FocusScope.of(context).unfocus();

    // Récupère l'utilisateur connecté.
    final User? utilisateur = FirebaseAuth.instance.currentUser;

    // Vérifie qu'un utilisateur est connecté.
    if (utilisateur == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun utilisateur connecté.')),
      );

      return;
    }

    // Récupère les données saisies.
    final String nom = _nomController.text.trim();

    final String nouvelEmail = _emailController.text.trim();

    final String telephone = _telephoneController.text.trim();

    final String pays = _paysController.text.trim();

    final String ville = _villeController.text.trim();

    // ------------------------------------------------------
    // VALIDATION DES CHAMPS
    // ------------------------------------------------------

    // Le nom est obligatoire.
    if (nom.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez saisir votre nom.')),
      );

      return;
    }

    // L'e-mail est obligatoire.
    if (nouvelEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez saisir votre adresse e-mail.')),
      );

      return;
    }

    // Vérifie le format de l'e-mail.
    final bool emailValide = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(nouvelEmail);

    if (!emailValide) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez saisir un e-mail valide.')),
      );

      return;
    }

    // Récupère l'ancien e-mail.
    final String ancienEmail = utilisateur.email ?? '';

    // Vérifie si l'e-mail a changé.
    final bool emailModifie =
        nouvelEmail.toLowerCase() != ancienEmail.toLowerCase();

    // Active le chargement.
    setState(() {
      _enregistrementEnCours = true;
    });

    try {
      // ----------------------------------------------------
      // 1. MODIFIER LE NOM DANS FIREBASE AUTHENTICATION
      // ----------------------------------------------------

      await utilisateur.updateDisplayName(nom);

      // Vérifie si l'utilisateur a modifié son adresse e-mail
      if (emailModifie) {
        // Demande une reconnexion sécurisée
        final bool reconnexionReussie = await _reconnecterUtilisateur();

        // Si la reconnexion échoue, on arrête l'opération
        if (!reconnexionReussie) {
          if (mounted) {
            setState(() {
              _enregistrementEnCours = false;
            });
          }

          return;
        }

        // Envoie un lien de confirmation à la nouvelle adresse
        await utilisateur.verifyBeforeUpdateEmail(nouvelEmail);

        // Affiche un message avant la déconnexion
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Un lien de confirmation a été envoyé. '
                'Veuillez vous reconnecter.',
              ),
            ),
          );
        }

        // Déconnecte l'utilisateur de Firebase
        await FirebaseAuth.instance.signOut();

        // Vérifie que l'écran existe toujours
        if (!mounted) return;

        // Redirige vers l'écran de connexion
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );

        // Arrête la fonction pour éviter de continuer
        return;
      }

      // ----------------------------------------------------
      // 3. SAUVEGARDER LA PHOTO LOCALEMENT
      // ----------------------------------------------------

      if (_photoSelectionnee != null) {
        await _sauvegarderPhotoLocalement();
      }

      // ----------------------------------------------------
      // 4. ENREGISTRER LES DONNÉES DANS FIRESTORE
      // ----------------------------------------------------

      await FirebaseFirestore.instance
          .collection('users')
          .doc(utilisateur.uid)
          .set(
            {
              // Identifiant de l'utilisateur.
              'uid': utilisateur.uid,

              // Nom complet.
              'nom': nom,

              // Adresse e-mail actuelle.
              'email': emailModifie ? ancienEmail : nouvelEmail,

              // Numéro de téléphone.
              'telephone': telephone,

              // Pays.
              'pays': pays,

              // Ville.
              'ville': ville,

              // Date de modification.
              'dateModification': FieldValue.serverTimestamp(),
            },

            // Conserve les autres champs du document.
            SetOptions(merge: true),
          );

      // Recharge les données Firebase.
      await utilisateur.reload();

      // Vérifie que l'écran existe toujours.
      if (!mounted) return;

      // Désactive le chargement.
      setState(() {
        _enregistrementEnCours = false;
      });

      // Message de confirmation.
      final String message = emailModifie
          ? 'Profil enregistré. Vérifiez votre nouvel e-mail.'
          : 'Profil modifié avec succès !';

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));

      // Retourne à l'écran précédent.
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      // Gère les erreurs Firebase Authentication.
      if (!mounted) return;

      setState(() {
        _enregistrementEnCours = false;
      });

      String message = 'Une erreur est survenue.';

      if (e.code == 'requires-recent-login') {
        message = 'Veuillez vous reconnecter avant de modifier votre e-mail.';
      } else if (e.code == 'email-already-in-use') {
        message = 'Cette adresse e-mail est déjà utilisée.';
      } else if (e.code == 'invalid-email') {
        message = 'L’adresse e-mail est incorrecte.';
      } else if (e.code == 'network-request-failed') {
        message = 'Vérifiez votre connexion Internet.';
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));

      debugPrint('Erreur Firebase : ${e.code}');
    } catch (e) {
      // Gère les autres erreurs.
      debugPrint('Erreur complète : $e');

      if (!mounted) return;

      setState(() {
        _enregistrementEnCours = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Une erreur est survenue. Consultez le terminal.'),
        ),
      );
    }
  }

  // ========================================================
  // LIBÉRER LES CONTRÔLEURS
  // ========================================================

  @override
  void dispose() {
    // Libère les contrôleurs pour éviter les fuites mémoire.
    _nomController.dispose();

    _emailController.dispose();

    _telephoneController.dispose();

    _paysController.dispose();

    _villeController.dispose();

    super.dispose();
  }

  // ========================================================
  // INTERFACE GRAPHIQUE
  // ========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barre supérieure.
      appBar: AppBar(
        title: const Text('Modifier mon profil'),

        // Bouton retour.
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),

          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      // Permet de faire défiler la page.
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [
            // ------------------------------------------------
            // PHOTO DE PROFIL
            // ------------------------------------------------
            GestureDetector(
              // Ouvre la galerie lors du clic.
              onTap: _choisirPhoto,

              child: Center(
                child: CircleAvatar(
                  // Taille de la photo.
                  radius: 60,

                  // Couleur de fond.
                  backgroundColor: const Color(0xFFE8F2EE),

                  // Affiche la photo sélectionnée.
                  backgroundImage: _photoSelectionnee != null
                      ? FileImage(_photoSelectionnee!)
                      : null,

                  // Affiche l'icône si aucune photo n'existe.
                  child: _photoSelectionnee == null
                      ? const Icon(
                          Icons.person,

                          size: 65,

                          color: Color(0xFF16803C),
                        )
                      : null,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Message sous la photo.
            const Center(
              child: Text(
                'Appuyez sur la photo pour la modifier',

                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),

            const SizedBox(height: 30),

            // ------------------------------------------------
            // CHAMP NOM COMPLET
            // ------------------------------------------------
            TextField(
              controller: _nomController,

              decoration: const InputDecoration(
                labelText: 'Nom complet',

                hintText: 'Exemple : Saikou Ly',

                prefixIcon: Icon(Icons.person),

                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // ------------------------------------------------
            // CHAMP E-MAIL
            // ------------------------------------------------
            TextField(
              controller: _emailController,

              keyboardType: TextInputType.emailAddress,

              decoration: const InputDecoration(
                labelText: 'Adresse e-mail',

                hintText: 'Exemple : nom@email.com',

                prefixIcon: Icon(Icons.email),

                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // ------------------------------------------------
            // CHAMP TÉLÉPHONE
            // ------------------------------------------------
            TextField(
              controller: _telephoneController,

              keyboardType: TextInputType.phone,

              decoration: const InputDecoration(
                labelText: 'Numéro de téléphone',

                hintText: 'Exemple : +224 000 000 000',

                prefixIcon: Icon(Icons.phone),

                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // ------------------------------------------------
            // CHAMP PAYS
            // ------------------------------------------------
            TextField(
              controller: _paysController,

              decoration: const InputDecoration(
                labelText: 'Pays',

                hintText: 'Exemple : Guinée',

                prefixIcon: Icon(Icons.public),

                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // ------------------------------------------------
            // CHAMP VILLE
            // ------------------------------------------------
            TextField(
              controller: _villeController,

              decoration: const InputDecoration(
                labelText: 'Ville',

                hintText: 'Exemple : Labé',

                prefixIcon: Icon(Icons.location_city),

                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            // ------------------------------------------------
            // BOUTON ENREGISTRER
            // ------------------------------------------------
            ElevatedButton.icon(
              // Désactive le bouton pendant l'enregistrement.
              onPressed: _enregistrementEnCours
                  ? null
                  : _enregistrerInformations,

              // Affiche un chargement pendant l'opération.
              icon: _enregistrementEnCours
                  ? const SizedBox(
                      width: 18,

                      height: 18,

                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),

              // Texte du bouton.
              label: Text(
                _enregistrementEnCours
                    ? 'Enregistrement...'
                    : 'Enregistrer les modifications',
              ),

              // Style du bouton.
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
