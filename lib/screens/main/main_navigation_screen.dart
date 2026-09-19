import 'package:flutter/material.dart';

import '../favorites/favorites_screen.dart';
import '../home/home_screen.dart';
import '../explorer/explorer_screen.dart';
import '../guides/guides_screen.dart';
import '../profile/profile_screen.dart';

/// Écran principal qui gère la navigation de GuineaGo.
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  // Index de l'onglet actuellement sélectionné.
  int _indexSelectionne = 0;

  // Catégorie sélectionnée depuis l'accueil.
  String _categorieSelectionnee = 'Toutes';

  // Liste des écrans de l'application.
  late List<Widget> _ecrans;

  @override
  void initState() {
    super.initState();

    _construireEcrans();
  }

  /// Construit la liste des écrans.
  void _construireEcrans() {
    _ecrans = [
      // =====================================================
      // ÉCRAN ACCUEIL
      // =====================================================
      HomeScreen(
        onOuvrirExplorer: (categorie) {
          setState(() {
            // Mémorise la catégorie choisie.
            _categorieSelectionnee = categorie;

            // Ouvre l'onglet Explorer.
            _indexSelectionne = 1;

            // Reconstruit Explorer avec la nouvelle catégorie.
            _construireEcrans();
          });
        },

        onOuvrirGuides: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GuidesScreen(
                onRetourAccueil: () {
                  Navigator.pop(context);
                },
              ),
            ),
          );
        },
      ),

      // =====================================================
      // ÉCRAN EXPLORER
      // =====================================================
      ExplorerScreen(
        key: ValueKey(_categorieSelectionnee),
        categorieInitiale: _categorieSelectionnee,

        onRetourAccueil: () {
          setState(() {
            _indexSelectionne = 0;
          });
        },
      ),

      // =====================================================
      // ÉCRAN FAVORIS
      // =====================================================
      FavoritesScreen(
        onRetourAccueil: () {
          setState(() {
            _indexSelectionne = 0;
          });
        },
      ),

      // =====================================================
      // ÉCRAN PROFIL
      // =====================================================
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Affiche l'écran correspondant à l'onglet sélectionné.
      body: IndexedStack(index: _indexSelectionne, children: _ecrans),

      // =====================================================
      // BARRE DE NAVIGATION INFÉRIEURE
      // =====================================================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indexSelectionne,

        onTap: (index) {
          setState(() {
            // Change l'écran sélectionné.
            _indexSelectionne = index;
          });
        },

        type: BottomNavigationBarType.fixed,

        selectedItemColor: const Color(0xFF033D27),
        unselectedItemColor: Colors.grey,

        selectedFontSize: 10,
        unselectedFontSize: 10,

        items: const [
          // =================================================
          // ONGLET ACCUEIL
          // =================================================
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Accueil',
          ),

          // =================================================
          // ONGLET EXPLORER
          // =================================================
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Explorer',
          ),

          // =================================================
          // ONGLET FAVORIS
          // =================================================
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: 'Favoris',
          ),

          // =================================================
          // ONGLET PROFIL
          // =================================================
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
