// Importation des composants principaux de Flutter.
import 'package:flutter/material.dart';

// Importation de Firebase Core pour initialiser Firebase.
import 'package:firebase_core/firebase_core.dart';

// Fichier généré automatiquement par FlutterFire.
// Il contient la configuration de notre projet Firebase GuineaGo.
import 'firebase_options.dart';

import 'package:provider/provider.dart';

// Importation de notre écran de démarrage.
import 'screens/splash/splash_screen.dart';

import 'providers/language_provider.dart';

// Importation du gestionnaire global des favoris.
import 'providers/favorites_provider.dart';

// Point d'entrée de l'application GuineaGo.
void main() async {
  // Permet à Flutter de terminer son initialisation
  // avant d'exécuter du code asynchrone.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation de Firebase avec la configuration
  // correspondant à la plateforme utilisée.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Rend le gestionnaire de langue disponible
  // dans toute l'application GuineaGo.
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),

        ChangeNotifierProvider(
          create: (_) => FavoritesProvider()..chargerFavoris(),
        ),
      ],
      child: const GuineaGoApp(),
    ),
  );
}

// Widget principal de l'application GuineaGo.
class GuineaGoApp extends StatelessWidget {
  const GuineaGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Supprime la bannière "DEBUG" en haut à droite.
      debugShowCheckedModeBanner: false,

      // Nom de notre application.
      title: 'GuineaGo',

      // Écran affiché au démarrage.
      home: const SplashScreen(),
    );
  }
}
