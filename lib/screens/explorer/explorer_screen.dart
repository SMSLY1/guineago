import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/destination.dart';
import '../../services/destination_service.dart';
import '../../providers/favorites_provider.dart';

import '../destinations/destination_detail_screen.dart';

/// Écran qui permet d'explorer les destinations.
class ExplorerScreen extends StatefulWidget {
  // Fonction permettant de revenir à l'accueil.
  // Fonction permettant de revenir à l'accueil.
  final VoidCallback onRetourAccueil;

  // Catégorie envoyée depuis l'écran d'accueil.
  final String categorieInitiale;

  const ExplorerScreen({
    super.key,
    required this.onRetourAccueil,
    this.categorieInitiale = 'Toutes',
  });

  @override
  State<ExplorerScreen> createState() => _ExplorerScreenState();
}

class _ExplorerScreenState extends State<ExplorerScreen> {
  // Service utilisé pour récupérer les destinations.
  final DestinationService _destinationService = DestinationService();

  // Contrôleur de la barre de recherche.
  final TextEditingController _rechercheController = TextEditingController();

  // Future contenant la liste des destinations.
  late Future<List<Destination>> _destinationsFuture;

  // Texte saisi dans la barre de recherche.
  String _texteRecherche = '';

  // Catégorie sélectionnée par l'utilisateur.
  // Par défaut, toutes les catégories sont affichées.
  String _categorieSelectionnee = 'Toutes';

