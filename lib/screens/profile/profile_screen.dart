// Permet de manipuler les fichiers locaux.
import 'dart:io';

import 'package:flutter/material.dart';

// Permet de récupérer le chemin de la photo sauvegardée.
import 'package:shared_preferences/shared_preferences.dart';

import 'package:firebase_auth/firebase_auth.dart';

// Importe la page permettant de modifier les informations du profil.
import '../edit_profile_screen.dart';
// Importation de l'écran de connexion
import '../login/login_screen.dart';

import '../maintenance_screen.dart';

import '../favorites/favorites_screen.dart';

// ----------------------------------------------------------
// ÉCRAN DU PROFIL
// ----------------------------------------------------------

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

// ----------------------------------------------------------
// ÉTAT DU PROFIL
// ----------------------------------------------------------

class _ProfileScreenState extends State<ProfileScreen> {
  // Couleur principale de GuineaGo.
  static const Color vertGuineaGo = Color(0xFF033D27);

  // Photo de profil sauvegardée sur le téléphone.
  File? _photoProfilLocale;

  // ----------------------------------------------------------
  // CHARGEMENT DE LA PHOTO LOCALE
  // ----------------------------------------------------------

  /// Charge la photo de profil sauvegardée sur le téléphone.
  Future<void> _chargerPhotoLocale() async {
    // Récupère les préférences enregistrées.
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    // Récupère le chemin de la photo.
    final String? cheminPhoto = preferences.getString('chemin_photo_profil');

    // Vérifie qu'un chemin existe.
    if (cheminPhoto == null || cheminPhoto.isEmpty) {
      return;
    }

    // Crée un fichier à partir du chemin récupéré.
    final File photo = File(cheminPhoto);

    // Vérifie que le fichier existe réellement.
    if (!await photo.exists()) {
      return;
    }

    // Vérifie que l'écran est toujours actif.
    if (!mounted) return;

    // Actualise l'interface avec la photo.
    setState(() {
      _photoProfilLocale = photo;
    });
  }

  // ----------------------------------------------------------
  // ACTUALISATION DES INFORMATIONS
  // ----------------------------------------------------------

  /// Recharge les informations de l'utilisateur et sa photo locale.
  Future<void> _actualiserProfil() async {
    // Récupère l'utilisateur connecté.
    final User? utilisateur = FirebaseAuth.instance.currentUser;

    // Vérifie qu'un utilisateur existe.
    if (utilisateur == null) return;

    // Recharge les données depuis Firebase Authentication.
    await utilisateur.reload();

    // Recharge également la photo enregistrée localement.
    await _chargerPhotoLocale();

    // Vérifie que l'écran est toujours actif.
    if (!mounted) return;

    // Actualise l'interface avec les nouvelles informations.
    setState(() {});
  }
  // ----------------------------------------------------------
  // INITIALISATION
  // ----------------------------------------------------------

  @override
  void initState() {
    super.initState();

    // Actualise les informations du profil.
    _actualiserProfil();
  }
  // ==========================================================
  // CHANGER LE MOT DE PASSE
  // ==========================================================

  Future<void> _changerMotDePasse() async {
    // Récupérer l'utilisateur connecté.
    final User? utilisateur = FirebaseAuth.instance.currentUser;

    // Vérifier que l'utilisateur possède une adresse e-mail.
    if (utilisateur == null || utilisateur.email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adresse e-mail introuvable.')),
      );
      return;
    }

