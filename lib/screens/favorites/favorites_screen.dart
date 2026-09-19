import 'package:flutter/material.dart';

import '../../models/destination.dart';
import '../../services/destination_service.dart';

import '../destinations/destination_detail_screen.dart';

import 'package:provider/provider.dart';

import '../../providers/favorites_provider.dart';

class FavoritesScreen extends StatefulWidget {
  // Fonction permettant de revenir à l'accueil.
  final VoidCallback onRetourAccueil;

  const FavoritesScreen({super.key, required this.onRetourAccueil});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  // Service de récupération des destinations.
  final DestinationService _destinationService = DestinationService();

  // Liste des destinations favorites.
  late Future<List<Destination>> _favorisFuture;

  @override
  void initState() {
    super.initState();

    // Charge les favoris au démarrage de l'écran.
    _favorisFuture = _chargerFavoris();
  }

  /// Récupère toutes les destinations disponibles.
  /// Le filtrage des favoris sera effectué dans build().
  Future<List<Destination>> _chargerFavoris() async {
    return await _destinationService.recupererDestinations();
  }

  /// Construit l'interface affichée lorsqu'il n'y a aucun favori.
  Widget _construireEtatVide() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/favorites/empty_favorite.webp',
              width: 230,
              height: 150,
              fit: BoxFit.contain,
            ),

            const SizedBox(height: 24),

            const Text(
              'Aucun favoris pour le moment',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF033D27),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Explorez les destinations et ajoutez '
              'vos coups de cœur ici.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
            ),

            const SizedBox(height: 22),

            SizedBox(
              width: 220,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('La navigation sera bientôt disponible.'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC107),
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Explorer les destinations',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Écoute les changements du FavoritesProvider.
    // L'écran sera actualisé automatiquement lorsque
    // les favoris sont chargés ou modifiés.
    final favorisProvider = context.watch<FavoritesProvider>();

    return Scaffold(
      backgroundColor: Colors.white,

      // --------------------------------------------------
      // CONTENU DE L'ÉCRAN
      // --------------------------------------------------
      body: SafeArea(
        child: Column(
          children: [
            // --------------------------------------------------
            // EN-TÊTE
            // --------------------------------------------------
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  // Bouton retour vers l'accueil.
                  IconButton(
                    onPressed: widget.onRetourAccueil,
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 20,
                      color: Color(0xFF033D27),
                    ),
                  ),

                  // Titre centré.
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Mes favoris',
                        style: TextStyle(
                          color: Color(0xFF033D27),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // Espace permettant de garder le titre centré.
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // --------------------------------------------------
            // LISTE DES FAVORIS
            // --------------------------------------------------
            Expanded(
              child: FutureBuilder<List<Destination>>(
                future: _favorisFuture,
                builder: (context, snapshot) {
                  // État de chargement.
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF033D27),
                      ),
                    );
                  }

                  // État d'erreur.
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Une erreur est survenue.',
                        style: TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    );
                  }

                  // Récupération de toutes les destinations.
                  final destinations = snapshot.data ?? [];

                  // Filtrage : on conserve uniquement les destinations
                  // dont l'identifiant existe dans FavoritesProvider.
                  final favoris = destinations
                      .where(
                        (destination) =>
                            favorisProvider.estFavori(destination.id),
                      )
                      .toList();

                  // État vide.
                  if (favoris.isEmpty) {
                    return _construireEtatVide();
                  }

                  // Affichage des favoris.
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: favoris.length,
                    itemBuilder: (context, index) {
                      final destination = favoris[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(8),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              destination.image,
                              width: 85,
                              height: 85,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey,
                                );
                              },
                            ),
                          ),
                          title: Text(
                            destination.nom,
                            style: const TextStyle(
                              color: Color(0xFF033D27),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            destination.localite,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          trailing: IconButton(
                            onPressed: () async {
                              await context
                                  .read<FavoritesProvider>()
                                  .retirerFavori(destination.id);

                              // Vérifie que l'écran existe toujours
                              // après l'opération asynchrone.
                              if (!context.mounted) return;

                              // Actualise la liste.
                              setState(() {
                                _favorisFuture = _chargerFavoris();
                              });

                              // Affiche le message de confirmation.
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Destination retirée des favoris.',
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.favorite, color: Colors.red),
                          ),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DestinationDetailScreen(
                                  destination: destination,
                                ),
                              ),
                            );

                            // Actualise la liste après le retour.
                            setState(() {
                              _favorisFuture = _chargerFavoris();
                            });
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
