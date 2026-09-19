import 'package:shared_preferences/shared_preferences.dart';

/// Service permettant de sauvegarder les données locales de GuineaGo.
class LocalStorageService {
  /// Sauvegarde la liste des identifiants des destinations favorites.
  Future<void> sauvegarderFavoris(List<String> favoris) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setStringList('favoris', favoris);
  }

  /// Récupère la liste des identifiants des destinations favorites.
  Future<List<String>> recupererFavoris() async {
    final preferences = await SharedPreferences.getInstance();

    return preferences.getStringList('favoris') ?? [];
  }
}