    try {
      // Envoyer le lien de réinitialisation.
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: utilisateur.email!,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Un lien de réinitialisation a été envoyé à votre e-mail.',
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Une erreur est survenue.')),
      );
    }
  }

  // ==========================================================
  // DÉCONNEXION DE L'UTILISATEUR
  // ==========================================================

  Future<void> _seDeconnecter() async {
    try {
      // Déconnecter l'utilisateur de Firebase.
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,

        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            return const LoginScreen();
          },

          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },

          transitionDuration: const Duration(milliseconds: 700),
        ),

        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Erreur lors de la déconnexion.')),
      );
    }
  }

  // ----------------------------------------------------------
  // CONSTRUCTION DE L'INTERFACE
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // Récupère l'utilisateur actuellement connecté.
    final User? utilisateur = FirebaseAuth.instance.currentUser;

    // Récupère le nom de l'utilisateur.
    final String nomUtilisateur =
        (utilisateur?.displayName?.trim().isNotEmpty ?? false)
        ? utilisateur!.displayName!.trim()
        : 'Utilisateur';

    // Récupère l'adresse e-mail de Firebase.
    final String emailUtilisateur =
        utilisateur?.email ?? 'E-mail non disponible';

    return Scaffold(
      backgroundColor: Colors.white,

      // ======================================================
      // BARRE SUPÉRIEURE
      // ======================================================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,

        title: const Text(
          'Mon profil',
          style: TextStyle(
            color: vertGuineaGo,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          // Bouton des paramètres
          IconButton(
            onPressed: () {
              // Ouvre la page de maintenance
              // lorsque l'utilisateur appuie sur le bouton.
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MaintenanceScreen(),
                ),
              );
            },

            // Icône des paramètres
            icon: const Icon(Icons.settings_outlined, color: vertGuineaGo),
          ),
        ],
      ),

      // ======================================================
      // CONTENU DU PROFIL
      // ======================================================
      body: RefreshIndicator(
        // Permet à l'utilisateur de tirer vers le bas
        // pour actualiser les informations du profil.
        onRefresh: _actualiserProfil,

        child: SingleChildScrollView(
          // Permet de faire défiler le contenu même
          // lorsque la page contient peu d'éléments.
          physics: const AlwaysScrollableScrollPhysics(),

          // Ajoute un espace inférieur adapté à la navigation Android.
          // Cela évite que le bouton Déconnexion soit recouvert.
          padding: EdgeInsets.fromLTRB(
            16, // Marge à gauche
            16, // Marge en haut
            16, // Marge à droite
            32 + MediaQuery.of(context).padding.bottom,
            // 32 pixels supplémentaires + espace système Android.
          ),

          child: Column(
            children: [
              // ==================================================
              // EN-TÊTE MODERNE DU PROFIL
              // ==================================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 28,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: vertGuineaGo,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    // Photo de profil
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: const Color(0xFFE8F2EE),

                      backgroundImage: _photoProfilLocale != null
                          ? FileImage(_photoProfilLocale!)
                          : (utilisateur?.photoURL != null
                                ? NetworkImage(utilisateur!.photoURL!)
                                : null),

                      child:
                          _photoProfilLocale == null &&
                              utilisateur?.photoURL == null
                          ? const Icon(
                              Icons.person,
                              size: 60,
                              color: vertGuineaGo,
                            )
                          : null,
                    ),

                    const SizedBox(height: 16),

                    // Nom de l'utilisateur
                    Text(
                      nomUtilisateur,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Adresse e-mail
                    Text(
                      emailUtilisateur,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const SizedBox(height: 12),

              // ==================================================
              // NOM DE L'UTILISATEUR
              // ==================================================
              Text(
                nomUtilisateur,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: vertGuineaGo,
                ),
              ),

              const SizedBox(height: 4),

              // ==================================================
              // E-MAIL DE L'UTILISATEUR
              // ==================================================
              Text(
                emailUtilisateur,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),

              const SizedBox(height: 24),

              // ==================================================
              // LISTE DES OPTIONS
              // ==================================================
              _optionProfil(
                icone: Icons.person_outline,
                titre: 'Mes informations',

                onTap: () async {
                  // Ouvre la page de modification.
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  );

                  // Actualise le profil après le retour.
                  await _actualiserProfil();
                  // Recharge la photo locale après une modification.
                  await _chargerPhotoLocale();
                },
              ),

              _optionProfil(
                icone: Icons.favorite_border,
                titre: 'Mes favoris',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FavoritesScreen(
                        onRetourAccueil: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  );
                },
              ),

              _optionProfil(
                icone: Icons.language,
                titre: 'Langue',
                sousTitre: 'Français',
                onTap: () {
                  // Fonctionnalité à ajouter plus tard.
                },
              ),

              _optionProfil(
                icone: Icons.lock_outline,
                titre: 'Changer le mot de passe',

                // Appelle la méthode lorsque l'utilisateur clique.
                onTap: _changerMotDePasse,
              ),

              // Option : Aide et support
              _optionProfil(
                icone: Icons.help_outline,
                titre: 'Aide et support',

                onTap: () {
                  // Ouvre la page de maintenance
                  // lorsque l'utilisateur sélectionne cette option.
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MaintenanceScreen(),
                    ),
                  );
                },
              ),

              // Option : À propos de GuineaGo
              _optionProfil(
                icone: Icons.info_outline,
                titre: 'À propos de GuineaGo',

                onTap: () {
                  // Ouvre la page de maintenance
                  // lorsque l'utilisateur sélectionne cette option.
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MaintenanceScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // ==================================================
              // BOUTON DE DÉCONNEXION
              // ==================================================
              SizedBox(
                width: double.infinity,

                child: OutlinedButton.icon(
                  //Deconnexion
                  onPressed: _seDeconnecter,

                  icon: const Icon(Icons.logout, color: Colors.red),

                  label: const Text(
                    'Se déconnecter',
                    style: TextStyle(color: Colors.red),
                  ),

                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // WIDGET RÉUTILISABLE POUR UNE OPTION
  // ==========================================================

  static Widget _optionProfil({
    required IconData icone,
    required String titre,
    String? sousTitre,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,

          leading: Icon(icone, color: vertGuineaGo),

          title: Text(titre, style: const TextStyle(fontSize: 14)),

          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (sousTitre != null)
                Text(
                  sousTitre,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),

              const SizedBox(width: 8),

              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),

          onTap: onTap,
        ),

        const Divider(height: 1, color: Color(0xFFE8E8E8)),
      ],
    );
  }
}
