import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import '../../models/destination.dart';
import '../../services/destination_service.dart';
import '../../services/local_storage_service.dart';
import '../destinations/destination_detail_screen.dart';
import '../profile/profile_screen.dart';

import 'package:provider/provider.dart';

import '../../providers/favorites_provider.dart';

class HomeScreen extends StatefulWidget {
  // Fonction permettant d'ouvrir Explorer
  // avec une catégorie sélectionnée.
  final void Function(String categorie)? onOuvrirExplorer;

  // Fonction permettant d'ouvrir l'écran des guides.
  final VoidCallback? onOuvrirGuides;

  const HomeScreen({super.key, this.onOuvrirExplorer, this.onOuvrirGuides});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Contrôle le défilement du carrousel.
  final PageController _pageController = PageController();

  // Permet de changer automatiquement de destination.
  Timer? _carouselTimer;

  // Index de la destination actuellement affichée.
  int _pageActuelle = 0;
  // Service permettant de récupérer les destinations depuis Firestore.
  final DestinationService _destinationService = DestinationService();

  // Service permettant de sauvegarder les favoris sur le téléphone.
  final LocalStorageService _localStorageService = LocalStorageService();

  // Permet de récupérer les destinations une seule fois.
  late Future<List<Destination>> _destinationsFuture;

  // Permet de rechercher une destination.
  final TextEditingController _rechercheController = TextEditingController();

  // Catégorie actuellement sélectionnée.
  String _categorieSelectionnee = 'Toutes';

  /// Filtre les destinations selon le texte recherché.
  List<Destination> _filtrerDestinations(List<Destination> destinations) {
    final recherche = _rechercheController.text.trim().toLowerCase();

    // Si aucun texte n'est saisi, afficher toutes les destinations.
    if (recherche.isEmpty) {
      return destinations;
    }

    return destinations.where((destination) {
      return destination.nom.toLowerCase().contains(recherche) ||
          destination.region.toLowerCase().contains(recherche) ||
          destination.localite.toLowerCase().contains(recherche) ||
          destination.categorie.toLowerCase().contains(recherche) ||
          destination.description.toLowerCase().contains(recherche) ||
          destination.informationsPratiques.toLowerCase().contains(recherche) ||
          destination.ecotourisme.toLowerCase().contains(recherche);
    }).toList();
  }

  // Identifiants des destinations ajoutées aux favoris.
  final Set<String> _favoris = {};

  // Indique si le carrousel automatique a déjà été démarré.
  bool _carrouselDemarre = false;

  // Photo de profil enregistrée localement.
  File? _photoProfilLocale;

  @override
  void initState() {
    super.initState();

    // Lance la récupération des destinations depuis Firestore.
    _destinationsFuture = _destinationService.recupererDestinations();

    // Récupère les favoris sauvegardés sur le téléphone.
    _chargerFavoris();
    _chargerPhotoLocale();
  }

  /// Charge les favoris sauvegardés sur le téléphone.
  Future<void> _chargerFavoris() async {
    final favorisSauvegardes = await _localStorageService.recupererFavoris();

    if (!mounted) {
      return;
    }

    setState(() {
      _favoris.addAll(favorisSauvegardes);
    });
  }

  /// Charge la photo de profil enregistrée localement.
  Future<void> _chargerPhotoLocale() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    final String? cheminPhoto = preferences.getString('chemin_photo_profil');

    if (cheminPhoto == null || cheminPhoto.isEmpty) {
      if (mounted) {
        setState(() {
          _photoProfilLocale = null;
        });
      }
      return;
    }

    final File photo = File(cheminPhoto);

    if (!await photo.exists()) {
      if (mounted) {
        setState(() {
          _photoProfilLocale = null;
        });
      }
      return;
    }

    if (!mounted) return;