  @override
  void initState() {
    super.initState();

    // Applique la catégorie reçue depuis l'accueil.
    _categorieSelectionnee = widget.categorieInitiale;

    // Chargement des destinations au démarrage.
    _destinationsFuture = _destinationService.recupererDestinations();

    // Écoute les changements du texte de recherche.
    _rechercheController.addListener(() {
      setState(() {
        _texteRecherche = _rechercheController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    // Libération du contrôleur lorsque l'écran est détruit.
    _rechercheController.dispose();

    super.dispose();
  }

  /// Filtre les destinations selon la recherche et la catégorie.
  List<Destination> _filtrerDestinations(List<Destination> destinations) {
    // Filtrage des destinations selon les critères sélectionnés.
    return destinations.where((destination) {
      // Récupération du nom de la destination.
      final nom = destination.nom.toLowerCase();

      // Récupération de la localité.
      final localite = destination.localite.toLowerCase();

      // Récupération de la catégorie.
      final categorie = destination.categorie.toLowerCase();

      // Vérifie si le texte recherché correspond
      // au nom ou à la localité.
      final correspondRecherche =
          nom.contains(_texteRecherche) || localite.contains(_texteRecherche);

      // Vérifie la catégorie sélectionnée.
      // Si "Toutes" est sélectionné, toutes les catégories
      // sont acceptées.
      final correspondCategorie =
          _categorieSelectionnee == 'Toutes' ||
          categorie == _categorieSelectionnee.toLowerCase();

      // La destination doit respecter les deux critères.
      return correspondRecherche && correspondCategorie;
    }).toList();
  }

  /// Construit un bouton de catégorie.
  Widget _construireBoutonCategorie(String categorie) {
    // Vérifie si cette catégorie est actuellement sélectionnée.
    final estSelectionnee = _categorieSelectionnee == categorie;

    return Padding(
      padding: const EdgeInsets.only(right: 8),

      child: ChoiceChip(
        // Texte affiché sur le bouton.
        label: Text(categorie),

        // Indique si le bouton est sélectionné.
        selected: estSelectionnee,

        // Couleur du bouton sélectionné.
        selectedColor: const Color(0xFF033D27),

        // Couleur du texte selon la sélection.
        labelStyle: TextStyle(
          color: estSelectionnee ? Colors.white : Colors.black87,
          fontSize: 12,
        ),

        // Forme du bouton.
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

        // Action lors de la sélection.
        onSelected: (selectionne) {
          setState(() {
            // Met à jour la catégorie sélectionnée.
            _categorieSelectionnee = categorie;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Écoute les changements des favoris.
    final favorisProvider = context.watch<FavoritesProvider>();

    return Scaffold(
      backgroundColor: Colors.white,

      // --------------------------------------------------
      // EN-TÊTE DE LA PAGE DESTINATIONS
      // --------------------------------------------------
      appBar: AppBar(
        // Bouton retour placé à gauche.
        leading: IconButton(
          onPressed: widget.onRetourAccueil,
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        ),

        // Titre de la page.
        title: const Text(
          'Destinations',
          style: TextStyle(
            color: Color(0xFF033D27),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        // Centre automatiquement le titre.
        centerTitle: true,

        // Couleur blanche de l'en-tête.
        backgroundColor: Colors.white,

        // Couleur du bouton retour.
        foregroundColor: const Color(0xFF033D27),

        // Supprime l'ombre sous l'en-tête.
        elevation: 0,
      ),

      body: Column(
        children: [
          // --------------------------------------------------
          // BARRE DE RECHERCHE
          // --------------------------------------------------
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _rechercheController,

              decoration: InputDecoration(
                hintText: 'Rechercher une destination...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: PopupMenuButton<String>(
                  icon: const Icon(Icons.tune, color: Color(0xFF033D27)),

                  // Affiche les catégories disponibles.
                  onSelected: (categorie) {
                    setState(() {
                      _categorieSelectionnee = categorie;
                    });
                  },

                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'Toutes', child: Text('Toutes')),
                    const PopupMenuItem(value: 'Nature', child: Text('Nature')),
                    const PopupMenuItem(
                      value: 'Culture',
                      child: Text('Culture'),
                    ),
                    const PopupMenuItem(
                      value: 'Histoire',
                      child: Text('Histoire'),
                    ),
                  ],
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // --------------------------------------------------
          // FILTRES PAR CATÉGORIE
          // --------------------------------------------------
          SizedBox(
            height: 45,

            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),

              children: [
                // Bouton Toutes.
                _construireBoutonCategorie('Toutes'),

                // Bouton Nature.
                _construireBoutonCategorie('Nature'),

                // Bouton Culture.
                _construireBoutonCategorie('Culture'),

                // Bouton Aventure.
                _construireBoutonCategorie('Aventure'),

                // Bouton Histoire.
                _construireBoutonCategorie('Histoire'),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // --------------------------------------------------
          // LISTE DES DESTINATIONS
          // --------------------------------------------------
          Expanded(
            child: FutureBuilder<List<Destination>>(
              future: _destinationsFuture,

              builder: (context, snapshot) {
                // Affichage pendant le chargement.
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF033D27)),
                  );
                }

                // Affichage en cas d'erreur.
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Impossible de charger les destinations.',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                // Récupération des destinations.
                final destinations = snapshot.data ?? [];

                // Application du filtre de recherche.
                final destinationsFiltrees = _filtrerDestinations(destinations);

                // Aucun résultat.
                if (destinationsFiltrees.isEmpty) {
                  return const Center(
                    child: Text(
                      'Aucune destination trouvée.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                // Affichage des destinations sous forme de grille.
                return GridView.builder(
                  // Espacement autour de la grille.
                  padding: const EdgeInsets.all(12),

                  // Configuration de la grille.
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    // Deux destinations par ligne.
                    crossAxisCount: 2,

                    // Espace horizontal entre les cartes.
                    crossAxisSpacing: 8,

                    // Espace vertical entre les cartes.
                    mainAxisSpacing: 10,

                    // Hauteur relative de chaque carte.
                    childAspectRatio: 0.78,
                  ),

                  // Nombre total de destinations affichées.
                  itemCount: destinationsFiltrees.length,

                  // Construction de chaque carte.
                  itemBuilder: (context, index) {
                    // Récupération de la destination actuelle.
                    final destination = destinationsFiltrees[index];

                    // Vérifie si la destination est favorite.
                    final estFavori = favorisProvider.estFavori(destination.id);

                    return GestureDetector(
                      // Ouvre la page de détails au clic.
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DestinationDetailScreen(
                              destination: destination,
                            ),
                          ),
                        );
                      },

                      child: Card(
                        elevation: 2,
                        margin: EdgeInsets.zero,

                        // Coins arrondis de la carte.
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),

                        // Coupe l'image selon les coins de la carte.
                        clipBehavior: Clip.antiAlias,

                        child: Stack(
                          children: [
                            // --------------------------------------------------
                            // IMAGE DE LA DESTINATION
                            // --------------------------------------------------
                            Positioned.fill(
                              child: Image.asset(
                                destination.image,
                                fit: BoxFit.cover,

                                // Image de remplacement en cas d'erreur.
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey,
                                  );
                                },
                              ),
                            ),

                            // --------------------------------------------------
                            // DÉGRADÉ POUR AMÉLIORER LA LISIBILITÉ
                            // --------------------------------------------------
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
                            // BOUTON FAVORI
                            // --------------------------------------------------
                            Positioned(
                              top: 5,
                              right: 5,
                              child: IconButton(
                                onPressed: () async {
                                  // Ajoute ou retire la destination des favoris.
                                  await context
                                      .read<FavoritesProvider>()
                                      .basculerFavori(destination.id);
                                },

                                icon: Icon(
                                  estFavori
                                      ? Icons.favorite
                                      : Icons.favorite_border,

                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),

                            // --------------------------------------------------
                            // NOM ET LOCALITÉ
                            // --------------------------------------------------
                            Positioned(
                              left: 8,
                              right: 8,
                              bottom: 8,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Nom de la destination.
                                  Text(
                                    destination.nom,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 3),

                                  // Localité de la destination.
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        color: Colors.white,
                                        size: 11,
                                      ),

                                      const SizedBox(width: 2),

                                      Expanded(
                                        child: Text(
                                          destination.localite,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
