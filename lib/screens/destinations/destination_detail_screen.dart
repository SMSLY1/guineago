import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/destination.dart';
import '../../providers/favorites_provider.dart';

/// Écran présentant les détails d'une destination.
class DestinationDetailScreen extends StatelessWidget {
  final Destination destination;

  const DestinationDetailScreen({super.key, required this.destination});

  /// Construit une petite carte d'information.
  Widget _carteInformation({
    required IconData icone,
    required String titre,
    required String valeur,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: const Color(0xFFF5F8F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0EAE4)),
      ),

      child: Row(
        children: [
          Icon(icone, color: const Color(0xFF033D27), size: 22),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titre,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),

                const SizedBox(height: 3),

                Text(
                  valeur.isEmpty ? 'Non renseigné' : valeur,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF033D27),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Récupération du gestionnaire des favoris.
    final favorisProvider = context.watch<FavoritesProvider>();

    // Vérification du statut favori.
    final estFavori = favorisProvider.estFavori(destination.id);

    return DefaultTabController(
      length: 3,

      child: Scaffold(
        backgroundColor: Colors.white,

        body: SafeArea(
          child: Column(
            children: [
              // ==================================================
              // 1. IMAGE PRINCIPALE ET BOUTONS
              // ==================================================
              SizedBox(
                height: 205,
                width: double.infinity,

                child: Stack(
                  children: [
                    // Image de la destination.
                    Positioned.fill(
                      child: Image.asset(
                        destination.image,
                        fit: BoxFit.cover,

                        // Image de remplacement si l'image échoue.
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFFE8F2EE),
                            child: const Center(
                              child: Icon(
                                Icons.landscape,
                                size: 65,
                                color: Color(0xFF033D27),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Dégradé supérieur pour améliorer
                    // la visibilité des boutons.
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 85,

                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,

                            colors: [
                              Colors.black.withValues(alpha: 0.40),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Bouton retour.
                    Positioned(
                      top: 16,
                      left: 14,

                      child: _boutonImage(
                        icone: Icons.arrow_back_ios_new,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),

                    // Bouton favori.
                    Positioned(
                      top: 16,
                      right: 62,

                      child: _boutonImage(
                        icone: estFavori
                            ? Icons.favorite
                            : Icons.favorite_border,

                        couleurIcone: estFavori
                            ? Colors.red
                            : const Color(0xFF033D27),

                        onPressed: () async {
                          await context
                              .read<FavoritesProvider>()
                              .basculerFavori(destination.id);
                        },
                      ),
                    ),

                    // Bouton partager.
                    Positioned(
                      top: 16,
                      right: 14,

                      child: _boutonImage(
                        icone: Icons.share,

                        onPressed: () {
                          _afficherMaintenance(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // ==================================================
              // 2. INFORMATIONS DE LA DESTINATION
              // ==================================================
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    // Nom de la destination.
                    Text(
                      destination.nom,

                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(
                        color: Color(0xFF033D27),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 3),

                    // Localisation.
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Color(0xFF033D27),
                          size: 16,
                        ),

                        const SizedBox(width: 4),

                        Expanded(
                          child: Text(
                            '${destination.localite}, '
                            '${destination.region}',

                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,

                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Avis de la destination.
                    const Row(
                      children: [
                        Icon(Icons.star, color: Color(0xFFFFC107), size: 18),

                        SizedBox(width: 4),

                        Text(
                          '4.8',
                          style: TextStyle(
                            color: Color(0xFF444444),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(width: 4),

                        Text(
                          '(124 avis)',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 6),

              // ==================================================
              // 3. MENU DES ONGLETS
              // ==================================================
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),

                child: TabBar(
                  labelColor: Color(0xFF033D27),
                  unselectedLabelColor: Colors.grey,

                  indicatorColor: Color(0xFF033D27),
                  indicatorWeight: 2,

                  labelStyle: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),

                  unselectedLabelStyle: TextStyle(fontSize: 11),

                  tabs: [
                    Tab(text: 'Présentation'),
                    Tab(text: 'Activités'),
                    Tab(text: 'Conseils'),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // ==================================================
              // 4. CONTENU DES ONGLETS
              // ==================================================
              Flexible(
                fit: FlexFit.loose,
                child: TabBarView(
                  children: [
                    // ==================================================
                    // ONGLET PRÉSENTATION
                    // ==================================================
                    SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --------------------------------------------------
                          // DESCRIPTION
                          // --------------------------------------------------
                          const Text(
                            'Description',
                            style: TextStyle(
                              color: Color(0xFF033D27),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            destination.description,
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF444444),
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 18),

                          // --------------------------------------------------
                          // CARTE À DÉCOUVRIR
                          // --------------------------------------------------
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),

                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F2EE),
                              borderRadius: BorderRadius.circular(16),
                            ),

                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.explore_outlined,
                                      color: Color(0xFF033D27),
                                      size: 24,
                                    ),

                                    SizedBox(width: 10),

                                    Text(
                                      'À découvrir',
                                      style: TextStyle(
                                        color: Color(0xFF033D27),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 8),

                                Text(
                                  'Découvrez les paysages, la culture '
                                  'et les richesses naturelles de cette destination.',
                                  style: TextStyle(
                                    color: Color(0xFF444444),
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 18),

                          // --------------------------------------------------
                          // INFORMATIONS ESSENTIELLES
                          // --------------------------------------------------
                          const Text(
                            'Informations essentielles',
                            style: TextStyle(
                              color: Color(0xFF033D27),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Ligne d'informations.
                          Row(
                            children: [
                              // Localité.
                              Expanded(
                                child: _carteInformation(
                                  icone: Icons.location_on_outlined,
                                  titre: 'Localité',
                                  valeur: destination.localite,
                                ),
                              ),

                              const SizedBox(width: 10),

                              // Catégorie.
                              Expanded(
                                child: _carteInformation(
                                  icone: Icons.category_outlined,
                                  titre: 'Catégorie',
                                  valeur: destination.categorie,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Région.
                          _carteInformation(
                            icone: Icons.map_outlined,
                            titre: 'Région',
                            valeur: destination.region,
                          ),
                        ],
                      ),
                    ),

                    // ==================================================
                    // ONGLET ACTIVITÉS
                    // ==================================================
                    SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Titre de la section.
                          const Text(
                            'Activités disponibles',
                            style: TextStyle(
                              color: Color(0xFF033D27),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 6),

                          // Introduction.
                          const Text(
                            'Explorez les activités disponibles et découvrez '
                            'les richesses naturelles et culturelles de cette '
                            'destination. Choisissez une activité et préparez-vous '
                            'à vivre une expérience inoubliable.',
                            style: TextStyle(
                              color: Color(0xFF555555),
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Cartes des activités.
                          _construireActivites(context),

                          const SizedBox(height: 16),

                          // Information complémentaire.
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F2EE),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Color(0xFF033D27),
                                  size: 23,
                                ),

                                SizedBox(width: 10),

                                Expanded(
                                  child: Text(
                                    'Explorez les activités disponibles et'
                                    ' préparez une expérience inoubliable.',
                                    style: TextStyle(
                                      color: Color(0xFF444444),
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ------------------------------------------
                    // ONGLET CONSEILS
                    // ------------------------------------------
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          // Informations pratiques.
                          const Text(
                            'Informations pratiques',

                            style: TextStyle(
                              color: Color(0xFF033D27),
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            destination.informationsPratiques,

                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,

                            style: const TextStyle(
                              color: Color(0xFF444444),
                              fontSize: 13,
                              height: 1.35,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Section écotourisme.
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),

                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F2EE),
                              borderRadius: BorderRadius.circular(14),
                            ),

                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                const Icon(
                                  Icons.eco_outlined,
                                  color: Color(0xFF033D27),
                                  size: 24,
                                ),

                                const SizedBox(width: 8),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,

                                    children: [
                                      const Text(
                                        'Écotourisme',

                                        style: TextStyle(
                                          color: Color(0xFF033D27),
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      const SizedBox(height: 4),

                                      Text(
                                        destination.ecotourisme,

                                        maxLines: 4,
                                        overflow: TextOverflow.ellipsis,

                                        style: const TextStyle(
                                          color: Color(0xFF444444),
                                          fontSize: 12,
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ==================================================
              // 5. BOUTON VOIR SUR LA CARTE
              // ==================================================
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),

                child: SizedBox(
                  width: double.infinity,
                  height: 46,

                  child: ElevatedButton(
                    onPressed: () {
                      _afficherMaintenance(context);
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF033D27),
                      foregroundColor: Colors.white,
                      elevation: 0,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),

                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        Icon(Icons.location_on_outlined, size: 20),

                        SizedBox(width: 8),

                        Text(
                          'Voir sur la carte',

                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(width: 8),

                        Icon(Icons.arrow_forward, size: 18),
                      ],
                    ),
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
  // CONSTRUCTION DES ACTIVITÉS
  // ==========================================================

  /// Construit les quatre boutons d'activités.
  Widget _construireActivites(BuildContext context) {
    final activites = [
      {'nom': 'Randonnée', 'icone': Icons.terrain_outlined},
      {'nom': 'Observation', 'icone': Icons.visibility_outlined},
      {'nom': 'Photographie', 'icone': Icons.camera_alt_outlined},
      {'nom': 'Détente', 'icone': Icons.spa_outlined},
    ];

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),

      decoration: BoxDecoration(
        color: const Color(0xFFE8F2EE),
        borderRadius: BorderRadius.circular(15),
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,

        children: activites.map((activite) {
          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),

              // Ouverture de la page de maintenance.
              onTap: () {
                Navigator.push(
                  context,

                  MaterialPageRoute(
                    builder: (context) {
                      return const MaintenanceScreen();
                    },
                  ),
                );
              },

              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 1),

                child: Column(
                  children: [
                    // Icône de l'activité.
                    Icon(
                      activite['icone'] as IconData,

                      color: const Color(0xFF033D27),
                      size: 27,
                    ),

                    const SizedBox(height: 5),

                    // Nom de l'activité.
                    Text(
                      activite['nom'] as String,

                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(
                        color: Color(0xFF033D27),
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ==========================================================
  // BOUTONS DE L'IMAGE
  // ==========================================================

  /// Construit un bouton circulaire placé sur l'image.
  Widget _boutonImage({
    required IconData icone,
    required VoidCallback onPressed,

    Color couleurIcone = const Color(0xFF033D27),
  }) {
    return Container(
      width: 40,
      height: 40,

      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        shape: BoxShape.circle,

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: IconButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,

        icon: Icon(icone, color: couleurIcone, size: 20),
      ),
    );
  }

  // ==========================================================
  // MESSAGE DE MAINTENANCE
  // ==========================================================

  /// Affiche un message de maintenance.
  void _afficherMaintenance(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cette fonctionnalité sera bientôt disponible.'),
      ),
    );
  }
}

// ============================================================
// PAGE DE MAINTENANCE
// ============================================================

/// Page affichée lorsqu'une fonctionnalité est indisponible.
class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },

          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        ),

        title: const Text(
          'Fonctionnalité',

          style: TextStyle(
            color: Color(0xFF033D27),
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF033D27),
        elevation: 0,
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              // Icône indiquant la maintenance.
              const Icon(
                Icons.construction_outlined,
                color: Color(0xFF033D27),
                size: 75,
              ),

              const SizedBox(height: 24),

              // Titre de la page.
              const Text(
                'Fonctionnalité en maintenance',

                textAlign: TextAlign.center,

                style: TextStyle(
                  color: Color(0xFF033D27),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              // Message explicatif.
              const Text(
                'Cette fonctionnalité sera bientôt disponible.',

                textAlign: TextAlign.center,

                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
