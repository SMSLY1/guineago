import 'package:flutter/material.dart';

import '../../models/guide.dart';
import '../../services/guide_service.dart';
import 'guide_detail_screen.dart';

/// Écran affichant la liste des guides touristiques.
class GuidesScreen extends StatefulWidget {
  final VoidCallback onRetourAccueil;

  const GuidesScreen({super.key, required this.onRetourAccueil});

  @override
  State<GuidesScreen> createState() => _GuidesScreenState();
}

class _GuidesScreenState extends State<GuidesScreen> {
  // Service permettant de récupérer les guides.
  final GuideService _guideService = GuideService();

  // Contrôleur de la barre de recherche.
  final TextEditingController _rechercheController = TextEditingController();

  // Liste complète des guides.
  List<Guide> _guides = [];

  // Indique si les données sont en cours de chargement.
  bool _chargement = true;

  // Message d'erreur éventuel.
  String? _erreur;

  // Texte actuellement recherché.
  String _texteRecherche = '';

  @override
  void initState() {
    super.initState();

    // Chargement des guides au démarrage.
    _chargerGuides();

    // Actualisation de la recherche pendant la saisie.
    _rechercheController.addListener(() {
      setState(() {
        _texteRecherche = _rechercheController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    // Libération du contrôleur.
    _rechercheController.dispose();

    super.dispose();
  }

  /// Récupère les guides depuis Firestore.
  Future<void> _chargerGuides() async {
    try {
      final guides = await _guideService.recupererGuides();

      if (!mounted) return;

      setState(() {
        _guides = guides;
        _chargement = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _erreur = 'Erreur : $e';
        _chargement = false;
      });
    }
  }

  /// Filtre les guides selon le texte de recherche.
  List<Guide> get _guidesFiltres {
    if (_texteRecherche.isEmpty) {
      return _guides;
    }

    return _guides.where((guide) {
      final nom = guide.nom.toLowerCase();
      final localite = guide.localite.toLowerCase();
      final specialite = guide.specialite.toLowerCase();

      return nom.contains(_texteRecherche) ||
          localite.contains(_texteRecherche) ||
          specialite.contains(_texteRecherche);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ==================================================
      // EN-TÊTE
      // ==================================================
      appBar: AppBar(
        leading: IconButton(
          onPressed: widget.onRetourAccueil,
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        ),

        title: const Text(
          'Nos guides',
          style: TextStyle(
            color: Color(0xFF033D27),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF033D27),
        elevation: 0,
      ),

      // ==================================================
      // CONTENU
      // ==================================================
      body: Column(
        children: [
          // Barre de recherche.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),

            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _rechercheController,

                    decoration: InputDecoration(
                      hintText: 'Rechercher un guide...',
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),

                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF033D27),
                      ),

                      filled: true,
                      fillColor: const Color(0xFFF5F7F5),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Bouton de filtre.
                Container(
                  height: 52,
                  width: 52,

                  decoration: BoxDecoration(
                    color: const Color(0xFF033D27),
                    borderRadius: BorderRadius.circular(14),
                  ),

                  child: IconButton(
                    onPressed: () {
                      _afficherMessageFiltre(context);
                    },

                    icon: const Icon(Icons.tune, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // Liste des guides.
          Expanded(child: _construireContenu()),
        ],
      ),
    );
  }

  /// Construit le contenu selon l'état de chargement.
  Widget _construireContenu() {
    if (_chargement) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF033D27)),
      );
    }

    if (_erreur != null) {
      return Center(
        child: Text(
          _erreur!,
          style: const TextStyle(color: Colors.red, fontSize: 14),
        ),
      );
    }

    if (_guidesFiltres.isEmpty) {
      return const Center(
        child: Text(
          'Aucun guide trouvé.',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),

      itemCount: _guidesFiltres.length,

      itemBuilder: (context, index) {
        final guide = _guidesFiltres[index];

        return _construireCarteGuide(guide);
      },
    );
  }

  /// Construit une carte présentant un guide.
  Widget _construireCarteGuide(Guide guide) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),

      padding: const EdgeInsets.all(10),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),

        border: Border.all(color: const Color(0xFFE5EAE6)),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Row(
        children: [
          // Photo du guide.
          ClipRRect(
            borderRadius: BorderRadius.circular(12),

            child: Image.asset(
              guide.image,
              width: 95,
              height: 125,
              fit: BoxFit.cover,

              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 95,
                  height: 125,
                  color: const Color(0xFFE8F2EE),

                  child: const Icon(
                    Icons.person,
                    size: 40,
                    color: Color(0xFF033D27),
                  ),
                );
              },
            ),
          ),

          const SizedBox(width: 12),

          // Informations du guide.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nom du guide.
                Text(
                  guide.nom,

                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    color: Color(0xFF033D27),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                // Note.
                Row(
                  children: [
                    const Icon(Icons.star, color: Color(0xFFFFC107), size: 16),

                    const SizedBox(width: 4),

                    Text(
                      '${guide.note.toStringAsFixed(1)} '
                      '(${guide.nombreAvis} avis)',

                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),

                const SizedBox(height: 5),

                // Localisation.
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: Color(0xFF033D27),
                      size: 15,
                    ),

                    const SizedBox(width: 4),

                    Expanded(
                      child: Text(
                        '${guide.localite}, ${guide.region}',

                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,

                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Badges de catégorie et spécialité.
                Wrap(
                  spacing: 5,
                  runSpacing: 5,

                  children: [
                    _construireBadge(guide.categorie),
                    _construireBadge(guide.specialite),
                  ],
                ),

                const SizedBox(height: 8),

                // Bouton de consultation.
                Align(
                  alignment: Alignment.centerRight,

                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),

                    // Action exécutée lorsque l'utilisateur clique sur « Voir ».
                    onTap: () {
                      // Ouvre la page des détails du guide.
                      Navigator.push(
                        context,

                        // Création d'une nouvelle page.
                        MaterialPageRoute(
                          builder: (context) {
                            // Envoie les informations du guide sélectionné
                            // vers la page des détails.
                            return GuideDetailScreen(guide: guide);
                          },
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),

                      decoration: BoxDecoration(
                        color: const Color(0xFF033D27),
                        borderRadius: BorderRadius.circular(20),
                      ),

                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Voir',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(width: 4),

                          Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construit un badge coloré.
  Widget _construireBadge(String texte) {
    if (texte.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),

      decoration: BoxDecoration(
        color: const Color(0xFFE8F2EE),
        borderRadius: BorderRadius.circular(20),
      ),

      child: Text(
        texte,

        maxLines: 1,
        overflow: TextOverflow.ellipsis,

        style: const TextStyle(
          color: Color(0xFF033D27),
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Message temporaire pour le filtre.
  void _afficherMessageFiltre(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Les filtres seront bientôt disponibles.')),
    );
  }
}