    setState(() {
      _photoProfilLocale = photo;
    });
  }

  /// Lance le défilement automatique du carrousel.
  void _demarrerCarrouselAutomatique(int nombreDestinations) {
    _carouselTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      // Vérifie que le contrôleur est disponible.
      if (!_pageController.hasClients) {
        return;
      }

      // Calcule la prochaine destination.
      final prochainePage = (_pageActuelle + 1) % nombreDestinations;

      // Affiche la prochaine destination.
      _pageController.animateToPage(
        prochainePage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    // Arrête le défilement automatique du carrousel.
    _carouselTimer?.cancel();

    // Libère le contrôleur du carrousel.
    _pageController.dispose();

    // Libère le contrôleur de recherche.
    _rechercheController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Récupère l'utilisateur actuellement connecté.
    final utilisateur = FirebaseAuth.instance.currentUser;

    // Récupère le nom affiché par Firebase.
    final nomUtilisateur = utilisateur?.displayName?.trim().isNotEmpty == true
        ? utilisateur!.displayName!
        : 'Saikou';

    return Scaffold(
      backgroundColor: Colors.white,

      // ==================================================
      // APPBAR FIXE : LOGO, NOTIFICATIONS ET PROFIL
      // ==================================================
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(78),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          titleSpacing: 12,

          // Logo horizontal utilisé comme une bannière.
          // Remplace le fichier assets/logo/logo.webp par ton nouveau logo.
          title: Image.asset(
            'assets/logo/logo2.webp',
            width: 175,
            height: 70,
            fit: BoxFit.contain,
          ),

          // Notification et photo de profil.
          actions: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  onPressed: () {
                    // Redirection vers la page de maintenance.
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MaintenanceScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.notifications_none,
                    color: Color(0xFF033D27),
                    size: 28,
                  ),
                ),

                // Badge de notification.
                Positioned(
                  right: 7,
                  top: 5,
                  child: Container(
                    width: 17,
                    height: 17,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        '3',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 4),

            // Photo de profil cliquable.
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );

                  // Recharge la photo après le retour du profil.
                  await _chargerPhotoLocale();

                  if (mounted) {
                    setState(() {});
                  }
                },
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFFE8F2EE),
                  backgroundImage: _photoProfilLocale != null
                      ? FileImage(_photoProfilLocale!)
                      : utilisateur?.photoURL != null
                      ? NetworkImage(utilisateur!.photoURL!)
                      : null,
                  child:
                      _photoProfilLocale == null &&
                          utilisateur?.photoURL == null
                      ? const Icon(Icons.person, color: Color(0xFF033D27))
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            // Le contenu principal peut défiler.
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 18),

                    // --------------------------------------------------
                    // MESSAGE DE BIENVENUE
                    // --------------------------------------------------
                    Text(
                      'Bonjour $nomUtilisateur 👋',
                      style: const TextStyle(
                        color: Color(0xFF033D27),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    const Text(
                      'Prêt à découvrir la Guinée ?',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),

                    const SizedBox(height: 18),

                    // --------------------------------------------------
                    // BARRE DE RECHERCHE
                    // --------------------------------------------------
                    TextField(
                      onChanged: (texte) {
                        setState(() {});
                      },
                      controller: _rechercheController,
                      decoration: InputDecoration(
                        hintText: 'Rechercher une destination, une activité...',
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFF033D27),
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            // Les filtres avancés seront ajoutés
                            // dans la prochaine étape.
                          },
                          icon: const Icon(
                            Icons.tune,
                            color: Color(0xFF033D27),
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFFE0E0E0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFFE0E0E0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFF033D27),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // --------------------------------------------------
                    // CATÉGORIES
                    // --------------------------------------------------
                    // Les quatre catégories prennent toute la largeur
                    // disponible de l'écran.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Catégorie Nature.
                        _categorie(
                          nom: 'Nature',
                          icone: Icons.landscape,
                          couleur: const Color(0xFF087F4F),
                        ),

                        // Catégorie Culture.
                        _categorie(
                          nom: 'Culture',
                          icone: Icons.account_balance,
                          couleur: const Color(0xFFFFB300),
                        ),

                        // Catégorie Aventure.
                        _categorie(
                          nom: 'Aventure',
                          icone: Icons.directions_run,
                          couleur: const Color(0xFFE53935),
                        ),

                        // Catégorie Histoire.
                        _categorie(
                          nom: 'Histoire',
                          icone: Icons.account_balance,
                          couleur: const Color(0xFF16865A),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),
                    // --------------------------------------------------
                    // ACCÈS AUX GUIDES
                    // --------------------------------------------------
                    GestureDetector(
                      onTap: () {
                        // Ouvre l'écran Nos guides.
                        widget.onOuvrirGuides?.call();
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F2EE),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            // Icône des guides.
                            Container(
                              width: 48,
                              height: 48,
                              decoration: const BoxDecoration(
                                color: Color(0xFF033D27),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person_pin,
                                color: Colors.white,
                                size: 25,
                              ),
                            ),

                            const SizedBox(width: 12),

                            // Texte.
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Nos guides',
                                    style: TextStyle(
                                      color: Color(0xFF033D27),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Découvrez la Guinée avec un guide local',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Flèche.
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Color(0xFF033D27),
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),
                    // --------------------------------------------------
                    // SECTION À LA UNE
                    // --------------------------------------------------
                    const Text(
                      'À la une',
                      style: TextStyle(
                        color: Color(0xFF033D27),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // --------------------------------------------------
                    // DESTINATIONS FIRESTORE
                    // --------------------------------------------------
                    FutureBuilder<List<Destination>>(
                      future: _destinationsFuture,
                      builder: (context, snapshot) {
                        // État de chargement.
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox(
                            height: 280,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF033D27),
                              ),
                            ),
                          );
                        }

                        // État d'erreur.
                        if (snapshot.hasError) {
                          return _messageDestination(
                            icone: Icons.error_outline,
                            message: 'Impossible de charger les destinations.',
                          );
                        }

                        // État vide.
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return _messageDestination(
                            icone: Icons.explore_off,
                            message:
                                'Aucune destination disponible pour le moment.',
                          );
                        }

                        // Récupère toutes les destinations venant de Firestore.
                        final toutesLesDestinations = snapshot.data!;

                        final destinations = _filtrerDestinations(
                          toutesLesDestinations,
                        );
                        //Gérer le cas où aucun résultat n'est trouvé
                        if (destinations.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    'Aucune destination trouvée',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'Essayez un autre mot-clé.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        if (destinations.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    'Aucune destination trouvée',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'Essayez un autre mot-clé.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        // Démarre le carrousel une seule fois,
                        // lorsque les destinations sont disponibles.
                        if (!_carrouselDemarre && destinations.length > 1) {
                          _carrouselDemarre = true;

                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              _demarrerCarrouselAutomatique(
                                destinations.length,
                              );
                            }
                          });
                        }

                        return SizedBox(
                          height: 300,
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: destinations.length,

                            onPageChanged: (index) {
                              setState(() {
                                _pageActuelle = index;
                              });
                            },

                            itemBuilder: (context, index) {
                              final destination = destinations[index];

                              return _carteDestination(
                                destination,
                                destinations.length,
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construit une catégorie de l'accueil.
  Widget _categorie({
    required String nom,
    required IconData icone,
    required Color couleur,
  }) {
    final selectionnee = _categorieSelectionnee == nom;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          // Sélectionne ou désélectionne la catégorie.
          final categorie = selectionnee ? 'Toutes' : nom;

          setState(() {
            _categorieSelectionnee = categorie;
          });

          // Ouvre Explorer avec la catégorie sélectionnée.
          widget.onOuvrirExplorer?.call(categorie);
        },
        child: Column(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: couleur,
                shape: BoxShape.circle,
                border: selectionnee
                    ? Border.all(color: const Color(0xFF033D27), width: 3)
                    : null,
              ),
              child: Icon(icone, color: Colors.white, size: 23),
            ),

            const SizedBox(height: 5),

            Text(
              nom,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF333333),
                fontSize: 11,
                fontWeight: selectionnee ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construit la carte d'une destination.
  Widget _carteDestination(Destination destination, int nombreDestinations) {
    final favorisProvider = context.watch<FavoritesProvider>();

    final estFavori = favorisProvider.estFavori(destination.id);

    return Container(
      // Hauteur adaptée à la maquette de l'écran d'accueil.
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Image de la destination.
          Positioned.fill(
            child: Image.asset(
              destination.image,
              fit: BoxFit.cover,

              // Si l'image n'existe pas encore,
              // affiche un emplacement temporaire.
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFFE8F2EE),
                  child: const Center(
                    child: Icon(
                      Icons.landscape,
                      color: Color(0xFF033D27),
                      size: 70,
                    ),
                  ),
                );
              },
            ),
          ),

          // Dégradé sombre permettant de lire le texte.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.75),
                  ],
                ),
              ),
            ),
          ),

          // --------------------------------------------------
          // INDICATEURS DU CARROUSEL
          // --------------------------------------------------
          // Ils sont placés sur l'image, en bas à droite.
          Positioned(
            right: 14,
            bottom: 14,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              // Les indicateurs sont générés dynamiquement en fonction
              // du nombre de destinations disponibles.
              children: List.generate(nombreDestinations, (index) {
                // Vérifie si cet indicateur correspond
                // à la destination actuellement affichée.
                final estActif = _pageActuelle == index;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.only(left: 4),
                  width: estActif ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    // Jaune identique au bouton « Découvrir ».
                    color: const Color(0xFFFFC107),
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              }),
            ),
          ),

          // Bouton favori.
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
              onTap: () async {
                await context.read<FavoritesProvider>().basculerFavori(
                  destination.id,
                );
              },
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  estFavori ? Icons.favorite : Icons.favorite_border,
                  color: estFavori ? Colors.red : const Color(0xFF033D27),
                  size: 20,
                ),
              ),
            ),
          ),

          // Informations de la destination.
          Positioned(
            left: 14,
            right: 14,
            bottom: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  destination.nom,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  destination.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),

                const SizedBox(height: 10),

                // Bouton Découvrir.
                ElevatedButton(
                  onPressed: () {
                    // Ouvre la fiche détaillée de la destination.
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DestinationDetailScreen(destination: destination),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC107),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Découvrir',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward, size: 14),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Affiche un message lorsqu'aucune destination n'est disponible.
  Widget _messageDestination({
    required IconData icone,
    required String message,
  }) {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F8F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icone, color: const Color(0xFF033D27), size: 45),

          const SizedBox(height: 12),

          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
